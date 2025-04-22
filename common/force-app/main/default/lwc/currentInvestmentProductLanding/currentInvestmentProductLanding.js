import { LightningElement, api } from 'lwc';

export default class CurrentInvestmentProductLanding extends LightningElement {

    @api strHeading;
    @api straSupportingCopy;
    @api openVCLogoUrl;
    @api productLogoUrl;
}