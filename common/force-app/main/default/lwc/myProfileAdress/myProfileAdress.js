import { LightningElement,api } from 'lwc';
import getMailingAdress from '@salesforce/apex/MyProfileController.getMailingAdress';
import updateAccount from '@salesforce/apex/MyProfileController.updateAccount';
export default class MyProfileAdress extends LightningElement {
    @api recordId;
    mailadd ={};
    showModal = false;
    showspinner = false;
    connectedCallback(){
        this.getmailadd();
    }
    getmailadd(){
        getMailingAdress({userId:this.recordId})
        .then(res =>{
            this.mailadd = res;
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
            dataMap['Id'] = this.mailadd.accId ;
            dataMap['PersonMailingStreet'] = inputareaelements.street ;
            dataMap['PersonMailingCity'] = inputareaelements.city ;
            dataMap['PersonMailingCountry'] = inputareaelements.country ;
            dataMap['PersonMailingState'] = inputareaelements.state ;
            dataMap['PersonMailingPostalCode'] = inputareaelements.postcode ;
            this.showspinner = true;
            updateAccount({dataMap})
            .then(res =>{
                console.log(res);
                this.hidemodal();
                this.getmailadd();
                this.showspinner = false;
            })
            .catch(e => {
                console.log(e);
                this.showspinner = false;
            });
        }
    }
}