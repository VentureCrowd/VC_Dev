/**
 * RaisePreraiseModal Component
 * @description This component handles the pre-raise modal, where users are required to complete a checklist before starting a raise. It manages form data, checks for existing raises, and navigates users to the raise form or resume raise page.
 */

import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

// Importing Apex methods
import apex_createRaiseRecord from '@salesforce/apex/RaiseController.createRaiseRecord';
import apex_getRaiseId from '@salesforce/apex/RaiseController.getRaiseDetailsFromCompanyId';
import apex_raiseExists from '@salesforce/apex/RaiseController.raiseExists';

export default class RaisePreraiseModal extends NavigationMixin(LightningElement) {


    // Array of values for radio buttons
    values = [
        {id: 1, value: 'Yes', label: 'Yes', checked: false},
        {id: 2, value: 'No', label: 'No', checked: false},
        
    ]

    investOptions = [
        {value:"Retail", label:"Retail"},
        {value:"Wholesale", label:"Wholesale"},
    ]

    // Exposed properties
    @api _formData = {}; // Stores form data
    @api percentageFilled = 50; // Percentage of form filled

    @api
    get formData(){
        return this._formData
    }
    set formData(v){
        this._formData = v;
    }

    @api
    get companyid(){
        return this._companyid;
    }
    set companyid(v){
        this._companyid = v;
        this.checkRaiseExists();
        
    }

    // Tracked properties
    @track hasRendered = false; // Indicates if the component has been rendered
    @track numFields = 0; // Number of fields in the form
    @track raiseExists = false; // Indicates if a raise already exists
    @track isLoading = false; // Indicates if the component is in loading state

    // Private properties
    _companyid

    @api
    get isRetail(){
        if(this.formData.investType==='Retail'){
            this.numFields = 6
            return true;
        }else{
            this.numFields = 5
            return false;
        }
    }
    
     /**
     * Handles the 'Get Started' button click event.
     * @param {Event} e - The event containing form data.
     * @fires RaisePreraiseModal#createRaiseRecord
     */
    async handleGetStarted(e){
        this.formData = {...e.detail.formData};
        this.createRaiseRecord(this.companyid);
    }


    /**
     * Creates a raise record.
     * @param {String} companyId - The company Id.
     * @fires RaisePreraiseModal#navigateToForm
     */
    async createRaiseRecord(companyId){
        try{
            // create raise record
            this.isLoading = true;
            let raiseRecord = await apex_createRaiseRecord({companyId:companyId, investType: this.formData.investType});
            this.isLoading = false;
            //navigate to form page
            this.navigateToForm(raiseRecord.Id);
        }catch (e){
            console.error(e);
        }
        
    }

    /**
     * Navigates to the form page.
     * @param {String} raiseId - The Id of the raise record.
     */
    navigateToForm(raiseId){
        //navigate to form
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Edit_Raise__c'
            },
            state: {
                id : raiseId
            }
        })
    }

    /**
     * Handles 'Resume Raise' button click event.
     * @fires RaisePreraiseModal#navigateToForm
     */
    async handleResumeRaise(){
        this.isLoading = true
        let retData = await apex_getRaiseId({companyId : this.companyid})
        let raiseData = JSON.parse(retData);
        let raiseId = raiseData.id;

        this.isLoading = false;
        this.navigateToForm(raiseId);
    }


    /**
     * Handles change event of form fields.
     * @param {Event} e - The change event.
     * @fires RaisePreraiseModal#showAlert
     */
    handleChange(e){
        
        let name = e.detail.name;
        let value = e.detail.value;

        this.formData = {
            ...this.formData,
            [name] : value
        }

        // remove retail asicRequirement field if Wholesale is selected
        if((name==='investType') && (value === 'Wholesale') && this.formData.asicRequirements){
            let newFormData = {...this.formData}
            delete newFormData.asicRequirements
            this.formData = {...newFormData}
        }

        // show alert if needed
        this.showAlert(name, value );
    }

    // Handle slot button submit -> Calls the submitForm method in the core-form to dispatch the required submission event to be handled in the this.handleGetStarted() method
    /**
     * Submits the form.
     * @fires RaisePreraiseModal#submitForm
     */
    submitForm(){
        this.refs.coreForm.submitForm()
    }


    /**
     * Checks if all form fields have 'Yes' value.
     * @returns {Boolean} True if all form fields have 'Yes' value, otherwise false.
     */
    get isAllValid(){
        return this.checkFormAll("Yes") && this.checkAllFieldsFilled() && this.formData.investType;
    }

    /**
     * Checks if at least one form field has 'No' value.
     * @returns {Boolean} True if at least one form field has 'No' value, otherwise false.
     */
    get isAllNo(){
        return this.checkFormAtLeastOne("No") && this.checkAllFieldsFilled() && !this.formData.investType;
    }

    /**
     * Checks if the button should be disabled.
     * @returns {Boolean} True if the button should be disabled, otherwise false.
     */
    get buttonDisabled(){
        return !this.isAllValid
    }

    /**
     * Checks if all form fields have the specified value.
     * @param {String} value - The value to check against.
     * @returns {Boolean} True if all form fields have the specified value, otherwise false.
     */
    checkFormAll(value){
        let checkArray = [];
        for(var key in this.formData){
            if(this.formData.hasOwnProperty(key) && key !== 'investType'){
                if(this.formData[key]=== value){
                    checkArray.push(true)
                }else{
                    checkArray.push(false)
                }
            }
        }
        return checkArray.every(v => v === true);
    }

    /**
     * Checks if at least one form field has the specified value.
     * @param {String} value - The value to check against.
     * @returns {Boolean} True if at least one form field has the specified value, otherwise false.
     */
    checkFormAtLeastOne(value){
        let checkArray = [];
        for(var key in this.formData){
            if(this.formData.hasOwnProperty(key) && key !== 'investType'){
                if(this.formData[key]=== value){
                    checkArray.push(true)
                }else{
                    checkArray.push(false)
                }
            }
        }
        return checkArray.includes(true);
    }

    /**
     * Checks if all fields are filled.
     * @returns {Boolean} True if all fields are filled, otherwise false.
     */
    checkAllFieldsFilled(){
        let counter = 0
        for (let prop in this.formData) {
            if (this.formData.hasOwnProperty(prop)){
                counter += 1
            };
        }
        if(this.numFields === 0){
            return false
        }else{
            return counter === this.numFields;
        }
    }

    // handler to show/hide field alerts when they are = No
    /**
     * Shows or hides field alerts.
     * @param {String} alertName - The name of the alert.
     * @param {String} value - The value of the field.
     */
    showAlert(alertName, value){

        let alertElement = this.template.querySelector(`c-core-alert[data-id="${alertName}"]`)
        if(alertElement){

            if(value==="No"){
                alertElement.style.display = "block"
            }else if(value==="Yes"){
                
                alertElement.style.display = "none";
                
            }
        }
       
    }

    countFields(){
        let selector = `c-core-radio`;
        let inputFields = this.template.querySelectorAll(selector)

        let selectorInput = `c-core-input`;
        let coreInputFields = this.template.querySelectorAll(selectorInput)


        this.numFields = inputFields.length + coreInputFields.length
    }

    /**
     * Callback function called when the component is rendered.
     * @fires RaisePreraiseModal#navigateToForm
     */
    renderedCallback(){
        if(this.hasRendered===false){
            this.countFields();
            this.hasRendered = true;
        }

    }

    /**
     * Checks if a raise exists for the company.
     * @fires RaisePreraiseModal#checkRaiseExists
     */
    async checkRaiseExists(){
        this.raiseExists = await apex_raiseExists({companyId : this.companyid});
        return this.raiseExists;
    }

    /**
     * Callback function called when the component is connected to the DOM.
     * @fires RaisePreraiseModal#checkRaiseExists
     */
    @track helpTextMapping = {
        retailOrWholesale : `https://${window.location.host}/articles/module/Pre-Raise-Checklist-Wholesale-or-Retail`,
        asicRequirements : `https://${window.location.host}/articles/module/Pre-Raise-Checklist-Retail-ASIC-Requirements`,
        amtCapital : `https://${window.location.host}/articles/module/Pre-Raise-Checklist-EOIs-Required`,
        capitalRaise:`https://${window.location.host}/articles/module/Capital-Raise-101-Course-Founder-Responsibilities`,
        keyDocumentsWholesale: `https://${window.location.host}/articles/module/Wholesale-Key-Documents`,
        keyDocumentsRetail: `https://${window.location.host}/articles/module/Retail-Raise-Key-Documents`,
        feesBenefits: `https://${window.location.host}/articles/module/Raise-Fees-Benefits`,
    }

    connectedCallback(){
        this.checkRaiseExists();
    }
}