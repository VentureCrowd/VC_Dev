import { api, LightningElement } from "lwc";
//import getProductDetails from "@salesforce/apex/InvestmentProductController.getProductDetails";
import getSelectedProductDetails from "@salesforce/apex/InvestmentProductController.getSelectedProductDetails";
import isMembershipPresent from "@salesforce/apex/InvestmentProductController.isMembershipPresent";
import performActionOnOpportunity from "@salesforce/apex/InvestmentProductController.performActionOnOpportunity";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class InvestmentProductClone extends LightningElement {
    @api recordId;
    selectedOption = 'Quantity';
    amount = '';
    quantity = '';
    disableamount = true;
    disablequantity= false;
    salePrice = 0;
    InvestorContributionFeeFinal = 0;
    showDonationAmountField = false;
    donationAmount = 100;
    includContributionFee = false;
    selectedProductValue ='';
    finQuantity ;
    finOrdrValue;
    totalContributionFee;
    finalDonation;
    finalTotalPayment;
    skipFee;
    initilacontributionfee ;
    showModal = false;
    showconsent = false;
    showspinner= false;
    approvalcomment;
    ////////////////////////////////////////////  



    get options() {
    return [
        { label: "Yes", value: "Yes" },
        { label: "No", value: "No" }
    ];
    }
    connectedCallback() {
        let params = new URLSearchParams(document.location.search.substring(1));
        this.recordId = params.get("c__recordId")? params.get("c__recordId"): this.recordId;
        this.checkMembership();
    }
    checkMembership() {
        isMembershipPresent({oppId: this.recordId})
        .then((result) => {
            this.skipFee = result;
        })
        .catch((error) => {
            this.error = error;
        });
    }
    handleProductChange(event) {
        this.quantity = 0;
        this.selectedProductId = event.detail.selectedRecordId;
        getSelectedProductDetails({productId: this.selectedProductId})
        .then((result) => {
            if (result) {
                this.initilacontributionfee =  result[0].Investor_Contribution_Fee__c ? result[0].Investor_Contribution_Fee__c : 0;
                this.InvestorContributionFeeFinal = this.skipFee ? 0 : this.initilacontributionfee;
                // this.InvestorContributionFee = result[0].Investor_Contribution_Fee__c;
                //this.totalContributionFee = (this.InvestorContributionFee * Number(this.amount))/100;
                this.salePrice = result[0].PricebookEntries[0].UnitPrice ? result[0].PricebookEntries[0].UnitPrice : 0;
            }
        })
        .catch((error) => {
            this.showLoading = false;
            this.error = error;
            this.recordsList = undefined;
        });
    }
    handchange(event){
        switch (event.target.dataset.id) {
            case "toggle":
                event.target.checked ? (this.selectedOption = 'Value', this.disableamount=false, this.quantity ='',this.disablequantity = true) : (this.selectedOption = 'Quantity', this.disableamount=true,this.amount='', this.disablequantity = false);
            break;
            case "invAmnt":
                this.amount = event.target.value;
            break;
            case "invQty":
                this.quantity = event.target.value;
            break;
            case "salprice":
                this.salePrice = event.target.value;
            break;
            case "InvesterFee":
                this.InvestorContributionFeeFinal = event.target.value;
            break;
            case "toggletrust":
                this.showDonationAmountField = event.target.checked;
            break;
            case "donationAmount":
                this.donationAmount = event.target.value;
            break;
            case "contributionfee":
                this.includContributionFee = event.target.checked;
            break;
            case "approvalcomment":
                this.approvalcomment = event.target.value;
            break;
        }
        this.calculateFinalAmount();
    }
    get showContFee(){
        return this.selectedOption == 'Value';
    }    
    handleDialogClose() {
        window.location.assign(`${window.location.origin}/${this.recordId}`);
        this.handleClose();
    }
    handleClose() {
        window.close();
    }
    handleInvestNow() {
        this.showspinner = true;
        if(this.totalContributionFee != (this.initilacontributionfee * parseFloat(this.finOrdrValue) / 100).toFixed(2) && !this.showconsent){
            this.showModal = true;
            this.showspinner = false;
            return;
        }else{
            performActionOnOpportunity({
                quantity: this.finQuantity,
                salePrice: this.salePrice,
                InvestorContributionFee: this.totalContributionFee,
                selectedProductId: this.selectedProductId,
                recordId: this.recordId,
                totalAmount: this.finOrdrValue,
                donationAmount: this.finalDonation,
                approvalcomment : this.approvalcomment,
                InvestorContributionFeeOriginal : (this.initilacontributionfee * parseFloat(this.finOrdrValue) / 100).toFixed(2)
            })
            .then((result) => {
                this.showspinner = false;
                if(result){
                    alert(result);
                    this.showNotification(result,'','error');
                }else{
                    window.location.assign(`${window.location.origin}/${this.recordId}`);
                    this.handleClose();
                }
            })
            .catch((error) => {
                this.showspinner = false;
                this.error = error;
                this.recordsList = undefined;
                console.error(JSON.stringify(error));
                
            });
        }
    }
    calculateFinalAmount(){
        if(this.selectedOption == 'Quantity'){
            this.finQuantity = parseFloat(this.quantity);
        }else if(this.selectedOption == 'Value'){
            if(this.includContributionFee){
                this.finQuantity = Math.floor(this.amount/(parseFloat(this.salePrice)*((100+parseFloat(this.InvestorContributionFeeFinal))/100)));
            }else{
                this.finQuantity = Math.floor(this.amount/this.salePrice);
            }
        }
        this.finOrdrValue = this.finQuantity * this.salePrice;
        this.totalContributionFee = this.finOrdrValue * this.InvestorContributionFeeFinal / 100;
        this.finalDonation = this.showDonationAmountField ? parseFloat(this.donationAmount) : 0;
        this.finalTotalPayment = parseFloat(this.finOrdrValue) + parseFloat(this.totalContributionFee) + parseFloat(this.finalDonation);
        (!this.finQuantity && this.finQuantity !== 0) ? this.finQuantity = 0 : this.finQuantity = this.finQuantity.toFixed(2);
        (!this.finOrdrValue && this.finOrdrValue !== 0) ? this.finOrdrValue = 0 : this.finOrdrValue = this.finOrdrValue.toFixed(2);
        (!this.totalContributionFee && this.totalContributionFee !== 0) ? this.totalContributionFee = 0 : this.totalContributionFee = this.totalContributionFee.toFixed(2);
        (!this.finalDonation && this.finalDonation !== 0) ? this.finalDonation = 0 : this.finalDonation = this.finalDonation.toFixed(2);
        (!this.finalTotalPayment && this.finalTotalPayment !== 0) ? this.finalTotalPayment = 0 : this.finalTotalPayment = this.finalTotalPayment.toFixed(2);
    }
    showNotification(title,message,variant) {
        const evt = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(evt);
    }
    closeModal(){
        this.showModal = false;
        this.showconsent = true;
        this.handleInvestNow();
    }
    get okdisabled(){
        return !this.approvalcomment;
    }
}