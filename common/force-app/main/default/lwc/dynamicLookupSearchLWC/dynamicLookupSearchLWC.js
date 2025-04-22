import { LightningElement, track, api } from "lwc"; 
import findRecords from "@salesforce/apex/DynamicLookupController.findRecords";

export default class DynamicLookupSearchLWC extends LightningElement {
    
  showRecords = false;
    @track recordsList;    
    @track searchKey = "";  
    @api selectedValue ='';  
    @api selectedRecordId;
    @api recordLabel;
    @api objectApiName = 'account';  
    @api iconName = 'standard:account';  
    @api lookupLabel = '';  
    @track message;
    @track recData = [];
  showLoading = false;
    
  onRecordSelection(event) {  
   this.selectedRecordId = event.target.dataset.key;  
   this.selectedValue = event.target.dataset.name;  
   this.searchKey = "";  
   this.onSeletedRecordUpdate();  
  }  
   
  handleKeyChange() {
    this.showRecords = true;
    this.showLoading = true;
   const searchKey = this.template.querySelector('input').value;  
    this.searchKey = searchKey;
    this.selectedValue = searchKey;
   this.getLookupResult();  
  } 


  getLookupResult() {  
      findRecords({
          searchKey: this.searchKey, objectName: this.objectApiName,recordLabel: this.recordLabel
      })
          .then((result) => {
              this.recordsList = [];
              this.recData = [];
     if (result.length===0) {         
         this.showLoading = false;
       this.message = "No Records Found";  
     } else {
         console.log('else :');
         this.recData = result;
         if (this.recordsList.length == 0) {
             this.recData.forEach((eachResult) => {
             let label = { Name: '' , Id : '' }
             this.recordLabel.split(',').forEach((eachLabel) => {
               label.Name = label.Name + eachResult[eachLabel] + ' ';
               label.Id = eachResult.Id;  
             })
             console.log('this.recordsList :'+JSON.stringify(this.recordsList));
             if (!this.recordsList.includes(label)) {
                  
                     this.recordsList.push(label);
              } 
             
            })
         }
         this.showLoading = false;
       this.message = "";  
      }  
      this.error = undefined;  
    })  
        .catch((error) => {
      this.showLoading = false;
     this.error = error;  
     this.recordsList = undefined;  
    });  
  }  
   
  onSeletedRecordUpdate() {
    this.showRecords = false;
    const selectedEvent = new CustomEvent("productchange", {
      detail: { selectedRecordId: this.selectedRecordId, selectedValue: this.selectedValue }  
    });
    this.dispatchEvent(selectedEvent);
  }  
 }