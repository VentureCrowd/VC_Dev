/**
 * @description       : 
 * @author            : mayurkumar.maisuriya@akecelo.com
 * @group             : 
 * @last modified on  : 06-21-2021
 * @last modified by  : abhijith.eanuga@zalando.de
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   17-05-2021   mayurkumar.maisuriya@akecelo.com   Initial Version
**/
import { LightningElement, api, track, wire } from 'lwc';

// PubSub Communication
import { fireEvent } from 'c/pubsub';
import { CurrentPageReference } from 'lightning/navigation';

export default class HeroBannerProductLandingPage extends LightningElement {
    @api backgroundimageurl = '';
    @api productLogo = '';
    @api titleText = '';
    @api IntroText = '';
    @api summaryText = '';
    @api primaryButtonColor = '';
    @api secondaryButtonColor = '';
    @api primaryButtonLabel = '';
    @api secondaryButtonLabel = '';
    @api primaryButtonLink = '';
    @api secondaryButtonLink = '';
    @api primaryButtonSameOrNew = '';
    @api secondaryButtonSameOrNew = '';
    @api productId;
    @api fixedAmount;
    @api investUrl;
    @api minAmount;
    @api targetAmount;
    @api fixedAmountCent = 0;
    @api minAmountCent = 0;

    @track displayProduct = false;

    // Prevent renderedCallback from firing multiple times. Garbage system and probably incorrect.
    @track hasRendered = true;
    @track listText = {};

    // PubSub stuff
    @wire(CurrentPageReference) pageRef;

    anchorTarget = { 'Same Tab': '_self', 'New Tab': '_blank' };

    colorCombination = { 'Teal': 'accent-teal', 'Pink': 'accent-pink', 'Purple': 'accent-purple', 'Ghost': 'accent-ghost', "White": 'accent-white' };


    // Video Popup
    @track isModalOpen = false;
    @track youTubeURL = null;

    // Get the ID from a YouTube Link
    getYouTubeID(url){
        url = url.split(/(vi\/|v%3D|v=|\/v\/|youtu\.be\/|\/embed\/)/);
        return undefined !== url[2]?url[2].split(/[^0-9a-z_\-]/i)[0]:url[0];
      }

    connectedCallback() {
        this.fixedAmount = this.fixedAmount+this.fixedAmountCent/100;
        this.minAmount = this.minAmount+this.minAmountCent/100;
        try {
            this.listText = { 'introList': [], 'summaryList': [] };
            if (this.IntroText && this.IntroText.includes('<br/>')) {
                let i = 1;
                (this.IntroText.split('<br/>')).forEach(ele => {
                    ((this.listText)['introList']).push({ 'key': i, 'value': ele });
                    i++;
                })
            }
            if (this.summaryText && this.summaryText.includes('<br/>')) {
                let i = 1;
                (this.summaryText.split('<br/>')).forEach(ele => {
                    ((this.listText)['summaryList']).push({ 'key': i, 'value': ele });
                    i++;
                })
            }

        } catch (ex) {
            console.log('===Exception Occured on Connected Callback===>', ex.message);
        }
    }

    closeModal() {
        this.isModalOpen = false;
    }

    renderedCallback() {
        if (this.productId) {
            this.displayProduct = true;
        }
        // Only run once.
        if (this.hasRendered) {

            // Select the element.
            var primaryButton = this.template.querySelector('.action-primary--button');

            // Add an event listener for the click action on the primary button.
            primaryButton.addEventListener('click', (e) => {

                var primaryHref = primaryButton.getAttribute('href');

                if (primaryHref.includes('anchor:')) {
                    // Stop the default link handler.
                    e.preventDefault();

                    // Split the string so we can select the correct element to scroll the page to.
                    const splitString = primaryHref.split(":");

                    // Send the event all components with a listener for reactivity.
                    fireEvent(this.pageRef, 'siblingEvent', { type: 'scroll', component: splitString[1] });

                } else if (primaryHref.includes('videoPlayer:url=')) {
                    // Stop the default link handler.
                    e.preventDefault();
                    const splitString = primaryHref.split(":url=");
                    console.log(this.getYouTubeID(splitString[1]))
                    this.youTubeURL = `https://www.youtube.com/embed/${this.getYouTubeID(splitString[1])}`;
                    this.isModalOpen = true;
            
                } else {
                    // Allow Anchor to fire as normal.
                }

            });

            // Make the buttons equal width
            var elButtons = this.template.querySelectorAll('ul li a');
            var elWidthArray = [];

            elButtons.forEach((el, index) => {
                elWidthArray.push(el.offsetWidth);
            });

            // Find the largest button size.
            let largestSize = Math.max(...elWidthArray);

            console.log(largestSize);

            // Set the minWidth of each button.
            elButtons.forEach((el, index) => {
                el.style.minWidth = largestSize + 'px';
            });

            this.hasRendered = false;
        }

    }


    get primaryButtonStyle() {
        return this.colorCombination[this.primaryButtonColor] + ' action-primary--button secondary-' + this.colorCombination[this.secondaryButtonColor];
    }

    get secondaryButtonStyle() {
        return this.colorCombination[this.secondaryButtonColor] + ' primary-' + this.colorCombination[this.primaryButtonColor];
    }

    get getbackgroundImgStyling() {
        return `background-image:url('${this.backgroundimageurl}')`;
    }

    get primaryButtonHref() {
        if(this.primaryButtonLink.includes('/invest-now?')){
            let url = new URL(window.location.href);
            let utm_source = url.searchParams.get("utm_source");
            let utm_medium = url.searchParams.get("utm_medium");
            let utm_campaign = url.searchParams.get("utm_campaign");
            let utm_content = url.searchParams.get("utm_content");
            let utm_term = url.searchParams.get("utm_term");
            return this.primaryButtonLink+`&utm_source=${utm_source}&utm_medium=${utm_medium}&utm_campaign=${utm_campaign}&utm_content=${utm_content}&utm_term=${utm_term}`;
        }else
        return this.primaryButtonLink;
    }

    get secondaryButtonHref() {
        return this.secondaryButtonLink;
    }

    get primaryButtonTarget() {
        return this.anchorTarget[this.primaryButtonSameOrNew];
    }

    get secondaryButtonTarget() {
        return this.anchorTarget[this.secondaryButtonSameOrNew];
    }
    changeMobileMargin(event){
        console.log('Deal is closed');
        var divblock = this.template.querySelector('[data-id="divblock"]');
        if(divblock){
            this.template.querySelector('[data-id="divblock"]').className='component-container component-container-closed';
        }        
       
    }

}