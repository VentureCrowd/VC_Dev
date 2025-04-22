import { LightningElement,track } from 'lwc';

export default class WebtoleadaddedfieldsLWC extends LightningElement {
    url;
    @track windowWidth;
    connectedCallback(){
        this.url = '/apex/webtoLeadextrafields?websource='+window.location.pathname.split('/s/')[1].split('/').pop();
        console.log('this.url :', this.url);
        window.addEventListener('resize', this.computeformfactor.bind(this));
        this.windowWidth = window.innerWidth;
    }

    renderedCallback() {
    }

    computeformfactor() {
        this.windowWidth = window.innerWidth;
        console.log('window.width ' + this.windowWidth);
        eval("$A.get('e.force:refreshView').fire();");
    }

    redirect(){
        console.log('event called');
        window.location.href = '/s/thank-you';
    }

    get iframeStyle() {
        return 'height: 920px;';
    }
}