import { LightningElement, api } from 'lwc';
import VC_CF_Register_Symphony from '@salesforce/label/c.VC_CF_Register_Symphony';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';


export default class RegisterTodayProductLanding extends LightningElement {

    @api registerBtnLabel;
    @api registerBtnUrl;
    @api backgroundColor;
    @api highlightColor;

    colorCombination = { 'White': '#FFF', 'Gray': '#02c8c81a', 'Black' : '#000000', 'Teal' : '#05c5d1', 'Pink' : '#dd5cff'};
    bgColorClass = { 'White': 'bg-white', 'Gray': 'bg-gray', 'Black' : 'bg-black'};
    accentColorClass = {'Teal' : 'accent-teal', 'Pink' : 'accent-pink', 'Purple' : 'accent-purple'};

    get getStyling() {
        return 'background-color : ' + this.colorCombination[this.backgroundColor];
    }
    
    get getComponentStyleClasses() {
        return 'component-container ' + this.bgColorClass[this.backgroundColor] + ' ' + this.accentColorClass[this.highlightColor];
    }
}