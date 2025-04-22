/*********************************************************************************************************************************************
Author		 :	 Prakash Borade
Description	 :   CreateNewCompany component show popup to create new company and handle creation of new company.
Child Component   : -
----------------------------------------------------------------------------------------------------------------------------------------------
Version      Date                 Author               Details
1            12/21/2023           Prakash Borade       Initial Development
2            19/02/2024           Tod/ Prakash         Final Optimization
**********************************************************************************************************************************************/
//Importing Lightning Web Components essentials
import { LightningElement,track,wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// import createNewCompany
import createCompany from '@salesforce/apex/MyCompaniesController.createNewCompany';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
// Importing the getRecordTypeId method from the Utils Apex class for retrieving the record type ID
import getRecordTypeId from '@salesforce/apex/Utils.getRecordTypeId';
// Importing the SECTOR_FIELD field from the Account object schema
import SECTOR_FIELD from "@salesforce/schema/Account.Sector__c";
// Importing the current user's ID from the @salesforce/user module
import Id from '@salesforce/user/Id';
// Importing a utility class
import { Utility } from 'c/utils';


export default class CreateNewCompany extends LightningElement {
    popup = false;
    showspinner = false;
    urlIsValid = false;
    disableSaveBtn = true;
    userId = Id;
    @api recordTypeId;
    @track notAusBasedCompany = false;
    cntryVal = 'au';
    @track sectorOptions = [];
    @track sectorValue;
    datamap = {};
    @track radioSelectedvalue = 'yes'
    @api pageHeader = 'Expression of interest'
    isAcnValid = false;

    /*
        getRecordTypeId - Method used to get Record Type Id for specific record type.
    */
    getRecordTypeId() { 
        getRecordTypeId({objectName: 'Account', recordTypeLabel: 'Ventures Company Account'})
        .then(result =>{
            if(result) { 
                this.recordTypeId = result;
            }
        })
        .catch(e => {
            console.log('error in getting recordTypeId')
        })
    }

    /*
        getPicklistValues - Its a wire method used to get values of SECTOR_FIELD picklist.
    */
    @wire(getPicklistValues, {
        recordTypeId: "$recordTypeId",
        fieldApiName: SECTOR_FIELD
      })
      wireObjectInfo({ error, data }){
        if(data){
            this.objectInfoData = data;
            this.sectorOptions = this.objectInfoData.values;
            this.sectorValue = this.sectorOptions[0].value;
           
        } else if (error) {
            console.log(Error ,' Error while getting SECTOR_FIELD picklist values')
        }
    }
    
    connectedCallback() { 
        this.getRecordTypeId(); 
    }
    
    /*
        handleChange - This method is used set the values to datamap onchange of field.
    */
    handleChange(event) {  
        // Check if the changed input field is 'Name'
        if(event.target.name == 'Name') { 
            //To validate given input are correct using validateInputs method
            this.datamap['Name'] = event.target.value;
            this.validateInputs('Name');
        }
        if(event.target.name == 'BillingCountry') { 
             //To validate given input are correct using validateInputs method
            this.datamap['BillingCountry'] = event.target.value;
            this.validateInputs('BillingCountry');
        }
        if(event.target.name == 'Website') { 
             //To validate given input are correct using validateInputs method
            let websiteField = this.template.querySelector('[data-id="Website"]');
            this.datamap['Website'] = event.target.value;
            this.urlIsValid = Utility.validateUrl(this.datamap['Website']);
            if (!this.urlIsValid) {
                websiteField.setCustomValidity('Invalid URL. Please provide a valid URL like www.yourcompany.com');
            } else {
                websiteField.setCustomValidity('');
            }
            this.validateInputs(''); 
        }
        if(event.target.name == 'Sector__c') { 
             //To validate given input are correct using validateInputs method
            this.datamap['Sector__c'] = event.target.value;
        }
        if(event.target.name == 'ACN__c') { 
             //To validate given input are correct using validateInputs method
            this.datamap['ACN__c'] = event.target.value.replace(/\s+/g, '');
            let abnInput = this.template.querySelector('lightning-input[data-id="ACN__c"]');
            let abnNumber = abnInput.value.trim();
            var result= Utility.abnValidation(abnNumber);
            if (!result) {
                abnInput.setCustomValidity('Invalid ABN. Please provide a valid number.');
            } else {
                abnInput.setCustomValidity('');
                this.isAcnValid = true;
              }    
              abnInput.reportValidity(); 
            this.validateInputs(''); 
        }
    }
    /**
     * Validates the input fields and determines the state of save and 
     * update button's validity as per given input.
     */
    validateInputs(fieldType) {
         //get all lightning-input fields
        let inputelements = this.template.querySelectorAll('lightning-input');
        //Covert to array format
        let allelements = Array.from(inputelements);
        let isformvalid = true;
        //Iterate over the allelements and check input field name and item name of iteration matches/not.
        allelements.forEach((ele) => {
            ele.value = ele.value ? ele.value : ele.value;
            if (ele.name == fieldType) {
                ele.reportValidity();
            }
            isformvalid = isformvalid & ele.checkValidity();
        });
        //If form,url and radioSelectedvalue is "yes" is valid then disableSaveBtn and disableUpdateBtn will be false otherwise true.
        if (isformvalid && this.urlIsValid && this.radioSelectedvalue == 'yes' && this.isAcnValid) {
            this.disableSaveBtn = false;
        } else {
            this.disableSaveBtn = true;
        }
    }

    /*
        createCompany - using this method to create company record.
    */
    createCompany(){
        // Show spinner while creating the company
        this.showspinner = true;
        // Get the datamap containing company data
        let datamap = this.datamap
        // Call the Apex method to create the company
        createCompany({datamap})
        .then(r =>{
            // If company creation is successful
            if(r == 'Success'){  
            this.popup = false;
            // Show success toast message
            this.showtoast('New company has been created','success');
            window.location.reload()
            this.showspinner = false;
            }else{
                 // If company creation fails, show error toast message
                this.showtoast('Error in creating new company.','error');
                this.showspinner = false;
            }                
        })
        .catch(e => {
             // If an error occurs during company creation, show error toast message
            this.showtoast('Error in creating new company.','error');
            this.showspinner = false;
        })
    }

    /**
     * Opens the modal for adding a new founder.
     * Resets relevant properties and sets initial state for the modal like disable save button.
     */
    showpopup(){
        this.datamap = {};
        this.datamap['BillingCountry'] = this.cntryVal
        this.datamap['Sector__c'] = this.sectorValue;
        this.popup = true;
        this.disableSaveBtn = true;
        this.notAusBasedCompany = false;
        this.radioSelectedvalue = 'yes'
    }

    /**
     * Closes the modal for adding a new founder.
     * Resets relevant properties and sets initial state for the modal.
     */
    closeppup(){
        this.popup = false;
        this.disableSaveBtn = true;
        this.notAusBasedCompany = false;
        this.radioSelectedvalue = 'yes'
    }

    handleRadioSelection(event) {
        // Check if event and event.target.value exist
        if(event && event && event.target.value) { 
            this.radioSelectedvalue = event.target.value;
             // Update the 'notAusBasedCompany' property based on the selected value
            if(this.radioSelectedvalue == 'no') { 
                this.notAusBasedCompany = true;
            } else { 
                 // If 'Yes' is selected, set 'notAusBasedCompany' to false
                this.notAusBasedCompany = false;
            }
        }
        // Validate inputs after radio selection
        this.validateInputs('');
    }

    /**
     * Displays a toast notification with the given message and variant.
     */
    showtoast(m,k){
        this.dispatchEvent(
            new ShowToastEvent({
                title: m,
                variant: k
            })
        );
    }
}