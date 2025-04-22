import { LightningElement,wire } from 'lwc';
import GLObal_ASSET from '@salesforce/resourceUrl/VC_CF_GlobalAssets';
import VC_CF_CommonCSS from '@salesforce/resourceUrl/VC_CF_CommonCSS';
import VC_CF_HomeCSS from '@salesforce/resourceUrl/VC_CF_HomeCSS';
import overrideSLDSvfp from '@salesforce/resourceUrl/overrideSLDSvfp';
import {loadScript, loadStyle} from 'lightning/platformResourceLoader';
import ISGUEST from '@salesforce/user/isGuest';
import {getRecord} from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
 import USER_AVATAR from '@salesforce/schema/User.SmallPhotoUrl';
import PUBLICURL from '@salesforce/label/c.VC_CF_Public_URL';
import SMALL_PHOTO_URL from '@salesforce/schema/User.SmallPhotoUrl';

export default class VcHeaderGuest extends LightningElement {

logo=GLObal_ASSET+'/img/logo.png';
isGuest=ISGUEST;
username;
userId=USER_ID;
userAvatar = USER_AVATAR;
publicURL = PUBLICURL;

connectedCallback() {
    Promise.all([
      /*loadStyle(this, GLObal_ASSET + '/css/fonts.css'),
      //loadStyle(this, GLObal_ASSET + '/css/bootstrap_min.css'),
      loadStyle(this, GLObal_ASSET + '/css/font_awesome_min.css'),
      loadStyle(this, GLObal_ASSET + '/css/google_css2_playfar_display.css'),
      loadStyle(this, GLObal_ASSET + '/css/jquery_fancybox.css'), 
      loadStyle(this,VC_CF_CommonCSS),
      loadStyle(this,VC_CF_HomeCSS),
      loadStyle(this,overrideSLDSvfp),*/
    ]).then(() => {
         console.log("style loaded succesfully");
// initialize the library using a reference to the container element obtained from the DOM
 
    }).catch(error=>{
         console.log("erro while loading jszip>>",error);
    });
  
}


@wire(getRecord, {
    recordId: USER_ID,
    fields: [NAME_FIELD]
}) wireuser({
    error,
    data
}) {
    if (error) {
       this.error = error ; 
    } else if (data) {
        this.username = data.fields.Name.value;
    }
}



}