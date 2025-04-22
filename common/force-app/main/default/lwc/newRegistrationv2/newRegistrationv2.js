/* eslint-disable dot-notation */
import { LightningElement, track, wire } from 'lwc';

// Schema Imports
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import Industry_Field from '@salesforce/schema/Account.Sector__c';

// Apex Imports
import verifyrecaptchaToken from '@salesforce/apex/ReCaptchaAuraController.verifyrecaptchaToken';
import createAccountAndUser from '@salesforce/apex/ReCaptchaAuraController.createAccountAndUser';
import getRecordTypeId from '@salesforce/apex/Utils.getRecordTypeId';
import apex__getLeadById from '@salesforce/apex/LeadControllerNew.getLeadById';

// Resource Imports
import GLObal_ASSET from '@salesforce/resourceUrl/VC_CF_GlobalAssets';
import VC_MasterCss_New from '@salesforce/resourceUrl/VC_MasterCss_NewTemp';
import portalAssets from '@salesforce/resourceUrl/VC_NewPortalAssets';
import arrowIcons from '@salesforce/resourceUrl/ReturnArrows_Icon';
import pageUrl from '@salesforce/resourceUrl/captcha_HTML';

// Utility Imports
import { Utility } from 'c/utils';
import { mobileCodes } from './mobileCodes';

// Screen Templates
import screen1 from './screen1.html';
import screen2 from './screen2.html';
import screen3 from './screen3.html';
import screen4 from './screen4.html';

// Standard Components Imports
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';
import { CurrentPageReference } from 'lightning/navigation';

/**
 * Represents the New Registration component.
 * Handles user registration through multiple screens with form validation and server-side interactions.
 */
export default class NewRegistrationv2 extends LightningElement {
    // Record Type IDs
    venturePersonAccRecordTypeId;
    ventureCompanyAccRecordTypeId;

    //lead ID
    @track leadId;
    @track leadData={
        firstName: '',
        lastName: '',
        email: '',
        company: '',
        mobile: '',
        source: '',
        webSource: '',
    };

    // Form Validation
    @track isFormValid = false;

    // Picklist Values
    @wire(getPicklistValues, {
        recordTypeId: '$ventureCompanyAccRecordTypeId',
        fieldApiName: Industry_Field
    })
    industryPicklistValues;

    // User Selections
    @track selectedValue;
    @track selectedSector;
    @track isNoSelected = false;

    // Navigation and Screens
    screen1 = true;
    screen2 = false;
    screen3 = false;
    screen4 = false;

    // Loading State
    @track showspinner = false;

    // User Data
    userdata = {};
    abn;
    isuseralredayexsists = false;

    // Background Images and Icons
    page1Background = `${portalAssets}/Assets/Images/Registration_page1.jpg`;
    page2Background = `${portalAssets}/Assets/Images/Registration_page2.jpg`;
    page3Background = `${portalAssets}/Assets/Images/Registration_page3.jpg`;
    BtnArrow = `${portalAssets}/Assets/Icons/BtnArrow.svg`;
    mainlogo = `${portalAssets}/Assets/Images/teal_icon.png`;
    leftArrow = `${arrowIcons}/ReturnArrow_Default.svg`;

    // Screen 1 Icons
    vc_logo = `${portalAssets}/Assets/Icons/teal_icon.png`;
    medicalIcon = `${portalAssets}/Assets/Icons/medical.svg`;
    jayrideIcon = `${portalAssets}/Assets/Icons/Jayride_logo.svg`;

    // Screen 2 Icons
    engeneicIcon = `${portalAssets}/Assets/Icons/EnGeneIC_Logo.svg`;
    vectorIcon = `${portalAssets}/Assets/Icons/Vector_logo.svg`;
    nexbaIcon = `${portalAssets}/Assets/Icons/nexba_logo.svg`;

    // Screen 3 Icons and Logos | Same with Screen 4 Logos
    australianIcon = `${portalAssets}/Assets/Icons/TheAustralian.png`;
    bnaIcon = `${portalAssets}/Assets/Icons/BNA.png`;
    frIcon = `${portalAssets}/Assets/Icons/FR.png`;
    ausbizIcon = `${portalAssets}/Assets/Icons/ausbiz.png`;
    sevenIcon = `${portalAssets}/Assets/Icons/7.png`;

    // Flags and States
    isCaptchValidated = false;
    screen1error = false;
    accId;
    userId;
    retURL;
    IsAccountCreated;
    disablesecondbutton = true;
    disablethirdbutton = true;
    rendered = false;

    // Sandbox Environment Flag
    @track isSandbox = false;

    // Navigation URL
    navigateTo;

    /**
     * Retrieves the current page reference and sets the form type based on URL parameters.
     * @param {Object} pageReference - The current page reference object.
     * @wire
     */
    @wire(CurrentPageReference)
    async getPageReference(pageReference) {
        if (pageReference) {
            this.leadId = pageReference.state.id ? pageReference.state.id : pageReference.state.skey;
            // Perform additional logic based on the id parameter
            if(this.leadId){
                this.fetchLeadData(this.leadId)
            }
        }
    }

     /**
     * Fetches lead data from Apex and populates the form fields.
     * @param {Id} leadId - The ID of the lead record.
     */
     async fetchLeadData(leadId) {
        try {
            const lead = await apex__getLeadById({ leadId });
            if (lead) {
                // Map Apex Lead fields to leadData properties
                this.leadData = {
                    firstName: lead.firstName || '',
                    lastName: lead.lastName || '',
                    email: lead.email || '',
                    company: lead.company || '',
                    mobile: lead.mobileNumber || '',
                    source: lead.source || '',
                    webSource : lead.webSource || '',
                    // Map other fields as necessary
                };
                // Optionally, populate form fields programmatically
                // this.populateFormFields();
            }
        } catch (error) {
            console.error('Error fetching lead data:', error.body?.message || error.message);
            this.showtoast('Error', 'Unable to retrieve lead data.', 'error');
        }
    }


    /**
     * Lifecycle hook: Invoked when the component is inserted into the DOM.
     * Loads CSS, fetches record type IDs, and determines if running in a sandbox.
     */
    connectedCallback() {
        this.loadStyles()
            .then(() => {
                this.scrollToLogo();
            })
            .catch(error => {
                console.error('Error loading styles:', error.body?.message || error);
            });

        this.getRecordTypeId('Ventures Company Account');
        this.getRecordTypeId('Ventures Person Account');

        this.checkSandboxEnvironment();
    }

    /**
     * Constructor to initialize component properties and event listeners.
     */
    constructor() {
        super();
        this.navigateTo = pageUrl;
        window.addEventListener('message', this.listenForMessage.bind(this));
    }

    /**
     * Loads the necessary CSS styles.
     * @returns {Promise<void>}
     */
    loadStyles() {
        return loadStyle(this, VC_MasterCss_New);
    }

    /**
     * Scrolls the window to the registration page logo.
     */
    scrollToLogo() {
        const logoElement = this.template.querySelector('.vc_RegistrationPageLogo');
        if (logoElement) {
            window.scrollTo(0, logoElement.scrollHeight);
        }
    }

    /**
     * Determines if the current environment is a sandbox.
     */
    checkSandboxEnvironment() {
        const currentUrl = window.location.href;
        this.isSandbox = currentUrl.includes('sandbox');
    }

    /**
     * Handles incoming messages for reCAPTCHA token verification.
     * @param {MessageEvent} message - The message event containing data.
     */
    listenForMessage(message) {
        const data = JSON.stringify(message.data);
        if (data && data.includes('****CaptchToken****')) {
            const token = message.data.split('****CaptchToken****')[0];
            this.verifyCaptchaToken(token);
        }
    }

    /**
     * Verifies the reCAPTCHA token by invoking the Apex method.
     * @param {string} token - The reCAPTCHA token.
     */
    async verifyCaptchaToken(token) {
        try {
            const result = await verifyrecaptchaToken({ token });
            this.isCaptchValidated = result;
        } catch (error) {
            console.error('Captcha verification failed:', error);
        }
    }

    /**
     * Renders the appropriate screen based on the current state.
     * @returns {TemplateResult}
     */
    render() {
        if (this.screen1) return screen1;
        if (this.screen2) return screen2;
        if (this.screen3) return screen3;
        return screen4;
    }

    // Background Style Getters
    get backgroundStylePage1() {
        return `background-image:url(${this.page1Background})`;
    }

    get backgroundStylePage2() {
        return `background-image:url(${this.page2Background})`;
    }

    get backgroundStylePage3() {
        return `background-image:url(${this.page3Background})`;
    }

    /**
     * Provides phone number options from imported mobile codes.
     * @returns {Array<{label: string, value: string}>}
     */
    get phoneoptions() {
        return mobileCodes;
    }

    /**
     * Validates the password based on defined criteria.
     * @param {string} password - The password to validate.
     * @returns {string|null} - Returns validation message or null if valid.
     */
    isValidPassword(password) {
        if (password.length < 8) {
            return 'Password must be at least 8 characters long.';
        }

        if (password.length > 128) {
            return 'Password cannot be longer than 128 characters.';
        }

        if (!/[A-Za-z]/.test(password)) {
            return 'Password must contain at least one letter.';
        }

        if (!/\d/.test(password)) {
            return 'Password must contain at least one number.';
        }

        const commonPatterns = ['password', 'welcome', '123456', 'qwerty', 'asdfgh', 'zxcvbn'];
        if (commonPatterns.some(word => password.toLowerCase().includes(word))) {
            return 'Password should not contain easy keyboard patterns or common words.';
        }

        return null;
    }

    /**
     * Handles changes to the first name input.
     * @param {Event} event - The input change event.
     */
    handleFirstName(event) {
        this.handleInputChange(event);
    }

    /**
     * Handles changes to the last name input.
     * @param {Event} event - The input change event.
     */
    handleLastName(event) {
        this.handleInputChange(event);
    }

    /**
     * Handles changes to the email input with validation.
     * @param {Event} event - The input change event.
     */
    handleEmailChange(event) {
        const email = event.target.value;
        const emailInput = event.target;

        const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

        if (!emailPattern.test(email)) {
            emailInput.setCustomValidity('Please enter a valid email address.');
        } else {
            emailInput.setCustomValidity('');
        }

        emailInput.reportValidity();
        this.handleInputChange(event);
    }

    /**
     * Handles changes to the password input with validation.
     * @param {Event} event - The input change event.
     */
    passwordchange(event) {
        const password = event.target.value;
        const passwordEle = this.template.querySelector('[data-id="password"]');

        const validationMessage = this.isValidPassword(password);

        if (validationMessage) {
            passwordEle.setCustomValidity(validationMessage);
        } else {
            passwordEle.setCustomValidity('');
        }
        passwordEle.reportValidity();

        this.cnfpasswordchange();
        this.handleInputChange(event);
    }

    /**
     * Handles changes to the confirm password input with validation.
     */
    cnfpasswordchange() {
        const cnfpassword = this.template.querySelector('[data-id="cnfpassword"]');
        const password = this.template.querySelector('[data-id="password"]');

        if (cnfpassword.value !== password.value) {
            cnfpassword.setCustomValidity('Password and Confirm Password does not match. Please verify.');
        } else {
            cnfpassword.setCustomValidity('');
        }
        cnfpassword.reportValidity();

        this.handleInputChange(cnfpassword);
    }

    /**
     * Validates all form inputs and updates the form validity state.
     */
    validateForm() {
        const inputElements = [
            ...this.template.querySelectorAll('lightning-input'),
            ...this.template.querySelectorAll('lightning-combobox')
        ];
        this.isFormValid = inputElements.every(input => input.checkValidity());
    }

    /**
     * Generic handler for input changes to validate the form.
     * @param {Event} event - The input change event.
     */
    handleInputChange(event) {
        this.validateForm();
    }

    /**
     * Handles changes to the mobile code input.
     * @param {Event} event - The input change event.
     */
    handlemobilecodeChange(event) {
        this.handleInputChange(event);
    }

    /**
     * Handles changes to the mobile number input with validation.
     * @param {Event} event - The input change event.
     */
    handlemobileChange(event) {
        const inputMobile = event.target.value;
        const mobilePattern = /^(\d{9,10}){1}$/g;

        if (!mobilePattern.test(inputMobile)) {
            event.target.setCustomValidity('Invalid Mobile Number.');
        } else {
            event.target.setCustomValidity('');
        }
        event.target.reportValidity();
        this.handleInputChange(event);
    }

    /**
     * Handles changes to checkboxes.
     * @param {Event} event - The checkbox change event.
     */
    handleCheckboxChange(event) {
        this.handleInputChange(event);
    }

    /**
     * Handles incoming messages for reCAPTCHA token verification.
     * @param {MessageEvent} message - The message event containing data.
     */
    listenForMessage(message) {
        const data = JSON.stringify(message.data);
        if (data && data.includes('****CaptchToken****')) {
            const token = message.data.split('****CaptchToken****')[0];
            this.verifyrecaptchaToken(token);
        }
    }

    /**
     * Verifies the reCAPTCHA token by invoking the Apex method.
     * @param {string} token - The reCAPTCHA token.
     */
    async verifyrecaptchaToken(token) {
        try {
            const result = await verifyrecaptchaToken({ token });
            this.isCaptchValidated = result;
        } catch (error) {
            console.error('Captcha verification failed:', error);
        }
    }

    /**
     * Displays a toast message.
     * @param {string} title - The title of the toast.
     * @param {string} message - The message/content of the toast.
     * @param {string} variant - The variant type of the toast (e.g., 'success', 'error').
     */
    showtoast(title, message, variant) {
        const evt = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(evt);
    }

    /**
     * Handles navigation to Screen 2 after validation.
     */
    async handlePage2() {
        this.validateForm();

        if (this.isFormValid && (this.isCaptchValidated || this.isSandbox)) {
            this.showspinner = true;

            try {
                const userDataMap = this.constructUserDataMap();
                this.userdata = { ...this.userdata, ...userDataMap };

                this.screen1 = false;
                this.screen2 = true;
            } catch (error) {
                console.error('Error handling Page 2:', error);
                this.screen1error = true;
                this.showtoast('Error', 'There was an error while processing the request. Please contact our support team.', 'error');
            } finally {
                this.showspinner = false;
            }
        } else {
            this.showtoast('Error', 'Please verify your inputs.', 'error');
        }
    }

    /**
     * Constructs the user data map from form inputs and URL parameters.
     * @returns {Object} - The constructed user data map.
     */
    constructUserDataMap() {
        const userDataMap = {};
        const url = new URL(window.location.href);

        userDataMap['utm_source__c'] = url.searchParams.get('utm_source') || '';
        userDataMap['utm_medium__c'] = url.searchParams.get('utm_medium') || '';
        userDataMap['utm_campaign__c'] = url.searchParams.get('utm_campaign') || '';
        userDataMap['utm_content__c'] = url.searchParams.get('utm_content') || '';
        userDataMap['utm_term__c'] = url.searchParams.get('utm_term') || '';
        userDataMap['utm_keyword__c'] = url.searchParams.get('utm_keyword') || '';

        this.template.querySelectorAll('lightning-input').forEach(input => {
            if (input.dataset.id) {
                userDataMap[input.dataset.id] = input.value;
            }
        });

        userDataMap['countrycode'] = this.template.querySelector('[data-id="countrycode"]').value || '';
        userDataMap['mobile'] = `${userDataMap['countrycode']}${userDataMap['mobile']?.replace(/^0+/, '') || ''}`;

        // userDataMap['mobile'] = `+${userDataMap['countrycode']}${this.formatNumberWithoutZero(userDataMap['mobile']) || ''}`;
        userDataMap['Email_Opt_In__pc'] = this.template.querySelector('[data-id="Email_Opt_In__pc"]').checked;

        return userDataMap;
    }

    /**
     * Handles navigation to Screen 3 or Screen 4 based on user selection.
     */
    handlePage3() {
        const selectval = this.selectedValue;
        this.isNoSelected = false;

        if (!selectval) {
            this.showtoast('Error', 'Please select any one of the options above.', 'error');
            return;
        }

        if (this.screen1error) {
            this.showtoast('Error', 'There was an error while processing the request. Please contact our support team.', 'error');
            return;
        }

        this.userdata['Self_Identification__pc'] = this.selectedValue;

        switch (selectval) {
            case 'Founder':
                this.screen2 = false;
                this.screen4 = true;
                break;
            case 'Wholesale':
            case 'Retail':
                this.screen2 = false;
                this.screen3 = true;
                break;
            default:
                this.showtoast('Error', 'Invalid selection.', 'error');
        }

        this.disablethirdbutton = true;

    }

    /**
     * Handles the back button to navigate to the previous screen.
     */
    backButton() {
        this.screen2 = true;
        this.screen3 = false;
        this.screen4 = false;
    }

    /**
     * Handles submission of Screen 4 and navigates to the Thank You page after creating the account and user.
     */
    async handlePage4() {
        this.showspinner = true;
        this.isuseralredayexsists = false;

        const inputelements = Array.from(this.template.querySelectorAll('lightning-input'));
        let isformvalid = true;

        inputelements.forEach(input => {
            isformvalid = isformvalid && input.checkValidity();
            input.reportValidity();
        });

        if (isformvalid && !this.isNoSelected && this.selectedSector !== undefined) {
            try {
                const founderMap = this.constructFounderMap();
                this.userdata = { ...this.userdata, ...founderMap };

                // add lead websource to final data map
                this.userdata = {
                    ...this.userdata,
                    webSource: this.leadData.webSource, 
                    source : this.leadData.source,
                }
                const result = await createAccountAndUser({ userdata: this.userdata });

                if (result.IsValidtransaction) {
                    this.showtoast('Success', 'Your registration is completed.', 'success');
                    window.location.href = this.constructRedirectUrl();
                } else if(result.error === 'Account already exists with this email.'){
                    this.isuseralredayexsists = true;
                }else {
                    console.error('Error occured')
                    this.showtoast('Error', 'There was an error while processing the request. Please contact our support team.', 'error');
                }
            } catch (error) {
                console.error('Server error:', error);
                this.showtoast('Error', 'There was an error while processing the request. Please contact our support team.', 'error');
            } finally {
                this.showspinner = false;
            }
        } else {
            this.showtoast('Error', 'There was a error while processing the request. Please verify your fields.', 'error');
            this.showspinner = false;
        }
    }

    /**
     * Constructs the founder data map from Screen 3 inputs.
     * @returns {Object} - The constructed founder data map.
     */
    constructFounderMap() {
        return {
            'Ventures_Company_Name__c': this.template.querySelector('[data-id="name-company"]').value || '',
            'Website': this.template.querySelector('[data-id="company-website"]').value || '',
            'Sector__c': this.template.querySelector('[data-id="company-sector"]').value || '',
            'ACN__c': (this.template.querySelector('[data-id="abn-number"]').value || '').replace(/\s+/g, ''),
            'Create_Company_Account__c': true
        };
    }

    /**
     * Constructs the redirect URL after successful registration.
     * @returns {string} - The constructed redirect URL.
     */
    constructRedirectUrl() {
        const { email, password, ACN__c } = this.userdata;
        return `/s/typ-newuser2?eml=${btoa(email)}&pd=${btoa(password)}&selectedValue=${encodeURIComponent(this.selectedValue)}&abn=${encodeURIComponent(ACN__c)}`;
    }

    /**
     * Completes the registration process by submitting final details.
     */
    async completeRegistration() {
        this.showspinner = true;
        this.isuseralredayexsists = false;
        const inputareaelements = this.template.querySelector('c-loqate-address');
        const inputelements = this.template.querySelectorAll('input');
        const allelements = Array.from(inputelements);
        let isformvalid = true;

        allelements.forEach(input => {
            isformvalid = isformvalid && input.checkValidity();
            input.reportValidity();
        });


        if (isformvalid && inputareaelements.checkValidity()) {
            try {
                const address = this.template.querySelector('c-loqate-address');
                const datmap = this.constructFinalDataMap(address);
                this.userdata = { ...this.userdata, ...datmap };


                // add lead websource to final data map
                this.userdata = {
                    ...this.userdata,
                    webSource: this.leadData.webSource, 
                    source : this.leadData.source,
                }

                const result = await createAccountAndUser({ userdata: this.userdata });

                if (result.IsValidtransaction) {
                    this.showtoast('Success', 'Your registration is completed.', 'success');
                    window.location.href = this.constructFinalRedirectUrl();
                }else if(result.error === 'Account already exists with this email.'){
                    this.isuseralredayexsists = true;
                }else {
                    console.error('Error occured')
                    this.showtoast('Error', 'There was an error while processing the request. Please contact our support team.', 'error');
                }
            } catch (error) {
                console.error('Server error:', error);
                this.showtoast('Error', 'There was an error while processing the request. Please contact our support team.', 'error');
            } finally {
                this.showspinner = false;
            }
        }else{
            console.error('Server error: Form Valid ',isformvalid);
            this.showtoast('Error', 'There was an error while processing the request. Please contact our support team.', 'error');
        }
    }

    /**
     * Constructs the final data map from address and banking details.
     * @param {HTMLElement} address - The loqate-address component.
     * @returns {Object} - The constructed final data map.
     */
    constructFinalDataMap(address) {
        return {
            'BillingStreet': address.street || '',
            'BillingCity': address.city || '',
            'BillingState': address.state || '',
            'BillingPostalCode': address.postcode || '',
            'BillingCountry': address.country || '',
            'Id': this.accId || '',
            'Bank_Account_Name__c': this.template.querySelector('[data-id="bankaccname"]').value || '',
            'Bank_Account_Number__c': this.template.querySelector('[data-id="bankaccnum"]').value || '',
            'BSB_Number__c': this.template.querySelector('[data-id="bsbnum"]').value || ''
        };
    }

    /**
     * Constructs the final redirect URL after registration completion.
     * @returns {string} - The constructed redirect URL.
     */
    constructFinalRedirectUrl() {
        const { email, password } = this.userdata;
        const investentity = this.template.querySelector('[data-id="investentity"]').checked;
        return `/s/typ-newuser2?eml=${btoa(email)}&pd=${btoa(password)}&investentity=${investentity}`;
    }

    /**
     * Handles ABN validation using Utility class.
     * @param {Event} event - The form submission event.
     */
    abnValidation(event) {
        event.preventDefault();
        const abnInput = this.template.querySelector('[data-id="abn-number"]');
        const abnNumber = abnInput.value.trim();
        const result = Utility.abnValidation(abnNumber);

        if (!result) {
            abnInput.setCustomValidity('Invalid ABN. Please provide a valid number.');
        } else {
            abnInput.setCustomValidity('');
        }
        abnInput.reportValidity();
    }

    /**
     * Validates the company website URL.
     * @param {Event} event - The form submission event.
     */
    urlValidation(event) {
        event.preventDefault();
        const urlCompany = this.template.querySelector('[data-id="company-website"]');
        const regexUrl = /^(https?:\/\/)?(www\.)?[a-zA-Z0-9-]+(\.[a-zA-Z]{2,})+([\/\w .-]*)*\/?$/;

        if (!regexUrl.test(urlCompany.value)) {
            urlCompany.setCustomValidity('Invalid URL. Please provide a valid URL like www.yourcompany.com.');
        } else {
            urlCompany.setCustomValidity('');
        }
        urlCompany.reportValidity();
    }

    /**
     * Handles sector selection changes.
     * @param {Event} event - The combobox change event.
     */
    handleSectorChange(event) {
        this.selectedSector = event.detail.value;
    }

    /**
     * Retrieves sector options from picklist values.
     * @returns {Array<{label: string, value: string}>}
     */
    get sectorOptions() {
        if (this.industryPicklistValues && this.industryPicklistValues.data) {
            return this.industryPicklistValues.data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
        }
        return [{ label: 'This is an empty value', value: 'null' }];
    }

    /**
     * Retrieves Record Type ID by label.
     * @param {string} recordTypeLabel - The label of the Record Type.
     */
    async getRecordTypeId(recordTypeLabel) {
        try {
            const result = await getRecordTypeId({ objectName: 'Account', recordTypeLabel });
            if (result) {
                if (recordTypeLabel === 'Ventures Person Account') {
                    this.venturePersonAccRecordTypeId = result;
                } else if (recordTypeLabel === 'Ventures Company Account') {
                    this.ventureCompanyAccRecordTypeId = result;
                }
            }
        } catch (error) {
            console.error('error in getting recordTypeId', error);
        }
    }

    /**
     * Displays a toast message.
     * @param {string} title - The title of the toast.
     * @param {string} message - The message/content of the toast.
     * @param {string} variant - The variant type of the toast (e.g., 'success', 'error').
     */
    showtoast(title, message, variant) {
        const evt = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(evt);
    }

    /**
     * Redirects the user to the Forgot Password page.
     */
    forgotpassword() {
        window.location.href = '/s/login/ForgotPassword';
    }

    /**
     * Redirects the user to the Login page.
     */
    login() {
        window.location.href = '/s/login';
    }

    /**
     * Handles radio button changes for self-identification in Screen 4.
     * @param {Event} event - The radio change event.
     */
    handleRadioChange(event) {
        this.isNoSelected = event.target.value === 'No';
    }


    //? Method to handle radio button change for self-identification
    //$ This is new
    radiochange(event) {
        this.selectedValue = event.target.value;
        //- KENDRICK 6/09/2024 REG FORM FIX
        this.handleInputChange(event);
    }


    // This is a requirement for voice call to work | The number should be in the format +61412345678
    formatNumberWithoutZero(value) {
        if (value[0] === '0') {
            return value.slice(1);
        }
        return value;
    }
}