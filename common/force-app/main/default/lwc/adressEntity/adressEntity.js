import { LightningElement,api } from 'lwc';
import getBillingAdress from '@salesforce/apex/MyProfileController.getBillingAdress';
import updateAccount from '@salesforce/apex/MyProfileController.updateAccount';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
export default class AdressEntity extends LightningElement {
    @api recordId;
    adress ={};
    showModal = false;
    showspinner = false;
    connectedCallback(){
        this.getBillAdd();
    }
    getBillAdd(){
        getBillingAdress({accId:this.recordId})
        .then(res =>{
            this.adress = res;
        })
        .catch(e => console.log(e))
    }

    handleedit(){
        this.displaymodal();
    }
    displaymodal(){
        this.showModal = true;
    }
    hidemodal(){
        this.showModal = false;
    }
    handlesave(){
        let inputareaelements  = this.template.querySelector('c-loqate-address');
        if(inputareaelements.checkValidity()){
            let dataMap = {};
            dataMap['Id'] = this.recordId ;
            dataMap['BillingStreet'] = inputareaelements.street ;
            dataMap['BillingCity'] = inputareaelements.city ;
            dataMap['BillingCountry'] = inputareaelements.country ;
            dataMap['BillingState'] = inputareaelements.state ;
            dataMap['BillingPostalCode'] = inputareaelements.postcode ;
            this.showspinner = true;
            updateAccount({dataMap})
            .then(res =>{
                console.log(res);
                this.hidemodal();
                this.getBillAdd();
                this.showspinner = false;
                this.refreshAccPage();
            })
            .catch(e => {
                console.log(e);
                this.showspinner = false;
            });
        }
    }
    refreshAccPage(){
		getRecordNotifyChange([{recordId: this.recordId}]);
	}
}