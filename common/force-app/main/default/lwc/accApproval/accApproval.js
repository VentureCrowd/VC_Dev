import { LightningElement,api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import submitAccForApproval from '@salesforce/apex/accTriggerHandler.submitAccForApproval';
import getUsers from '@salesforce/apex/accTriggerHandler.getUsers';
export default class AccApproval extends LightningElement {
    bodyMsg = 'Could you provide an explanation for why you are seeking to take ownership of this account?';
    isSubmitDisabled = false;
    @api recordId;
    recordAvailable = false;
    showcomment = true;
    CancelLbel;
    defaultVal;
    selectedUserId;
    showusers = false;
    options = [];
    originalOptions = [];
    connectedCallback(){
       this.CancelLbel = 'Cancel';
       getUsers()
       .then(res =>{
            this.options = res;
            this.originalOptions = res;
            this.defaultVal = res[0].label;
            this.selectedUserId = res[0].value;
            this.showusers = true;
        })
        .catch(e => console.log(e))
    }
    submitForApproval(){
        this.disableSubmit();
        let comment = this.template.querySelectorAll('lightning-input')[1].value;
        submitAccForApproval({recId:this.recordId,comment,requestedby:this.selectedUserId })
        .then(res =>{
            this.bodyMsg = res;
            this.hidecommnet();
            this.CancelLbel = 'Close';
        })
        .catch(e => console.log(e));
    }
    cancel(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    hidecommnet(){
        this.showcomment = false;
    }
    disableSubmit(){
        this.isSubmitDisabled = true;
    }
    optionsel(event){
        this.selectedUserId = event.detail;
    }
    handinputchange(event){
        let tempOptns = []
        this.originalOptions.forEach(e =>{
            if(e.label.toUpperCase().includes(event.detail.toUpperCase())){
                tempOptns.push(e);
            }
        })
        this.options = tempOptns;
    }
}