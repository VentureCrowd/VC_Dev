import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class InvestmentCard extends NavigationMixin(LightningElement) {
    @api investment;
    showModal = false;
    connectedCallback(){
        console.log(this.investment);
    }
    closemodal(){
        this.showModal = false;
    }
    showModalpop(){
        this.showModal = true;
    }
    navigateToRecordViewPage() {
        window.location.replace(window.location.origin+'/s/portal/detail/'+this.investment.Id);
    }
}