/**
 * @description       : 
 * @author            : mayurkumar.maisuriya@akecelo.com
 * @group             : 
 * @last modified on  : 17-05-2021
 * @last modified by  : mayurkumar.maisuriya@akecelo.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   17-05-2021   mayurkumar.maisuriya@akecelo.com   Initial Version
**/
import { LightningElement, api, track, wire } from 'lwc';

// PubSub Communication
import { fireEvent } from 'c/pubsub';
import { CurrentPageReference } from 'lightning/navigation';
import ISGUEST from '@salesforce/user/isGuest';
import portalAssets from '@salesforce/resourceUrl/VC_NewPortalAssets';
import { loadStyle } from 'lightning/platformResourceLoader';
//import VC_MasterCss_New from '@salesforce/resourceUrl/VC_MasterCss_New';



export default class HeroBannerProductLandingPage extends LightningElement {

    //VC_MasterCss_New=portalAssets +'/Assets/VC_MasterCss_New.css';
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
    @api primaryButtonLabel_Login = '';
    @api secondaryButtonLabel_Login = '';
    @api primaryButtonColor_Login = '';
    @api secondaryButtonColor_Login = '';
    @api primaryButtonLink_Login = '';
    @api secondaryButtonLink_Login = '';
    @api primaryButtonSameOrNew_Login = '';
    @api secondaryButtonSameOrNew_Login = '';
    @api videoURL='';
    @api videoURLSameOrNew='';

    @track primaryButtonVisible = true;
    @track secondaryButtonVisible = true; 

    @track primaryButtonVisible_Login = true;
    @track secondaryButtonVisible_Login = true;   

    // PubSub stuff
    @wire(CurrentPageReference) pageRef;

    // Prevent renderedCallback from firing multiple times. Garbage system and probably incorrect.
    @track hasRendered = true;

    @track listText = {};

    isGuest = ISGUEST;

    anchorTarget = { 'Same Tab': '_self', 'New Tab': '_blank' };

    colorCombination = { 'Teal': 'accent-teal', 'Pink': 'accent-pink', 'Purple': 'accent-purple', 'Ghost': 'accent-ghost', 'White': 'accent-white' };

    handlePrimButValueChange(event){
            const label = event.target.label;  
            if (label.length){
                primaryButtonVisible=true;
            } else {
                primaryButtonVisible=false;
            }
            console.log('Called handlePrimButValueChange');
    
    }
    handleSecButValueChange(event){
        const label = event.target.label;  
        if (label.length){
            secondaryButtonVisible=true;
        } else {
            secondaryButtonVisible=false;
        }
        console.log('Called handleSecButValueChange');

}

    connectedCallback() {
        Promise.all( [
            loadStyle( this, portalAssets+'/Assets/VC_MasterCss_New.css' )
        ] ).then( () => {
            console.log( 'CSS New Files loaded' );
        } )
        .catch( error => {
            console.log( error.body.message );
        } );

        try {
            console.log('isGuest', this.isGuest);
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


    renderedCallback() {

        if(this.primaryButtonLabel.length){
        this.primaryButtonVisible=true;
        }
    else {
        this.primaryButtonVisible=false;
    }

    if(this.primaryButtonLabel_Login.length){
        this.primaryButtonVisible_Login=true;
        }
    else {
        this.primaryButtonVisible_Login=false;
    }

        // Only run once.
        if (this.hasRendered) {     

        }
        if(this.secondaryButtonLabel.length){
            this.secondaryButtonVisible=true;
            }
        else {
            this.secondaryButtonVisible=false;
        }

        if(this.secondaryButtonLabel_Login.length){
            this.secondaryButtonVisible_Login=true;
            }
        else {
            this.secondaryButtonVisible_Login=false;
        }

            // Only run once.
            if (this.hasRendered) {     

                // Select the element.
                var primaryButton = this.template.querySelector('.action-primary--button');
    
                // Add an event listener for the click action on the primary button.
                primaryButton.addEventListener('click', (e) => {
    
                    var primaryHref = primaryButton.getAttribute('href');
    
                    if(primaryHref.includes('anchor:')) {
                        // Stop the default link handler.
                        e.preventDefault();
    
                        // Split the string so we can select the correct element to scroll the page to.
                        const splitString = primaryHref.split(":");
    
                        // Send the event all components with a listener for reactivity.
                        fireEvent(this.pageRef, 'siblingEvent',  {type: 'scroll', component: splitString[1]});
    
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

    get primaryButtonStyle_Login() {
        return this.colorCombination[this.primaryButtonColor_Login] + ' action-primary--button secondary-' + this.colorCombination[this.secondaryButtonColor_Login];
    }

    get secondaryButtonStyle() {
        return this.colorCombination[this.secondaryButtonColor] + ' primary-' + this.colorCombination[this.primaryButtonColor];
    }

    get secondaryButtonStyle_Login() {
        return this.colorCombination[this.secondaryButtonColor_Login] + ' primary-' + this.colorCombination[this.primaryButtonColor_Login];
    }

    get getbackgroundImgStyling() {
        return `background-image:url('${this.backgroundimageurl}')`;
    }

    get primaryButtonHref() {
        return this.primaryButtonLink;
    }

    get primaryButtonHref_Login() {
        return this.primaryButtonLink_Login;
    }

    get secondaryButtonHref() {
        return this.secondaryButtonLink;
    }

    get secondaryButtonHref_Login() {
        return this.secondaryButtonLink_Login;
    }

    get primaryButtonTarget() {
        return this.anchorTarget[this.primaryButtonSameOrNew];
    }

    get primaryButtonTarget_Login() {
        return this.anchorTarget[this.primaryButtonSameOrNew_Login];
    }

    get secondaryButtonTarget() {
        return this.anchorTarget[this.secondaryButtonSameOrNew];
    }

    get secondaryButtonTarget_Login() {
        return this.anchorTarget[this.secondaryButtonSameOrNew_Login];
    }

    get getClassWrapper1(){
        if(this.videoURL){
            return 'col-md-8';
        }
        else{
            return 'col-md-12';
        }
    }

}