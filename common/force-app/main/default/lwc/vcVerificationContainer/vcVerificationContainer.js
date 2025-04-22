import { LightningElement } from 'lwc';

export default class VcVerificationContainer extends LightningElement {
    pageUrl;
    frameHeight;

    // height of navbar in pixels, this will be used for extra container height
    navbarHeight = 75;

    connectedCallback() {
        this.pageUrl = '/apex/venturecrowdVerification';
        window.addEventListener('message', this.postMessageHandler.bind(this));
    }

    postMessageHandler(event) {
        let fullUrl = window.location.href;
        if (!fullUrl.includes(event.origin)) return;

        if (event.data['scrollHeight']) {
            let scrHeight = event.data['scrollHeight'];
            this.frameHeight = scrHeight;
            this.resizeContainer();
        }
    }

    resizeContainer() {
        let container = this.template.querySelectorAll('.frame-container');
        if (container.length > 0) {
            /* container height */
            let totalHeight = this.navbarHeight + this.frameHeight;
            container[0].style.height = totalHeight + 'px';

            /* container top margin */
            container[0].style.margin = this.navbarHeight + 'px 0px 0px';
        }

        // attempting to override the rule given by common CSS, which was 'height: 100vh'
        let frame = this.template.querySelectorAll('.form-frame');
        if (frame.length > 0) {
            frame[0].style.height = '100%';
        }
    }
}