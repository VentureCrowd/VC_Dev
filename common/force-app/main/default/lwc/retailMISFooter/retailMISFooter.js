import { LightningElement, api, track} from 'lwc';
import USER_ID from '@salesforce/user/Id';
import ISGUEST from '@salesforce/user/isGuest';
import VC_NewPortalAssets from '@salesforce/resourceUrl/VC_NewPortalAssets';
import ChevronUp from '@salesforce/resourceUrl/ChevronUp';
import isRetailProd from '@salesforce/apex/ProductController.isRetailProd';

export default class RetailMISFooter extends LightningElement {
    @api productId;
    isGuest=ISGUEST;
    userId=USER_ID;
    ready = true;
    logo= VC_NewPortalAssets + '/Assets/Logo/VentureCrowd_Logo_White.svg';
    securityLogo = VC_NewPortalAssets + '/Assets/Images/white_gsl_full_logo.png';
    fb= VC_NewPortalAssets + '/Assets/Icons/FB-white.svg';
    insta= VC_NewPortalAssets + '/Assets/Icons/IG-white.png';
    linkedin= VC_NewPortalAssets + '/Assets/Icons/LI-white.png';
    ChevronUp = `${ChevronUp}#ChevronUp`;    
    showMisfooter = false;
    showNormalFooter = false;
    showDynamicFooter = false;
    footertext ;
    @track currentYear = new Date().getFullYear();
    get footerclass(){
        if(this.isGuest){
            return 'state--guest';
        }
        return 'state--logged-in';
    }
    get profileurl(){
        return '/s/portal/profile/'+this.userId;
    }
    topFunction(){
        const scrollOptions = {
            left: 0,
            top: 0,
            behavior: 'smooth'
        }
        window.scrollTo(scrollOptions);
    }
    connectedCallback(){
        this.togglecontent();
        setTimeout(() => {
            this.ready = false;
        }, 3000);
    }
    @api
    togglecontent(){
        let urlParams = new URLSearchParams(window.location.href.split('?')[1]);
        if(urlParams.get('Id') || this.productId){
            let prodId = urlParams.get('Id') ? urlParams.get('Id') : this.productId;
            isRetailProd({prodId})
            .then(res =>{
                if(res.Type__c == 'Retail MIS'){
                    this.showMisfooter = true;
                    this.showDynamicFooter = false;
                    this.showNormalFooter = false;
                }else if(res.Type__c == 'Retail IPO' || res.AFSL_Licence__c =='GSL'|| res.Type__c =='CSF Nominee'){
                    this.showMisfooter = false;
                    this.showDynamicFooter = true;
                    this.showNormalFooter = false;
                    this.footertext = res.Footer_Text__c;
                }else{
                    this.showMisfooter = false;
                    this.showDynamicFooter = false;
                    this.showNormalFooter = true;
                }
            })
        }else{
            this.showMisfooter = false;
            this.showDynamicFooter = false;
            this.showNormalFooter = true;
        }
    }
}