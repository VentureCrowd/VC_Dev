import { LightningElement, api } from 'lwc';

export default class BlogPromoBladeCta extends LightningElement {

    @api headingText;
    @api descriptionText;
    @api label;
    @api buttonLabel;
    @api buttonLink;
    @api buttonColor;
    @api buttonOpenInSameOrNew;
    @api backgroundColor;
    @api highlightColor;
    @api headingTextStyle;

    isTextRendered = false;

    anchorTarget = { 'Same Tab': '_self', 'New Tab': '_blank' };
    colorCombination = {'Purple': 'accent-purple', 
                        'Teal': 'accent-teal',
                        'Gradient' : 'accent-gradient', };
    bgColorClass = { 'White': 'bg-white', 'Gray': 'bg-gray', 'Black': 'bg-black' };
    headerClassCombination = {
        'h1' : 'header-h1',
        'h2' : 'header-h2',
        'h3' : 'header-h3',
        'h4' : 'header-h4',
        'h5' : 'header-h5',
        'h6' : 'header-h6'
    }

    get buttonStyle() {
        return this.colorCombination[this.buttonColor] + ' action-primary--button';
    }

    get headerStyle(){
        return this.headerClassCombination[this.headingTextStyle] ;
    }

    get primaryButtonTarget() {
        return this.anchorTarget[this.buttonOpenInSameOrNew];
    }

    get getComponentStyleClasses() {
        return 'component-container ' + this.bgColorClass[this.backgroundColor];
    }
}