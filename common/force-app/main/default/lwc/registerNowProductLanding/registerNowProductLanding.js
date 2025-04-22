import { LightningElement, api } from 'lwc';

export default class RegisterNowProductLanding extends LightningElement {

    @api title
    @api subTitle
    @api buttonName
    @api buttonRedirectUrl;

    // Colours
    @api backgroundColor;
    @api highlightColor;
    colorCombination = { 'White': '#FFF', 'Gray': '#02c8c81a', 'Black' : '#000000', 'Teal' : '#05c5d1', 'Pink' : '#dd5cff'};

    bgColorClass = { 'White': 'bg-white', 'Gray': 'bg-gray', 'Black' : 'bg-black'};

    accentColorClass = {'Teal' : 'accent-teal', 'Pink' : 'accent-pink', 'Purple' : 'accent-purple'};

    get getStyling() {
        return 'background-color : ' + this.colorCombination[this.backgroundColor];
    }
    get getComponentStyleClasses() {
        return 'component-container text-center ' + this.bgColorClass[this.backgroundColor] + ' ' + this.accentColorClass[this.highlightColor];
    }

    handleRegisterNowBtnClick() {
        window.open(this.buttonRedirectUrl);
    }
}