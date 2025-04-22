import { LightningElement,api } from 'lwc';

export default class SearchCombobox extends LightningElement {
    @api label = 'Relate To';
    @api placeholder = 'Search Address';
    @api options = [];

    @api fontSize;
    @api pagestyle;

    get fontCss() {
        console.log('@@@fontCss :', this.fontSize);
        return `font-size: ${this.fontSize} !important;`;
    }

    get labelStyle(){
        console.log('this.pagestyle :', this.pagestyle);
        return this.pagestyle == 'verifPageStyle' ? 'verifPageStyle' : 'defaultPageStyle';
        //return `font-size : ${this.fontSize} !important`;
    }


    handleinputfocus(event){
        this.template.querySelector('.slds-dropdown-trigger').classList.add("slds-is-open");
    }
    handlefocusout(event){
        this.template.querySelector('.slds-dropdown-trigger').classList.remove("slds-is-open");
    }
    handleoptionselect(event){
        this.dispatchEvent(new CustomEvent('optselected', { detail: event.currentTarget.dataset.val }));
    }
    handleinputchange(event){
        this.dispatchEvent(new CustomEvent('inpchange', { detail: event.target.value}));
    }
}