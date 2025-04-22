import { LightningElement, track, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import retrieveRaisedAmount from '@salesforce/apex/InvestmentDetailsController.retrieveRaisedAmount';

const FIELDS = ['Product2.Offer_Close_Date__c', 'Product2.Maximum_Investment__c', 'Product2.Minimum_Investment__c'];
export default class InvestmentDetails extends LightningElement {

  //Offer_Close_Date__c is to be used for date calculation
  // Maximum_Investment__c
  // Minimum_Investment__c
  @api productId;
  @api fixedAmount;
  @api investUrl;
  @api minAmount = '1';
  @api targetAmount = '5.1';
  @track days = 0;
  @track hours = 0;
  @track minutes = 0;
  @track seconds = 0;
  @track currencyValue;
  @track redirectUrl;
  @track displayTimer = true;

  @track minimumValue = 0;
  @track maximumValue = 999;
  @track offerCloseDate = new Date("Jan 5, 2022 14:37:25").getTime();
  @track offerCloseDateTime;
  @track raisedAmount = '0';
  raisedtoDateMessage = 'Raised to date:';
  progressBarPercentage = 'width:100%;';
  targetConversionValue = '1';
  totalAmountRaised = '';

  overflowMessage = '';
  underflowMessage = '';

  setIntervalInstance;

  // Clean up of front end
  frontEndPercentage;

  frontEndPercentageClass = 'progress-text';

  // Date vars
  @track frontEndMonth;
  @track frontEndDay;
  @track frontEndYear;
  @track frontEndTime;
  noclosedate =false;
  @wire(getRecord, { recordId: '$productId', fields: FIELDS })
  retrievedProduct({ error, data }) {
    console.log(this.productId);
    if (data) {
      this.minimumValue = data.fields.Minimum_Investment__c.value;
      this.maximumValue = data.fields.Maximum_Investment__c.value;
      if(!data.fields.Offer_Close_Date__c.value)
      this.noclosedate = true;
      this.offerCloseDate = new Date(data.fields.Offer_Close_Date__c.value).getTime();
      this.offerCloseDateTime = data.fields.Offer_Close_Date__c.displayValue;
      let maxval = this.maximumValue.toFixed(2);
      let minval = this.minimumValue.toFixed(2);
      this.overflowMessage = `You have exceeded the maximum investment amount of $${maxval}. Please adjust your investment amount.`;
      this.underflowMessage = `This deal has a minimum investment amount of $${minval}. Please adjust your investment amount.`;
      this.productCallBack();/*underflowMessage*/

      var dateObj = new Date(this.offerCloseDate);

      this.frontEndDay = dateObj.toLocaleString('default', { day: 'numeric' });
      this.frontEndMonth = dateObj.toLocaleString('default', { month: 'short' });
      this.frontEndYear = dateObj.toLocaleString('default', { year: 'numeric' });
      this.frontEndTime = dateObj.toLocaleString('default', { hour: 'numeric', hour12: true,  minute: 'numeric' });

    } else if (error) {
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
  }


  productCallBack() {
    this.currencyValue = this.fixedAmount;
    let url = new URL(window.location.href);
    let utm_source = url.searchParams.get("utm_source");
    let utm_medium = url.searchParams.get("utm_medium");
    let utm_campaign = url.searchParams.get("utm_campaign");
    let utm_content = url.searchParams.get("utm_content");
    let utm_term = url.searchParams.get("utm_term");
    this.redirectUrl = `${this.investUrl}?Id=${this.productId}&amount=${this.currencyValue}&utm_source=${utm_source}&utm_medium=${utm_medium}&utm_campaign=${utm_campaign}&utm_content=${utm_content}&utm_term=${utm_term}`;
    this.setIntervalInstance = setInterval(_ => {
      let dueDate = this.offerCloseDate;
      // Get today's date and time
      var now = new Date().getTime().toLocaleString("en-US", { timeZone: "Australia/Sydney" }).replaceAll(',', '');

      // Find the distance between now and the count down date
      var distance = dueDate - now;

      // Time calculations for days, hours, minutes and seconds
      this.days = Math.floor(distance / (1000 * 60 * 60 * 24));
      this.hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
      this.minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
      this.seconds = Math.floor((distance % (1000 * 60)) / 1000);

      // If the count down is over clear Interval
      if (distance < 0) {
        this.clearInterval();
        const closedealevent = new CustomEvent("dealclosedevent");
        this.dispatchEvent(closedealevent);
  
      }
    }, 1000);

    retrieveRaisedAmount({ 'productId': this.productId })
      .then(result => {
        this.raisedAmount = result;
        let targetAmountVar = parseFloat(this.targetAmount) * 1000000;
        let percentageRaised = (this.raisedAmount / targetAmountVar) * 100;

        let percentageTotal = percentageRaised;

        if (percentageRaised > 100) {
          percentageRaised = 100;
        }

        this.progressBarPercentage = 'width:' + (percentageRaised) + '%';
        this.frontEndPercentage = Math.round(percentageTotal);

        if (this.frontEndPercentage < 50) {
          this.frontEndPercentageClass = 'progress-text less-than-50';
        } else {
          this.frontEndPercentageClass = 'progress-text more-than-50';
        }

        if (parseFloat(this.targetAmount) < 1) {
          this.targetConversionValue = (parseFloat(this.targetAmount) * 1000) + 'K';
        } else {
          this.targetConversionValue = (parseFloat(this.targetAmount)) + 'M';
        }

        if (this.raisedAmount < 1000000) {
          let quotientValue = (this.raisedAmount / 1000);
          if (Math.floor(quotientValue) >= 100) {
            this.totalAmountRaised = Math.floor(quotientValue) + 'K';
          } else if (Math.floor(quotientValue) >= 10) {
            this.totalAmountRaised = quotientValue.toFixed(1) + 'K';
          } else if (Math.floor(quotientValue) >= 1) {
            this.totalAmountRaised = quotientValue.toFixed(2) + 'K';
          } else {
            this.totalAmountRaised = quotientValue.toFixed(3) + 'K';
          }
        } else {
          let quotientValue = (this.raisedAmount / 1000000);
          if (Math.floor(quotientValue) >= 100) {
            this.totalAmountRaised = Math.floor(quotientValue) + 'M';
          } else if (Math.floor(quotientValue) >= 10) {
            this.totalAmountRaised = quotientValue.toFixed(1) + 'M';
          } else {
            this.totalAmountRaised = quotientValue.toFixed(2) + 'M';
          }
        }

        if (this.raisedAmount > targetAmountVar) {
          this.raisedtoDateMessage = 'Over subscribed:';
        }

      })
      .catch(error => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Something went wrong',
            message: 'Amount was not calculated',
            variant: 'error',
          }),
        );
      });
  }

  clearInterval() {
    this.displayTimer = false;
    this.template.querySelector('.vc-anchor').classList.add('vc-anchor-disabled');
    clearInterval(this.setIntervalInstance);

  }

  handleCurrencyUpdate(event) {
    this.currencyValue = event.target.value
    console.log(this.currencyValue + '-->Min:' + this.minimumValue + '--Max:' + this.maximumValue);
    this.template.querySelector('.vc-anchor').classList.remove('vc-anchor-disabled');
    if (!this.displayTimer || !this.currencyValue || (this.currencyValue  && this.currencyValue < this.minimumValue) || (this.maximumValue && this.currencyValue > this.maximumValue) ) {
      this.template.querySelector('.vc-anchor').classList.add('vc-anchor-disabled');
    }
    else {
      this.template.querySelector('.vc-anchor').classList.remove('vc-anchor-disabled');
    }
    let url = new URL(window.location.href);
    let utm_source = url.searchParams.get("utm_source");
    let utm_medium = url.searchParams.get("utm_medium");
    let utm_campaign = url.searchParams.get("utm_campaign");
    let utm_content = url.searchParams.get("utm_content");
    let utm_term = url.searchParams.get("utm_term");
    this.redirectUrl = `${this.investUrl}?Id=${this.productId}&amount=${this.currencyValue}&utm_source=${utm_source}&utm_medium=${utm_medium}&utm_campaign=${utm_campaign}&utm_content=${utm_content}&utm_term=${utm_term}`;
  }
  get displayTimer_invest(){
    return (this.displayTimer && !this.noclosedate) || this.noclosedate;
  }
}