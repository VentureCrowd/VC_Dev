import { LightningElement, track, wire,api } from 'lwc';
import getProducts from "@salesforce/apex/ProductController.getProducts";
import PUBLICURL from '@salesforce/label/c.VC_CF_Public_URL';

export default class VcProductListLwc extends LightningElement {
    @track productList;
    @api isSucessfull;
    @api productType;
    @api showOfferButton;
    @track showproductslst = [];
    // showmorebtn = false;
    publicURL = PUBLICURL + '/invest';
    connectedCallback(){
        getProducts({isSucessfull:this.isSucessfull?true:false, productType: this.productType }).then(result=>{
                this.productList=result;
                this.showproductslst = this.productList.length > 3 ? [...this.productList].splice(0,3) :this.productList ;
            }).catch(error=>{
                console.error("error while loading products",error);
            }) 
    }
    get showmorebtn(){
        return this.showproductslst && this.productList && this.showproductslst.length < this.productList.length;
        // return true;
    }
    showmore(){
        this.showproductslst = [...this.productList].splice(0,this.showproductslst.length+3);
    }
}