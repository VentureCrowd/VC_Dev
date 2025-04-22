import { LightningElement, api, track } from 'lwc';
import VC_CF_Public_URL from '@salesforce/label/c.VC_CF_Public_URL';
import blogDetails from '@salesforce/apex/CustomBlogSideBarCntrl.fetchBlogDetails';

export default class NextPostBlog extends LightningElement {

    @track backgroundimageurl;
    @api nextPostButtonLabel;
    @track nextPostTitle;
    @track nextPostRedirectUrl;
    @api currentBlogSeqNumber;

    connectedCallback() {
        try {
            blogDetails({
                currentBlogSeqNum : this.currentBlogSeqNumber
            })
            .then(result => {
                console.log('===Next Post result===>', JSON.parse(JSON.stringify(result)));
                this.nextPostTitle  = result['nextBlog']['News_Label__c'];
               // this.backgroundimageurl = result['nextBlog']['CategoryBanner_Img_Url__c']; https://assets.venturecrowd.vc/uploads/2021/03/tech-hub_TickerTV.jpeg
                this.nextPostRedirectUrl = result['nextBlog']['Navigation_url__c'];
                this.backgroundimageurl = 'https://assets.venturecrowd.vc/uploads/2021/03/tech-hub_TickerTV.jpeg'
            })
            .catch(error => {
                console.log('===error===>', error.message);
            });
        } catch (ex) {
            console.log('*** Exception Occured on Connected Callback *** ', ex.message);
        }
    }

    get getRedirectUrl() {
        return this.nextPostRedirectUrl;
    }

    get getbackgroundImgStyling() {
        return `background-image:url('${this.backgroundimageurl}')`;
    }
}