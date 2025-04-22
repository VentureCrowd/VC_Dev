import { LightningElement } from 'lwc';
import {NavigationMixin} from "lightning/navigation";
import getProddetails from "@salesforce/apex/InvestController.getProddetails";
export default class InvestThankYou extends NavigationMixin(LightningElement) {
    displayurl;
    prodName;
    connectedCallback(){
        let params = new URLSearchParams(window.location.href.split('?')[1]);
        let recordId =  params.get("Id");
        getProddetails({recordId})
        .then(res =>{
            this.displayurl = res.DisplayUrl;
            this.prodName = res.Name;
        })
        if(recordId == '01t5i000008HEbAAAW'){
            window.dataLayer = window.dataLayer || [];
            window.dataLayer.push({
              'event': 'investment_success',
              'fund': 'Be Fit Food'
            });
            console.log(window.dataLayer,'Be Fit Food Tag Req 27/06/23');
        }
    }
    handleClickHome(){
        window.location.href = "/s/portal/portfolio"
    }
}