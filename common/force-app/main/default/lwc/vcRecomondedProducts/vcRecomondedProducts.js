import { LightningElement, track, api } from 'lwc';
import getRelProds from "@salesforce/apex/ProductController.getRelProds";
export default class VcRecomondedProducts extends LightningElement {
    connectedCallback(){        
        document.addEventListener('IS_Rec_Invests', this.handleNotification);
        document.dispatchEvent(new CustomEvent('IS_Rec_Invests_Ready'));
    }
    prodIdlst = [];
    showRecomondedProds = false;
    @track productList_1 = [];
    @api title;
    @api description;
    handleNotification = (event) => {
        if(event?.detail?.payload?.investRecs){
            event.detail.payload.investRecs.forEach( e=>{
            this.prodIdlst.push(e.id);            
            })
        }
        getRelProds( { prodIdlst: this.prodIdlst } )
        .then(res=>{
            let result = JSON.parse(JSON.stringify(res));
            this.productList_1=result;
            this.showRecomondedProds = this.productList_1.length;
                
        }).catch(error=>{
            console.log("error  while loading recommended products",error);
        })            
    }  
}