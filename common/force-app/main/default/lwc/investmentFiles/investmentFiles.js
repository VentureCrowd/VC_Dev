import { LightningElement,api, wire } from 'lwc';
import fetchFiles from '@salesforce/apex/ProductController.fetchFiles';
import {NavigationMixin,CurrentPageReference } from "lightning/navigation";

import FORM_FACTOR from '@salesforce/client/formFactor';
import Id from '@salesforce/user/Id';

export default class InvestmentFiles extends NavigationMixin(LightningElement) {
    userId=Id;

    data;
    error;
    currentPageReference = null; 
    urlStateParameters = null;


    investDocs = [];
    investDocLength = 0;
    investUpdateLength = 0;
    financeStatementDocLength = 0;
    investUpdateDocs = [];
    financeStatementDocs = [];
    previewsrc;
    showPreview = false;
    showFiles = false;
    showViewMore = false;
    singlepage = false;
    @api recordId;
    columns = [ 
        { label: 'File', fieldName: 'fileUrl' , type: 'url', typeAttributes: { label: { fieldName: 'fileName' },target: '_blank'},target: '_blank'},
        { label: 'Created Date', fieldName: 'createdDate'}
    ];
    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
       if (currentPageReference) {
          console.log(currentPageReference);
          this.recordId = currentPageReference.attributes.recordId || null;
          this.currentPageReference = currentPageReference.attributes;
          let states = currentPageReference.state;
          let type = currentPageReference.type;
       }
    }
    connectedCallback(){



        if(!this.recordId){
            let params = new URLSearchParams(window.location.search);
            this.singlepage = true;
            this.recordId = params.get("id"); 
        }
        fetchFiles({recordId:this.recordId})
        .then(res =>{
            this.investDocs = res['Investment Documents'];
            this.investUpdateDocs = res['Investment Updates and Actions'];
            this.financeStatementDocs = res['Financial Statements and Distributions'];
            this.investDocLength = this.investDocs.length;
            this.investUpdateLength = this.investUpdateDocs.length;
            this.financeStatementDocLength = this.financeStatementDocs.length;
            this.showFiles = this.investDocs.length || this.investUpdateDocs.length || this.financeStatementDocs.length;
            if((this.investDocs.length > 3 || this.investUpdateDocs.length > 3 || this.financeStatementDocs.length > 3 )&& !this.singlepage){
                this.investDocs = this.investDocs.slice(0,3);
                this.investUpdateDocs = this.investUpdateDocs.slice(0,3);
                this.financeStatementDocs = this.financeStatementDocs.slice(0,3);
                this.showViewMore = true;
            }
        })
        .catch(err => console.log(err))

    }
    get showinvestDocs(){
        return this.investDocs?.length;
    }
    get showinvestUpdateDocs(){
        return this.investUpdateDocs?.length;
    }
    get showfinanceStatementDocs(){
        return this.financeStatementDocs?.length;
    }
    viewMore(){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name : 'Files__c'
            },
            state: {
                id: this.recordId
            }
        });
    }
    
    /* VEN-293 --  added code for mobile factor  */
    get isDesktop() {
        if(FORM_FACTOR === 'Large'){
            return FORM_FACTOR === 'Large';
        }else if   (FORM_FACTOR === 'Medium'){
            return FORM_FACTOR === 'Medium';
        }else if   (FORM_FACTOR === 'Small'){
        }
        
       
    }

    backMore(){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Investment__c',
                actionName: 'view'
            },
        });
    }
    backMore1(){
        
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Portfolio__c'
            }
        });

    }
}