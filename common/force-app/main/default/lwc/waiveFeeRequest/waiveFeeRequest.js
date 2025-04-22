import { LightningElement,api } from 'lwc';
import getdata from "@salesforce/apex/oppUtilityclass.getdata";
import proceedwaiverequest from "@salesforce/apex/oppUtilityclass.proceedwaiverequest";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
export default class WaiveFeeRequest extends LightningElement {
    @api recordId;
    Contribution_Fee__c;
    Contribution_Fee_Original__c;
    comment;
    oliId;
    showspinner =false;
    connectedCallback(){
        let url = new URL(window.location.href);      
        this.recordId = url.searchParams.get("recordId");
        getdata({recordId:this.recordId})
        .then(r =>{
            this.Contribution_Fee__c = r.Contribution_Fee__c;
            this.Contribution_Fee_Original__c = r.Contribution_Fee_Original__c;
            if(!this.Contribution_Fee_Original__c)
            this.Contribution_Fee_Original__c = 0;
            this.oliId = r.oliId;
        })
        .catch(e =>{
            console.log(e);
        })
    }
    databinder(event){
        this.Contribution_Fee__c = event.target.value;
    }
    handchange(event){
        this.comment = event.target.value;
    }
    get iscommentdisabled(){
        return !(this.Contribution_Fee_Original__c && this.Contribution_Fee__c && this.Contribution_Fee__c != this.Contribution_Fee_Original__c) ;
    }
    proceed(){
        this.showspinner = true;
        proceedwaiverequest({oppId:this.recordId,comment:this.comment,Contribution_Fee:this.Contribution_Fee__c,oliId:this.oliId})
        .then(r=>{
            this.showspinner = false;
            this.dispatchEvent(new CloseActionScreenEvent());
        })
        .catch(e=>{
            this.showspinner = false;
            console.log(e);
            this.showNotification('There is a error. Please contact your System Admin','','error');
        })
    }
    get isproceeddisabled(){
        return !this.comment;
    }
    showNotification(title,message,variant) {
        const evt = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(evt);
    }
}