import { LightningElement } from 'lwc';
import screen1 from './screen1.html';
import screen2 from './screen2.html';
import screen3 from './screen3.html';
import GLObal_ASSET from '@salesforce/resourceUrl/VC_CF_GlobalAssets';
import pageUrl from '@salesforce/resourceUrl/captcha_HTML';
import verifyrecaptchaToken from '@salesforce/apex/ReCaptchaAuraController.verifyrecaptchaToken';
import upsertPersonAccount from '@salesforce/apex/ReCaptchaAuraController.upsertPersonAccount';
import updateAccount from '@salesforce/apex/ReCaptchaAuraController.updateAccount';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';
import VC_MasterCss_New from '@salesforce/resourceUrl/VC_MasterCss_NewTemp';
import portalAssets from '@salesforce/resourceUrl/VC_NewPortalAssets';
export default class NewRegistration extends LightningElement {
    navigateTo;
    screen1 = true;
    screen2 = false;
    screen3 = false;
    showspinner = false;
    userdata;
    isuseralredayexsists = false;
    page1Background = portalAssets + '/Assets/Images/Registration_page1.jpg';
    page2Background = portalAssets + '/Assets/Images/Registration_page2.jpg';
    page3Background = portalAssets + '/Assets/Images/Registration_page3.jpg';
    BtnArrow = portalAssets + '/Assets/Icons/BtnArrow.svg';

    mainlogo = portalAssets + '/Assets/Images/teal_icon.png';
    // Screen 1 Icons
    vc_logo = portalAssets + '/Assets/Icons/teal_icon.png';
    medicalIcon = portalAssets + '/Assets/Icons/medical.svg';
    jayrideIcon = portalAssets + '/Assets/Icons/Jayride_logo.svg';

    // Screen 2 Icons
    engeneicIcon = portalAssets + '/Assets/Icons/EnGeneIC_Logo.svg';
    vectorIcon = portalAssets + '/Assets/Icons/Vector_logo.svg';
    nexbaIcon = portalAssets + '/Assets/Icons/nexba_logo.svg';

    // Screen 3 Icons
    australianIcon = portalAssets + '/Assets/Icons/TheAustralian.png';
    bnaIcon = portalAssets + '/Assets/Icons/BNA.png';
    frIcon = portalAssets + '/Assets/Icons/FR.png';
    ausbizIcon = portalAssets + '/Assets/Icons/ausbiz.png';
    sevenIcon = portalAssets + '/Assets/Icons/7.png';

    isCaptchValidated = false;
    screen1error = false;
    accId;
    userId;
    retURL;
    selfIdentification = 'Retail';
    IsAccountCreated;
    disablesecondbutton = true;
    disablethirdbutton = true;
    rendered = false;
    connectedCallback() {

        Promise.all( [
            loadStyle( this, VC_MasterCss_New )
        ] ).then( () => {
            console.log( 'CSS New Files loaded' );
            window.scrollTo( 0, this.template.querySelector( ".vc_RegistrationPageLogo" ).scrollHeight );
        } )
            .catch( error => {
                console.log( error.body.message );
            } );
    }
    constructor () {
        super();
        this.navigateTo = pageUrl;
        window.addEventListener( "message", this.listenForMessage );
    }
    render() {
        return this.screen1 ? screen1 : this.screen2 ? screen2 : screen3;
    }
    // renderedCallback(){
    //     console.log("renderedCallback");
    //     if(this.rendered)
    //     return ;

    //     this.rendered=true;
    // }
    get backgroundStylePage1() {
        return `background-image:url(${ this.page1Background })`;
    }
    get backgroundStylePage2() {
        return `background-image:url(${ this.page2Background })`;
    }
    get backgroundStylePage3() {
        return `background-image:url(${ this.page3Background })`;
    }
    userdetailmap = {};
    logo = GLObal_ASSET + '/img/logo.png';
    get phoneoptions() {
        let phoneNumberoptns = [ { "value": "93", "label": "Afghanistan +93" },
        { "value": "358", "label": "Åland +358" },
        { "value": "355", "label": "Albania +355" },
        { "value": "213", "label": "Algeria +213" },
        { "value": "1684", "label": "American Samoa +1684" },
        { "value": "376", "label": "Andorra +376" },
        { "value": "244", "label": "Angola +244" },
        { "value": "1264", "label": "Anguilla +1264" },
        { "value": "672", "label": "Antarctica +672" },
        { "value": "1268", "label": "Antigua and Barbuda +1268" },
        { "value": "54", "label": "Argentina +54" }, { "value": "374", "label": "Armenia +374" }, { "value": "297", "label": "Aruba +297" }, { "value": "61", "label": "Australia +61" }, { "value": "43", "label": "Austria +43" }, { "value": "994", "label": "Azerbaijan +994" }, { "value": "1242", "label": "Bahamas +1242" }, { "value": "973", "label": "Bahrain +973" }, { "value": "880", "label": "Bangladesh +880" }, { "value": "1246", "label": "Barbados +1246" }, { "value": "375", "label": "Belarus +375" }, { "value": "32", "label": "Belgium +32" }, { "value": "501", "label": "Belize +501" }, { "value": "229", "label": "Benin +229" }, { "value": "1441", "label": "Bermuda +1441" }, { "value": "975", "label": "Bhutan +975" }, { "value": "591", "label": "Bolivia +591" }, { "value": "599", "label": "Bonaire +599" }, { "value": "387", "label": "Bosnia and Herzegovina +387" }, { "value": "267", "label": "Botswana +267" }, { "value": "55", "label": "Brazil +55" }, { "value": "246", "label": "British Indian Ocean Territory +246" }, { "value": "1284", "label": "British Virgin Islands +1284" }, { "value": "673", "label": "Brunei +673" }, { "value": "359", "label": "Bulgaria +359" }, { "value": "226", "label": "Burkina Faso +226" }, { "value": "257", "label": "Burundi +257" }, { "value": "855", "label": "Cambodia +855" }, { "value": "237", "label": "Cameroon +237" }
            , { "value": "1", "label": "Canada +1" }, { "value": "238", "label": "Cape Verde +238" }, { "value": "345", "label": "Cayman Islands +345" }, { "value": "236", "label": "Central African Republic +236" }, { "value": "235", "label": "Chad +235" }, { "value": "56", "label": "Chile +56" }, { "value": "86", "label": "China +86" }, { "value": "61", "label": "Christmas Island +61" }, { "value": "61", "label": "Cocos [Keeling] Islands +61" }, { "value": "57", "label": "Colombia +57" }, { "value": "269", "label": "Comoros +269" }, { "value": "243", "label": "Congo +243" }, { "value": "682", "label": "Cook Islands +682" }, { "value": "506", "label": "Costa Rica +506" }, { "value": "385", "label": "Croatia +385" }, { "value": "53", "label": "Cuba +53" }, { "value": "599", "label": "Curaçao +599" }, { "value": "357", "label": "Cyprus +357" }, { "value": "420", "label": "Czech Republic +420" }, { "value": "45", "label": "Denmark +45" }, { "value": "253", "label": "Djibouti +253" }, { "value": "1767", "label": "Dominica +1767" }, { "value": "1767", "label": "Dominican Republic +1767" }, { "value": "670", "label": "East Timor +670" }, { "value": "593", "label": "Ecuador +593" }, { "value": "20", "label": "Egypt +20" }, { "value": "503", "label": "El Salvador +503" }, { "value": "240", "label": "Equatorial Guinea +240" }, { "value": "291", "label": "Eritrea +291" }, { "value": "372", "label": "Estonia +372" }, { "value": "251", "label": "Ethiopia +251" }, { "value": "500", "label": "Falkland Islands +500" }, { "value": "298", "label": "Faroe Islands +298" }
            , { "value": "691", "label": "Federated States of Micronesia +691" }, { "value": "679", "label": "Fiji +679" }, { "value": "358", "label": "Finland +358" }, { "value": "33", "label": "France +33" }, { "value": "594", "label": "French Guiana +594" }, { "value": "689", "label": "French Polynesia +689" }, { "value": "78", "label": "French Southern Territories" }, { "value": "241", "label": "Gabon +241" }, { "value": "220", "label": "Gambia +220" }, { "value": "995", "label": "Georgia +995" }, { "value": "49", "label": "Germany +49" }, { "value": "233", "label": "Ghana +233" }, { "value": "350", "label": "Gibraltar +350" }, { "value": "30", "label": "Greece +30" }, { "value": "299", "label": "Greenland +299" }, { "value": "1473", "label": "Grenada +1473" }, { "value": "590", "label": "Guadeloupe +590" }, { "value": "1671", "label": "Guam +1671" }, { "value": "502", "label": "Guatemala +502" }, { "value": "44", "label": "Guernsey +44" }, { "value": "224", "label": "Guinea +224" }, { "value": "245", "label": "Guinea-Bissau +245" }, { "value": "595", "label": "Guyana +595" }, { "value": "509", "label": "Haiti +509" }, { "value": "962", "label": "Hashemite Kingdom of Jordan +962" }, { "value": "504", "label": "Honduras +504" }, { "value": "852", "label": "Hong Kong +852" }, { "value": "36", "label": "Hungary +36" }, { "value": "354", "label": "Iceland +354" }, { "value": "91", "label": "India +91" }, { "value": "62", "label": "Indonesia +62" }, { "value": "98", "label": "Iran +98" }, { "value": "964", "label": "Iraq +964" }, { "value": "353", "label": "Ireland +353" }, { "value": "44", "label": "Isle of Man +44" }, { "value": "972", "label": "Israel +972" }, { "value": "39", "label": "Italy +39" }, { "value": "225", "label": "Ivory Coast +225" }, { "value": "1876", "label": "Jamaica +1876" }, { "value": "81", "label": "Japan +81" }, { "value": "44", "label": "Jersey +44" }, { "value": "77", "label": "Kazakhstan +77" }, { "value": "254", "label": "Kenya +254" }
            , { "value": "686", "label": "Kiribati +686" }, { "value": "383", "label": "Kosovo +383" }, { "value": "965", "label": "Kuwait +965" }, { "value": "996", "label": "Kyrgyzstan +996" }, { "value": "856", "label": "Laos +856" }, { "value": "371", "label": "Latvia +371" }, { "value": "961", "label": "Lebanon +961" }, { "value": "266", "label": "Lesotho +266" }, { "value": "231", "label": "Liberia +231" }, { "value": "218", "label": "Libya +218" }, { "value": "423", "label": "Liechtenstein +423" }, { "value": "352", "label": "Luxembourg +352" }, { "value": "853", "label": "Macau +853" }, { "value": "389", "label": "Macedonia +389" }, { "value": "261", "label": "Madagascar +261" }, { "value": "265", "label": "Malawi +265" }, { "value": "60", "label": "Malaysia +60" }, { "value": "960", "label": "Maldives +960" }, { "value": "223", "label": "Mali +223" }, { "value": "356", "label": "Malta +356" }, { "value": "692", "label": "Marshall Islands +692" }, { "value": "596", "label": "Martinique +596" }, { "value": "222", "label": "Mauritania +222" }, { "value": "230", "label": "Mauritius +230" }, { "value": "262", "label": "Mayotte +262" }, { "value": "52", "label": "Mexico +52" }, { "value": "377", "label": "Monaco +377" }, { "value": "976", "label": "Mongolia +976" }, { "value": "382", "label": "Montenegro +382" }, { "value": "1664", "label": "Montserrat +1664" }, { "value": "212", "label": "Morocco +212" }, { "value": "258", "label": "Mozambique +258" }, { "value": "95", "label": "Myanmar [Burma] +95" }, { "value": "264", "label": "Namibia +264" }, { "value": "674", "label": "Nauru +674" }, { "value": "977", "label": "Nepal +977" }, { "value": "31", "label": "Netherlands +31" }, { "value": "687", "label": "New Caledonia +687" }, { "value": "64", "label": "New Zealand +64" }, { "value": "505", "label": "Nicaragua +505" }, { "value": "227", "label": "Niger +227" }, { "value": "234", "label": "Nigeria +234" }, { "value": "683", "label": "Niue +683" }
            , { "value": "672", "label": "Norfolk Island +672" }, { "value": "850", "label": "North Korea +850" }, { "value": "1670", "label": "Northern Mariana Islands +1670" }, { "value": "47", "label": "Norway +47" }, { "value": "968", "label": "Oman +968" }, { "value": "92", "label": "Pakistan +92" }, { "value": "680", "label": "Palau +680" }, { "value": "970", "label": "Palestine +970" }, { "value": "507", "label": "Panama +507" }, { "value": "675", "label": "Papua New Guinea +675" }, { "value": "595", "label": "Paraguay +595" }
            , { "value": "51", "label": "Peru +51" }, { "value": "63", "label": "Philippines +63" }, { "value": "872", "label": "Pitcairn Islands +872" }, { "value": "48", "label": "Poland +48" }, { "value": "351", "label": "Portugal +351" }, { "value": "1939", "label": "Puerto Rico +1939" }, { "value": "974", "label": "Qatar +974" }, { "value": "82", "label": "Republic of Korea +82" }, { "value": "370", "label": "Republic of Lithuania +370" }, { "value": "373", "label": "Republic of Moldova +373" }, { "value": "242", "label": "Republic of the Congo +242" }, { "value": "262", "label": "Réunion +262" }, { "value": "40", "label": "Romania +40" }, { "value": "7", "label": "Russia +7" }, { "value": "250", "label": "Rwanda +250" }, { "value": "290", "label": "Saint Helena +290" }, { "value": "1869", "label": "Saint Kitts and Nevis +1869" }, { "value": "1758", "label": "Saint Lucia +1758" }, { "value": "590", "label": "Saint Martin +590" }, { "value": "508", "label": "Saint Pierre and Miquelon +508" }, { "value": "1784", "label": "Saint Vincent and the Grenadines +1784" }, { "value": "590", "label": "Saint-Barthélemy +590" }, { "value": "685", "label": "Samoa +685" }, { "value": "378", "label": "San Marino +378" }, { "value": "239", "label": "São Tomé and Príncipe +239" }, { "value": "966", "label": "Saudi Arabia +966" }, { "value": "221", "label": "Senegal +221" }, { "value": "381", "label": "Serbia +381" }, { "value": "248", "label": "Seychelles +248" }, { "value": "232", "label": "Sierra Leone +232" }, { "value": "65", "label": "Singapore +65" }, { "value": "590", "label": "Sint Maarten +590" }, { "value": "421", "label": "Slovakia +421" }, { "value": "386", "label": "Slovenia +386" }, { "value": "677", "label": "Solomon Islands +677" }, { "value": "252", "label": "Somalia +252" }, { "value": "27", "label": "South Africa +27" }, { "value": "500", "label": "South Georgia and the South Sandwich Islands +500" }, { "value": "211", "label": "South Sudan +211" }, { "value": "34", "label": "Spain +34" }, { "value": "94", "label": "Sri Lanka +94" }, { "value": "249", "label": "Sudan +249" }, { "value": "597", "label": "Suriname +597" }, { "value": "47", "label": "Svalbard and Jan Mayen +47" }, { "value": "268", "label": "Swaziland +268" }, { "value": "46", "label": "Sweden +46" }, { "value": "41", "label": "Switzerland +41" }, { "value": "963", "label": "Syria +963" }, { "value": "886", "label": "Taiwan +886" }, { "value": "992", "label": "Tajikistan +992" }
            , { "value": "255", "label": "Tanzania +255" }, { "value": "66", "label": "Thailand +66" }, { "value": "228", "label": "Togo +228" }
            , { "value": "690", "label": "Tokelau +690" },
        { "value": "676", "label": "Tonga +676" },
        { "value": "1868", "label": "Trinidad and Tobago +1868" },
        { "value": "216", "label": "Tunisia +216" },
        { "value": "90", "label": "Turkey +90" }, { "value": "993", "label": "Turkmenistan +993" }, { "value": "1649", "label": "Turks and Caicos Islands +1649" },
        { "value": "688", "label": "Tuvalu +688" }, { "value": "230", "label": "U.S. Minor Outlying Islands" }, { "value": "1340", "label": "U.S. Virgin Islands +1340" }, { "value": "256", "label": "Uganda +256" },
        { "value": "380", "label": "Ukraine +380" }, { "value": "971", "label": "United Arab Emirates +971" },
        { "value": "44", "label": "United Kingdom +44" }, { "value": "1", "label": "United States +1" }, { "value": "598", "label": "Uruguay +598" }, { "value": "998", "label": "Uzbekistan +998" }, { "value": "678", "label": "Vanuatu +678" }, { "value": "379", "label": "Vatican City +379" }, { "value": "58", "label": "Venezuela +58" }, { "value": "84", "label": "Vietnam +84" }, { "value": "681", "label": "Wallis and Futuna +681" }, { "value": "967", "label": "Yemen +967" }, { "value": "260", "label": "Zambia +260" },
        { "value": "263", "label": "Zimbabwe +263" } ];
        return phoneNumberoptns;
    }
    handlemobilecodeChange( event ) {
        // console.log(event.target.value);
    }
    listenForMessage( message ) {
        let data = JSON.stringify( message.data );
        if ( data && data.includes( '****CaptchToken****' ) ) {
            let token = message.data.split( '****CaptchToken****' )[ 0 ];
            verifyrecaptchaToken( { token } )
                .then( r => {
                    this.isCaptchValidated = r;
                } )
                .catch( e => {
                    console.log( e );
                } )
        }
    }
    captchaLoaded( evt ) {
    }
    passwordchange( event ) {
        let passwordInfo = event.target.value;
        let smallCase = /[a-z]/g;
        let capitalCase = /[A-Z]/g;
        let digit = /[\d]/g;
        if ( passwordInfo.length < 8 || !smallCase.test( passwordInfo ) || !capitalCase.test( passwordInfo ) && !digit.test( passwordInfo ) || passwordInfo == "password" ) {
            event.target.setCustomValidity( "Invalid password. Please ensure your password is a minimum of 8 characters, including both letters and numbers" );
        } else {
            event.target.setCustomValidity( "" );
        }
        event.target.reportValidity();
        this.cnfpasswordchange();
    }
    cnfpasswordchange( event ) {
        let cnfpassword = this.template.querySelector( '[data-id="cnfpassword"]' );
        let password = this.template.querySelector( '[data-id="password"]' );
        if ( cnfpassword.value != password.value ) {
            cnfpassword.setCustomValidity( "Password and Confirm Password doesnt match. Please verify" );
        } else {
            cnfpassword.setCustomValidity( "" );
        }
        cnfpassword.reportValidity();
    }
    handlePage2() {
        let inputelements = this.template.querySelectorAll( 'lightning-input' );
        inputelements = Array.from( inputelements ).concat( Array.from( this.template.querySelectorAll( 'input' ) ) );
        let isinputValid = true;
        inputelements.forEach( e => {
            isinputValid = isinputValid && e.checkValidity();
            e.reportValidity();
        } )
        if ( isinputValid && window.isCaptchValidated ) {
            this.showspinner = true;
            let userdatamap = {}
            let url = new URL(window.location.href);
            userdatamap['utm_source__c'] = url.searchParams.get("utm_source");
            userdatamap['utm_medium__c'] = url.searchParams.get("utm_medium");
            userdatamap['utm_campaign__c'] = url.searchParams.get("utm_campaign");
            userdatamap['utm_content__c'] = url.searchParams.get("utm_content");
            userdatamap['utm_term__c'] = url.searchParams.get("utm_term");
            userdatamap['utm_keyword__c'] = url.searchParams.get("utm_keyword");
            this.template.querySelectorAll( 'lightning-input' ).forEach( e => {
                userdatamap[ e.dataset.id ] = e.value;
            } )
            userdatamap[ 'countrycode' ] = this.template.querySelector( '[data-id="countrycode"]' ).value;
            userdatamap[ 'mobile' ] = userdatamap[ 'countrycode' ] + userdatamap[ 'mobile' ];
            userdatamap[ 'Email_Opt_In__pc' ] = this.template.querySelector( '[data-id="Email_Opt_In__pc"]' ).checked;
            this.userdata = userdatamap;
            upsertPersonAccount( { userdatamap } )
                .then( r => {
                    if ( r.IsValidtransaction ) {
                        this.accId = r.accId;
                        this.userId = r.userId;
                        this.retURL = r.retURL;
                        this.IsAccountCreated = r.IsAccountCreated;
                        this.disablesecondbutton = false;
                    } else {
                        this.isuseralredayexsists = true;
                        // this.showtoast('User already exsists for this email','error');
                    }
                    this.showspinner = false;
                    this.screen1 = false;
                    this.screen2 = true;
                } )
                .catch( e => {
                    console.log( e );
                    this.screen1error = true;
                    this.showspinner = false;
                    this.showtoast( 'There was a error while processing the request. Please contact our support team', 'error' );
                } )
        }
        // this.screen1 = false;//remove
        // this.screen2 = true;//Remove
    }
    showtoast( m, k ) {
        this.dispatchEvent(
            new ShowToastEvent( {
                title: m,
                variant: k,
            } )
        );
    }
    handlePage3() {
        let selectval;
        let inputelements = this.template.querySelectorAll( 'input' );
        inputelements.forEach( e => {
            if ( e.checked )
                selectval = e.dataset.id;
        } )
        if ( !selectval ) {
            this.showtoast( 'Please select any one of the options above', 'error' );
        } else if ( this.screen1error ) {
            this.showtoast( 'There was a error while processing the request. Please contact our support team', 'error' );
        } else {
            let datmap = {};
            datmap[ 'Self_Identification__pc' ] = this.selfIdentification;
            datmap[ 'Id' ] = this.accId;
            console.log( datmap );
            updateAccount( { datmap } )
                .then( r => {
                    if ( r == 'success' ) {
                        this.screen2 = false;
                        this.screen3 = true;
                        this.disablethirdbutton = false;
                    } else {
                        this.disablethirdbutton = true;
                        this.showtoast( 'There was a error while processing the request. Please contact our support team', 'error' );
                    }
                } )
                .catch( e => {
                    console.log( e );
                } )
        }
        this.screen2 = false;
        this.screen3 = true;
    }
    radiochange( event ) {
        let inputelements = this.template.querySelectorAll( 'input' );
        inputelements.forEach( e => {
            if ( e.dataset.id != event.target.dataset.id )
                e.checked = false;
        } )
        this.selfIdentification = event.target.dataset.id;
    }
    completeRegistration() {
        let inputareaelements = this.template.querySelector( 'c-loqate-address' );
        let inputelements = this.template.querySelectorAll( 'input' );
        let allelements = Array.from( inputelements );
        let isformvalid = true;
        allelements.forEach( e => {
            isformvalid = isformvalid && e.checkValidity();
            e.reportValidity();
        } )
        if ( isformvalid && inputareaelements.checkValidity() ) {
            let address = this.template.querySelector( 'c-loqate-address' );
            let datmap = {};
            datmap[ 'BillingStreet' ] = address.street;
            datmap[ 'BillingCity' ] = address.city;
            datmap[ 'BillingState' ] = address.state;
            datmap[ 'BillingPostalCode' ] = address.postcode;
            datmap[ 'BillingCountry' ] = address.country;
            datmap[ 'Id' ] = this.accId;
            datmap[ 'Bank_Account_Name__c' ] = this.template.querySelector( '[data-id="bankaccname"]' ).value;
            datmap[ 'Bank_Account_Number__c' ] = this.template.querySelector( '[data-id="bankaccnum"]' ).value;
            datmap[ 'BSB_Number__c' ] = this.template.querySelector( '[data-id="bsbnum"]' ).value;
            updateAccount( { datmap } )
                .then( r => {
                    if ( r == 'success' ) {
                        this.showtoast( 'Your registration is completed', 'success' );
                    } else {
                        this.showtoast( 'There was a error while processing the request. Please contact our support team', 'error' );
                    }
                } )
                .catch( e => {
                    console.log( e );
                } )
            window.location.href = '/s/typ-newuser?eml=' + btoa( this.userdata.email ) + '&pd=' + btoa( this.userdata.password ) + '&investentity=' + this.template.querySelector( '[data-id="investentity"]' ).checked;
        }
    }
    handlemobileChange( event ) {
        let mobilePattern = /^(\d{8,10}){1}$/g;
        if ( !mobilePattern.test( event.target.value ) ) {
            event.target.setCustomValidity( "Invalid Mobile Number." );
        } else {
            event.target.setCustomValidity( "" );
        }
        event.target.reportValidity();
    }
    forgotpassword() {
        window.location.href = "/s/login/ForgotPassword";
    }
    login() {
        window.location.href = "/s/login";
    }
}