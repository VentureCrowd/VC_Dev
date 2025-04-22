({
    doInit: function (cmp, event, helper) {
        /* var cList= [{"value":"93","key":"Afghanistan +93"},
                     {"value":"358","key":"Åland +358"},
                     {"value":"355","key":"Albania +355"},
                     {"value":"213","key":"Algeria +213"},
                     {"value":"1684","key":"American Samoa +1684"},
                     {"value":"376","key":"Andorra +376"},
                     {"value":"244","key":"Angola +244"},
                     {"value":"1264","key":"Anguilla +1264"},
                     {"value":"672","key":"Antarctica +672"},
                     {"value":"1268","key":"Antigua and Barbuda +1268"},
                     {"value":"54","key":"Argentina +54"},{"value":"374","key":"Armenia +374"},{"value":"297","key":"Aruba +297"},{"value":"61","key":"Australia +61"},{"value":"43","key":"Austria +43"},{"value":"994","key":"Azerbaijan +994"},{"value":"1242","key":"Bahamas +1242"},{"value":"973","key":"Bahrain +973"},{"value":"880","key":"Bangladesh +880"},{"value":"1246","key":"Barbados +1246"},{"value":"375","key":"Belarus +375"},{"value":"32","key":"Belgium +32"},{"value":"501","key":"Belize +501"},{"value":"229","key":"Benin +229"},{"value":"1441","key":"Bermuda +1441"},{"value":"975","key":"Bhutan +975"},{"value":"591","key":"Bolivia +591"},{"value":"599","key":"Bonaire +599"},{"value":"387","key":"Bosnia and Herzegovina +387"},{"value":"267","key":"Botswana +267"},{"value":"55","key":"Brazil +55"},{"value":"246","key":"British Indian Ocean Territory +246"},{"value":"1284","key":"British Virgin Islands +1284"},{"value":"673","key":"Brunei +673"},{"value":"359","key":"Bulgaria +359"},{"value":"226","key":"Burkina Faso +226"},{"value":"257","key":"Burundi +257"},{"value":"855","key":"Cambodia +855"},{"value":"237","key":"Cameroon +237"}
                     ,{"value":"1","key":"Canada +1"},{"value":"238","key":"Cape Verde +238"},{"value":"345","key":"Cayman Islands +345"},{"value":"236","key":"Central African Republic +236"},{"value":"235","key":"Chad +235"},{"value":"56","key":"Chile +56"},{"value":"86","key":"China +86"},{"value":"61","key":"Christmas Island +61"},{"value":"61","key":"Cocos [Keeling] Islands +61"},{"value":"57","key":"Colombia +57"},{"value":"269","key":"Comoros +269"},{"value":"243","key":"Congo +243"},{"value":"682","key":"Cook Islands +682"},{"value":"506","key":"Costa Rica +506"},{"value":"385","key":"Croatia +385"},{"value":"53","key":"Cuba +53"},{"value":"599","key":"Curaçao +599"},{"value":"357","key":"Cyprus +357"},{"value":"420","key":"Czech Republic +420"},{"value":"45","key":"Denmark +45"},{"value":"253","key":"Djibouti +253"},{"value":"1767","key":"Dominica +1767"},{"value":"1767","key":"Dominican Republic +1767"},{"value":"670","key":"East Timor +670"},{"value":"593","key":"Ecuador +593"},{"value":"20","key":"Egypt +20"},{"value":"503","key":"El Salvador +503"},{"value":"240","key":"Equatorial Guinea +240"},{"value":"291","key":"Eritrea +291"},{"value":"372","key":"Estonia +372"},{"value":"251","key":"Ethiopia +251"},{"value":"500","key":"Falkland Islands +500"},{"value":"298","key":"Faroe Islands +298"}
                     ,{"value":"691","key":"Federated States of Micronesia +691"},{"value":"679","key":"Fiji +679"},{"value":"358","key":"Finland +358"},{"value":"33","key":"France +33"},{"value":"594","key":"French Guiana +594"},{"value":"689","key":"French Polynesia +689"},{"value":"78","key":"French Southern Territories"},{"value":"241","key":"Gabon +241"},{"value":"220","key":"Gambia +220"},{"value":"995","key":"Georgia +995"},{"value":"49","key":"Germany +49"},{"value":"233","key":"Ghana +233"},{"value":"350","key":"Gibraltar +350"},{"value":"30","key":"Greece +30"},{"value":"299","key":"Greenland +299"},{"value":"1473","key":"Grenada +1473"},{"value":"590","key":"Guadeloupe +590"},{"value":"1671","key":"Guam +1671"},{"value":"502","key":"Guatemala +502"},{"value":"44","key":"Guernsey +44"},{"value":"224","key":"Guinea +224"},{"value":"245","key":"Guinea-Bissau +245"},{"value":"595","key":"Guyana +595"},{"value":"509","key":"Haiti +509"},{"value":"962","key":"Hashemite Kingdom of Jordan +962"},{"value":"504","key":"Honduras +504"},{"value":"852","key":"Hong Kong +852"},{"value":"36","key":"Hungary +36"},{"value":"354","key":"Iceland +354"},{"value":"91","key":"India +91"},{"value":"62","key":"Indonesia +62"},{"value":"98","key":"Iran +98"},{"value":"964","key":"Iraq +964"},{"value":"353","key":"Ireland +353"},{"value":"44","key":"Isle of Man +44"},{"value":"972","key":"Israel +972"},{"value":"39","key":"Italy +39"},{"value":"225","key":"Ivory Coast +225"},{"value":"1876","key":"Jamaica +1876"},{"value":"81","key":"Japan +81"},{"value":"44","key":"Jersey +44"},{"value":"77","key":"Kazakhstan +77"},{"value":"254","key":"Kenya +254"}
                     ,{"value":"686","key":"Kiribati +686"},{"value":"383","key":"Kosovo +383"},{"value":"965","key":"Kuwait +965"},{"value":"996","key":"Kyrgyzstan +996"},{"value":"856","key":"Laos +856"},{"value":"371","key":"Latvia +371"},{"value":"961","key":"Lebanon +961"},{"value":"266","key":"Lesotho +266"},{"value":"231","key":"Liberia +231"},{"value":"218","key":"Libya +218"},{"value":"423","key":"Liechtenstein +423"},{"value":"352","key":"Luxembourg +352"},{"value":"853","key":"Macau +853"},{"value":"389","key":"Macedonia +389"},{"value":"261","key":"Madagascar +261"},{"value":"265","key":"Malawi +265"},{"value":"60","key":"Malaysia +60"},{"value":"960","key":"Maldives +960"},{"value":"223","key":"Mali +223"},{"value":"356","key":"Malta +356"},{"value":"692","key":"Marshall Islands +692"},{"value":"596","key":"Martinique +596"},{"value":"222","key":"Mauritania +222"},{"value":"230","key":"Mauritius +230"},{"value":"262","key":"Mayotte +262"},{"value":"52","key":"Mexico +52"},{"value":"377","key":"Monaco +377"},{"value":"976","key":"Mongolia +976"},{"value":"382","key":"Montenegro +382"},{"value":"1664","key":"Montserrat +1664"},{"value":"212","key":"Morocco +212"},{"value":"258","key":"Mozambique +258"},{"value":"95","key":"Myanmar [Burma] +95"},{"value":"264","key":"Namibia +264"},{"value":"674","key":"Nauru +674"},{"value":"977","key":"Nepal +977"},{"value":"31","key":"Netherlands +31"},{"value":"687","key":"New Caledonia +687"},{"value":"64","key":"New Zealand +64"},{"value":"505","key":"Nicaragua +505"},{"value":"227","key":"Niger +227"},{"value":"234","key":"Nigeria +234"},{"value":"683","key":"Niue +683"}
                     ,{"value":"672","key":"Norfolk Island +672"},{"value":"850","key":"North Korea +850"},{"value":"1670","key":"Northern Mariana Islands +1670"},{"value":"47","key":"Norway +47"},{"value":"968","key":"Oman +968"},{"value":"92","key":"Pakistan +92"},{"value":"680","key":"Palau +680"},{"value":"970","key":"Palestine +970"},{"value":"507","key":"Panama +507"},{"value":"675","key":"Papua New Guinea +675"},{"value":"595","key":"Paraguay +595"}
                     ,{"value":"51","key":"Peru +51"},{"value":"63","key":"Philippines +63"},{"value":"872","key":"Pitcairn Islands +872"},{"value":"48","key":"Poland +48"},{"value":"351","key":"Portugal +351"},{"value":"1939","key":"Puerto Rico +1939"},{"value":"974","key":"Qatar +974"},{"value":"82","key":"Republic of Korea +82"},{"value":"370","key":"Republic of Lithuania +370"},{"value":"373","key":"Republic of Moldova +373"},{"value":"242","key":"Republic of the Congo +242"},{"value":"262","key":"Réunion +262"},{"value":"40","key":"Romania +40"},{"value":"7","key":"Russia +7"},{"value":"250","key":"Rwanda +250"},{"value":"290","key":"Saint Helena +290"},{"value":"1869","key":"Saint Kitts and Nevis +1869"},{"value":"1758","key":"Saint Lucia +1758"},{"value":"590","key":"Saint Martin +590"},{"value":"508","key":"Saint Pierre and Miquelon +508"},{"value":"1784","key":"Saint Vincent and the Grenadines +1784"},{"value":"590","key":"Saint-Barthélemy +590"},{"value":"685","key":"Samoa +685"},{"value":"378","key":"San Marino +378"},{"value":"239","key":"São Tomé and Príncipe +239"},{"value":"966","key":"Saudi Arabia +966"},{"value":"221","key":"Senegal +221"},{"value":"381","key":"Serbia +381"},{"value":"248","key":"Seychelles +248"},{"value":"232","key":"Sierra Leone +232"},{"value":"65","key":"Singapore +65"},{"value":"590","key":"Sint Maarten +590"},{"value":"421","key":"Slovakia +421"},{"value":"386","key":"Slovenia +386"},{"value":"677","key":"Solomon Islands +677"},{"value":"252","key":"Somalia +252"},{"value":"27","key":"South Africa +27"},{"value":"500","key":"South Georgia and the South Sandwich Islands +500"},{"value":"211","key":"South Sudan +211"},{"value":"34","key":"Spain +34"},{"value":"94","key":"Sri Lanka +94"},{"value":"249","key":"Sudan +249"},{"value":"597","key":"Suriname +597"},{"value":"47","key":"Svalbard and Jan Mayen +47"},{"value":"268","key":"Swaziland +268"},{"value":"46","key":"Sweden +46"},{"value":"41","key":"Switzerland +41"},{"value":"963","key":"Syria +963"},{"value":"886","key":"Taiwan +886"},{"value":"992","key":"Tajikistan +992"}
                     ,{"value":"255","key":"Tanzania +255"},{"value":"66","key":"Thailand +66"},{"value":"228","key":"Togo +228"}
                     ,{"value":"690","key":"Tokelau +690"},
                     {"value":"676","key":"Tonga +676"},
                     {"value":"1868","key":"Trinidad and Tobago +1868"},
                     {"value":"216","key":"Tunisia +216"},
                     {"value":"90","key":"Turkey +90"},{"value":"993","key":"Turkmenistan +993"},{"value":"1649","key":"Turks and Caicos Islands +1649"},
                     {"value":"688","key":"Tuvalu +688"},{"value":"230","key":"U.S. Minor Outlying Islands"},{"value":"1340","key":"U.S. Virgin Islands +1340"},{"value":"256","key":"Uganda +256"},
                     {"value":"380","key":"Ukraine +380"},{"value":"971","key":"United Arab Emirates +971"},
                     {"value":"44","key":"United Kingdom +44"},{"value":"1","key":"United States +1"},{"value":"598","key":"Uruguay +598"},{"value":"998","key":"Uzbekistan +998"},{"value":"678","key":"Vanuatu +678"},{"value":"379","key":"Vatican City +379"},{"value":"58","key":"Venezuela +58"},{"value":"84","key":"Vietnam +84"},{"value":"681","key":"Wallis and Futuna +681"},{"value":"967","key":"Yemen +967"},{"value":"260","key":"Zambia +260"},
                     {"value":"263","key":"Zimbabwe;; +263"}];*/

        var cList = [{ "value": "93", "label": "Afghanistan +93" },
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
        { "value": "263", "label": "Zimbabwe;; +263" }];
        cmp.set("v.countriesList", cList);
        if (window.screen.width < 490 || $A.get("$Browser.isPhone")) {
            cmp.set('v.isMobile', true);
        }
    },
    handleReset: function (component, event, helper) {
        var comp = component.find('nicaptcha');
        comp.reset();
        var submitButton = component.find('submit');
        submitButton.set("v.disabled", true);
    },
    handleExecute: function (component, event, helper) {
        var comp = component.find('nicaptcha');
        comp.execute();
    },
    handleGetCaptcha: function (component, event, helper) {
        var comp = component.find('nicaptcha');
        var response = comp.getCaptchaResponse();
        console.log('Response: ' + response);
    },
    handleCallback: function (component, event, helper) {
        var submitButton = component.find('submit');
        submitButton.set("v.disabled", false);
        console.log('Callback: ' + event.getParam('response'));
    },
    handleVerifyCallback: function (component, event, helper) {
        console.log('Verified Response: ' + event.getParam('response'));
    },
    handleExpiredCallback: function (component, event, helper) {
        var submitButton = component.find('submit');
        submitButton.set("v.disabled", true);
        console.log('Expired Callback');
    },
    handleErrorCallback: function (component, event, helper) {
        var submitButton = component.find('submit');
        submitButton.set("v.disabled", true);
        console.log('Error Callback');
    },
    handleClick: function (cmp, event, helper) {
        cmp.set('v.showformValidation', false);
        var countryCode = cmp.get("v.countryCode");
        var firstName = cmp.get("v.firstName");
        var lastName = cmp.get("v.lastName");
        var mobile = cmp.get("v.mobile");
        var email = cmp.get("v.email");
        var confirmPassword = cmp.get("v.confirmPassword");
        var password = cmp.get("v.password");
        var investPimpa = cmp.get("v.investmentPimpa");
        var investBotanic = cmp.get("v.investmentBotanic");
        var investSYield = cmp.get("v.investmentSYield");
        var investorDetail = cmp.get("v.investorDetail");
        var Email_Opt_In = cmp.get("v.Email_Opt_In");
        if (helper.isEmpty(countryCode) ||
            helper.isEmpty(firstName) ||
            helper.isEmpty(lastName) ||
            helper.isEmpty(mobile) ||
            helper.isEmpty(email)
        ) {
            cmp.set('v.showformValidation', true); return;
        } else if (helper.isEmpty(password)) {
            cmp.set('v.showformValidation', true);
            helper.passwordKeyUp(cmp, event);
            return;
        } else if (helper.isEmpty(confirmPassword) || (confirmPassword != password)) {
            cmp.set('v.showformValidation', true);
            helper.confirmPasswordKeyUp(cmp, event);
            return;
        } else if (!cmp.get("v.terms")) {
            cmp.set('v.showformValidation', true);
            cmp.set('v.formValidationText', 'Please select the terms and conditions checkbox to proceed with registration');
            return;
        }
        var tempCountryCodeList = countryCode.split(' ');
        countryCode = tempCountryCodeList[tempCountryCodeList.length - 1];
        while (mobile.charAt(0) === '0') {
            mobile = mobile.substring(1);
        }
        mobile = countryCode + mobile;
        var registerSubmit = {
            'firstName': firstName,
            'lastName': lastName,
            'mobile': mobile,
            'email': cmp.get("v.email"),
            'password': cmp.get("v.password"),
            'confirmPassword': cmp.get("v.confirmPassword"),
            "terms": cmp.get("v.terms"),
            "investSYield": investSYield,
            "investorDetail": investorDetail,
            "investSYield": investSYield,
            "Email_Opt_In": Email_Opt_In,
            "investPimpa": investPimpa
        };
        //console.log(registerSubmit);
        var action = cmp.get('c.getRegisterSubmit');
        cmp.set('v.showspinner', true);
        // method name i.e. getEntity should be same as defined in apex class
        // params name i.e. entityType should be same as defined in getEntity method
        action.setParams({
            "registerComponentInfo": registerSubmit
        });
        action.setCallback(this, function (a) {
            var state = a.getState(); // get the response state
            cmp.set('v.showspinner', false);
            if (state == 'SUCCESS') {
                console.log('success');
                console.log(a.getReturnValue());
                if (a.getReturnValue() == 'passwordResetExistingUser') {
                    cmp.set("v.isResetModal", true);
                } else if (a.getReturnValue() == 'error') {
                    cmp.set("v.showLoginError", true);
                } else {
                    window.location.replace(a.getReturnValue());
                }
            } else if (state == 'Error' || state == 'ERROR') {
                cmp.set("v.showLoginError", true);
            }
        });
        $A.enqueueAction(action);
    },
    passwordKeyUp: function (cmp, event, helper) {
        helper.passwordKeyUp(cmp, event);

    },
    confirmPasswordKeyUp: function (cmp, event, helper) {
        helper.confirmPasswordKeyUp(cmp, event);
        /*if(cmp.get("v.password") != cmp.get("v.confirmPassword")){
            $A.util.addClass(cmp.find("confirmPassword"), "slds-has-error-reCap"); // remove red border
            $A.util.removeClass(cmp.find("confirmPassword"), "hide-error-message-reCap");
            cmp.find("confirmPassword").reportValidity();
            cmp.find("confirmPassword").setCustomValidity("password and confirmpassword must match");
        } else {
            $A.util.removeClass(cmp.find("confirmPassword"), "slds-has-error"); // remove red border
            $A.util.addClass(cmp.find("confirmPassword"), "hide-error-message");
        }*/
        //$A.get('e.force:refreshView').fire(); 
    },
    onMobileKeyUp: function (cmp, event, helper) {
        var mobilePattern = /^(\d{9,10}){1}$/g;
        var cmpFindMobile = cmp.find("mobile");
        var mobileInfo = cmp.get("v.mobile");
        if (!mobilePattern.test(mobileInfo)) {
            $A.util.addClass(cmpFindMobile, "slds-has-error");
            $A.util.removeClass(cmpFindMobile, "hide-error-message");
            cmpFindMobile.reportValidity();
            cmpFindMobile.setCustomValidity("Invalid Mobile Number!");
        } else {
            $A.util.removeClass(cmpFindMobile, "slds-has-error"); // remove red border
            $A.util.addClass(cmpFindMobile, "hide-error-message");
        }
    },
    closeResetModal: function (cmp, event, helper) {
        helper.closeResetModal(cmp, event);
    },
    redirectToLogin: function (cmp, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": '/'
        });

        urlEvent.fire();
    },
    redirectToForgotPassword: function (cmp, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": '/' + 'ForgotPassword'
        });

        urlEvent.fire();
    },

    handleChange: function (cmp, event) {
        var changeValue = event.getParam("value");
        cmp.set('v.investorDetail', changeValue);
    },

    handleMoreInfo: function (cmp, event) {
        cmp.set('v.showMoreInfo', true);
        document.querySelector('body').classList.add('modal-active');
    },
    handleCancel: function (cmp, event) {
        cmp.set('v.showMoreInfo', false);
        document.querySelector('body').classList.remove('modal-active');
    },
    handleTermsAndConditionsInNewWindow: function (component, event, helper) {
        window.open("https://www.venturecrowd.com.au/s/legals", '_blank');
    },
    handleChangeTerm: function (cmp, event) {
        cmp.set('v.Email_Opt_In', true);
        cmp.set('v.terms', true);
    },
    handleOnClickCountry: function (cmp, event) {
        var getCode = event.currentTarget.dataset.id;
        cmp.set('v.countryCode', getCode);

        cmp.set('v.showCountries', false);
    },
    handleShowCountries: function (cmp, event) {
        var showCountries = cmp.get('v.showCountries');
        if (showCountries == true) {
            cmp.set('v.showCountries', false);
        } else {
            cmp.set('v.showCountries', true);
        }

    },
    handleShowCountriesFalse: function (cmp, event) {

            cmp.set('v.showCountries', false);

    }
})