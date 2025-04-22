import { api, LightningElement, track,wire } from 'lwc';
import HAMBURGER_ICON from '@salesforce/resourceUrl/HamburgerIcon';
import HAMBURGER from '@salesforce/resourceUrl/hamburger';
import ISGUEST from '@salesforce/user/isGuest';
import {getRecord} from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import SMALL_PHOTO_URL from '@salesforce/schema/User.SmallPhotoUrl';
import getheaders from "@salesforce/apex/CommunityUserDetailController.getheaders";
import DisplayUrl from '@salesforce/schema/Product2.DisplayUrl';
import { CurrentPageReference } from 'lightning/navigation';

// Ven 127 - Nav Bar Burger Menu
import Chevron from '@salesforce/resourceUrl/Vector_1';
import Close from '@salesforce/resourceUrl/X';


export default class VcHeaderGuestMobile extends LightningElement {
    isGuest=ISGUEST;
    @track currentUser={};
    @track  menus=[];

    showDropDown=false;
    HamburgerIcon=HAMBURGER_ICON;
    hamburger=HAMBURGER;
    userId=USER_ID;

    // Ven 127 - Nav Bar Burger Menu 
    showDropBurger=false;
    chevronBurger = `${Chevron}#Vector1`;
    closeButtonBurger = `${Close}#X`;
    @wire(CurrentPageReference)
    currentPageReference;

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD,SMALL_PHOTO_URL]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
           this.error = error ; 
        } else if (data) {
            this.currentUser.Name=data.fields.Name.value;
            this.currentUser.SmallPhotoUrl=data.fields.SmallPhotoUrl.value;
        }
    }

    // Navigate to specific url
    navigateToCommPage(event) {
        var url = event.target.dataset.url;  

        // let a = this.template.querySelector('.onClickColorChange');
        // console.log('a => ' + a.style.color);
        // a.style.fontFamily = "SuisseIntl-Bold"
        
        window.open(url, '_top');
    }
    
   
    connectedCallback(){
        console.log(getheaders());
        // console.log(this.currentPage = currentPageReference.attributes.name); 
        getheaders()
        .then(r=>{
            console.log('r', r);

            if(!this.isGuest){
                let menus=[ 
                    {id: 0, label: "Investors", active: false,url:'/invest', submenu: r['INVEST']},
                    {id: 1, label: "Founders", active: false, url:'/raise', submenu: r['RAISE']},
                    {id: 2, label: "Venture Capital", active: false,url:'/s/invest/ventures', submenu: r['VENTURES']},
                    {id: 3, label: "Property", active: false, url:'/property', submenu: r['PROPERTY']},                    
                    {id: 4, label: "Learn", active: false, url:'/blog', submenu: r['LEARN']},
                    {id: 5, label: "About Us", active: false, url:'/about', submenu: r['ABOUT']},
                    {id: 6, label: "My Portfolio", active: false, url:'/s/portal/my-portfolio', submenu:null},
                    {id: 7, label: "My Profile", active: false, url:'/s/portal/profile/'+this.userId, submenu:null},
                    {id: 8, label: "My Entities", active: false, url:'/s/portal/my-entities', submenu:null},
                    {id: 9, label: "My Companies", active: false, url:'/s/portal/my-companies', submenu:null},
                    {id: 10, label: "Log out", active: false, url:'/secur/logout.jsp?retURL=/s/login', submenu:null}];
                    this.menus=[...menus];
            }else if(this.isGuest){
                let menus=[ 
                    {id: 0, label: "Investors", active: false,url:'/s/invest', submenu: r['INVEST']},
                    {id: 1, label: "Founders", active: false, url:'/s/raise', submenu: r['RAISE']},
                    {id: 2, label: "Venture Capital", active: false,url:'/s/invest/ventures', submenu: r['VENTURES']},
                    {id: 3, label: "Property", active: false, url:'/s/property', submenu: r['PROPERTY']},
                    {id: 4, label: "Learn", active: false, url:'/s/blog', submenu: r['LEARN']},
                    {id: 5, label: "About Us", active: false, url:'/s/about', submenu: r['ABOUT']},        
                    {id: 6, label: "Login", active: false, url:'/s/login', submenu:null},
                    {id: 7, label: "Register", active: false, url:'/s/login/SelfRegister?startURL=%2Fs%2Fportal%2Fportfolio', submenu:null}];
                    this.menus=[...menus];
            }

        })
        .catch(e=>console.log(e))
    }

    onHamburgerClick(event){	

        // setTimeout(() => {
        //     this.ready = true;
     
     
        this.showDropDown=!this.showDropDown;	
        // @Simplus VEN-170: New Navbar	
        // event to pass to standardPageHeader LWC to switch Logos/background	
        const mobileEvent = new CustomEvent('showdropdown',{	
            detail:{	
                mobileLogo: this.showDropDown	
            }	
        });	
        this.dispatchEvent(mobileEvent);
        
        // }, 1000);
        	
    }


    // Ven 127 - Nav Bar Burger Menu
    onDropdownClick(event){

       
         //set to true if false, false if true.

         var  itemIndex = event.currentTarget.dataset.index;    
        console.log('ID index=> ' + itemIndex);

        const itemIndex1 = event.currentTarget.dataset.targetId;
        console.log('ID => ' + itemIndex1);

        let r = this.template.querySelector('ul[id]');
        console.log('aria-labelledby => ' + r.id);
        let treeId = r.id.replace(/[^0-9]/g,'')
        console.log('treeId => ' + r.id);
        if(this.isGuest){
        let x = this.template.querySelector('li[id="'+itemIndex+'-'+treeId+'"]');
        console.log("CONSOLE IDsss4 => " +x.id+ ' ----- '  +x.setAttribute('aria-expanded', 
        x.getAttribute('aria-expanded') === 'true' 
          ? 'false' 
          : 'true'));
        } else if(!this.isGuest){
            let x = this.template.querySelector('li[id="'+itemIndex+'-'+treeId+'"]');
            console.log("CONSOLE IDsss4 => " +x.id+ ' ----- '  +x.setAttribute('aria-expanded', 
            x.getAttribute('aria-expanded') === 'true' 
              ? 'false' 
              : 'true'));    
        }
    }
}