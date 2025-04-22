import { LightningElement,api,track,wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getSObjectInstance from '@salesforce/apex/MyProfileController.getSObjectInstance';
import inputtel from '@salesforce/resourceUrl/inputtel';

export default class MyProfileComponent extends LightningElement {
    @api recordId;
    @api cardTitle;
    @api editBehaviour;
    @api isDisplayPicture;
    @api sObjectName;
    @api sObjectBFields;
    @api sObjectPFields;
    @api sObjectSFields;
    @api isOnlyPersonalAccount;
    @api editOverRide;
    @api helptext;
    @api helptextpopup;
    @track displayEdit = false;
    @track fields;
    @api displayFields;
    @track displayData;
    @track data;
    @track contactChecked;
    @track FullPhotoUrl;
    @track imageUrl;
    @track displayPopover;
    @track displayOverride;
    @track overrideLabel;
    @track displayComponent = true;

    //Popover variables
    isEditRecord;
    toUpdateRecordId;
    toUpdateObject;
    isMobileNumber;
    mobileNumber;

    isUpdateImage;
    popoverTitle;
    userType;


    @wire(getRecord,{ recordId: '$recordId', fields: '$fields'})
    wiredResponse(response) {
        if (response.data) {
            this.data = response.data;

            //Switch Statement for Updating conditional Data
            switch(this.cardTitle) {

                //Information Case
                case 'Information':
                  // code block
                  this.displayData = []; 
                  
                  //Business vs Partner user
                  if (this.userType == 'Contact') {
                      let  updatedFields = [];
                      if (response.data.fields.Contact) {
                        if (response.data.fields.Contact.value.fields.Wholesale__c.value) {
                            updatedFields.push({'field':'Wholesale Investor','value':response.data.fields.Contact.displayValue,'Id':this.recordId});
                        } else {
                            updatedFields.push({'field':'Investor Profile','value':response.data.fields.Contact.displayValue,'Id':this.recordId});    
                        }
                        if (response.data.fields.Contact.value.fields.Birthdate) {
                            updatedFields.push({'field':'Date of Birth','value':response.data.fields.Contact.value.fields.Birthdate.displayValue,'Id':'2'});
                        }

                        if (response.data.fields.Contact.value.fields.ID_Checked__c.value) {
                            updatedFields.push({'field':'Id Verification','value':`<img style="margin-top:8px;height:1rem;width:1rem"  src=${this.imageUrl} alt="Contact Validated?"></img> Complete`,'Id':'3'});
                            
                        } else {
                            updatedFields.push({'field':'Id Verification','value':'To be completed','Id':'3'});

                        }
                        this.contactChecked = response.data.fields.Contact.value.fields.ID_Checked__c.value;
                      }                  
                      this.displayData.push(...updatedFields);
                    } else if (this.userType == 'Account') {
                        let  updatedFields = [];
                      if (response.data.fields.Account) {
                        if (response.data.fields.Account.value.fields.Wholesale__pc.value) {
                            updatedFields.push({'field':'Wholesale Investor','value':response.data.fields.Account.displayValue,'Id':this.recordId});
                        } else {
                            updatedFields.push({'field':'Investor Profile','value':response.data.fields.Account.displayValue,'Id':this.recordId});    
                        }
                        if (response.data.fields.Account.value.fields.PersonBirthdate) {
                            updatedFields.push({'field':'Date of Birth','value':response.data.fields.Account.value.fields.PersonBirthdate.displayValue,'Id':'2'});
                        }
                        if (response.data.fields.Account.value.fields.ID_Checked__pc.value) {
                            updatedFields.push({'field':'ID Verification','value':`<img style="margin-top:8px;height:1rem;width:1rem"  src=${this.imageUrl} alt="Contact Validated?"></img> Complete`,'Id':'3'});
                            
                        } else {
                            updatedFields.push({'field':'ID Verification','value':'To be completed','Id':'3'});

                        }
                        this.contactChecked = response.data.fields.Account.value.fields.ID_Checked__pc.value;
                      }                  
                      this.displayData.push(...updatedFields);
                    } else {
                        // updatedFields
                        let  updatedFields = [];
                        updatedFields.push({'field':'','value':response.data.fields.Name.value,'Id':this.recordId});
                        this.displayData.push(...updatedFields);
                    }
                    this.FullPhotoUrl = this.isDisplayPicture ? response.data.fields.FullPhotoUrl.value : null;
                  break;

                // 'Phone Number'   realed fields
                case 'Phone Number':
                  // code block
                  this.displayData = []; 
                  if (this.userType == 'Contact') {
                      let  updatedFields = [];
                      updatedFields.push({'field':'','value':response.data.fields.Contact.value.fields.MobilePhone.value,'Id':this.recordId});
                      this.mobileNumber = response.data.fields.Contact.value.fields.MobilePhone.value;
                      this.displayData.push(...updatedFields);
                  }  else if (this.userType == 'Account') {
                    let  updatedFields = [];
                      this.displayData.push(...updatedFields);
                      updatedFields.push({'field':'','value':response.data.fields.Account.value.fields.PersonMobilePhone.value,'Id':this.recordId});
                      this.mobileNumber = response.data.fields.Account.value.fields.PersonMobilePhone.value;
                      this.displayData.push(...updatedFields);
                 } else {
                    let  updatedFields = [];
                    updatedFields.push({'field':'','value':response.data.fields.MobilePhone.value,'Id':this.recordId});
                    this.mobileNumber = response.data.fields.MobilePhone.value;
                    this.displayData.push(...updatedFields);
                 }
                  break;
                
                case 'Email Address':
                    // code block

                    this.displayData = []; 
                    let  updatedFields = [];
                    updatedFields.push({'field':'','value':response.data.fields.Email.value,'Id':this.recordId});
                    this.displayData.push(...updatedFields);
                    break;
                
                case 'Address':
                    this.displayData = [];
                    if (this.userType == 'Account') {
                        let  updatedFields = [];
                          this.displayData.push(...updatedFields);
                          updatedFields.push({'field':'','value':response.data.fields.Account.value.fields.PersonMailingStreet.value,'Id':this.recordId});
                          updatedFields.push({'field':'','value':response.data.fields.Account.value.fields.PersonMailingCity.value,'Id':this.recordId});
                          updatedFields.push({'field':'','value':response.data.fields.Account.value.fields.PersonMailingState.value,'Id':this.recordId});
                          updatedFields.push({'field':'','value':response.data.fields.Account.value.fields.PersonMailingCountry.value,'Id':this.recordId});
                          this.displayData.push(...updatedFields);
                     } 
                     break;

                case 'Bank Details':
                    this.displayData = [];
                    if (this.userType == 'Account') {
                        let  updatedFields = [];
                        updatedFields.push({'field':'','value':response.data.fields.Account.value.fields.Bank_Account_Name__c.value,'Id':'1'});
                        updatedFields.push({'field':'','value':response.data.fields.Account.value.fields.BSB_Number__c.value,'Id':'2'});
                        updatedFields.push({'field':'','value':response.data.fields.Account.value.fields.Bank_Account_Number__c.value,'Id':'3'});
                        this.displayData.push(...updatedFields);                  
                    } 
                    break;
                    
                case 'BPAY Details':
                    this.displayData = [];
                    if (this.userType == 'Account') {
                        let  updatedFields = [];
                        updatedFields.push({'field':'Biller Code','value':response.data.fields.Account.value.fields.BPAY_Biller_Code__c.value,'Id':'1'});
                        updatedFields.push({'field':'Reference Number','value':response.data.fields.Account.value.fields.BPAY_CRN__c.value.replace(/\d{4}(?=.)/g, "$& "),'Id':'2'});
                        this.displayData.push(...updatedFields);                  
                    } 
                break;    
                case 'Tax Details':
                    this.displayData = [];
                    let  updatedFields1 = [];
                    updatedFields1.push({'field':'TFN','value':response.data.fields.Account.value.fields.TFN_e__c.value,'Id':response.data.fields.Account.value.fields.Id.value});
                    this.displayData.push(...updatedFields1);
                break;
                case 'Holder Identification Number':
                    this.displayData = [];
                    let updatedFields2 = [];
                    updatedFields2.push({'field':'HIN','value':response.data.fields.Account.value.fields.HIN__c.value,'Id':response.data.fields.Account.value.fields.Id.value});
                    this.displayData.push(...updatedFields2);
                break;
                default:
                  // code block
              }
        } else {
            
            console.log('error>>',response.error);
        }
    }

    connectedCallback() {

        if (this.editBehaviour == 'Yes') {
            this.displayEdit = true;
        } else if(this.editBehaviour == 'No') {
            this.displayEdit = false;
        } else if(this.editBehaviour == 'No-Customize Edit') {
            this.displayEdit = false;
            this.displayOverride = true;
            // this.overrideLabel = this.editOverRide.split(',')[0];
            this.overrideLabel = this.editOverRide.split(',')[0]
        }

        getSObjectInstance({userId:this.recordId})
         .then(response => {
             this.userType = response;
            //Switch Statement for Rendering page based on current user
            this.fields = [];
            console.log(response);
            console.log(this.sObjectPFields,'sObjectPFields');
            switch(response) {
                // When contact is of type contact
                case 'Contact':
                  // code block
                  this.fields = this.sObjectBFields.split(",") || [];
                  break;
                //When contact is of type account
                case 'Account':
                  // code block
                  this.fields = this.sObjectPFields.split(",") || [];
                  break;
                default:
                    this.fields = this.sObjectSFields.split(",") || [];
                  // code block
              }

              if (response != 'Account' && this.isOnlyPersonalAccount) {
                this.displayComponent = false;
              }
         })
         .catch(error => {
             
         });
         this.imageUrl = inputtel+'/img/Tick_Collapsed.png';
    }

    handleImageChange() {
        this.displayPopover = true;
        this.popoverTitle = 'Update Image';
        this.isUpdateImage = true;
    }

    //Handle Overide Edit click
    handleOverrideClick() {
        let overridePath = this.editOverRide.split(',')[1] ? this.editOverRide.split(',')[1] : null;
        window.location = window.location.href.replace('/profile/', overridePath);
    }
    
    //Handle Edit functionality
    handleEditClick() {
        try{
        if (this.cardTitle.includes("Phone Number")) {            
            // this.isEditRecord = true;
            this.fieldsToEdit = []
            if (this.userType == 'Contact') {
                this.toUpdateObject = 'Contact';
                this.fieldsToEdit.push('MobilePhone');
                this.toUpdateRecordId = this.data.fields.Contact.value.id;              
            }  else if (this.userType == 'Account') {
                this.toUpdateObject = 'Account';
                this.fieldsToEdit.push('PersonMobilePhone');
                this.toUpdateRecordId = this.data.fields.Account.value.id;
              } else {
                this.toUpdateObject = 'User';
                this.fieldsToEdit.push('MobilePhone');
                this.toUpdateRecordId = this.recordId;
            }
            this.popoverTitle = 'Update Phone Number';
            this.displayPopover = true;
            this.isMobileNumber = true;
            // this.isEditRecord = true;
            
        } else if (this.cardTitle.includes("Bank Details")) {
            this.isEditRecord = true;
            this.fieldsToEdit = [];
            if (this.userType == 'Account') {
                this.toUpdateObject = 'Account';
                this.fieldsToEdit.push('Bank_Account_Name__c');
                this.fieldsToEdit.push('BSB_Number__c');
                this.fieldsToEdit.push('Bank_Account_Number__c');
                this.toUpdateRecordId = this.data.fields.Account.value.id;
            }
            this.popoverTitle = 'Update Bank Details';
            this.displayPopover = true;
        } else if (this.cardTitle.includes("Address")) {
            this.isEditRecord = true;
            this.fieldsToEdit = [];
            if (this.userType == 'Account') {
                this.toUpdateObject = 'Account';
                this.fieldsToEdit.push('PersonMailingAddress');
                this.toUpdateRecordId = this.data.fields.Account.value.id;
            }
            this.popoverTitle = 'Update Address';
            this.displayPopover = true;
        } else if (this.cardTitle.includes("Tax Details")) {
            this.fieldsToEdit = [];
            this.isEditRecord = true;
            this.toUpdateObject = 'Account';
            this.fieldsToEdit.push('TFN_e__c');
            this.popoverTitle = 'Update Tax Details';
            this.toUpdateRecordId = this.data.fields.Account.value.fields.Id.value;
            this.displayPopover = true;
        } else if (this.cardTitle.includes("Holder Identification Number")) {
            this.fieldsToEdit = [];
            this.isEditRecord = true;
            this.toUpdateObject = 'Account';
            this.fieldsToEdit.push('HIN__c');
            this.popoverTitle = 'Update Holder Identification Number';
            this.toUpdateRecordId = this.data.fields.Account.value.fields.Id.value;
            this.displayPopover = true;
        }
    }catch(e){
        console.log(e);
    }
 
    }

    //Method to Handle Pop-up Closure
    handleClosePopup() {
        this.displayPopover = false;
    }

}