import { LightningElement,track,api } from 'lwc';
import getInvestProds from "@salesforce/apex/ProductController.getInvestProds";
export default class VcProductInvest extends LightningElement {
    @api showOfferButton;

    @track productList_1 = [];
    @track productList_2 = [];
    @track sucessprodlst = [];
    connectedCallback(){
        getInvestProds()
        .then(res=>{
            let result = JSON.parse(JSON.stringify(res));
            this.productList_1=result[0];
            this.sucessprodlst=result[1];
            this.productList_2= result[1].length > 9 ? [...this.sucessprodlst].splice(0,9) :this.sucessprodlst ;
        }).catch(error=>{
            console.log("error  while loading products",error);
        })
    }
    showmore(){
        this.productList_2 = [...this.sucessprodlst].splice(0,this.productList_2.length+3);
    }
    get showmorebtn(){
        return this.productList_2.length < this.sucessprodlst.length;
    }
}