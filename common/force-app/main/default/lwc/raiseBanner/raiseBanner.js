import { LightningElement,api, track } from 'lwc';
import apex__getProductDetails from '@salesforce/apex/tempProductController.getProductDetails';
import { NavigationMixin } from 'lightning/navigation';

export default class RaiseBanner extends NavigationMixin(LightningElement) {

    @api productId;
    @api logoUrl;
    @api banner;
    @api heading;
    @api subheading;
    @api minInvestAmount;
    @track productDetails = {}
    @track closeDate;
    @track dealLive;
    @track _logoUrl;
    @track _productId;
    @track values = { minimumTarget: 0, RaisedAmount: 0 };
    @track queryParameters;
    @track investmentBoxValue;


    async getProductDetails(productId){
        try {
            let raiseProduct = await apex__getProductDetails({productId : productId})
            let parsedData = JSON.parse(raiseProduct);
            let _closeDate = parsedData.offerCloseDate.split('T')[0];
            this._productId = parsedData.Id;
            this._logoUrl = this.logoUrl;
            this.closeDate = _closeDate;
            this.investmentBoxValue = '$' + this.minInvestAmount;
            this.values = { minimumTarget: parseInt(parsedData.targetAmt), RaisedAmount: parseInt(parsedData.amountRaised)}

            return parsedData;
        } catch(error){
            console.error('Error fetching data for raiseId', error)
        }
    }

    handleInvestClick() {
        const amountInput = this.template.querySelector('.amount-input');
        if (amountInput) {
            // Remove the dollar sign
            let amount = amountInput.value.replace('$', ''); 
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: 'Invest_Now__c' 
                },
                state: {
                    Id: this.productId,
                    amount: amount,
                    utm_source: this.queryParameters.utm_source ? this.queryParameters.utm_source : 'null',
                    utm_medium: this.queryParameters.utm_medium ? this.queryParameters.utm_medium : 'null',
                    utm_campaign: this.queryParameters.utm_campaign ? this.queryParameters.utm_campaign : 'null',
                    utm_content: this.queryParameters.utm_content ? this.queryParameters.utm_content : 'null',
                    utm_term: this.queryParameters.utm_term ? this.queryParameters.utm_term : 'null',
                },
            });
        } else {
            this.showToast('Error', 'Amount input element not found', 'error');
        }
    }

    connectedCallback() {
        this.getQueryParameters().then((result) => {
            this.queryParameters = {...result};
        })

        this._productId = this.productId
        this.getProductDetails(this.productId).then((result) => {
            this.productDetails = result;
        }).catch((error) => {
            console.error(error);
        });
    }

    validateInput(event) {
        const input = event.target;
        let value = input.value;

        // Remove non-numeric characters except the first '$'
        value = value.replace(/[^0-9.]/g, '');

        // Ensure the value starts with a dollar sign
        if (!value.startsWith('$')) {
            value = '$' + value;
        }
        
        input.value = value;
    }

    get bannerStyle() {
        return `background-image: url(${this.banner});`;
    }

    handleDealLiveChange(event) {
        this.dealLive = event.detail.dealLive;
    }

    getQueryParameters() {
        return new Promise((resolve,reject)=>{
            var params = {};
            var search = location.search.substring(1);

            if (search) {
                params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
                    return key === "" ? value : decodeURIComponent(value)
                });
            }
            resolve(params);
        })
    }
    
}