import { LightningElement,api } from 'lwc';
import getMatchingLead from "@salesforce/apex/OpportunityTriggerHandler.getMatchingLead";
import { NavigationMixin } from 'lightning/navigation';
export default class DuplicateLeadForOpp extends NavigationMixin(LightningElement) {
    @api recordId;
    @api backgroundimageurl;
    showComponent = false;
    numberOFleads = 0;
    leads = [];
    connectedCallback(){
        getMatchingLead({OppId:this.recordId})
        .then(res =>{
            this.leads = res;
            this.showComponent = this.leads?.length;
            this.numberOFleads = this.leads?.length;
        })
        .catch(e=>{
            console.log(e);
        })
    }
    navigatetolead(event){
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.dataset.id,
                actionName: 'view',
            },
        }).then((url) => {
            window.open(url);
        });
    }
    get title(){
       return  `Matching Lead Found (${this.numberOFleads})`;
    }
}