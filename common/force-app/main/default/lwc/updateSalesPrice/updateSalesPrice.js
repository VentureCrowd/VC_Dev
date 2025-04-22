import { LightningElement,api } from 'lwc';
import getProddetails from '@salesforce/apex/interestDividendDisbursementCntrl.getProddetails';
import updatePriceBookEntry from '@salesforce/apex/interestDividendDisbursementCntrl.updatePriceBookEntry';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class UpdateSalesPrice extends LightningElement {
    prodName;
    currentSalesPrice;
    newSP;
    renewSP;
    @api recordId;
    connectedCallback(){
        getProddetails({ProdId:this.recordId})
        .then(r=>{
            this.prodName = r.prodName;
            this.currentSalesPrice = r.currentprice;
        })
        .catch(e=>console.log(e))
    }
    handleCancel(event) {
        this.dispatchEvent(new CustomEvent('closecmp'));
    }
    databinder(event){
        switch (event.target.dataset.id){
            case 'newSP':
                this.newSP = event.target.value;
            break;
            case 'renewSP':
                this.renewSP = event.target.value;
            break;
        }
    }
    get savebtndisabled(){
        return !(this.newSP && this.renewSP && this.newSP != this.currentSalesPrice && this.newSP == this.renewSP);
    }
    saverecord(){
        updatePriceBookEntry({ProdId:this.recordId,newListprice:this.newSP})
        .then(r=>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: '',
                    message: 'List Price has been updated successfully. ',
                    variant: 'success'
                })
            );
            this.dispatchEvent(new CustomEvent('closecmp'));
        })
        .catch(e=>{
            console.log(e);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: '',
                    message: 'There has been a unexpected error. Please contact our support Team for more help.',
                    variant: 'error',mode: 'sticky'
                })
            );
        })
    }
}