import { LightningElement,api } from 'lwc';

export default class SearchComboBoxGeneral extends LightningElement {
    @api label = 'Relate To';
    @api placeholder = 'Search Address';
    @api options = [];
    @api selectedValue ='';
    @api fontSize = '13px';
    connectedCallback(){
        
    }
    get fontCss() {
        return `font-size: ${this.fontSize} !important;`;
    }
    handleinputfocus(event){
        this.template.querySelector('.slds-dropdown-trigger').classList.add("slds-is-open");
    }
    handlefocusout(event){
        this.template.querySelector('.slds-dropdown-trigger').classList.remove("slds-is-open");
    }
    handleoptionselect(event){
        this.selectedValue = event.currentTarget.dataset.label;
        this.template.querySelector('[data-id="inputText"]').value = this.selectedValue;
        this.dispatchEvent(new CustomEvent('optselected', { detail: event.currentTarget.dataset.val }));
    }
    handleinputchange(event){
        this.dispatchEvent(new CustomEvent('inpchange', { detail: event.target.value}));
    }
}