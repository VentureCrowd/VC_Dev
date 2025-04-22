import { LightningElement, api } from 'lwc';

export default class CustomErrorMessage extends LightningElement {
    @api message = 'This field must be completed to submit the expression of interest to be published.';
    @api showErrorMessage = false;
}