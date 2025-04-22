import { LightningElement, track, wire } from 'lwc';
import getCurrentUser from "@salesforce/apex/CommunityUserDetailController.getCurrentUser";
import PORTFOLIO from '@salesforce/resourceUrl/Portfolio';
import PROFILE from '@salesforce/resourceUrl/Profile';
import ENTITIES from '@salesforce/resourceUrl/Entities';
import COMPANIES from '@salesforce/resourceUrl/Companies';
import { CurrentPageReference,NavigationMixin } from 'lightning/navigation';
import Id from '@salesforce/user/Id';
import ISGUEST from '@salesforce/user/isGuest';


export default class UserActionMenuLwcV2 extends NavigationMixin(LightningElement) {

     @track currentUser;
     isUserAvailable;
     showDropDown=false;
     showspinner=false;
     Portfolio=PORTFOLIO;
     Profile=PROFILE;
     Entities=ENTITIES;
     Companies=COMPANIES;
     userId=Id;
     isGuest=ISGUEST;
     actionMenuclass="slds-dropdown-trigger slds-dropdown-trigger_click";

     @wire(CurrentPageReference)
    pageRef;
     @wire(getCurrentUser)
     loaduser({error,data}){
        if(data){
            if(data.length>0){
               this.currentUser=data[0];
               this.isUserAvailable=true;  
                  console.log("current user=",data[0]);
              }

        }else{
            console.log("error while loading user",error);
        }
     }
     get isUser(){
         console.log("isGuest===",this.isGuest);
         return !this.isGuest;
     }

    get profilepageurl(){
        return '/s/portal/profile/'+this.userId;
    }

    get entitiespageurl(){
        return '/s/portal/my-entities';
    }

    get portfoliopageurl(){
        return '/s/portal/portfolio';
    }
    get mycompaniespageurl(){
        return '/s/portal/my-companies';
    }

    get logoutUrl() {
        return '/secur/logout.jsp?retURL=/s/login';
    }

     menuclick(event){
         console.log("menu clicked item==",event.detail.value);

         switch (event.detail.value) {
             case 'portfolio':
                 
                 break;
                 case 'profile':
                 this.navigateTOcommunityPage('profile');
                 break;
                    case 'entities':
                 
                 break;

                 case 'logout':
                 
                 break;
         
             default:
                 break;
         }
     }
navigateTOcommunityPage(pagename){
    this[NavigationMixin.Navigate]({
        type: 'comm__namedPage',
        attributes: {
            name: pagename
        },
        state: {
            recordId: this.userId
        }
    });
}

showmenu(event){
    //var script = document.querySelector('script[type="application/l10n"]');
   // this.actionMenuclass=this.actionMenuclass+' slds-is-open';

   //`[data-index="${rowindex}"]`
   let Allele = this.template.querySelectorAll(`[data-index="actionMenu"]`);
   console.log("allele==",Allele);
    let actionmenu=this.template.querySelector("slds-dropdown-trigger");
    console.log("actionmenu open==",actionmenu);
    console.log(" Allele[0].classList==", Allele[0].classList);
    if( Allele[0].classList.contains('slds-is-open')){
        console.log("removing class");
        Allele[0].classList.remove('slds-is-open');
        console.log("after remove  Allele[0].classList==", Allele[0].classList);
    }else{
        Allele[0].classList.add('slds-is-open');
    }
   
}
}