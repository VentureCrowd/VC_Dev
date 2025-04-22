/* eslint-disable no-unused-vars */
import { api, track, LightningElement } from 'lwc';

export default class PpgProductTile extends LightningElement {
    @api productData;
    @api productId;
    @api investmentAmount;

    /*
    investmentDetails = {
        investmentAmount : '',
        contributionFee : '',
        totalInvestment : '',
        investingAs : ''
    }
    */ 
    @api investmentDetails

    @track isMobile;

    @track lineItems =  [
        {label: 'Investing as', value : ''},
        {label: 'Contribution Fee', value : ''},
    ]

    handleShowMobileDetails(e){
        console.log('SHOWING MOBILE DEETS')
    }

    connectedCallback(){
        this.checkScreenWidth();
        window.addEventListener('resize', () => this.checkScreenWidth());
    }

    disconnectedCallback() {
        window.removeEventListener('resize', () => this.checkScreenWidth());
    }

    checkScreenWidth(){
        this.isMobile = window.innerWidth <= 768;
    }
}