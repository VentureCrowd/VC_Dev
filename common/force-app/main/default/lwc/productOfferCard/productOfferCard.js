/**
 * @description Component for offer cards
 * @createdBy Cesar
 * @createdDate 2024-08-29
 * @version 1.0
 */

import { LightningElement, api, track} from 'lwc';

import { NavigationMixin } from 'lightning/navigation';


export default class ProductOfferCard extends NavigationMixin(LightningElement) {
    @api companyName;
    @track singleCompanyName;
    @api companyOneLiner;
    @api logoUrl;
    @api bannerUrl;
    @api industryType;
    @api investmentType;
    @api dealPageLink
    @api status;
    @api bannerAuto;
    @api isEoi;

    /**
     * Handles the offer button click event. It generates a URL using the NavigationMixin and opens the deal page link in the same tab.
     *
     * @method handleOfferButton
     * @public
     *
     * @returns {void}
     *
     **/
    handleOfferButton(){
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: ''
            }
        }).then(url => {
            window.open(this.dealPageLink, "_self");
        });
    }

    get backgroundStyle() {
        if (this.isEoi || this.bannerAuto) {
            return `background-image: url('${this.bannerUrl}');`;
        }
        return '';
    }

    /**
     * We are using this to extract the name of the company
     * In the flow is added the 'Invest in + companyName'
     * @returns {String} The name of the company
     **/
    connectedCallback() {
        this.singleCompanyName = this.companyName.replace('invest in ', '');
    }

}