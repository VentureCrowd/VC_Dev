import { LightningElement } from 'lwc';
import getInvestments from "@salesforce/apex/investmentHelper.getInvestments";

export default class InvestmentCardsList extends LightningElement {
    totalinvlst ;
    showinvlst;
    connectedCallback(){
        getInvestments()
        .then(res =>{
            console.log(res);
            this.totalinvlst = res;
            this.showinvlst = this.totalinvlst.length < 4 ? this.totalinvlst : [...this.totalinvlst].slice(0,3);
        })
        .catch(e => console.log(e));
    }
    get showMore(){
        return this.totalinvlst > this.showinvlst;
    }
    showmorerec(){
        this.showinvlst = [...this.totalinvlst].slice(0,this.showinvlst.length+3);
    }
    get numerator(){
        return this.showinvlst?.length;
    }
    get denominator(){
        return this.totalinvlst?.length;
    }
}