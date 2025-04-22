import { LightningElement,track,api,wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const FIELDS = ['Product2.Offer_Close_Date__c','Product2.Maximum_Investment__c','Product2.Minimum_Investment__c'];

export default class DealpageSticky extends LightningElement {
    @track currencyValue;
    @track redirectUrl;
    @api productId;
    @api fixedAmount;
    @api scrollNumber;
    @api investUrl;
    @api heading1Text;
    @api heading1Id;
    @api heading2Text;
    @api heading2Id;
    @api heading3Text;
    @api heading3Id;
    @api heading4Text;
    @api heading4Id;
    @api heading5Text;
    @api heading5Id;
    @track minimumValue = 0;
    @track maximumValue = 999;
    overflowMessage = '';
    underflowMessage = '';

    // Prevent renderedCallback from firing multiple times. Garbage system and probably incorrect.
    @track hasRendered = true;
 
    setIntervalInstance;
 
    @wire(getRecord, { recordId: '$productId', fields: FIELDS })
     retrievedProduct({error, data}) {
       if (data) {
            this.minimumValue = data.fields.Minimum_Investment__c.value;
            this.maximumValue = data.fields.Maximum_Investment__c.value;
            this.overflowMessage = `You have exceeded the maximum investment amount of $${this.maximumValue}. Please adjust your investment amount.`;
            this.underflowMessage = `This deal has a minimum investment amount of $${this.minimumValue}. Please adjust your investment amount.`;
            
            let offerCloseDate = new Date(data.fields.Offer_Close_Date__c.value).getTime();
            // Get today's date and time
            var now = new Date().getTime();
                
            // Find the distance between now and the count down date
            var distance = offerCloseDate - now;
            if (distance < 0) {
            this.template.querySelector('.vc-anchor').classList.add('vc-anchor-disabled');
            }
            this.handleCurrencyUpdate();
        }else if (error) {     
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading contact',
                    message,
                    variant: 'error',
                }),
            );
        }
        this.stickyCallBack();
     }

     connectedCallback() {
        this.currencyValue = this.fixedAmount;
        // this.handleCurrencyUpdate();
     }


    // renderedCallback() {
    //     try {
    //         window.onscroll = () => {
    //             let stickysection = this.template.querySelector('.myStickyHeader');
    //             let sticky2 = stickysection.offsetTop;
    //             console.log('stickysection  => ' + stickysection);
    //             console.log('stickysection id  => ' + stickysection.id);
    //             console.log('sticky2  => ' + sticky2);
    //             console.log('window.pageYOffset  => ' + window.pageYOffset);
    //             // console.log('window.pageYOffset  => ' + window.querySelector('.myStickyHeader').pageYOffset);
                
    //             if (window.pageYOffset > sticky2) {
    //                 stickysection.classList.add("sticky2");
    //             } else {
    //                 stickysection.classList.remove("sticky2");
    //             }
    //         }
    //     } catch (error) {
    //         console.log('error =>', error);
    //     }
    // }

    renderedCallback() {
        if (this.hasRendered) {
            var indexLink = this.template.querySelector('.index-link');
            var closeButton = this.template.querySelector('.icon-close');

            indexLink.addEventListener('click', (e) => {
                e.preventDefault();
                this.template.querySelector('.page-index-list').classList.remove('d-none');
                this.template.querySelector('.page-index-list').classList.add('d-block');

            });

            closeButton.addEventListener('click', (e) => {
                e.preventDefault();
                this.template.querySelector('.page-index-list').classList.remove('d-block');
                this.template.querySelector('.page-index-list').classList.add('d-none');
            });
            this.hasRendered = false;
        }

    }

    stickyCallBack() {

        this.redirectUrl = `${this.investUrl}?Id=${this.productId}&amount=${this.currencyValue}`;
        window.addEventListener('scroll', _ => {
            if (window.pageYOffset > parseInt(this.scrollNumber)) {
                this.addClasss();
            } else {
                this.removeClass();

            }
        });
    }

    addClasss() {
        this.template.querySelector('.myStickyHeader').classList.add('vc-sticky');
    }

    removeClass() {
        this.template.querySelector('.myStickyHeader').classList.remove('vc-sticky');
    }

    handleCurrencyUpdate(event) {
        if(event)
        this.currencyValue = event.target.value
        console.log(this.currencyValue+'-->Min:'+this.minimumValue+'--Max:'+this.maximumValue);
        if(this.currencyValue < this.minimumValue ||  this.currencyValue > this.maximumValue){
          this.template.querySelector('.vc-anchor').classList.add('vc-anchor-disabled');
        }
        else{
          this.template.querySelector('.vc-anchor').classList.remove('vc-anchor-disabled');
        }
        this.redirectUrl = `${this.investUrl}?Id=${this.productId}&amount=${this.currencyValue}`;
    }
}