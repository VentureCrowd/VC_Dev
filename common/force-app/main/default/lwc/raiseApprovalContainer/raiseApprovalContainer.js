import { LightningElement, track} from 'lwc';

// apex imports
import apex__getRaiseDetails from '@salesforce/apex/RaiseController.getRaiseDetails'
import apex__updateStatus from '@salesforce/apex/RaiseController.updateRaiseStatus'

// Importing the NavigationMixin module for navigating to different pages
import { NavigationMixin } from 'lightning/navigation';
import apex_createLearningForRaise from '@salesforce/apex/RaiseController.createLearningForRaise';


export default class RaiseApprovalContainer extends NavigationMixin(LightningElement) {
    @track title;

    @track raiseDetails = {};

    // Delete this part
    @track raiseId;
    @track _formData={};

    @track alreadyDownloaded;

    get formData(){
        return this._formData;
    }

    set formData(v){
        this._formData = v;
    }

    @track isLoading = false;

    // Values used for the raise approval steps
    @track values = [
        { id: 1, label: 'Pre Raise Checklist', completed: true, active: false, variation: 'light'},
        { id: 2, label: 'Raise Information', completed: true, active: false, variation: 'light'},
        { id: 3, label: 'Approvals', completed: false, active: true, variation: 'light'},
        { id: 4, label: 'Fees', completed: false, active: false, variation: 'light'},
        { id: 5, label: 'Capital Raising 101 Course', completed: false, active: false, variation: 'light'}, 
        { id: 6, label: 'Raise Live', completed: false, active: false, variation: 'light'},
    ];

    @track checkBoxValue =  [{ id: 1, label: 'Yes', value: 'Yes', checked: false}];
    
    // Help text mapping for various learning modules
    @track helpTextMapping = {
        amazingBenefits: `https://${window.location.host}/articles/module/Pre-Raise-Checklist-Fees-Benefits`,
        capitalRaise101: `https://${window.location.host}/articles/module/Pre-Raise-Checklist-Capital-Raise-101-Course-Founder-Responsibilities`,
        keyDocuments: `https://${window.location.host}/articles/module/Pre-Raise-Checklist-Raise-Key-Documents`
    }

    // Track whether the investment type is retail or wholesale 
    @track investType;
    @track modalDisabled = false;


    /**
     * Method to fetch the details of the raise using the raise ID.
     * @param {Id} raiseId - The ID of the raise.
     * @returns {Promise<void>}
     */
    async getRaiseDetails(raiseId){
        this.isLoading = true; // Start loading spinner
    
        // Call Apex method to get raise details
        let returnData = await apex__getRaiseDetails({raiseId : raiseId});
    
        // Parse the returned data and update raiseDetails property
        this.raiseDetails = {...JSON.parse(returnData)};
    
        // If investment type exists, update investType property
        if(this.raiseDetails.investmentType){
            this.investType = this.raiseDetails.investmentType
        }
    
        // Update title property with raise name
        this.title = this.raiseDetails.name;
    
        // Stop loading spinner
        this.isLoading = false;
    
        // If raise status is not 'In Progress', navigate to My Companies page
        if(this.raiseDetails?.status !== 'In Progress'){
            this.returnToCompanies()
        }
    }

    /**
     * @description Method to create learning modules for a raise.
     * @param {string} raiseId - The ID of the raise.
     * @returns {Promise<void>}
     */
    createLearningForRaise(raiseId){
        return new Promise(async(resolve,reject)=>{
            try{
                let returnData = await apex_createLearningForRaise({raiseId :raiseId});
                resolve(returnData)
            }catch(err){
                reject(err);
                console.error('An error occured:', err);
            }
            
        })
    }

    /**
     * Get method to check if the investment type is retail.
     * @returns {boolean} - True if the investment type is retail
     */    
    get isRetail(){
        if(this.investType==='Retail'){
            return true;
        }else{
            return false;
        }
    }

    get isWholesale(){
        if(this.investType==='Wholesale'){
            return true;
        }else{
            return false;
        }
    }

    connectedCallback(){
        this.getQueryParameters().then((result) => {
            let raiseId = result.id
            this.raiseId = raiseId;
            this.getRaiseDetails(raiseId);
        });
    }

    // If the users download the Pdf it will change the state of this variable
    recordClick() {
        this.alreadyDownloaded = true;
    }

    /**
    * Method to handle the submission of the form.
    * It updates the raise status to 'Ready for review' and creates learning modules for the raise.
    * If the raise PDF has not been downloaded yet, it triggers the download.
    * 
    * @returns {Promise<void>}
    */
    async submitForm() {
        try {
            if (!this.alreadyDownloaded) {
                this.refs.raisePdfEL.fillForm();
                this.alreadyDownloaded = true;
            }  
            apex__updateStatus({ raiseId: this.raiseId, status: 'Ready for review' }).then((res)=>{
                if(this.raiseId){
                    this.createLearningForRaise(this.raiseId).then(result => {
                    })
                    .catch(err => {
                        console.error("An error has occurred:", err)
                    })
                }
            });
        } catch (error) {
            console.error('Error updating status:', error);
        } 
    }

    

    /**
     * Handles the radio button event in the form. By updating the form value
     */
    handleChange(e){
        // Update the formData property with the new form data from the event
        e.stopPropagation();

        let fieldName = e.detail.name;
        let fieldValue = e.detail.value;

        if(fieldValue.length > 0){
            this.formData = {
                ...this.formData,
                [fieldName] : fieldValue
            }
        }

        
    }
    
    /**
     * checks if the button should be disabled based on the number of inputs
     */
    get disableButton(){
        let selector = `c-core-checkbox`;
        let checkboxFields = this.template.querySelectorAll(selector);

        const radioValidation = Object.values(this.formData).every(value => value.includes("Yes"));

        return !radioValidation || ( checkboxFields.length !== Object.keys(this.formData).length) || checkboxFields.length===0 || Object.keys(this.formData).length === 0
    }

    /**
     * Method to navigate to return to my companies page.
     */
    returnToCompanies() {
        this[NavigationMixin.Navigate]({
            // Define navigation type and target page name
            type: 'comm__namedPage',
            attributes: {
                name: 'my_companies__c' // Page name for my Companies
            }
        });
    }

    /**
     * Method to navigate to the page for preview a Raise.
     */
    previewRaisePage() {
        this[NavigationMixin.Navigate]({
            // Define navigation type and target page name
            type: 'comm__namedPage',
            attributes: {
                name: 'Preview__c'
            },
            state: {
                id: this.raiseId
            }
        });
    }

    /**
     * Method to navigate to the page for managing a Raise.
     */
    returnToForm() {
        this[NavigationMixin.Navigate]({
            // Define navigation type and target page name
            type: 'comm__namedPage',
            attributes: {
                name: 'Edit_Raise__c'
            },
            state: {
                id: this.raiseId
            }
        });
    }

    /**
     * Method to navigate to the page for managing an Expression of Interest (EOI)
     */
    manageEoi() {
        this[NavigationMixin.Navigate]({
            // Define navigation type and target page name
            type: 'comm__namedPage',
            attributes: {
                name: 'manage_eoi__c' // Page name for managing EOI
            },
            state: {
                id: this.raiseDetails.eoi // Pass the EOI id as a state parameter
            }
        });
    }

    /**
     * Method to retrieve query parameters from the URL.
     * @returns {Promise<Object>} - A promise that resolves to an object containing the query parameters.
     */
    getQueryParameters() {
        return new Promise((resolve)=>{
            var params = {};
            var search = location.search.substring(1);
            // If there are query parameters in the URL
            if (search) {
                // Parse the query parameters into an object
                params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
                    // Decode the values of the query parameters
                    return key === "" ? value : decodeURIComponent(value)
                });
            }
            // Resolve the promise with the parsed query parameters
            resolve(params);
        })
    }

}