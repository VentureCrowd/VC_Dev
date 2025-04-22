import { LightningElement, api } from 'lwc';
//import portalAssets from '@salesforce/resourceUrl/VC_NewPortalAssets';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class ThreeUpHome extends LightningElement {

    @api HeaderText;

    @api firstImg;
    @api secondImg;
    @api thirdImg;

    @api firstImgTitle;
    @api secondImgTitle;
    @api thirdImgTitle;

    @api firstImgFooterText;
    @api secondImgFooterText;
    @api thirdImgFooterText;

    @api backgroundColor;
    @api footerBtnLabel;
    @api footerBtnRedirectUrl;

    bgColorClass = { 'White': 'component-bg-white', 'Grey': 'component-bg-gray', 'Dark Navy': 'component-bg-dark-navy', "Black": 'component-bg-black' };

    isHtmlUpdated = false;

    connectedCallback() {
        Promise.all( [
            //loadStyle( this, portalAssets+'/Assets/VC_MasterCss_New.css' )
        ] ).then( () => {
            console.log( 'CSS New Files loaded' );
        } )
            .catch( error => {
                console.log( error.body.message );
            } );
    }

    renderedCallback() {
        if ( !this.isHtmlUpdated ) {

            // Check if the element actually exists. This is required to stop SalesForce throwing an error if it didn't exist.
            if ( this.template.querySelector( '.firstImgFooterTextSec' ) ) {
                this.template.querySelector( '.firstImgFooterTextSec' ).innerHTML = this.firstImgFooterText;
            }

            if ( this.template.querySelector( '.secondImgFooterTextSec' ) ) {
                this.template.querySelector( '.secondImgFooterTextSec' ).innerHTML = this.secondImgFooterText;
            }

            if ( this.template.querySelector( '.thirdImgFooterTextSec' ) ) {
                this.template.querySelector( '.thirdImgFooterTextSec' ).innerHTML = this.thirdImgFooterText;
            }
        }
    }

    get getComponentStyleClasses() {
        return 'pt-lg-5 pb-lg-5 component-container ' + this.bgColorClass[ this.backgroundColor ];
    }
}