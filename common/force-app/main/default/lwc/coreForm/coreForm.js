/* eslint-disable @lwc/lwc/no-async-operation */
/**
 * CoreForm Component
 * @description The `coreForm` component represents a generic form component. 
 * It includes properties for title, subtitle, button label, and form data management. 
 * This component is designed to facilitate creating and managing forms in Salesforce applications.
 * 
 * @example
 *  <!-- Example of using CoreForm -->
 *  <c-core-form 
 *      title="User Registration Form" 
 *      subtitle="Please fill in the required information."
 *      button-label="Register"
 *      refresh
 *      onsubmit={handleSubmit}
 *      onchange={handleFormChange}>
 *      <div slot="header">
 *          <!-- Custom header content can be added here -->
 *      </div>
 *      <div slot="body">
 *          <c-core-input label="First Name" name="firstName"></c-core-input>
 *          <c-core-input label="Last Name" name="lastName"></c-core-input>
 *          <c-core-input type="email" label="Email" name="email"></c-core-input>
 *          <!-- Additional input fields can be added here -->
 *      </div>
 *      <div slot="footer">
 *          <!-- Custom footer content can be added here -->
 *      </div>
 *  </c-core-form>
 */

import { LightningElement, api, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CoreForm extends LightningElement {
    /**
     * The title of the form.
     * @type {string}
     */
    @api title;
    
    /**
     * The subtitle of the form.
     * @type {string}
     */
    @api subtitle;
    
    /**
     * Determines whether the form should refresh after submission.
     * @type {boolean}
     */
    @api refresh;


     /**
     * The label for the submit button.
     * Default value is 'Submit'.
     * @type {string}
     */
    @api buttonLabel='Submit';


    /**
     * The hide submit button.
     * Default value is 'False'.
     * @type {boolean}
     */
    @api hideButton;

     /**
     * To Align the core button in the center
     * Default value is false.
     * @type {boolean}
     */
     @api centerFormButton=false;

    /**
     * To Align the core button to the left
     * Default value is false.
     * @type {boolean}
     */
    @api leftFormButton = false;

    /**
     * To make the core button full width
     * Default value is false.
     * @type {boolean}
     */
    @api fullWidth=false;

    /**
    Values - Padding for the form wrapper
    @example '20px' or 'var(--space-md) -> You can use variables
    **/
    @api padding = 'var(--space-md)';

    @api buttonVariation = 'primary';

    @api disableSubmit = false;


    /**
     * Flag to track if the component is loading.
     * @type {boolean}
     */    
    @track _isLoading = false;

     /**
     * Flag to track if the component has been rendered.
     * Used to perform initialization tasks in the renderedCallback.
     * @type {boolean}
     */
    @track hasRendered = false;

    /**
     * Stores the form data in JSON format.
     * @type {Object}
     */
    @track _formData={};

    @api isSubmitLoading;

    @api debounce = false;
    debounceTimeout;
    

    @api 
    get formData(){
        return this._formData;
    }
    set formData(data){
        this._formData = {...data};
    }

    get getFooterStyle(){
        if (this.centerFormButton) {

            return this.centerFormButton = 'justify-content: center;';

        } else if (this.leftFormButton) {

            return this.leftFormButton = 'justify-content: flex-start;'

        } else {

            return 'justify-content: flex-end;';

        }
    }

    constructor() {
        super();
        // Attach event listeners for input change and form submission
        this.template.addEventListener("change", this.handleInputChange);
        this.template.addEventListener("submit", this.submitForm);
    }


    /**
     * Event handler for input change events.
     * Updates the form data and dispatches a 'change' event with the updated form data.
     * @param {Event} event - The change event.
     */
    handleInputChange = (event) => {
        event.stopPropagation();
        const { name, value } = event.detail;
        this._formData = { ...this._formData, [name]: value };

        // Debounce dispatching change event
        if(this.debounce){
            clearTimeout(this.debounceTimeout);

            this.debounceTimeout = setTimeout(() => {
                this.dispatchEvent(new CustomEvent('change', {
                    detail: { 
                        name: name,
                        value: value
                    },
                    bubbles: true,
                    composed: false,
                }));
            }, 300); // Adjust debounce delay as needed 
        }else{
            this.dispatchEvent(new CustomEvent('change', {
                detail: { 
                    name: name,
                    value: value
                },
                bubbles: true,
                composed: false,
            }));
        }
        
    }



    /**
     * Sets input field values based on the provided input name and new value.
     * @param {string} inputName - The name of the input field.
     * @param {any} newValue - The new value for the input field.
     */
    async setInputFields(inputName,newValue){

        // get input element
        let selector = `* > c-core-input`;
        let inputFields = this.querySelectorAll(selector)

         // Set newValue for the matching input element
        for (let inputElement of inputFields) {
            if (inputElement.name === inputName) {
                // Handle dropdown and file type inputs specifically
                if (inputElement.isDropdown) {
                    // Set the selectedOption directly for dropdowns
                    inputElement.selectedOption = newValue;
                    inputElement.value = newValue; // Make sure to update the value as well
                } else {
                    // Default handling for other input types
                    inputElement.value = newValue;
                }
                break; // Optional: break if you expect only one match to improve performance
            }
        }

        // set radio buttons
        let radioFields = this.querySelectorAll(`* > c-core-radio`)
        for(let radioInput of radioFields){
            if(radioInput.name === inputName){
                radioInput.value = newValue
            }
        }
    }

    /**
     * Resets the form data to an empty object.
     */
    @api refreshForm(){
        //clear form values
        this._formData={};
    }

    

    
    /**
     * Submits the form by dispatching a 'submit' event with the form data.
     * Also triggers form refresh if refresh is enabled.
     */
    @api submitForm(){
        if (this.checkAllInputsValidity()) {
            // If all inputs are valid, proceed to submit the form
            const submitEvent = new CustomEvent('submit', {
                detail: { 
                    formData: this._formData,
                },
                bubbles: true,
                composed: false,
            });
    
            this.dispatchEvent(submitEvent);
    
            // Refresh the form if enabled
            if (this.refresh) {
                this.refreshForm();
            }
        } else {
            // Handle the invalid input case, e.g., show an error message
            console.error('One or more inputs are invalid. Please check and try again.');
            this.showToast('Error', 'One or more inputs are invalid. Please check and try again.', 'error');
        }
    }

    /**
     * Displays a toast message.
     * @param {string} title - The title of the toast message.
     * @param {string} message - The message content of the toast.
     * @param {string} variant - The variant of the toast message, e.g., 'error', 'success'.
     */
    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(toastEvent);
    }

    /**
     * Lifecycle hook that runs after the component's elements have been rendered.
     * Populates form fields with existing form data if available.
     */
    _rendering;
    async renderedCallback(){
        //Values - Padding form wrapper
        this.style.setProperty('--form-padding', this.padding);

        //populate form with formData if there is any
        
        if(!this.hasRendered){
            for(let key in this.formData){
                this.setInputFields(key, this.formData[key])
            }
            this.hasRendered = true;
        }else if(this._rendering){
            return;
        }else{
            this._rendering = true;
            //prefill form with existing formData if any
            // for(let key in this.formData){
            //     this.setInputFields(key, this.formData[key])
            // }
            await Promise.resolve();
            this._rendering = false;
        }
        
    }

    /**
     * Delays execution for the specified time.
     * @param {number} time - The delay time in milliseconds.
     * @returns {Promise} A promise that resolves after the delay.
     */
    delay(time) {
        return new Promise(resolve => setTimeout(resolve, time));
    }

    /**
     * Checks the validity of all CoreInput components in the form.
     * @returns {boolean} True if all inputs are valid, otherwise false.
     */
    @api
    checkAllInputsValidity() {
        const allCoreInputs = this.querySelectorAll('* > c-core-input');
        let allValid = Array.from(allCoreInputs).map((input) => input.checkValidity());

        const allCoreRadio = this.querySelectorAll('* > c-core-radio');
        const allValidRadio = Array.from(allCoreRadio).map(input => input.checkValidity());

        const allCoreCheckbox = this.querySelectorAll('* > c-core-checkbox');
        const allValidCheckbox = Array.from(allCoreCheckbox).map(input => input.checkValidity());

        return allValid.every(input => input===true) && allValidRadio.every(input => input===true) && allValidCheckbox.every(input => input===true);
    }

    
}