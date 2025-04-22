import { LightningElement, wire, track, api } from 'lwc';
import GLObal_ASSET from '@salesforce/resourceUrl/VC_CF_GlobalAssets';
import VC_CF_CommonCSS from '@salesforce/resourceUrl/VC_CF_CommonCSS';
import VC_CF_HomeCSS from '@salesforce/resourceUrl/VC_CF_HomeCSS';
import overrideSLDSvfp from '@salesforce/resourceUrl/overrideSLDSvfp';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import ISGUEST from '@salesforce/user/isGuest';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import USER_AVATAR from '@salesforce/schema/User.SmallPhotoUrl';
import PUBLICURL from '@salesforce/label/c.VC_CF_Public_URL';
import SMALL_PHOTO_URL from '@salesforce/schema/User.SmallPhotoUrl';
import getheaders from "@salesforce/apex/CommunityUserDetailController.getheaders";
import { CurrentPageReference } from 'lightning/navigation';
import COMMUNITY_URL from '@salesforce/label/c.Community_URL';


export default class VcHeaderGuestV2 extends LightningElement {

    label = {COMMUNITY_URL};
    logo = GLObal_ASSET + '/img/logo.png';
    isGuest = ISGUEST;
    username;
    userId = USER_ID;
    userAvatar = USER_AVATAR;
    publicURL = PUBLICURL;
    getInvestdetails;
    getLearndetails;
    getRaisedetails;
    getPropertydetails;
    getAboutdetails;
    getNewsdetails;
    getVenturesDetails;
    mobileLogo = false;
    getInvestbutton = COMMUNITY_URL + "/s/invest";
    getVenturesbutton = COMMUNITY_URL + "/s/invest/ventures";
    getPropertybutton = COMMUNITY_URL + "/s/invest/property";
    getRaisebutton = COMMUNITY_URL + "/s/raise";
    getLearnbutton = COMMUNITY_URL + "/s/blog";
    getAboutbutton = COMMUNITY_URL + "/s/about";

    

    

    @track currentUser={};
    // @Simplus VEN-170: New Navbar
    background = "default-background";
    @api currentPage;
    
    // @Simplus VEN-170: New Navbar, CurrentPage Getter and UI modifier of selected menu item
    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
        if (currentPageReference) {
           this.currentPage = currentPageReference.attributes.name || null;
           if (this.template.querySelector('.active') != null) {
                this.template.querySelector('.active').classList?.remove('active');
            }
                const NAV_LINKS = this.template.querySelectorAll('.menu_item');                
                if (this.currentPage == 'Invest_LWC__c') {
                    NAV_LINKS[0]?.classList?.add('active');
                } else if (this.currentPage == 'Ventures__c' || (window.location.pathname.match('ventures|lp') != null)) {
                    NAV_LINKS[1]?.classList?.add('active');
                } else if (this.currentPage == 'Invest_Property__c' || (window.location.pathname.match('property') != null)) {
                    NAV_LINKS[2]?.classList?.add('active');
                } else if (this.currentPage == 'raise__c'){
                    NAV_LINKS[3]?.classList?.add('active');
                } else if (this.currentPage == 'blog__c' || (window.location.pathname.match('blog|education|learn') != null)) {
                    NAV_LINKS[4]?.classList?.add('active');
                } else if (this.currentPage == 'about__c' || (window.location.pathname.match('about|more|manage|partnership') != null)) {
                    NAV_LINKS[5]?.classList?.add('active');
                }                
        }
     }

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD, SMALL_PHOTO_URL]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.username = data.fields.Name.value;
            this.currentUser.SmallPhotoUrl=data.fields.SmallPhotoUrl.value;
        }
    }
    
    connectedCallback(){
        getheaders()
        .then(r=>{
            console.log('r', r);
            this.getInvestdetails = r['INVEST'];
            this.getLearndetails = r['LEARN'];
            this.getRaisedetails = r['RAISE'];
            this.getPropertydetails = r['PROPERTY'];
            this.getAboutdetails = r['ABOUT'];
            this.getNewsdetails = r['NEWS'];
            this.getVenturesDetails = r['VENTURES'];
        })
        .catch(e=>console.log(e));
    }

    // @Simplus VEN-170: New Navbar, handler of logo and menu background on mobile devices
    handleLogo(event){
        this.mobileLogo = event.detail.mobileLogo;
        if(this.mobileLogo){
            this.logo = GLObal_ASSET + '/img/mobile_logo.png';            
            this.background = "black-background";
        }else{
            this.logo = GLObal_ASSET + '/img/logo.png';
            this.background = "default-background";
        }
        
    }
}