import { LightningElement,track,api } from 'lwc';

// VEN-152 - added expected landing page that contains the "Thank you for your interest" VFP
const TY_PAGE_URL = '/apex/VC_CF_ThankYou';

export default class WebtoleadLWCcase extends LightningElement {
    url;
    @track windowWidth;
    @api investor;
    @api webSource;

    // VEN-152 - added properties for dynamic iframe container height
    windowHeight;
    frameHeight;
    showThankYou = false;

    connectedCallback(){
        console.log('hello');
        let url1 = new URL(window.location.href);
        let utm_source = url1.searchParams.get("utm_source");
        let utm_medium = url1.searchParams.get("utm_medium");
        let utm_campaign = url1.searchParams.get("utm_campaign");
        let utm_content = url1.searchParams.get("utm_content");
        let utm_keyword = url1.searchParams.get("utm_keyword");
        let websource = window.location.pathname.split('/s/')[1].split('/').pop();
        websource = this.webSource ? this.webSource : websource;
        this.url = `/apex/VC_CF_WebtoLead?websource=${websource}&utm_medium=${utm_medium}&utm_campaign=${utm_campaign}&utm_content=${utm_content}&utm_source=${utm_source}&utm_keyword=${utm_keyword}&investortype=${this.investor}`;
        console.log('this.url :', this.url);
        window.addEventListener('resize', this.computeformfactor.bind(this));
        this.windowWidth = window.innerWidth;

        this.windowHeight = window.innerHeight;
        this.showThankYou = false;
        window.addEventListener('message', this.postMessageHandler.bind(this));
    }

    renderedCallback() {
    }

    computeformfactor() {
        this.windowWidth = window.innerWidth;
        this.windowHeight = window.innerHeight;
        console.log('window.width ' + this.windowWidth);
        eval("$A.get('e.force:refreshView').fire();");
    }

    redirect(){
        console.log('event called');
        window.location.href = '/s/thank-you';
    }

    // VEN-152 - handling event from Visualforce page contained in iframe
    postMessageHandler(event) {
        let fullUrl = window.location.href;
        if (!fullUrl.includes(event.origin)) return;

        if (event.data['scrollHeight']) {
            let frameHeight = event.data['scrollHeight'];
            this.frameHeight = frameHeight;
        } else if (event.data['typUrl']) {
            if (TY_PAGE_URL == event.data['typUrl']) {
                this.showThankYou = true;
                let url = event.data['typUrl'];
                this.url = url;
            }
        }

        eval("$A.get('e.force:refreshView').fire();");
    }

    // VEN-152 - Frame container sizing
    get frameContainerStyle() {
        if (this.showThankYou) {
            if (this.windowHeight > this.windowWidth) {
                // portrait
                return (this.windowWidth >= 799)
                    ? 'height: ' + this.windowWidth + 'px'
                    : 'height: ' + this.frameHeight + 'px';
            } else {
                // landscape
                return 'height: ' + this.windowHeight + 'px';
            }
        } else {
            return 'height: calc(' + this.frameHeight + 'px + 1rem);';
        }
    }

    /* Original code */
    // get iframeStyle() {
    //     if(this.windowWidth <= 494 && this.windowWidth > 433) {
    //         return 'height: 630px;';
    //     } else if (this.windowWidth <= 433) {
    //         return 'height: 800px;';
    //     } else {
    //         return 'height: 750px;';
    //     }
    // }
}