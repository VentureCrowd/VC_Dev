/**
 * RaiseFormContainer Component
 * @description This component handles the display and management of the raise details form. It provides functionality to fetch and display raise details, manage form data, and navigate to different pages.
 */

import { LightningElement , track ,api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// apex imports
import apex__getRaiseDetails from '@salesforce/apex/RaiseController.getRaiseDetails'
import apex__updateRaiseDetails from '@salesforce/apex/RaiseController.updateRaiseDetails';


// Importing the NavigationMixin module for navigating to different pages
import { NavigationMixin } from 'lightning/navigation';

export default class RaiseFormContainer extends NavigationMixin(LightningElement) {
    @track title;

    @track raiseDetails = {};

    @track _raiseId;

    @track formData={};

    @track isLoading = false;

    @track isDealPageLoading = false;

    @track warningBannerAcknowledged = false;

    @track acknowledgeIsLoading = false;

    @track values = [
        { id: 1, label: 'Pre Raise Checklist', completed: true, active: false, variation: 'light'},
        { id: 2, label: 'Raise Information', completed: false, active: true, variation: 'light'},
        { id: 3, label: 'Approvals', completed: false, active: false, variation: 'light'},
        { id: 5, label: 'Capital Raising 101 Course', completed: false, active: false, variation: 'light'},
        { id: 6, label: 'Raise Live', completed: false, active: false, variation: 'light'},
    ];

    // retail or wholesale?
    @track investType;

    /**
     * The ID of the raise, used to fetch and display the corresponding raise details.
     * @type {string}
     */
    @api
    get raiseId(){
        return this._raiseId;
    }
    set raiseId(v){
        this._raiseId = v;
        //get raise details        
    }

    get showMultipleAcknowledgeBanner(){
        return !this.warningBannerAcknowledged
    }

    /**
     * @method getRaiseDetails
     * @description Fetches the raise details for a given raise ID and updates the component state.
     * @param {string} raiseId - The ID of the raise.
     * @returns {Promise<void>}
     */
    async getRaiseDetails(raiseId){
        this.isLoading = true;
        try{
            let returnData = await apex__getRaiseDetails({raiseId : raiseId});
            this.raiseDetails = {...JSON.parse(returnData)};
            if(this.raiseDetails.investmentType){
                this.investType = this.raiseDetails.investmentType
            }

            //update title
            this.title = this.raiseDetails.name;

            // REMOVED AS PART OF REVUP-100
            //this.warningBannerAcknowledged = this.raiseDetails?.multipleDevicesAcknowledged;
        }catch(e){
            console.error('An error has occured loading the form data: ', JSON.stringify(e));
        }finally{
            this.isLoading = false;
        }
        
    }

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

    /**
     * @method connectedCallback
     * @description Lifecycle hook that runs when the component is connected to the DOM. Initializes data loading based on the query parameters.
     */
    connectedCallback(){
       this.getQueryParameters().then((result)=>{
            let raiseId = result.id
            this.raiseId = raiseId
            this.getRaiseDetails(raiseId);
        })
    }


    
    /**
     * @method previewDealpage
     * @description Saves form data and navigates to the preview page based on the investment type.
     * @returns {Promise<void>}
     */ 
    async previewDealpage() {
        this.isDealPageLoading = true;
        if (this.isRetail) {
            const retailFormEL = this.template.querySelector('c-raise-form-retail');
            if (retailFormEL) {
                try{
                    await retailFormEL.saveFormData({"noCheckRequired" : true});
                    this.navigateToPreview();
                }catch(error){
                    console.error('There was an error submitting the form data! Please try again.', JSON.stringify(error));
                }finally{
                    this.isDealPageLoading = false;
                }
            }
        } else if (this.isWholesale) {
            const wholesaleFormEL = this.template.querySelector('c-raise-form-wholesale');
            if (wholesaleFormEL) {
                try{
                    await wholesaleFormEL.saveFormData({"noCheckRequired" : true});
                    this.navigateToPreview();
                }catch(error){
                    console.error('There was an error submitting the form data! Please try again.', JSON.stringify(error));
                }finally{
                    this.isDealPageLoading = false;
                }
                
            }
        } else {
            this.navigateToPreview();
            this.isDealPageLoading = false;
        }
    }

    /**
     * @method navigateToPreview
     * @description Navigates to the preview page for the current raise.
     */
    navigateToPreview() {
        this[NavigationMixin.Navigate]({
            // Define navigation type and target page name
            type: 'comm__namedPage',
            attributes: {
                name: 'Preview__c' // Page name for my Companies
            },
            state:{
                id:this.raiseId
            }
        });
    }

    /**
     * @method returnToCompanies
     * @description Navigates back to the 'My Companies' page.
     * @param {Event} event - The event triggered by the navigation action.
     */
    returnToCompanies(event) {
        this[NavigationMixin.Navigate]({
            // Define navigation type and target page name
            type: 'comm__namedPage',
            attributes: {
                name: 'my_companies__c' // Page name for my Companies
            }
        });
    }

    /**
     * @method getQueryParameters
     * @description Parses the query parameters from the URL.
     * @returns {Promise<Object>} - A promise that resolves with the query parameters.
     */ 
    getQueryParameters() {
        return new Promise((resolve,reject)=>{
            var params = {};
            var search = location.search.substring(1);

            if (search) {
                params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
                    return key === "" ? value : decodeURIComponent(value)
                });
            }
            resolve(params);
        })
        
    }

    /**
    * Displays a toast message.
    * @param {string} title - The title of the toast message.
    * @param {string} message - The message content of the toast.
    * @param {string} variant - The variant of the toast message, e.g., 'error', 'success'.
    */
    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(toastEvent);
    }

// ERROR HANDLING

    @track errorTitle

    @track errorBodyFields

    handleClickErrorField(event){
        const fieldLabel = event.target.dataset.id;
        

        if(this.isRetail){
            const formEle = this.template.querySelector('c-raise-form-retail');
            formEle.handleFocusField(fieldLabel);
        }

        if(this.isWholesale){
            const formEle = this.template.querySelector('c-raise-form-wholesale');
            formEle.handleFocusField(fieldLabel);

        }
    }

    handleErrors(event){
        const errorFields = event.detail.errorFields;

        if(errorFields.length > 0){
            this.errorTitle = `There are errors in the following field${errorFields.length > 1 ? 's' : ''} (${errorFields.length}):`;
            this.errorBodyFields = errorFields

            this.template.querySelector('c-core-toast-message').showToast()
        }
    }

    closeErrorsToast(event){
        this.template.querySelector('c-core-toast-message').handleClose();
    }

    async handleAcknowledgeWarningBanner(event){
        // do logic to acknowledge banner
        this.acknowledgeIsLoading = true;
        
        // REMOVED AS PART OF REVUP-100
        // const updateMap  = {
        //     multipleDevicesAcknowledged : 'true'
        // }

        try{
            
            // update state to true
            // REMOVED AS PART OF REVUP-100
            //const result = await apex__updateRaiseDetails({raiseId: this.raiseId, fieldsToUpdate: updateMap});
            this.warningBannerAcknowledged = true;

        }catch(e){
            console.error(e)
        }finally{
            this.acknowledgeIsLoading = false;
        }
    }

   
}