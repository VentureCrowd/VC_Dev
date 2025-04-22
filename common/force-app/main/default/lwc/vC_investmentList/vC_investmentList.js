import { LightningElement,api } from 'lwc';
import investmentsRecords from "@salesforce/apex/ProductController.investmentsRecords";

export default class VC_investmentList extends LightningElement {
    @api investmentTile;
    query;
    investmentList;
    showcomponet = false;
    connectedCallback(){
        if(this.investmentTile == 'Current Investments - Personal'){
            this.query = " WHERE Stage__c = 'Closed Won' AND Is_Person_Account__c = TRUE AND Process_Fund_Disbursement__c = FALSE ";
        }else if(this.investmentTile == 'Current Investments - Entities'){
            this.query = " WHERE Stage__c = 'Closed Won' AND Is_Person_Account__c = FALSE AND Process_Fund_Disbursement__c = FALSE ";
        }else if(this.investmentTile == 'Pending Investments'){
            this.query = " WHERE (Stage__c = 'Application Received'  OR Stage__c = 'Receipt Issued' )AND Process_Fund_Disbursement__c = FALSE ";
        }else if(this.investmentTile == 'Previous Investments'){
            this.query = " WHERE Stage__c = 'Closed Won' AND Process_Fund_Disbursement__c = TRUE ";
        }
        investmentsRecords({filter:this.query,investmentTile:this.investmentTile})
        .then(res =>{
            this.investmentList = res;
            this.showcomponet = res?.length > 0; 
            console.log(res,'GSAC');
        })
        .catch(err => console.log(err,'GSAC'));
    }
}