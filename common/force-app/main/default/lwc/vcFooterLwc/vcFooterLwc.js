import { LightningElement, track, wire } from 'lwc';
import getCurrentUser from "@salesforce/apex/CommunityUserDetailController.getCurrentUser";
import PORTFOLIO from '@salesforce/resourceUrl/Portfolio';
import PROFILE from '@salesforce/resourceUrl/Profile';
import ENTITIES from '@salesforce/resourceUrl/Entities';
import { CurrentPageReference,NavigationMixin } from 'lightning/navigation';
import USER_ID from '@salesforce/user/Id';
import ISGUEST from '@salesforce/user/isGuest'

export default class VcFooterLwc extends LightningElement {
    isGuest=ISGUEST;
    userId=USER_ID;
    
    get footerclass(){
        if(this.isGuest){
            return 'state--guest';
        }
        return 'state--logged-in';
    }
    get profileurl(){
    return '/profile/'+this.userId;
    }

    topFunction(){
        const scrollOptions = {
            left: 0,
            top: 0,
            behavior: 'smooth'
        }
        window.scrollTo(scrollOptions);
    }

}