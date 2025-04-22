import { LightningElement, track, wire } from 'lwc';
import getCurrentUser from "@salesforce/apex/CommunityUserDetailController.getCurrentUser";
import PORTFOLIO from '@salesforce/resourceUrl/Portfolio';
import PROFILE from '@salesforce/resourceUrl/Profile';
import ENTITIES from '@salesforce/resourceUrl/Entities';
import { CurrentPageReference,NavigationMixin } from 'lightning/navigation';
import USER_ID from '@salesforce/user/Id';
import ISGUEST from '@salesforce/user/isGuest';
import VC_NewPortalAssets from '@salesforce/resourceUrl/VC_NewPortalAssets';
import ChevronUp from '@salesforce/resourceUrl/ChevronUp';

export default class VcFooterLwc extends LightningElement {
    isGuest=ISGUEST;
    userId=USER_ID;
    ready = true;
    logo= VC_NewPortalAssets + '/Assets/Logo/VentureCrowd_Logo_White.svg';
    fb= VC_NewPortalAssets + '/Assets/Icons/FB-white.svg';
    insta= VC_NewPortalAssets + '/Assets/Icons/IG-white.png';
    linkedin= VC_NewPortalAssets + '/Assets/Icons/LI-white.png';
    @track currentYear = new Date().getFullYear();

    ChevronUp = `${ChevronUp}#ChevronUp`;
    
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
        setTimeout(() => {
            this.ready = false;
        }, 3000);
    }
}