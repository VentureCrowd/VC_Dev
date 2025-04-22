/**
 * @description       : https://akcelo.atlassian.net/browse/VC-1161
 * @author            : ranjana.tiwari@akecelo.com
 * @group             : 
 * @last modified by  : ranjana.tiwari@akecelo.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0                ranjana.tiwari@akecelo.com        Initial Version
 **/
 import {
    LightningElement,
    track,
    api
} from 'lwc';
import GLObal_ASSET from '@salesforce/resourceUrl/VC_CF_GlobalAssets';
import CONTACT_US_ASSET from '@salesforce/resourceUrl/VC_CF_ContactUsAssets';
import VC_CF_CommonCSS from '@salesforce/resourceUrl/VC_CF_CommonCSS';
import VC_CF_AboutCSS from '@salesforce/resourceUrl/VC_CF_AboutCSS';
import VC_CF_CommonJS from '@salesforce/resourceUrl/VC_CF_CommonJS';
import VC_CF_Moment from '@salesforce/resourceUrl/VC_CF_Moment';
import {
    loadScript,
    loadStyle
} from 'lightning/platformResourceLoader';
import notifyEmail from "@salesforce/apex/SendEmailController.notifyEmail";
import VC_CF_Stackpath_Bootstrap from '@salesforce/resourceUrl/VC_CF_Stackpath_Bootstrap';
import VC_CF_Bootstrap from '@salesforce/resourceUrl/VC_CF_Bootstrap';
//Importing image from static resource
export default class ValidateRecaptcha extends LightningElement {

    bg = CONTACT_US_ASSET + '/VC_CF_ContactUsAssets/img/Contact-us-Background.jpg';
    fb = CONTACT_US_ASSET + '/VC_CF_ContactUsAssets/img/FB-white.png';
    ig = CONTACT_US_ASSET + '/VC_CF_ContactUsAssets/img/IG-white.png';
    li = CONTACT_US_ASSET + '/VC_CF_ContactUsAssets/img/LI-white.png';
    @track firstName;
    lastName;
    helpText;
    message;
    email;
    showspinner = false;
    showSuccess = false;
    buttondisabled = true;
    recaptchaComplete = false;
    @api isRequired = false;
    @track showOptions = false;
    selectedOption = 'Select an Option';
    
    

    options = [
        {
            'label': 'Investing',
            'value': 'Investing'
        },
        {
            'label': 'Raising capital',
            'value': 'Raising capital'
        },
        {
            'label': 'Listing a property',
            'value': 'Listing a property'
        },
        {
            'label': 'Private Syndicate Platform (PSP)',
            'value': 'Private Syndicate Platform (PSP)'
        },
        {
            'label': 'Other',
            'value': 'Other'
        }
    ];

    get image() {
        return `background-image: url("https://assets.venturecrowd.vc/uploads/2020/04/about_us_3.png");
        height: 100%; 
        background-position: center;
        background-repeat: no-repeat;
        background-size: cover;`

    }

    get getBackgroundImage(){
        return `background-image:url("${this.bg}")`;
        
    }

    renderedCallback() {
        console.log('In renderedCallback');
    }


    connectedCallback() {
        console.log("In connectedCallback");
        Promise.all([
            loadStyle(this, GLObal_ASSET + '/css/bootstrap_min.css'),
            loadStyle(this, GLObal_ASSET + '/css/font_awesome_min.css'),
            loadStyle(this, GLObal_ASSET + '/css/fonts.css'),
            loadStyle(this, VC_CF_CommonCSS),
            loadStyle(this, VC_CF_AboutCSS),
            loadScript(this, VC_CF_CommonJS)
        ]).then(() => {
            console.log("style loaded succesfully");
            // initialize the library using a reference to the container element obtained from the DOM

        }).catch(error => {
            console.log("error while loading jszip>>", error);
        });



    }

    validateForm() {
        let isValidInputs = [...this.template.querySelectorAll('lightning-input')].reduce((val, inp) => {
            inp.reportValidity();
            return val && inp.checkValidity();
        }, true);

        // let isValidComboBox = [...this.template.querySelectorAll('lightning-combobox')].reduce((val, inp) => {
        //     inp.reportValidity();
        //     return val && inp.checkValidity();
        // }, true);       

        let isValidTextArea = [...this.template.querySelectorAll('lightning-textarea')].reduce((val, inp) => {
            inp.reportValidity();
            return val && inp.checkValidity();
        }, true);

        console.log('isValidInputs: ', isValidInputs);
        // console.log('isValidComboBox: ', isValidComboBox);
        console.log('isValidTextArea: ', isValidTextArea);

        if (isValidInputs && this.selectedOption !== 'Select an Option' && isValidTextArea && this.recaptchaComplete) {
            this.buttondisabled = false;
        } else {
            this.buttondisabled = true;

        }

    }


    handleVerifyCapthca(event) {
        // console.log("verifycapthca done");

        // let isValid = [...this.template.querySelectorAll('lightning-input')].reduce( (val, inp) => {
        //     inp.reportValidity();
        //     return val && inp.checkValidity();
        // }, true);

        // console.log('isValid', isValid);
        // if(isValid){
        //     this.buttondisabled = false;

        // }

        this.recaptchaComplete = true;
        this.validateForm();

    }

    handleResetAll(){
        this.template.querySelectorAll('lightning-input').forEach(element => {
          if(element.type === 'checkbox' || element.type === 'checkbox-button'){
            element.checked = false;
          }else{
            element.value = null;
          }      
        });

        this.selectedOption = 'Select an Option';
        this.template.querySelectorAll('lightning-textarea').forEach(element => element.value = null);
      }
    

    sendEmail(event) {

        try {
            let isValid = [...this.template.querySelectorAll('input')].reduce((val, inp) => {
                inp.reportValidity();
                return val && inp.checkValidity();
            }, true);

            console.log("isValid=", isValid);

            if (isValid) {
                this.showError = false;
                this.sendEmailhelper(event);
                this.buttondisabled = true;
            } else {
                this.showError = true;
            }
        } catch (error) {
            console.log("error occured while email sending=", error);
        }
    }

    handleFirstNameChange(event) {
        this.firstName = event.target.value;
        this.validateForm();
    }

    handleLastNameChange(event) {
        this.lastName = event.target.value;
        this.validateForm();
    }

    // handleHelpTextChange(event) {
    //     this.helpText = event.target.value;
    //     console.log('selected is :'+this.helpText);
    //     this.validateForm();
    // }

    handleEmailChange(event) {
        this.email = event.target.value;
        this.validateForm();
    }

    handleMessageChange(event) {
        this.message = event.target.value;
        this.validateForm();
    }


    sendEmailhelper(event) {
        console.log("sending email");
        this.showspinner = true;
        this.showSuccess = false;
        var action = notifyEmail;

        action({
            name: this.firstName + ' ' + this.lastName,
            email: this.email,
            helptext: this.helpText,
            message: this.message
        }).then(() => {

            this.emailinfo = {};
            this.showspinner = false;
            this.showSuccess = true;

            this.firstName = '';
            this.lastName = '';
            this.email = '';
            this.helptext = '';
            this.message = '';

            this.handleResetAll();


        }).catch(response => {
            var errors = response;
            if (errors) {
                if (errors[0] && errors[0].message) {
                    console.log("Error message: " +
                        errors[0].message);
                }
            } else {
                console.log("Unknown error");
            }
        });


    }

    handleShowOptions() {
        if (this.showOptions) {
            this.showOptions = false;
        } else {
            this.showOptions = true;
        }
    }

    handleOnClickOption(event) {
        var selectedItem = event.currentTarget; 
        this.helpText = selectedItem.dataset.value;
        this.selectedOption = this.helpText;
        this.validateForm();
        this.handleShowOptions();
    }
}