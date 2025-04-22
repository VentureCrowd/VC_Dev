import { LightningElement,api, wire  } from 'lwc';
import {NavigationMixin,CurrentPageReference } from "lightning/navigation";


import FORM_FACTOR from '@salesforce/client/formFactor';

export default class BackButton extends NavigationMixin(LightningElement) {

    currentPageReference = null; 
    urlStateParameters = null;
    type = '';
    states = null;

    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
       if (currentPageReference) {
          console.log(currentPageReference);
          console.log(currentPageReference.attributes.name);
          this.recordId = currentPageReference.attributes.recordId || null;
          this.currentPageReference = currentPageReference.attributes;
          this.states = currentPageReference.state;
          this.type = currentPageReference.type;
          console.log("console.log(this.currentPageReference);");
          console.log(this.currentPageReference);
       }
    }

    @api recordId;


    backMore1(){
        console.log(this.currentPageReference);
        console.log(this.type);
        console.log(this.states);
        if(this.type == 'standard__recordPage'){
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: 'Portfolio__c'
                }
            });
            
        }
        if(this.type == 'comm__namedPage'){
                // history.back();
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.states.id,
                        objectApiName: 'Investment__c',
                        actionName: 'view'
                    },
                });
        }

    }
    get isDesktop() {
        if(FORM_FACTOR === 'Large'){
            return FORM_FACTOR === 'Large';
        }else if   (FORM_FACTOR === 'Medium'){
            return FORM_FACTOR === 'Medium';
        }else if   (FORM_FACTOR === 'Small'){
        }
    }
}