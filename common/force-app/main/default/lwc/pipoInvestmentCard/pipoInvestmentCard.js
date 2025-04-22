/**
 * @description Individual cards of the investment
 * @dependencies core-icon
 * @createdBy Cesar
 * @createdDate 2024-09-26
 * @version 1.1
 */

import { LightningElement, api } from 'lwc';

export default class PipoInvestmentCard extends LightningElement {

    @api productName;
    @api investorName;
    @api price;
    @api logoUrl;
    @api investmentId;
    @api investmentStatus;
    @api investmentDate;
    @api lastInterest;
    @api cardBgColor = '#FFF';
    @api cursor;
    iconColor;

    yieldingMapping = {
        'Int_IP': {
            spotlightView: true,
            iconName: 'dollarCircle',
            label: 'Interest paid',
            color: '#27B48A',
            backgroundColor: '#D9FFE5',
        },
        'Int_ACC': {
            spotlightView: true,
            iconName: 'accruing',
            label: 'Accruing interest',
            color: '#407FFF',
            backgroundColor: '#E2EBFF',
        },
        'Int_COM': {
            spotlightView: false,
            iconName: 'compounding',
            label: 'Compounding Interest',
            color: '#F3A73B',
            backgroundColor: '#FFEDC8',
        },
        'Int_CAP': {
            spotlightView: false,
            iconName: 'clockCircle',
            label: 'Capitalised Interest',
            color: '#D95BAA',
            backgroundColor: '#F9E6F2',
        },
        'Red_PT': {
            spotlightView: false,
            iconName: 'dollarCircle',
            label: 'Partially redeemed',
            color: '#CFCECC',
            backgroundColor: '#F0F1F2',
        },
        'Red_FULL': {
            spotlightView: false,
            iconName: 'dollarCircle',
            label: 'Fully redeemed',
            color: '#CFCECC',
            backgroundColor: '#F0F1F2',
        }
    };

    /**
     * Method to handle button click event
     * Dispatches a custom event 'buttonclick' with the button label
     * @event buttonclick
     * @param {Event} event - The event object
     */
    handleClick(){
        const buttonClicked = new CustomEvent('buttonclick',{
            detail: {
                investmentId: this.investmentId
            },
            bubbles: true,
            composed : true,
        });

        this.dispatchEvent(buttonClicked);
    }

    get badgeStyle() {
        let prodView = this.lastInterest || null;
        if (prodView !== null) {
            this.iconColor = this.yieldingMapping[prodView].color;
        }
        return this.yieldingMapping[prodView] || false;
    }

    get activeInvestment() {
        return this.investmentStatus === 'active';
    }
    
    renderedCallback() {
        this.template.host.style.setProperty('--icon-color', this.iconColor);
        this.template.host.style.setProperty('--card-bg-color', this.cardBgColor);
        this.template.host.style.setProperty('--cursor', this.cursor);
    }
}