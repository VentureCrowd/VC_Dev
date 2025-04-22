import { LightningElement,api } from 'lwc';
import {
    FlowAttributeChangeEvent,
    FlowNavigationNextEvent,
    FlowNavigationBackEvent,
    FlowNavigationFinishEvent 
} from 'lightning/flowSupport';
import createLogRecords from '@salesforce/apex/redeemProcessController.transactionLogs';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class RedeemProcess extends LightningElement {
    disableamount = false;
    disableQuantity = true;
    @api amount;
    @api quantity;
    @api OriginalInvestedQuantity;
    @api  OriginalInvestedAmount;
    @api totalPrice;
    @api lineItemquantity;
    @api AppliedDate = new Date().toISOString();
    @api opportunityId;
    @api oppProdId;
    @api itemUnitPrice;
    @api itemListPrice;
    isValid = true;
    @api availableActions = [];
    isLoaded = true;
    amountError=false;
    qtyError = false;
    amountErrorMessage;
    qtyErrorMessage;
    calculatedAmount;
    calculatedQuantity;

    connectedCallback() {
        // let calculatedAmount = this.itemListPrice * this.quantity;
        // this.calculatedAmount = parseFloat(calculatedAmount).toFixed(2);
        this.calculatedAmount = this.amount;
        this.calculatedQuantity = this.quantity;
    }

    handchange(event){
        if(event.target.checked ==true){
            this.disableamount = true;
            this.disableQuantity = false;
        }else{
            this.disableamount = false;
            this.disableQuantity = true;
        }

        this.calculatedAmount = this.amount;
        this.calculatedQuantity = this.quantity;
        this.isValid = this.validateRedeemedValues(event);
    }


    handleAmtChnge(event){

        if (this.disableamount) return;
        this.isLoaded = false;
        this.calculatedAmount = event.target.value;
        let calQuantity = this.calculatedAmount / this.itemListPrice;
        this.calculatedQuantity =  parseFloat(calQuantity).toFixed(4);
        // this.calculatedQuantity = Math.round(calQuantity);

        
        // this.quantity =  this.amount / this.itemUnitPrice;
        this.isValid = this.validateRedeemedValues(event);
        this.isLoaded = true;
    }

    handleQtyChnge(event){
        if (this.disableQuantity) return;
        this.isLoaded = false;
        this.calculatedQuantity = event.target.value;
        let calAmount = this.calculatedQuantity  * this.itemListPrice;
        this.calculatedAmount = parseFloat(calAmount).toFixed(2);
        // this.amount = this.quantity  * this.itemUnitPrice;
        this.isValid = this.validateRedeemedValues(event);
        this.isLoaded = true;
    }
    

    handledateChnge(event){
        this.AppliedDate = event.target.value;
    }

    validateRedeemedValues(event){
        let amountCmp = this.template.querySelector(".amountFld");
        let qtyCmp = this.template.querySelector(".qtyFld");
        let validate = true;
        if(this.amount  < this.calculatedAmount){
            this.amountError = true;
            validate = false;
            this.amountErrorMessage = 'Redeemed Amount should not be greater than actual amount';
        }else{
            this.amountError = false;
        }

        if(this.calculatedQuantity > this.lineItemquantity){
            this.qtyError = true;
            validate = false;
            this.qtyErrorMessage= 'Redeemed Quanity should not be greater than actual Quantity';
        }else{
            this.qtyError = false;
        }
        return validate;
    }

    handleRedeem(event){
        if(this.totalPrice>0){
            if(this.isValid){
                this.isLoaded = false;
                createLogRecords({ opportunityId: this.opportunityId,opportunityProdId:this.oppProdId,amount: parseFloat(this.calculatedAmount).toFixed(2) ,quantity: parseFloat(this.calculatedQuantity).toFixed(2) ,appliedDate:this.AppliedDate })
                    .then(result => {
                        this.isLoaded = true;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Processing Success!',
                                message: 'Logs created',
                                variant: 'Success'                        }),
                        );
                        if (this.availableActions.find((action) => action === "FINISH")) {
                            const navigateNextEvent = new FlowNavigationFinishEvent();
                            this.dispatchEvent(navigateNextEvent);
                        }

                        
                    })
                    .catch(error => {
                        this.isLoaded = true;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Processing Error',
                                message: error.body.message,
                                variant: 'error',
                                mode:'sticky'
                            }),
                        );
                    })
                }
        }else{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Processing Error',
                    message: 'No Valid amount to redeem',
                    variant: 'error',
                    mode:'sticky'
                }),
            );
        }
    }

    previousScreen(event){
        if (this.availableActions.find((action) => action === "BACK")) {
            const navigateBackEvent = new FlowNavigationBackEvent();
            this.dispatchEvent(navigateBackEvent);
          }
    }


}