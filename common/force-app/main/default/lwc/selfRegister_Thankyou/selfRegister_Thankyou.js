import { LightningElement } from 'lwc';
import communityLogin from '@salesforce/apex/ReCaptchaAuraController.communityLogin';

export default class SelfRegister_Thankyou extends LightningElement {
    connectedCallback(){
        let url = new URL(window.location.href);
        let email = atob(decodeURIComponent(url.searchParams.get("eml")));
        let pwd = atob(decodeURIComponent(url.searchParams.get("pd")));
        let investentity = url.searchParams.get("investentity");

        //* If it's a founder go to my companies | if it's retail or wholesale and have the investentity checked go to my entities
        //* otherwise go to my portfolio
        // let landingurl = investentity == 'true' ? '/s/portal/my-entities' : '/s/portal/my-companies';        
        let landingurl = '/s/portal/portfolio';        

        communityLogin({email, pwd, landingurl})
        .then(res => {
            window.location.href = res;
        })
        .catch(e => console.log(e));
        
    }
}