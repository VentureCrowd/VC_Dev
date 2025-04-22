/**
 * RaiseFormWholesale Component
 * @description This component manages the wholesale form for the raise process. It handles form data input, validation, submission, and navigation to different pages within the raising process. It also interacts with Apex controllers to fetch and update data.
 * 
 * @example
 * <c-raise-form-wholesale record-id={recordId}></c-raise-form-wholesale>
 */

import { LightningElement, track, api, wire } from 'lwc';
import ventureCrowdTheme from "@salesforce/resourceUrl/ventureCrowdTheme";
import { investProductTypeMapping } from './investTypeFields'; 

import apex_submitFormData from '@salesforce/apex/RaiseController.updateRaiseDetails';
import apex_getRaiseData from '@salesforce/apex/RaiseController.getRaiseDetailsForm';
import apex_getPicklistValues from '@salesforce/apex/RaiseController.getPicklistValues';

import { getRecord } from 'lightning/uiRecordApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';

// Import the Raise object and the picklist field for Investment Product Type.
import INVEST_PRODUCT_TYPE_FIELD from '@salesforce/schema/Raise__c.Form_Investment_Product_Type__c';


const FIELDS = ['Raise__c.RecordTypeId'];

import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class RaiseFormWholesale extends NavigationMixin(LightningElement) {
    @api recordId;

    @track _formData;


    picklistFields = [
        {formField: 'stage', variableName:'stageOptions', fieldName : 'Form_Stage__c'},
        {formField: 'sector',variableName:'sectorOptions', fieldName : 'Form_Sector__c'},
        // {formField: 'investProductType',variableName:'investProductTypeOptions', fieldName : 'Form_Investment_Product_Type__c'},
    ]

    hideValues = ['Interests in a Limited Partnership', 'Secured Loan', 'Units in a MIS'];

    yesNoOptions = [
        {id:1, label:"Yes", value:'true', checked:false},
        {id:2, label:"No", value:'false', checked:false},
    ];

    termsAndConditionsOptions = [
        {id:1, label:"I acknowledge and agree to the the above details about my company's raise and would like to progress to submission.", value:'true', checked:false},
    ];

    // TODO: Pull values from SF
    sectorOptions;

    // TODO: Pull values from SF
    stateOptions = [
        {value:"NSW", label:"New South Wales"},
        {value:"QLD", label:"Queensland"},
        {value:"VIC", label:"Victoria"},
        {value:"NT", label:"Northen Territory"},
        {value:"WA", label:"Western Australia"},
        {value:"ACT", label:"Canberra"},
        {value:"TAS", label:"Tasmania"},
    ]

    // TODO: Pull values from SF
    stageOptions;

    investProductTypeOptions;
    recordTypeId;

    // Wire adapter to get the current record's record type.
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRaiseRecord({ error, data }) {
        if (data) {
            this.recordTypeId = data.fields.RecordTypeId.value;
        } else if (error) {
            console.error('Error retrieving record:', error);
        }
    }

    // Wire adapter to get picklist values for Form_Investment_Product_Type__c
    // using the record's actual recordTypeId.
    @wire(getPicklistValues, { 
        recordTypeId: '$recordTypeId', 
        fieldApiName: INVEST_PRODUCT_TYPE_FIELD 
    })
    wiredInvestProductType({ data, error }) {
        if (data) {
            // data.values contains the picklist options valid for the provided record type.
            this.investProductTypeOptions = [...data.values];
        } else if (error) {
            console.error('Error retrieving investment product type picklist values:', error);
        }
    }


    structureAndStrategyTitle = "Structure & Strategy"

    @track isDealPageLoading;

    @api
    get formData(){
        return this._formData;
    }
    set formData(v){
        this._formData = v;
    }

    @track dataRetrieved = false;

    @track isLoading = false;
    @track isPrevLoading = false;
    @track isNextLoading = false;
    @track isSaving = false;

    @track halfWayMark = false;
    @track endMark = false;

    @track showHalfWayPopup = false;
    @track showEndPopup = false;

    @track currentStep;

    halfWayPopupImage = ventureCrowdTheme + '/Images/halfWayPopup.png';
    endPopupImage = ventureCrowdTheme + '/Images/endPopup.png';

    @track investTypeFields;

    get previewDealPageURL(){
        return `/s/portal/my-companies/edit-raise/preview?id=${this.recordId}`;
    }

    get financialFileRequired(){
        const returnJSON = {
            required : this.formData?.financialInformationUrl ? false : true,
            text : this.formData?.financialInformationUrl ? "Upload statements (optional)" : "Upload statements (required)",
        }
        return returnJSON
    }
  
    // This is field is not mandatory since 15/10/24
    // get financialDataLinkRequired(){
    //     const returnJSON = {
    //         required : this.formData?.financialInformationFileId ? false : true,
    //         text : "Add link to data room (optional)",
    //     }
    //     return returnJSON
    // }
  

    // Reference to the child form component
    coreMultiStepForm;
    /**
     * Handles form data submission.
     * @param {Event} e - The submit event.
     */
    async handleData(e) {

        e.stopPropagation();
        this.formData = { ...e.detail.formData };
        try {
            await this.submitFormData(this.recordId, this.formData);
            this.navigateToApprovals(this.recordId);
        } catch (err) {
            console.error('Error in handleData:', err);
            this.showToast('Error', 'There was an error submitting the form data! Please try again.', 'error');
        }
    }
    
    /**
     * Navigates to the approvals page for the specified raise ID.
     * @param {string} raiseId - The ID of the raise.
     */
    navigateToApprovals(raiseId) {
        this[NavigationMixin.Navigate]({
            // Define navigation type and target page name
            type: 'comm__namedPage',
            attributes: {
                name: 'Raise_Approval__c' // Page name for my Companies
            },
            state :{
                id : raiseId
            }
        });
    }

    /**
     * Navigate to the preview page for the specified raise ID.
     */
    async handleAdditionalButton() {
        this.isDealPageLoading = true;
        try{
            await this.saveFormData({"noCheckRequired" : true});
            this[NavigationMixin.Navigate]({
                // Define navigation type and target page name
                type: 'comm__namedPage',
                attributes: {
                    name: 'Preview__c'
                },
                state: {
                    id: this.recordId
                }
            });
        }catch(error){
            console.error('There was an error submitting the form data! Please try again.', JSON.stringify(error));
        }finally{
            this.isDealPageLoading = false;
        }
    }

    closeErrorMessageToast(){
        const closeErrorsEvent = new CustomEvent('closetoast', {
            detail: { 
                error: false
            },
            bubbles: true,
            composed: true,
        });
        this.dispatchEvent(closeErrorsEvent);
    }

    /**
     * Handles the event when the user navigates to the next step in the form.
     * @param {Event} e - The next event.
     */
    async handleNext(e) {
        this.isNextLoading = true;
        // stop event prop
        e.stopPropagation();
        // get step index
        let stepIndex = String(Number(e.detail.currentStepIndex) + 1);

        this.formData = { ...e.detail.formData, currentPageIndex: stepIndex};

        if (this.formData.termsAndConditions && this.formData.termsAndConditions.length > 0) {
            this.formData.termsAndConditions = this.formData.termsAndConditions[0];
        } else {
            this.formData.termsAndConditions = "false";
        }

        try {
            await this.submitFormData(this.recordId, this.formData);
            
            // udpate step indexes
            this.currentStep = Number(stepIndex);
            
    
            if (stepIndex == 2 && this.halfWayMark == false) {

                if(this.coreMultiStepForm){
                    this.coreMultiStepForm.goToNextStep();
                }

                this.halfWayMark = true;
                this.showHalfWayPopup = true;
    
                const halfWayReachedData = {
                    halfwayReached: "true",
                };
    
                try {
                    await apex_submitFormData({ raiseId: this.recordId, fieldsToUpdate: halfWayReachedData });
                } catch (err) {
                    console.error('Error updating halfwayReached:', err);
                }
            }else if (stepIndex == 3 && this.endMark == false) {
                if(this.coreMultiStepForm){
                    this.coreMultiStepForm.goToNextStep();
                }

                this.endMark = true;
                this.showEndPopup = true;
    
                const endReachedData = {
                    endReached: "true",
                };
    
                try {
                    await apex_submitFormData({ raiseId: this.recordId, fieldsToUpdate: endReachedData });
                } catch (err) {
                    console.error('Error updating endReached:', err);
                }
            }else{
                if(this.coreMultiStepForm){
                    this.coreMultiStepForm.goToNextStep();
                }
            }
             
        } catch (err) {
            console.error('Error in handleNext:', err);
            this.showToast('Error', 'There was an error submitting the form data! Please try again.', 'error');
        }finally{
            this.isNextLoading=false;
        }
    }
    
    debouncedSubmit = this.debounce(this.submitFormData.bind(this), 500); // 500ms debounce delay


    /**
     * Saves the form data.
     * Used in the RaiseFormContainer to save the form data when the preview button is clicked.
     * @returns {Promise} A promise that resolves to the server response.
     */
    @api
    async saveFormData(options) {
        try {
            if(this.coreMultiStepForm.validateCurrentStep(options)){
                const res = await this.submitFormData(this.recordId, this.formData);
                return res;
            }else{
                throw new Error('Field errors still exist')
            }   
            
        } catch (err) {
            console.error('Error in saveFormData:', err);
            throw err;
        }
    }


    /**
     * Handles the event when the user navigates to the previous step in the form.
     * @param {Event} e - The previous event.
     */
    async handlePrev(e) {
        this.isPrevLoading = true;
        e.stopPropagation();
        const stepIndex = String(Number(e.detail.currentStepIndex) - 1);
    
        const updateStepData = {
            ...e.detail.formData,
            currentPageIndex: stepIndex,
        };

        if (updateStepData.termsAndConditions && updateStepData.termsAndConditions.length > 0) {
            updateStepData.termsAndConditions = updateStepData.termsAndConditions[0];
        } else {
            updateStepData.termsAndConditions = "false";
        }
    
        try {
            // try and save data first
            await apex_submitFormData({ raiseId: this.recordId, fieldsToUpdate: updateStepData });
            
            // udpate step indexes
            this.formData.currentPageIndex = stepIndex;
            this.currentStep = Number(stepIndex);
            
            // If save is successful, navigate to the previous step
            if(this.coreMultiStepForm){
                this.coreMultiStepForm.goToPreviousStep();
            }
        } catch (err) {
            console.error('Error in handlePrev:', err);
            this.showToast(
                'Error',
                'There was an error saving your progress. Please try again.',
                'error'
            );
        }finally{
            this.isPrevLoading=false
        }
    }
    
    /**
     * Handles closing of the popup.
     * @param {Event} e - The close event.
     */
    handleClosePopup(e){
        this.showHalfWayPopup = false;
        this.showEndPopup = false;
    }

    
    /**
     * Submits the form data to the server.
     * @param {string} raiseId - The ID of the raise.
     * @param {Object} formData - The form data to be submitted.
     * @returns {Promise} A promise that resolves to the server response.
     */
    async submitFormData(raiseId, formData) {
        this.isSaving = true;
        // Convert TNC to Boolean
        if (formData.termsAndConditions && formData.termsAndConditions.length > 0) {
            formData.termsAndConditions = formData.termsAndConditions[0];
        } else {
            formData.termsAndConditions = "false";
        }

        try {
            const returnData = await apex_submitFormData({ raiseId: raiseId, fieldsToUpdate: formData });
            return returnData;
        } catch (error) {
            console.error('Error submitting form data:', error);
            throw error;
        }finally{
            this.isSaving = false;
        }
    }


/**
 * Fetches the form data for the specified raise ID.
 * @param {string} raiseId - The ID of the raise.
 * @returns {Promise} A promise that resolves to the form data.
 */
    getFormData(raiseId){
        this.isLoading = true;
        apex_getRaiseData({raiseId : raiseId}).then((result)=>{
            this.formData = result;
            this.isLoading = false;
            return this.formData;
        }).then((formData)=>{
            // add any default field values to the form data here if needed - remember to check if an existing value is present before overriding

            if(this.formData.investProductType){
                const fieldsToDisplay = investProductTypeMapping.find(item => item.key === this.formData.investProductType);
                this.investTypeFields = fieldsToDisplay
            }

            // placeholder text for growthPlan if empty
            if(!this.formData.growthPlan){
                this.formData.growthPlan = 'Please outline here the growth strategy you have in place or share where in your pitch investors can find this information.'
            }

            // placeholder text for financial statements if empty
            if(!this.formData.financialInformation){
                this.formData.financialInformation = 'Please outline here the financial statements you have uploaded.'
            }

            // set step
            const stepIndex = this.formData?.currentPageIndex ?  this.formData?.currentPageIndex : 0;
            this.currentStep = Number(stepIndex);

            // set halfway marker
            if(this.formData?.halfwayReached === "true"){
                this.halfWayMark = true;
                this.showHalfWayPopup = false;
            }

            // set end marker
            if(this.formData?.endReached === "true"){
                this.endMark = true;
                this.showEndPopup = false;
            }

            this.dataRetrieved = true;
        }).catch(err=>{
            this.isLoading = false;
        });
    }
/**
 * Handles form data changes.
 * @param {Event} e - The change event.
 */
    handleChange(e){
        e.stopPropagation();

        const { name, value } = e.detail;

       // Update formData with the new value
       this._formData = { ...this._formData, [name]: value };

       // Auto calculate share price if relevant fields are changed
       //! This auto calculate should be re implemented in the future? - Cesar 28/10/24
    //    if(name === 'valuation' || name === 'numberOfShares'){
    //        const valuationAmt = parseFloat(this._formData.valuation) || 0;
    //        const numShares = parseFloat(this._formData.numberOfShares) || 1; // Avoid division by zero
    //        const sharePrice = valuationAmt / numShares;
    //        this._formData = { ...this._formData, sharePrice: sharePrice.toFixed(2) };
    //    }


        // get investment product type fields
        if(name === 'investProductType'){
            const fieldsToDisplay = investProductTypeMapping.find(item => item.key === value);
            this.investTypeFields = fieldsToDisplay;
        }

        const saveObj = {};
        saveObj[name] = value;

        // Call the debounced submit function
        this.debouncedSubmit(this.recordId, saveObj);
        
    }


    /**
     * Fetches picklist values for the specified fields.
     * @param {Array} fields - The fields for which to fetch picklist values.
     * @returns {Promise} A promise that resolves to the picklist values.
     */
    async getPicklistValues(fields) {
        this.isLoading = true;
        try {
            const returnValues = await Promise.all(
                fields.map(async (field) => {
                    try {
                        const result = await this.getPicklist('Raise__c', field.fieldName);
                        this[field.variableName] = [...result];
                        return {
                            fieldName: field.variableName,
                            value: result,
                        };
                    } catch (error) {
                        console.error(`Error fetching picklist for ${field.fieldName}:`, error);
                        throw error;
                    }
                })
            );
            this.isLoading = false;
            return returnValues;
        } catch (err) {
            this.isLoading = false;
            console.error('Error in getPicklistValues:', err);
            throw err;
        }
    }

    /**
     * Fetches picklist values for the specified object and field.
     * @param {string} objectName - The name of the object.
     * @param {string} fieldName - The name of the field.
     * @returns {Promise} A promise that resolves to the picklist values.
     */
    async getPicklist(objectName, fieldName) {
    try {
        let picklistValues = await apex_getPicklistValues({ objectName: objectName, fieldName: fieldName });
        return picklistValues;
    } catch (err) {
        console.error(`Error fetching picklist for ${fieldName}:`, err);
        throw err;
    }
}


    @track helpTextMapping = {
        // About us links
        oneLiner : `https://${window.location.host}/articles/module/Raise-About-Us#one-liner`,
        pitchVideo : `https://${window.location.host}/articles/module/Raise-About-Us#pitch-video`,
        guidanceVideo : `https://${window.location.host}/articles/module/Raise-About-Us#guidance-video`,
        companyOverview : `https://${window.location.host}/articles/module/Raise-About-Us#company-overview`,
        problem: `https://${window.location.host}/articles/module/Raise-About-Us#problem`,
        solution: `https://${window.location.host}/articles/module/Raise-About-Us#solution`,
        differentiation: `https://${window.location.host}/articles/module/Raise-About-Us#differentiation`,
        intellectualProperty : `https://${window.location.host}/articles/module/Raise-About-Us#intellectual-property`,
        totalAddMarket : `https://${window.location.host}/articles/module/Raise-About-Us#total-addressable-market`,
        progress : `https://${window.location.host}/articles/module/Raise-About-Us#progress`,
        // Structure & strategy links
        directors : `https://${window.location.host}/articles/module/Wholesale-Raise-Structure-and-Strategy#directors`,
        advisors : `https://${window.location.host}/articles/module/Wholesale-Raise-Structure-and-Strategy#advisors`,
        growthPlan : `https://${window.location.host}/articles/module/Wholesale-Raise-Structure-and-Strategy#growth-plan`,
        financialInfo : `https://${window.location.host}/articles/module/Wholesale-Raise-Structure-and-Strategy#financial-info`,
        debtFunding : `https://${window.location.host}/articles/module/Wholesale-Raise-Structure-and-Strategy#debt-funding`,
        legal : `https://${window.location.host}/articles/module/Wholesale-Raise-Structure-and-Strategy#legal`,
        materialAgreements : `https://${window.location.host}/articles/module/Wholesale-Raise-Structure-and-Strategy#material-agreements`,
        // Intended raise links
        stage : `https://${window.location.host}/articles/module/Wholesale-Intended-Raise#stage`,
        pitchDeck : `https://${window.location.host}/articles/module/Wholesale-Intended-Raise#pitch-deck`,
        useOfFunds : `https://${window.location.host}/articles/module/Wholesale-Intended-Raise#use-of-funds`,
        launchDate: `https://${window.location.host}/articles/module/Wholesale-Intended-Raise#launch-date`,
        closeDate: `https://${window.location.host}/articles/module/Wholesale-Intended-Raise#close-date`,
        productType : `https://${window.location.host}/articles/module/Wholesale-Intended-Raise#product-type`,
    }

    async connectedCallback() {
        try {
            await this.getPicklistValues(this.picklistFields)
            await this.getFormData(this.recordId);
        } catch (err) {
            console.error('Error in connectedCallback:', err);
            this.showToast(
                'Error',
                'There was an error initializing the form. Please refresh the page or contact support.',
                'error'
            );
        }
    }
    
    renderedCallback(){
        // Obtain a reference to the child component after rendering
       if(!this.coreMultiStepForm && this.dataRetrieved){
           this.coreMultiStepForm = this.template.querySelector('c-core-multi-step-form');
       }
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

    @api
    handleFocusField(fieldLabel){
        let multiStepFormEle = this.template.querySelector("c-core-multi-step-form");
        
        if(multiStepFormEle){
            multiStepFormEle.focusField(fieldLabel);
        }
    }


    handleErrorsFound(event){

        this.closeErrorMessageToast();

        event.stopPropagation();
        const errorFields = event.detail.errorFields;
        const errorsFound = event.detail.errors;

        if(errorsFound){
            const errorsEvent = new CustomEvent('errorsfound', {
                detail: { 
                    errorFields : errorFields
                },
                bubbles: true,
                composed: true,
            });
            this.dispatchEvent(errorsEvent);
        }
       
        
    }

    debounce(func, wait) {
        let timeout;
        return function (...args) {
            const later = () => {
                clearTimeout(timeout);
                func.apply(this, args);
            };
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
        };
    }


}