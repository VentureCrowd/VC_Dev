/* eslint-disable @lwc/lwc/no-api-reassignments */
import { api, track, LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import apex__verifyrecaptchaToken from '@salesforce/apex/ReCaptchaAuraController.verifyrecaptchaToken';
import apex__createLead from'@salesforce/apex/LeadControllerNew.createLead';
import apex__getEoiDetails from '@salesforce/apex/EOI_Controller.getEOIByID';
import {phoneNumberoptns} from './utilities.js';
//import apex__getLiveRaiseFromEOI from '@salesforce/apex/EOI_Controller.getLiveRaiseFromEOI';

/**
    ** Add this to the experience builder head markup to capture this event  
    * The following listener is to listen for gtagEvents from LWC's Leads form and lodge them

        document.addEventListener('lwc_onleadgtaevent', (e) => {
            const currentURL = window.location.href;

            // Trigger Google Analytics Event
            window.gtag('event', 'EOI_Submission', {
                event_category: 'EOI_form',
                event_label: currentURL,  // Track the full URL for attribution
                email: e.detail.formDetails.email,
                first_name: e.detail.formDetails.firstName,
                last_name: e.detail.formDetails.lastName,
                phone: e.detail.formDetails.mobileNumber,
                form_name: 'EOI_form_' + e.detail.formDetails.eoiName
            });
        });
*/



export default class EoiLeadForm extends NavigationMixin(LightningElement) {
    @api formData = {
        'ausResident' : 'true',
        'mobileCode' : '61-AU',
        'investorType' : 'Wholesale',
    }

    @track _eoiId;

    @api
    get eoiId(){
        return this._eoiId;
    }

    set eoiId(v){
        this._eoiId = v;

        if(this._eoiId){
            apex__getEoiDetails({eoiId : this._eoiId})
            .then((data)=>{
                this.eoiData = data

                if(this.eoiData?.minimumInvestmentAmt){
                    this.minInvestAmt = this.eoiData.minimumInvestmentAmt
                }
            })
            .catch((e)=>{console.error(e)})
        }
    }

    @api eoiName;
    @track eoiData;

    @track phoneNumberCodes;
    @track isSandbox;
    @track hasLiveRaise = false;
    @track isLoading;
    @track showExclusiveAccess = false;
    @track minInvestAmt;

    
    constructor() {
        super();
        window.addEventListener('message', this.listenForMessage);
    }

    investorOptions = [
        {value:'Wholesale',label:'Wholesale'},
        {value:'Retail',label:'Retail'},

    ]
    ausResidentOptions = [ 
        { id: 1, value: 'true', label: 'Yes', checked: true },
        { id: 2, value: 'false', label: 'No', checked: false },
    ];


    isSandboxEnvironment(){
        const hostname = window.location.hostname.toLowerCase();
        // Common sandbox hostname patterns include 'sandbox', 'cs', or specific domain variations
        return hostname.includes('sandbox') || hostname.startsWith('cs');
    }

    listenForMessage(message) {
        let data = JSON.stringify(message.data);
        if (data && data.includes('****CaptchToken****')) {
            let token = message.data.split('****CaptchToken****')[0];
            apex__verifyrecaptchaToken({ token })
                .then((r) => {
                    if(this.isSandbox){
                        this.isCaptchValidated = true;
                    }else{
                        this.isCaptchValidated = r;
                    }
                })
                .catch((e) => {
                    console.error(e);
                });
        }
    }

    splitMobileCode(value){
        return value.split('-')[0].replace('+', '').trim();
    }

    handleSubmit(event){
        // set loading
        this.isLoading = true;

        //scroll to loading container
        this.scrollToDiv('form-container');

        // extract mobile code from unique identifier
        const eventData = event.detail;

        //populate form data with coreForm event
        this.formData = {...eventData.formData};
        let mobileNumber = this.formData.mobileNumber.replace(/^0+/, '');
        // format mobile number field
        let formattedNumber= '+' + this.splitMobileCode(this.formData.mobileCode) + mobileNumber;
        this.formData.mobileCodeFormatted = formattedNumber
        
        // wholesale check
        this.formData.isWholesale = this.formData.investorType === 'Wholesale' ? 'Yes' : 'No';

        // add lead sources
        this.formData.webSource = `${this.eoiName ? this.eoiName.replace(' ', '-') : this.eoiId}-EOI`;
        this.formData.source = 'Organic';

        this.formData.emailOptIn = true;

        // populate related EOI field
        this.formData.relatedEOI = this.eoiId;
        apex__createLead({fieldsToAdd : this.formData})
        .then((returnValue)=>{
            this.refreshFormData();
            this.handleGTAGEvent({...eventData.formData, eoiName: this.eoiName, formattedNumber: formattedNumber });
            this.handleNavigation();
            this.openSuccessModal();
        })
        .catch((error)=>{
            console.error('Server error: ' + error);
        })
        .finally(()=>{           
            this.isLoading = false;
        })
    }

    handleNavigation(){
        if(this.hasLiveRaise){
            // open the modal for the PPG
            this.template.querySelector('c-core-modal').openModal();
        }
    }

    refreshFormData(){
        this.formData = {
            'ausResident' : 'true',
            'mobileCode' : '61-AU',
            'investorType' : 'Wholesale',
        };
    }

    handleFormChange(e){
        const key = e.detail.name;
        const value = e.detail.value;

        this.formData[key] = value;
    }


    connectedCallback(){
        this.phoneNumberCodes = phoneNumberoptns;
        this.isSandbox = this.isSandboxEnvironment();



        // Capture UTM parameters from the URL
        const urlParams = new URLSearchParams(window.location.search);
        this.formData.utm_source = urlParams.get('utm_source') || '';
        this.formData.utm_medium = urlParams.get('utm_medium') || '';
        this.formData.utm_campaign = urlParams.get('utm_campaign') || '';
        this.formData.utm_content = urlParams.get('utm_content') || '';
        this.formData.utm_keyword = urlParams.get('utm_keyword') || '';

        // See if a Raise exists for this EOI - PPG
        // if(this.eoiId){
        //     this.isLoading = true;
        //     apex__getLiveRaiseFromEOI({eoiId : this.eoiId})
        //     .then((result)=>{
        //         console.log("Raises: ", JSON.stringify(result));
        //         this.hasLiveRaise = true;
        //     })
        //     .catch(error => console.error(error))
        //     .finally(()=>{
        //         this.isLoading = false;
        //     })
        // }


    }


    scrollToDiv(divId) {
        const element = this.template.querySelector(`[data-id="${divId}"]`);
        if (element) {
            element.scrollIntoView({ behavior: 'smooth' });
        } else {
            console.error(`Element with data-id="${divId}" not found.`);
        }
    }

    // Send event to get captured - Cesar 2/4/25
    handleGTAGEvent(formData){
        // Get the full current URL
        try{
            this.dispatchEvent(new CustomEvent('lwc_onleadgtaevent',
                { 
                    detail: {
                        url: window.location.href,
                        formDetails: formData
                    },
                    bubbles: true, 
                    composed: true
                }));
        }catch(error){
            console.error('Error logging gTag event:', JSON.stringify(error))
        }
    }
    
    // Rather than a typ shows up a modal - Cesar 2/4/25
    openSuccessModal(){
        const successModal = this.refs.successModal;
        if(successModal){
            successModal.openModal();
        }
    }

}