/**
 * @description       : 
 * @author            : Enquero
 * @group             : 
 * @last modified on  : 12-02-2021
 * @last modified by  : Enquero
 * Modifications Log 
 * Ver   Date         Author    Modification
 * 1.0   12-02-2021   Enquero   Initial Version
**/
import { LightningElement, track, api } from 'lwc';
import vf_url from '@salesforce/label/c.GOOGLE_CPATCHA_VF_URL';

export default class GoogleReCaptcha extends LightningElement {
    @track navigateTo = "/apex/portalSmartyAddress";
    @track _url = "/apex/GoogleRecaptchaVF";
    @track _height = "";
    @track data;
    @api usedincomunity;

    @api
    get height() {
        return this._height;
    }

    set height(value) {
        this._height = value;
    }

    @api
    get url() {
        return this._url;
    }

    set url(value) {
        this._url = value;
    }

    @api
    getAddress() {
        return window.address;
    }

    @api
    getValue() {
        return window.data;
    }

    listenMessage(event) {
        try {
            console.log("handled captcha");
            let data = event.data;
            console.log("captcha verfied=", data);
            if (data === 'VALID') {
                console.log("firing  event in lwc");
                this.dispatchEvent(new CustomEvent('verifycapthca', {
                    detail: event.data
                }));
            }
        }
        catch(error) {
            console.log('===Exception Message===>', error.message);
        }
    }

    connectedCallback() {
        if (window.addEventListener) {
            window.addEventListener("message", this.listenMessage.bind(this), false);
        } else {
            window.attachEvent("onmessage", this.listenMessage.bind(this));
        }
    }
    @api get
        capthcapageurl() {
        /*   if(this.usedincomunity){
               return '/InvestorLogin'+this._url;
           }*/

        return this._url;
    }
}