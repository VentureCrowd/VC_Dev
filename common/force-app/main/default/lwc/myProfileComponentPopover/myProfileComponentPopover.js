import { LightningElement,api,track } from 'lwc';
import saveAttachment from '@salesforce/apex/MyProfileController.saveAttachment';
import updateSObject from '@salesforce/apex/MyProfileController.updateSObject';
import inputtel from '@salesforce/resourceUrl/inputtel';
// import flags from '@salesforce/resourceUrl/inputtel/img/flags';
// import utils from '@salesforce/resourceUrl/inputtel/utils.js'; //simplus ms
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import { updateRecord,getRecordNotifyChange } from 'lightning/uiRecordApi';


export default class MyProfileComponentPopover extends LightningElement {
    @api displayEdit;
    @api title;
    @api isUpdateImage;
    @track showLoadingSpinner;
    @api flexipageRegionWidth;

    //Record Edit form components
    @api isEditRecord;
    @api recordId;
    @api toUpdateRecordId;
    @api toUpdateObject;
    @api fieldsToEdit;
    @api userType;
    
    //Upload related variables
    MAX_FILE_SIZE = 1500000;
    @track fileName = '';

    //Mobile Number related variables
    telInitialized = false;
    @api isMobileNumber;
    @api mobileNumber;
    mobileNumberInput;

    hasRendered = false;
    widthDiff = 596;
    @track isSmallWidth = false;

    @track ccClass = 'slds-col slds-size_1-of-5 slds-p-right_medium ';
    @track pnClass = 'slds-col slds-size_4-of-5 ';

    // 768 1061

    countrycode = [ 
        [ "Afghanistan (‫افغانستان‬‎)", "af", "93" ], [ "Albania (Shqipëri)", "al", "355" ], [ "Algeria (‫الجزائر‬‎)", "dz", "213" ], [ "American Samoa", "as", "1", 5, [ "684" ] ], [ "Andorra", "ad", "376" ], [ "Angola", "ao", "244" ], [ "Anguilla", "ai", "1", 6, [ "264" ] ], [ "Antigua and Barbuda", "ag", "1", 7, [ "268" ] ], [ "Argentina", "ar", "54" ], [ "Armenia (Հայաստան)", "am", "374" ], [ "Aruba", "aw", "297" ], [ "Ascension Island", "ac", "247" ], [ "Australia", "au", "61", 0 ], [ "Austria (Österreich)", "at", "43" ], [ "Azerbaijan (Azərbaycan)", "az", "994" ], [ "Bahamas", "bs", "1", 8, [ "242" ] ], [ "Bahrain (‫البحرين‬‎)", "bh", "973" ], [ "Bangladesh (বাংলাদেশ)", "bd", "880" ], [ "Barbados", "bb", "1", 9, [ "246" ] ], [ "Belarus (Беларусь)", "by", "375" ], [ "Belgium (België)", "be", "32" ], [ "Belize", "bz", "501" ], [ "Benin (Bénin)", "bj", "229" ], [ "Bermuda", "bm", "1", 10, [ "441" ] ], [ "Bhutan (འབྲུག)", "bt", "975" ], [ "Bolivia", "bo", "591" ], [ "Bosnia and Herzegovina (Босна и Херцеговина)", "ba", "387" ], [ "Botswana", "bw", "267" ], [ "Brazil (Brasil)", "br", "55" ], [ "British Indian Ocean Territory", "io", "246" ], [ "British Virgin Islands", "vg", "1", 11, [ "284" ] ], [ "Brunei", "bn", "673" ], [ "Bulgaria (България)", "bg", "359" ], [ "Burkina Faso", "bf", "226" ], [ "Burundi (Uburundi)", "bi", "257" ], [ "Cambodia (កម្ពុជា)", "kh", "855" ], [ "Cameroon (Cameroun)", "cm", "237" ], [ "Canada", "ca", "1", 1, [ "204", "226", "236", "249", "250", "289", "306", "343", "365", "387", "403", "416", "418", "431", "437", "438", "450", "506", "514", "519", "548", "579", "581", "587", "604", "613", "639", "647", "672", "705", "709", "742", "778", "780", "782", "807", "819", "825", "867", "873", "902", "905" ] ], [ "Cape Verde (Kabu Verdi)", "cv", "238" ], [ "Caribbean Netherlands", "bq", "599", 1, [ "3", "4", "7" ] ], [ "Cayman Islands", "ky", "1", 12, [ "345" ] ], [ "Central African Republic (République centrafricaine)", "cf", "236" ], [ "Chad (Tchad)", "td", "235" ], [ "Chile", "cl", "56" ], [ "China (中国)", "cn", "86" ], [ "Christmas Island", "cx", "61", 2, [ "89164" ] ], [ "Cocos (Keeling) Islands", "cc", "61", 1, [ "89162" ] ], [ "Colombia", "co", "57" ], [ "Comoros (‫جزر القمر‬‎)", "km", "269" ], [ "Congo (DRC) (Jamhuri ya Kidemokrasia ya Kongo)", "cd", "243" ], [ "Congo (Republic) (Congo-Brazzaville)", "cg", "242" ], [ "Cook Islands", "ck", "682" ], [ "Costa Rica", "cr", "506" ], [ "Côte d’Ivoire", "ci", "225" ], [ "Croatia (Hrvatska)", "hr", "385" ], [ "Cuba", "cu", "53" ], [ "Curaçao", "cw", "599", 0 ], [ "Cyprus (Κύπρος)", "cy", "357" ], [ "Czech Republic (Česká republika)", "cz", "420" ], [ "Denmark (Danmark)", "dk", "45" ], [ "Djibouti", "dj", "253" ], [ "Dominica", "dm", "1", 13, [ "767" ] ], [ "Dominican Republic (República Dominicana)", "do", "1", 2, [ "809", "829", "849" ] ], [ "Ecuador", "ec", "593" ], [ "Egypt (‫مصر‬‎)", "eg", "20" ], [ "El Salvador", "sv", "503" ], [ "Equatorial Guinea (Guinea Ecuatorial)", "gq", "240" ], [ "Eritrea", "er", "291" ], [ "Estonia (Eesti)", "ee", "372" ], [ "Eswatini", "sz", "268" ], [ "Ethiopia", "et", "251" ], [ "Falkland Islands (Islas Malvinas)", "fk", "500" ], [ "Faroe Islands (Føroyar)", "fo", "298" ], [ "Fiji", "fj", "679" ], [ "Finland (Suomi)", "fi", "358", 0 ], [ "France", "fr", "33" ], [ "French Guiana (Guyane française)", "gf", "594" ], [ "French Polynesia (Polynésie française)", "pf", "689" ], [ "Gabon", "ga", "241" ], [ "Gambia", "gm", "220" ], [ "Georgia (საქართველო)", "ge", "995" ], [ "Germany (Deutschland)", "de", "49" ], [ "Ghana (Gaana)", "gh", "233" ], [ "Gibraltar", "gi", "350" ], [ "Greece (Ελλάδα)", "gr", "30" ], [ "Greenland (Kalaallit Nunaat)", "gl", "299" ], [ "Grenada", "gd", "1", 14, [ "473" ] ], [ "Guadeloupe", "gp", "590", 0 ], [ "Guam", "gu", "1", 15, [ "671" ] ], [ "Guatemala", "gt", "502" ], [ "Guernsey", "gg", "44", 1, [ "1481", "7781", "7839", "7911" ] ], [ "Guinea (Guinée)", "gn", "224" ], [ "Guinea-Bissau (Guiné Bissau)", "gw", "245" ], [ "Guyana", "gy", "592" ], [ "Haiti", "ht", "509" ], [ "Honduras", "hn", "504" ], [ "Hong Kong (香港)", "hk", "852" ], [ "Hungary (Magyarország)", "hu", "36" ], [ "Iceland (Ísland)", "is", "354" ], [ "India (भारत)", "in", "91" ], [ "Indonesia", "id", "62" ], [ "Iran (‫ایران‬‎)", "ir", "98" ], [ "Iraq (‫العراق‬‎)", "iq", "964" ], [ "Ireland", "ie", "353" ], [ "Isle of Man", "im", "44", 2, [ "1624", "74576", "7524", "7924", "7624" ] ], [ "Israel (‫ישראל‬‎)", "il", "972" ], [ "Italy (Italia)", "it", "39", 0 ], [ "Jamaica", "jm", "1", 4, [ "876", "658" ] ], [ "Japan (日本)", "jp", "81" ], [ "Jersey", "je", "44", 3, [ "1534", "7509", "7700", "7797", "7829", "7937" ] ], [ "Jordan (‫الأردن‬‎)", "jo", "962" ], [ "Kazakhstan (Казахстан)", "kz", "7", 1, [ "33", "7" ] ], [ "Kenya", "ke", "254" ], [ "Kiribati", "ki", "686" ], [ "Kosovo", "xk", "383" ], [ "Kuwait (‫الكويت‬‎)", "kw", "965" ], [ "Kyrgyzstan (Кыргызстан)", "kg", "996" ], [ "Laos (ລາວ)", "la", "856" ], [ "Latvia (Latvija)", "lv", "371" ], [ "Lebanon (‫لبنان‬‎)", "lb", "961" ], [ "Lesotho", "ls", "266" ], [ "Liberia", "lr", "231" ], [ "Libya (‫ليبيا‬‎)", "ly", "218" ], [ "Liechtenstein", "li", "423" ], [ "Lithuania (Lietuva)", "lt", "370" ], [ "Luxembourg", "lu", "352" ], [ "Macau (澳門)", "mo", "853" ], [ "Macedonia (FYROM) (Македонија)", "mk", "389" ], [ "Madagascar (Madagasikara)", "mg", "261" ], [ "Malawi", "mw", "265" ], [ "Malaysia", "my", "60" ], [ "Maldives", "mv", "960" ], [ "Mali", "ml", "223" ], [ "Malta", "mt", "356" ], [ "Marshall Islands", "mh", "692" ], [ "Martinique", "mq", "596" ], [ "Mauritania (‫موريتانيا‬‎)", "mr", "222" ], [ "Mauritius (Moris)", "mu", "230" ], [ "Mayotte", "yt", "262", 1, [ "269", "639" ] ], [ "Mexico (México)", "mx", "52" ], [ "Micronesia", "fm", "691" ], [ "Moldova (Republica Moldova)", "md", "373" ], [ "Monaco", "mc", "377" ], [ "Mongolia (Монгол)", "mn", "976" ], [ "Montenegro (Crna Gora)", "me", "382" ], [ "Montserrat", "ms", "1", 16, [ "664" ] ], [ "Morocco (‫المغرب‬‎)", "ma", "212", 0 ], [ "Mozambique (Moçambique)", "mz", "258" ], [ "Myanmar (Burma) (မြန်မာ)", "mm", "95" ], [ "Namibia (Namibië)", "na", "264" ], [ "Nauru", "nr", "674" ], [ "Nepal (नेपाल)", "np", "977" ], [ "Netherlands (Nederland)", "nl", "31" ], [ "New Caledonia (Nouvelle-Calédonie)", "nc", "687" ], [ "New Zealand", "nz", "64" ], [ "Nicaragua", "ni", "505" ], [ "Niger (Nijar)", "ne", "227" ], [ "Nigeria", "ng", "234" ], [ "Niue", "nu", "683" ], [ "Norfolk Island", "nf", "672" ], [ "North Korea (조선 민주주의 인민 공화국)", "kp", "850" ], [ "Northern Mariana Islands", "mp", "1", 17, [ "670" ] ], [ "Norway (Norge)", "no", "47", 0 ], [ "Oman (‫عُمان‬‎)", "om", "968" ], [ "Pakistan (‫پاکستان‬‎)", "pk", "92" ], [ "Palau", "pw", "680" ], [ "Palestine (‫فلسطين‬‎)", "ps", "970" ], [ "Panama (Panamá)", "pa", "507" ], [ "Papua New Guinea", "pg", "675" ], [ "Paraguay", "py", "595" ], [ "Peru (Perú)", "pe", "51" ], [ "Philippines", "ph", "63" ], [ "Poland (Polska)", "pl", "48" ], [ "Portugal", "pt", "351" ], [ "Puerto Rico", "pr", "1", 3, [ "787", "939" ] ], [ "Qatar (‫قطر‬‎)", "qa", "974" ], [ "Réunion (La Réunion)", "re", "262", 0 ], [ "Romania (România)", "ro", "40" ], [ "Russia (Россия)", "ru", "7", 0 ], [ "Rwanda", "rw", "250" ], [ "Saint Barthélemy", "bl", "590", 1 ], [ "Saint Helena", "sh", "290" ], [ "Saint Kitts and Nevis", "kn", "1", 18, [ "869" ] ], [ "Saint Lucia", "lc", "1", 19, [ "758" ] ], [ "Saint Martin (Saint-Martin (partie française))", "mf", "590", 2 ], [ "Saint Pierre and Miquelon (Saint-Pierre-et-Miquelon)", "pm", "508" ], [ "Saint Vincent and the Grenadines", "vc", "1", 20, [ "784" ] ], [ "Samoa", "ws", "685" ], [ "San Marino", "sm", "378" ], [ "São Tomé and Príncipe (São Tomé e Príncipe)", "st", "239" ], [ "Saudi Arabia (‫المملكة العربية السعودية‬‎)", "sa", "966" ], [ "Senegal (Sénégal)", "sn", "221" ], [ "Serbia (Србија)", "rs", "381" ], [ "Seychelles", "sc", "248" ], [ "Sierra Leone", "sl", "232" ], [ "Singapore", "sg", "65" ], [ "Sint Maarten", "sx", "1", 21, [ "721" ] ], [ "Slovakia (Slovensko)", "sk", "421" ], [ "Slovenia (Slovenija)", "si", "386" ], [ "Solomon Islands", "sb", "677" ], [ "Somalia (Soomaaliya)", "so", "252" ], [ "South Africa", "za", "27" ], [ "South Korea (대한민국)", "kr", "82" ], [ "South Sudan (‫جنوب السودان‬‎)", "ss", "211" ], [ "Spain (España)", "es", "34" ], [ "Sri Lanka (ශ්‍රී ලංකාව)", "lk", "94" ], [ "Sudan (‫السودان‬‎)", "sd", "249" ], [ "Suriname", "sr", "597" ], [ "Svalbard and Jan Mayen", "sj", "47", 1, [ "79" ] ], [ "Sweden (Sverige)", "se", "46" ], [ "Switzerland (Schweiz)", "ch", "41" ], [ "Syria (‫سوريا‬‎)", "sy", "963" ], [ "Taiwan (台灣)", "tw", "886" ], [ "Tajikistan", "tj", "992" ], [ "Tanzania", "tz", "255" ], [ "Thailand (ไทย)", "th", "66" ], [ "Timor-Leste", "tl", "670" ], [ "Togo", "tg", "228" ], [ "Tokelau", "tk", "690" ], [ "Tonga", "to", "676" ], [ "Trinidad and Tobago", "tt", "1", 22, [ "868" ] ], [ "Tunisia (‫تونس‬‎)", "tn", "216" ], [ "Turkey (Türkiye)", "tr", "90" ], [ "Turkmenistan", "tm", "993" ], [ "Turks and Caicos Islands", "tc", "1", 23, [ "649" ] ], [ "Tuvalu", "tv", "688" ], [ "U.S. Virgin Islands", "vi", "1", 24, [ "340" ] ], [ "Uganda", "ug", "256" ], [ "Ukraine (Україна)", "ua", "380" ], [ "United Arab Emirates (‫الإمارات العربية المتحدة‬‎)", "ae", "971" ], [ "United Kingdom", "gb", "44", 0 ], [ "United States", "us", "1", 0 ], [ "Uruguay", "uy", "598" ], [ "Uzbekistan (Oʻzbekiston)", "uz", "998" ], [ "Vanuatu", "vu", "678" ], [ "Vatican City (Città del Vaticano)", "va", "39", 1, [ "06698" ] ], [ "Venezuela", "ve", "58" ], [ "Vietnam (Việt Nam)", "vn", "84" ], [ "Wallis and Futuna (Wallis-et-Futuna)", "wf", "681" ], [ "Western Sahara (‫الصحراء الغربية‬‎)", "eh", "212", 1, [ "5288", "5289" ] ], [ "Yemen (‫اليمن‬‎)", "ye", "967" ], [ "Zambia", "zm", "260" ], [ "Zimbabwe", "zw", "263" ], [ "Åland Islands", "ax", "358", 1, [ "18" ] ] 
    ];
    connectedCallback(){
        console.log(this.fieldsToEdit);
        console.log(this.toUpdateRecordId);

        //hide dropdown
        this.showCountries = false;

        window.addEventListener('resize', this.computeformfactor.bind(this));

        this.isSmallWidth = (window.innerWidth < this.widthDiff || (window.innerWidth >= 768 && window.innerWidth <= 1061)) ? true : false;
    }

    renderNewFormFactor = false;
    computeformfactor() {
        console.log('called computeformfactor');
        var current = (window.innerWidth < this.widthDiff || (window.innerWidth >= 768 && window.innerWidth <= 1061)) ? true : false;
        if(current != this.isSmallWidth) {
            this.isSmallWidth = current;
            this.renderNewFormFactor = true;
            this.showCountries = true;
            this.showCountries = false;
        }
    }

    renderedCallback() {
        if(!this.hasRendered) {
            try{

                // countryCode
                let opt;
                this.countrycodes = [];
                this.countrycode.forEach(ele =>{
                    ele[2] = '+'+ele[2];
                    do {
                        ele[2] += ' ';
                    }
                    while (ele[2].length < 6);
                    opt = {};
                    opt['id'] = ele[2];
                    opt['label'] = ele[2]+'  '+ele[0];
                    opt['value'] = ele[2];
                    opt['country'] = ele[0];
                    this.countrycodes.push(opt);
                });
                // end countryCode

                if(this.isSmallWidth) {
                    console.log('rendered callback fired');
                    console.log('isSmallWidth ' + this.isSmallWidth);
                    let divElement = this.template.querySelector('.ccClass');
                    divElement.classList.remove('slds-size_1-of-5');
                    divElement.classList.add('slds-size_2-of-5');

                    let divElement2 = this.template.querySelector('.pnClass');
                    divElement2.classList.remove('slds-size_4-of-5');
                    divElement2.classList.add('slds-size_3-of-5');
                }
                this.hasRendered = true;
                console.log(this.mobileNumber);
                if(this.mobileNumber != null) {
                    this.mobileNumberInput = this.mobileNumber.substr(this.mobileNumber.length - 10);
                    this.cntrycode = this.mobileNumber.substring(0, this.mobileNumber.length - 10);
                }

            } catch(e){console.log(e)}
        }
        if(this.renderNewFormFactor) {
            console.log('computed new form factor');
            
            if(this.isSmallWidth) {
                let divElement = this.template.querySelector('.ccClass');
                divElement.classList.remove('slds-size_1-of-5');
                divElement.classList.add('slds-size_2-of-5');

                let divElement2 = this.template.querySelector('.pnClass');
                divElement2.classList.remove('slds-size_4-of-5');
                divElement2.classList.add('slds-size_3-of-5');
                console.log('isSmallWidth');
            } else {
                let divElement = this.template.querySelector('.ccClass');
                divElement.classList.remove('slds-size_2-of-5');
                divElement.classList.add('slds-size_1-of-5');
                let divElement2 = this.template.querySelector('.pnClass');
                divElement2.classList.remove('slds-size_3-of-5');
                divElement2.classList.add('slds-size_4-of-5');
                console.log('!isSmallWidth');
            }
            this.renderNewFormFactor = false;
        }
    }

    /*renderedCallback() {
        console.log(inputtel + "/utils.js");
        
        //Initialize international telephone number
        if (!this.telInitialized) {
            Promise.all([
                loadScript(this, inputtel + '/data.js'),
                loadScript(this, inputtel + '/intlTelInput.js'),
                loadScript(this, inputtel + '/utils.js'),   
                loadStyle(this, inputtel + '/intlTelInput.css'),
                // loadStyle(this, inputtel + '/demo.css')
            ])
            .then(() => {
                this.telInitialized = true;
                console.log('Internation format loading complete..');
                if (this.title && this.title.includes("Phone Number")) {
                    let input = this.template.querySelector('lightning-input');
                    /*this.varInput = intlTelInput(input, {
                            separateDialCode : true,
                            initialCountry: "au",
                            preferredCountries: ['AU','NZ'],    //simplus ms
                            customContainer: "intl-tel-input",
                            // utilsScript: inputtel + "/utils.js",                 //simplus ms
                    })
                    // let iti = intlTelInputGlobals.getInstance(this.varInput);
                    // console.log(iti);
                    if (this.mobileNumber.length != 0) {
                        this.varInput.setNumber(this.mobileNumber);
                        console.log(this.varInput.getNumber());
                    }  
                }
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading International Telephone format',
                        message: error.message,
                        variant: 'error'
                    })
                );
            });
        }

        if (this.title && this.title.includes("Phone Number") && this.telInitialized) {
            
            let input = this.template.querySelector('lightning-input');
            this.varInput = intlTelInput(input, {
                    separateDialCode : true,
                    initialCountry: "au",
                    preferredCountries: ['AU','NZ'],    //simplus ms
                    customContainer: "intl-tel-input",
                    // utilsScript: inputtel + "/utils.js",                 //simplus ms
                });

            if (this.mobileNumber.length != 0) {
            this.varInput.setNumber(this.mobileNumber);
            }    
       }
    }*/

    //Mobile Number save logic
    handleMobileSubmission() {
        let numberCheck = this.template.querySelector('lightning-input').value;
        console.log(numberCheck);
        console.log(this.cntrycode);
        if (/^[\d ]*$/.test(numberCheck)) {
            let number = numberCheck;
            // let ccode = this.cntrycode.replace('+', '');
            let ccode = this.cntrycode;
            // ccode = ccode.replace(" ","");
            if (number.replace(/\s/g, "").length == 10) { 

                if (number[0] == '0') {
                    number = number.substring(1);
                }
                this.showLoadingSpinner = true;
                // let updatedNumber = `+${this.varInput.getSelectedCountryData().dialCode}${number}`;
                let updatedNumber = ccode + numberCheck;
                console.log(updatedNumber);
                const fields = {};
                fields['Id'] = this.toUpdateRecordId;
                fields[this.fieldsToEdit[0]] = updatedNumber;

                if (this.userType == 'Contact') {
                    // let updatedNumber = `+${this.varInput.getSelectedCountryData().dialCode}${number}`;
                    let updatedNumber = ccode + numberCheck;
                    const fields = {};
                    fields['Id'] = this.toUpdateRecordId;
                    fields[this.fieldsToEdit[0]] = updatedNumber;
                    this.updateSObject(fields);
                    this.handlePopupClose();
                    return;
                }


                updateRecord({fields})
                .then(() => {
                    const userFields = {};
                    userFields['Id'] = this.recordId;
                    // userFields['MobilePhone'] = `+${this.varInput.getSelectedCountryData().dialCode}${number}`;
                    userFields['MobilePhone'] = ccode + number;

                    this.updateSObject(userFields);
                    // Display fresh data in the form
                    this.handlePopupClose();
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error Updating record',
                            // message: (error.body.output && error.body.output.errors[0].message) || error.body.message,
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                    this.showLoadingSpinner = false;
                });

                
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: 'Please Enter a 10 digit number',
                        variant: 'warning',
                    }),
                );
            }
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please include only numbers',
                    variant: 'warning',
                }),
            );
        }
    }
    async updateSObject(userFields) {
        await updateSObject({sObj:userFields});
        getRecordNotifyChange([{recordId: this.recordId}]);
    }
    handleSubmit(event) {
        this.showLoadingSpinner = true;
        event.preventDefault();       // stop the form from submitting
        this.template.querySelector('lightning-record-edit-form').submit();       
    }    
    handleSuccess() {
        this.handlePopupClose();
    }
    handleError(event) {
        
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error Updating',
                    message: event.detail.detail,
                    variant: 'Warning'
                })
            );
        
        this.showLoadingSpinner = false;
    }
    handlePopupClose() {
        this.showLoadingSpinner = false;
        const selectedEvent = new CustomEvent("closepopup");
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }
    // getting file 
    handleFilesChange(event) {
        if(event.target.files.length > 0) {
            this.filesUploaded = event.target.files;
            this.fileName = event.target.files[0].name;
        }
    }

    handleUploadSave() {
        if(this.filesUploaded.length > 0) {
            this.uploadHelper();
        }
        else {
            this.fileName = 'Please select file to upload!!';
        }
    }

    uploadHelper() {
        this.file = this.filesUploaded[0];
       if (this.file.size > this.MAX_FILE_SIZE) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error while uploading File',
                message: 'File Size too large, Please choose a different size',
                variant: 'error',
            }),
            );
            return;
        }
        this.showLoadingSpinner = true;
        // create a FileReader object 
        this.fileReader= new FileReader();
        // set onload function of FileReader object  
        this.fileReader.onloadend = (() => {
            this.fileContents = this.fileReader.result;
            let base64 = 'base64,';
            this.content = this.fileContents.indexOf(base64) + base64.length;
            this.fileContents = this.fileContents.substring(this.content);
            
            // call the uploadProcess method 
            this.saveToFile();
        });
    
        this.fileReader.readAsDataURL(this.file);
    }

    // Calling apex class to insert the file
    saveToFile() {
        saveAttachment({ base64Data : encodeURIComponent(this.fileContents)})
        .then(result => {
            window.console.log('result ====> ' +result);
            // refreshing the datatable
            this.showLoadingSpinner = false;

            // Showing Success message after file insert
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!!',
                    message: this.file.name + ' - Uploaded Successfully!!!',
                    variant: 'success',
                }),
            );
            this.handlePopupClose();

        })
        .catch(error => {
            // Showing errors if any while inserting the files
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while uploading File',
                    message: error.message,
                    variant: 'error',
                }),
            );
        });
    }

    showCountries = true;
    cntrycode;
    countrycodes = [];

    /************************/
    handleShowCountriesFalse(){
        this.showCountries = false;
    }

    handleShowCountries(){        
        if (this.showCountries) {
            this.showCountries = false;
        } else {
            this.showCountries = true;
        }
    }

    handleOnClickCountry(event){     
        this.cntrycode = event.target.dataset.id;   
        this.showCountries = false;
    }
}