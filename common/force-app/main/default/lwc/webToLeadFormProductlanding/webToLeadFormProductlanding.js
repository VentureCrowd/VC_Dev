import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import createLeadRec from '@salesforce/apex/WebToLeadFormProductlandingCntrl.createLeadRec'
import PUBLIC_URL from '@salesforce/label/c.VC_CF_Public_URL';
// Style/JS Imports
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';

// Lightning Messaging Service
import { registerListener } from 'c/pubsub';
import { CurrentPageReference } from 'lightning/navigation';

export default class WebToLeadFormProductlanding extends LightningElement {

    // @api webToLeadFormId;
    // @api webToLeadFormName;
    @api webSourcePageName;     // Used for Lead Source mapping
    @api leadSourceVal;
    @api registerBtnLabel;

    // Pubsub stuff
    @wire(CurrentPageReference) pageRef;

    // Prevent renderedCallback from firing multiple times. Garbage system and probably incorrect.
    @track hasRendered = true;

    // Colours
    @api backgroundColor;
    @api highlightColor;

    // Title
    @api titleText = '';
    @api titleSubText = '';

    @track leadFirstName = '';
    @track leadLastName = '';
    @track leadEmail = '';
    @track leadMobile = '';

     @api  publicURL = PUBLIC_URL;

    mobilePrefix='+61';
   
    // Google Captcha Attribtes
    usedinComunity = true;
    isDisableRegBtn = true;
    classCombination = { 'enabledBtn': '', 'disabledBtn': 'disablebutton' };
    colorCombination = { 'Teal': '#05c5d1', 'Pink': '#dd5cff' };
    bgColorClass = { 'White': 'bg-white', 'Gray': 'bg-gray',  'Pink': 'bg-pink'   };
    accentColorClass = { 'Teal': 'accent-teal', 'Pink': 'accent-pink', 'Purple': 'accent-purple' };
    elComponentContainer = null;

 
    /*renderedCallback() {
        
        // Only run once.
        if (this.hasRendered) {
            console.log('Test rendered callback');
            // Select the element.
            var elComponentContainer2 = this.template.querySelector('.component-web-to-lead-form');
            console.log(elComponentContainer2);
            this.hasRendered = false;
        }

    }*/

    connectedCallback() {
        // Register the listener when the component is loaded.
        registerListener('siblingEvent', this.handlePubSubEvent, this);
    }

    handlePubSubEvent(eventData) {
        //Check if data was passed from the Sibling component, if it has been then parse the values
        if (eventData) {
            if (eventData.type === 'scroll' && eventData.component === 'web-to-lead-form') {
                let topOffset = this.template.querySelector('.component-web-to-lead-form').getBoundingClientRect();

                if (window.innerWidth < 992) {
                    var scrollTopPos = topOffset.top - 80;
                } else {
                    var scrollTopPos = topOffset.top;
                }
                const scrollOptions = {
                    left: 0,
                    top: scrollTopPos,
                    behavior: 'smooth'
                }
                window.scrollTo(scrollOptions);

                
            };
        }
    }

    handleFieldChange(event) {
        let target = event.target.dataset.item;

        if (target == 'firstName') this.leadFirstName = event.detail.value;
        if (target == 'lastName') this.leadLastName = event.detail.value;
        if (target == 'email') this.leadEmail = event.detail.value;
        if (target == 'mobile') this.leadMobile = event.detail.value;

       
    }

    handleLeadCreation(event) {

        console.log(this.leadMobile.charAt(0));
        if(this.leadMobile.charAt(0) === '0') {
            let substr = this.leadMobile;            
            this.leadMobile = substr.substring(1);            
        }
        console.log('Mobile number length==>:',this.leadMobile.length );
        let phoneno = /^\d{9}$/;
        if(this.leadMobile.match(phoneno))
        {
            console.log('True');
        }
        else
        {
            console.log('false');
        }
        const allValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
        if (allValid) {
            createLeadRec({
                leadFirstName: this.leadFirstName,
                leadLastName: this.leadLastName,
                leadEmail: this.leadEmail,
                leadMobile: this.mobilePrefix + this.leadMobile,
                leadSource: this.leadSourceVal,
                webSource: this.webSourcePageName
            })
            .then((result) => {
                // redirect
                window.open(this.publicURL+'/typ', "_self");
            })
            .catch((error) => {
                // throw error message
                const event = new ShowToastEvent({
                    "title": "erroError!",
                    "variant": "error",
                    "mode": "sticky",
                    "message": "Error Occured generating Lead. " + error
                });
                this.dispatchEvent(event);
            })
        }
    }

    handleVerifyCapthca(event) {
        
        this.isDisableRegBtn = false;
    }

    get getRegBtnStyling() {
        return this.isDisableRegBtn ? (this.classCombination['disabledBtn']) :
            (this.classCombination['enabledBtn']);
    }

    get titleTextOutput() {
        return this.titleText;
    }

    get titleSubTextOutput() {
        return this.titleSubText;
    }

    get getComponentStyleClasses() {
        return 'component-container component-web-to-lead-form ' + this.bgColorClass[this.backgroundColor] + ' ' + this.accentColorClass[this.highlightColor];
    }
}