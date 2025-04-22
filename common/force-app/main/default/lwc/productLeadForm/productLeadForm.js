/* eslint-disable @lwc/lwc/no-api-reassignments */
/*
* Add this to the head tags to listen for gtag events
*    document.addEventListener('lwc_ongtagevent', (e) => {
            const currentURL = window.location.href;

            // Trigger Google Analytics Event
            window.gtag('event', 'form_submission', {
            event_category: 'Lead Form',
                  event_label: currentURL,  // Track the full URL for attribution
        });
            console.log('GTAG FIRED')
        });
*/
import { api, track, LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import apex__verifyrecaptchaToken from '@salesforce/apex/ReCaptchaAuraController.verifyrecaptchaToken';
import apex__createLead from'@salesforce/apex/LeadControllerNew.createLead';
import apex_getProductByType from '@salesforce/apex/Product_V2_Controller.getProductByType';
//import apex__getLiveRaiseFromEOI from '@salesforce/apex/EOI_Controller.getLiveRaiseFromEOI';

import {phoneNumberoptns} from './utilities.js';
export default class PropertyLeadForm extends LightningElement {
    @api productType;
    @api recordType;
    @api successURL;
    @api formTitle;
    @api formSubtext;
    @api buttonLabel;
    @api successMessage;
    @api wholesaleOnly;
    @api showInvestorType;
    @api showProductDropdown;
    @api webSource;

    @api leadRecordType;


    @api formData = {
        'ausResident' : 'true',
        'mobileCode' : '61-AU',
        'investorType' : 'Wholesale',
    }

    @track phoneNumberCodes;
    @track isSandbox;
    @track isLoading;

    @track disableSubmit;

    get showWholesaleMessage(){
        return this.wholesaleOnly && this.disableSubmit
    }

    
    constructor() {
        super();
        window.addEventListener('message', this.listenForMessage);
    }

    productOptions = [
        {value:'All',label:'All'},
        {value:'Not Sure',label:'Not Sure'},
    ]
    investorOptions = [ 
        { id: 1, value: 'Wholesale', label: 'Wholesale', checked: true },
        { id: 2, value: 'Retail', label: 'Retail', checked: false },
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
        this.isSubmitted = false;

        //scroll to loading container
        this.scrollToDiv('form-container');

        // extract mobile code from unique identifier
        const eventData = event.detail;

        //populate form data with coreForm event
        this.formData = {...eventData.formData};
        
        let mobileNumber = this.formData.mobileNumber.replace(/^0+/, '');
        // format mobile number field
        this.formData.mobileCodeFormatted = '+' + this.splitMobileCode(this.formData.mobileCode) + mobileNumber;
        
        
        // wholesale check IF the investor type field is visible
        if(this.showInvestorType){
            this.formData.isWholesale = this.formData.investorType === 'Wholesale' ? 'Yes' : 'No';

        }

        // add lead sources
        this.formData.webSource = this.formData.product && this.formData.product !== 'All' && this.formData.product !=='Not Sure' ? this.formData.product : this.webSource;
        this.formData.source = 'Organic';

        this.formData.emailOptIn = true;


        if(this.leadRecordType){
            this.formData.recordTypeId = this.leadRecordType;
        }


        apex__createLead({fieldsToAdd : this.formData})
        .then((returnValue)=>{
            this.handleNavigation();
            this.handleGTAGEvent();
            this.openSuccessModal();
           
        })
        .catch((error)=>{
            console.error('Server error: ' + error);
        })
        .finally(()=>{           
            this.refreshFormData();
            this.isLoading = false;
        })
    }

    openSuccessModal(){
        const successModal = this.template.querySelector('c-core-modal');

        if(successModal){
            successModal.openModal();
        }

         
    }

    handleGTAGEvent(){
        // Get the full current URL
        try{
            this.dispatchEvent(new CustomEvent('lwc_ongtagevent',
                { 
                    detail : window.location.href,
                    bubbles: true, 
                    composed: true
                }
                
            ));
        }catch(error){
            console.error('Error logging gTag event:', JSON.stringify(error))
        }
        
    }

    handleNavigation(){
        if(this.successURL && this.successURL !== ''){
            this[NavigationMixin.Navigate]({
                // Define navigation type and target page name
                type: 'standard__webPage',
                attributes: {
                    url: this.successURL
                },
            });
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

        this.disableSubmit = this.wholesaleOnly && this.showInvestorType && this.formData.investorType==='Retail' ? true : false;
    }

    handleResetFormView(e){
        this.refreshFormData();

        const successModal = this.template.querySelector('c-core-modal');

        if(successModal){
            successModal.closeModal();
        }
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

        if(this.productType || this.recordType){
            this.getProductOptions(this.recordType, this.productType);
        }


    }

    async getProductOptions(recordTypeName, productType){
        this.isLoading = true;
        try{
            const products = await apex_getProductByType({
                productTypeName : productType ? productType : '',
                productRTName : recordTypeName ? recordTypeName : '',
            })


            const productsFormatted = products.map((product)=>{
                return {
                    label : product?.prodDisplayName || product?.prodName,
                    value : product.prodCode,
                }
            });
            
            this.productOptions = [
                {value:'All',label:'All'},
                {value:'Not Sure',label:'Not Sure'},
                ...productsFormatted
            ];

            // console.log('PRODUCTS LIST: ', JSON.stringify(this.productOptions));
        }catch(e){
            console.error('Error retrieving products :', JSON.stringify(e));        
        }
        finally{
            this.isLoading = false;
        }
    }


    scrollToDiv(divId) {
        const element = this.template.querySelector(`[data-id="${divId}"]`);
        if (element) {
            element.scrollIntoView({ behavior: 'smooth' });
        } else {
            console.error(`Element with data-id="${divId}" not found.`);
        }
    }

}