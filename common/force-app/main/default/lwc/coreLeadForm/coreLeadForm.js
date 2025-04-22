import { LightningElement , track, api, wire} from 'lwc';
import apex_createLead from '@salesforce/apex/LeadControllerNew.createLeadSXSW';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
/**
 * CoreLeadForm is a Lightning Web Component that captures lead information
 * from users during events like SXSW and integrates it with Salesforce.
 * Author: KENDRICK KAM 20/09/2024
 */

export default class CoreLeadForm extends NavigationMixin(LightningElement) {
     /**
     * @track formData - Holds the current state of the form fields.
     * Initialized with agreeComms set to ["marketingComms"].
     */
     @track formData = { "agreeComms": ["marketingComms"] };
    
     /**
      * @track isLoading - Indicates whether the form is in a loading state.
      * Used to display loading indicators during form submission.
      */
     @track isLoading = false;
     
     /**
      * @track isSubmitted - Indicates whether the form has been successfully submitted.
      * Used to display success messages and icons.
      */
     @track isSubmitted = false;

    /**
     * @api imgUrl - URL of the image to be displayed at the top of the form.
     * Configurable via Experience Builder.
     */
    @api imgUrl;
    
    /**
     * @api formTitle - The main title of the form.
     * Configurable via Experience Builder.
     */
    @api formTitle;
    
    /**
     * @api formSubtext - The subtitle or additional text under the form title.
     * Configurable via Experience Builder.
     */
    @api formSubtext;
    
    /**
     * @api buttonLabel - The label text for the form's submit button.
     * Configurable via Experience Builder.
     */
    @api buttonLabel;
    
    /**
     * @api successMessage - The message displayed upon successful form submission.
     * Configurable via Experience Builder.
     */
    @api successMessage;


   

    /**
     * userType - Array of user types available for selection in the form.
     * Options include 'Founder' and 'Investor'.
     */
    userType = [ 
        { id: 1, value: 'Founder', label: 'Founder', checked: false },
        { id: 2, value: 'Investor', label: 'Investor', checked: false },
    ];

    /**
     * marketingValue - Array representing the marketing consent checkbox.
     * Users can agree to receive communications from the organisation.
     */
    marketingValue = [
        { 
            id: 1, 
            value: 'marketingComms', 
            label: 'I agree to receive communications from VentureCrowd. I understand I can unsubscribe at any time.',
            checked: true,
        }
    ];

    /**
     * utmParams - Object to store the UTM parameters attached to the URL.
     */
    utmParams = {};

     /**
     * handleSubmit - Handles the form submission event.
     * Processes form data, splits the full name, constructs the lead object,
     * and calls the Apex method to create the lead in Salesforce.
     * 
     * @param {CustomEvent} e - The form submission event containing form data.
     */
    async handleSubmit(e){
        this.isLoading = true;
        this.formData = {...e.detail.formData};
        //formdata looks like this {"fullName":"Hello Name","email":"mail@mail.com","mobileNumber":"04333120000","type":"Founder","startupName":"Company"}

        try{
            const nameList = this.formData.fullName.split(" ");
            let firstName = ''
            let middleName = ''
            let lastName = ''

            // split name into first, last and middle names
            if(nameList.length>2){
            firstName = nameList[0];
            middleName = nameList.slice(1,nameList.length-1).join(' ');
            lastName = nameList[nameList.length-1];
            }else{
                firstName = nameList[0];
                lastName = nameList[nameList.length-1];
            }

            const email = this.formData?.email ? this.formData?.email : '';
            const mobileNumber = this.formData?.mobileNumber ? this.formData?.mobileNumber : '';
            const type = this.formData?.type ? this.formData?.type : '';
            const startupName = this.formData?.startupName ? this.formData?.startupName : '';
            const emailOptIn = this.formData?.agreeComms.length > 0 ? true : false;

            const submitObject = {
                'firstName': firstName,
                'middleNames' : middleName,
                'lastName': lastName,
                'webSource':'SXSW Sydney 2024',
                'email':email,
                'mobileNumber' : mobileNumber,
                'comments' : type,
                'source' : 'Website Form',
                'company': type === 'Founder' ? startupName : '', // Only include startupName if type is 'Founder'
                'emailOptIn' : emailOptIn,
                ...this.utmParams
            }

            const createResult = await apex_createLead({fieldsToAdd : submitObject})

            if(createResult){
                this.dispatchEvent(
                    new CustomEvent('leadcreated', {detail: {leadResult: createResult}})
                );
                this.isSubmitted = true;
                
            }else {
                this.dispatchEvent(
                    new CustomEvent('leadnotcreated', {detail: {leadResult: createResult}})
                );
            }
        }catch(err){
            console.error(err);
            this.dispatchEvent(
                new CustomEvent('leadnotcreated', {detail: {errorMessage: err}})
            );
        }finally{
            this.isLoading = false;
        }
        
    }

    /**
     * handleFormChange - Handles changes to the form fields.
     * Updates the formData property with the new values.
     * 
     * @param {CustomEvent} e - The form change event containing field name and value.
     */
    handleFormChange(e){
        const key = e.detail.name;
        const value = e.detail.value;

        if (key && value) {
            if (key === 'type' && value === 'Investor') {
                // Remove 'startupName' from formData
                const { startupName, ...rest } = this.formData;
                this.formData = { ...rest, [key]: value };
            } else {
                this.formData = { ...this.formData, [key]: value };
            }
        }
        
    }

    /**
     * handleShowStartup - Handles showing the startup field
     * Show the startup field if the user selects founder
     * 
     * @param {CustomEvent} e - The form change event containing field name and value.
     */
    get handleShowStartup(){
        return this.formData?.type === 'Founder';
    }

    @wire(CurrentPageReference)
    setCurrentPageReference(pageRef) {
        if (pageRef) {
            const state = pageRef.state;
            for (let key in state) {
                if (key.startsWith('utm_')) {
                    this.utmParams[key] = state[key];
                }
            }
        }
    }
}