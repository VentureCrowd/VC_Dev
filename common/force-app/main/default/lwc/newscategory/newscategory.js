import { LightningElement, track } from 'lwc';

export default class Newscategory extends LightningElement {
    @track paramValue;
    @track iframeurl;

    connectedCallback(){
        
        this.getURLParameterValue();
        //

        //https://"+window.location.hostname+
        this.iframeurl=`${'https://'+window.location.hostname}/apex/VC_CF_News_category?category=`+ (this.paramValue.category);
        console.log("@@@ iframer url= ",JSON.stringify(this.iframeurl));
    }

    getURLParameterValue() {
 
        var querystring = location.search.substr(1);
        var paramValue = {};
        querystring.split("&").forEach(function(part) {
            var param = part.split("=");
           // paramValue[param[0]] = decodeURIComponent(param[1]);
            paramValue[param[0]] = param[1];
        });
 
        console.log('@@@ paramValue-' , paramValue);
        this.paramValue=paramValue;
    }
}