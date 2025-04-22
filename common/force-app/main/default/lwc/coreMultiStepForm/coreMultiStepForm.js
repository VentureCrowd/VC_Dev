/**
 * CoreMultiStepForm Component
 * @description The `coreMultiStepForm` component extends the `coreForm` component to create a multi-step form. 
 * It provides navigation between steps, validation, and management of form data across multiple steps.
 * This component is designed for use cases where forms need to be split into logical sections or steps, improving user experience.
 * 
 * @example
 *  <c-core-multi-step-form
 *      current-step-index="0"
 *      steps={steps}
 *      vertical
 *      is-final={isFinal}
 *      is-not-first={isNotFirst}
 *      nextbutton="Next"
 *      prevbutton="Back"
 *      submitbutton="Submit"
 *      savebutton="Save"
 *      onsubmit={handleSubmit}
 *      onchange={handleFormChange}
 *      onpreviousstep={handlePreviousStep}
 *      onnextstep={handleNextStep}
 *      additional-button='Third'
 *      handle-additional-button={handleButton}>
 *  </c-core-multi-step-form>
 */
import { LightningElement, api, track } from 'lwc';

// Importing CoreForm component
import CoreForm from 'c/coreForm';

export default class CoreMultiStepForm extends CoreForm {
    /**
     * The current step index.
     * @type {number}
     */
    @api currentStepIndex = 0;

    /**
     * Steps - An array of step elements.
     * @type {Array}
     */
    @api steps = [];

    /**
     * Vertical - Determines if the stepper is vertical.
     * @type {boolean}
     */
    @api vertical;

    /**
     * Is Final - Indicates if the current step is the final step.
     * @type {boolean}
     */
    @api isFinal = false;

    /**
     * Is Not First - Indicates if the current step is not the first step.
     * @type {boolean}
     */
    @api isNotFirst = false;

     /**
     * Next Button - Label for the next button.
     * @type {string}
     */
    @api nextbutton = 'Next';

     /**
     * Previous Button - Label for the previous button.
     * @type {string}
     */
    @api prevbutton = 'Back';

    /**
     * Submit Button - Label for the submit button.
     * @type {string}
     */
    @api submitbutton = 'Submit';

    /**
     * Save Button - Label for the save button.
     * @type {string}
     */
    @api savebutton = 'Save';

    @api isAdditionalButtonLoading;

    /**
     * Additional Button - Label for the save button.
     * @type {string}
     */
    @api additionalButton;


    // Tracked properties
    @track hasRendered = false;
    @track stepperSteps = [];

    @api isPrevLoading;
    @api isNextLoading;

    @api isSaving;


    /**
    * Determines the wrapper class based on whether the stepper is vertical.
    * @returns {String} The wrapper class.
    */
    get wrapperClass(){
        if(this.vertical){
            return "multi-step-wrapper vertical-stepper"
        }else{
            return "multi-step-wrapper"
        }
    }
    

     /**
     * Checks if there is a next step.
     * @returns {Boolean} True if there is a next step, otherwise false.
     */
    hasNext(){
        return this.currentStepIndex !== -1 && this.currentStepIndex < this.steps.length - 1;
    }

    /**
     * Checks if there is a previous step.
     * @returns {Boolean} True if there is a previous step, otherwise false.
     */
    hasPrev(){
        //get current steps index
        return this.currentStepIndex !== -1 && this.currentStepIndex > 0;
    }

    /**
     * Scrolls to the top of the form.
     */
    scrollToTop() {
        const formContainer = this.template.querySelector('.header');
        if (formContainer) {
            formContainer.scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
    }

    /**
     * Handle button clicks to request navigation.
     */
    navigatePrev(){
        this.requestNavigatePrev();
    }

    navigateNext(){
        this.requestNavigateNext();
    }


    /**
     * Checks if the current step is the last step and updates the isFinal property.
     */
    isLastStep(){
        //if the current step is the last step, then set isFinal to true
        if(this.currentStepIndex === this.steps.length -1){
            this.isFinal = true;
        }else{
            this.isFinal = false;
        }
    }

    /**
     * Checks if the current step is not the first step and updates the isNotFirst property.
     */
    isNotFirstStep(){
        if(this.currentStepIndex !== 0){
            this.isNotFirst = true;
        }else{
            this.isNotFirst = false;
        }
    }



    /**
     * Displays the specified step.
     * @param {Number} stepIndex - The index of the step to be displayed.
     */
    displayStep(stepIndex){
        // set current step
        this.currentStepIndex = stepIndex;
        // display current step and hide the rest
        this.steps.forEach((step)=>{
            step.style.display = "none";
        })

        this.steps[stepIndex].style.display = "block" ;

        // Update flags
        this.isNotFirstStep();
        this.isLastStep();
        this.scrollToTop();
    }
    
    /**
     * Retrieves the steps from the DOM and initializes the component.
     */
    getSteps(){
        // get input element
        let selector = `* > .step`;
        let stepsFound = this.querySelectorAll(selector);
        
        // set 1st step
        if(stepsFound.length > 0){
            this.steps = [...stepsFound];
            //hide steps
            this.displayStep(this.currentStepIndex);
        }
    }

    /**
     * Retrieves stepper data from the DOM and initializes the stepperSteps array.
     */
    getStepperData(){
        // set stepper titles
        let stepSelector = `* .step-title`;
        let stepTitles = this.querySelectorAll(stepSelector);

        let stepDescSelector = `* .step-desc`;
        let stepDesc = this.querySelectorAll(stepDescSelector);

        let stepEtaSelector = `* .step-eta`;
        let stepEta = this.querySelectorAll(stepEtaSelector);
        
        if(stepTitles.length > 0){
            let stepCounter = 1
            stepTitles.forEach((ele, idx)=>{
                this.stepperSteps.push(
                    {
                        "index" : stepCounter,
                        "name" :  ele.innerHTML,
                        "active" : false,
                        "completed": false,
                        "error": false,
                        "textLength" : ele.innerHTML.length,
                        "shortDesc": stepDesc[idx] ? stepDesc[idx].innerHTML : '',
                        "eta" : stepEta[idx] ? stepEta[idx].innerHTML : '',
                    }
                )
                stepCounter += 1;
                if(this.vertical){
                    ele.style.display = 'none';
                    stepDesc[idx].style.display = 'none';
                    stepEta[idx].style.display = 'none';
                }
            })
        }
    }

     /**
     * Validates the current step by checking the validity of inputs in that step.
     * @returns {boolean} True if the current step is valid, false otherwise.
     */
     @api
     validateCurrentStep(options) {
        const currentStep = this.steps[this.currentStepIndex];

        let errorFields= []

        if (!currentStep) {
            console.error('Invalid step index');
            return false;
        }
        
        // Assuming each step might contain multiple inputs grouped under a specific class or directly as elements.
        const inputs = currentStep.querySelectorAll('c-core-input');
        const isValid = Array.from(inputs).map(input => options["noCheckRequired"] ? (input.value ? input.checkValidity() : true ) : input.checkValidity());

        if (isValid.every(input => input === true)) {
           // If valid, mark current step as completed and prepare for next step
           this.stepperSteps[this.currentStepIndex] = {
                ...this.stepperSteps[this.currentStepIndex],
                active: false,  
                completed: false,
                error: false
            };
        } else {
            
             // Set error on the current step
             this.stepperSteps[this.currentStepIndex] = {
                ...this.stepperSteps[this.currentStepIndex],
                active: false,
                completed: false,
                error: true
            };

            
            const errorIndexes = isValid.map((value, index) => !value ? index : null).filter(index => index !== null);
            
            for(let i=0; i < errorIndexes.length ; i++){
                errorFields.push({
                    label:inputs[errorIndexes[i]].label ? inputs[errorIndexes[i]].label : inputs[errorIndexes[i]].getErrorLabel, 
                    name: inputs[errorIndexes[i]].name , 
                    value: inputs[errorIndexes[i]].value
                })
            }

            //this.showToast('Error', 'Please correct the errors before proceeding.', 'error');
        }

        const radioInputs = currentStep.querySelectorAll('c-core-radio');
        const isValidRadio = Array.from(radioInputs).map(input => options["noCheckRequired"] ? (input.value ? input.checkValidity() : true ) : input.checkValidity());

        if (!isValidRadio.every(input => input === true)) {
            // Set error on the current step
            this.stepperSteps[this.currentStepIndex] = {
                ...this.stepperSteps[this.currentStepIndex],
                active: false,
                completed: false,
                error: true
            };


            // add to error list

            const errorIndexes = isValidRadio.map((value, index) => !value ? index : null).filter(index => index !== null);
            
            for(let i=0; i < errorIndexes.length ; i++){


                errorFields.push({
                    label:radioInputs[errorIndexes[i]].label, 
                    name: radioInputs[errorIndexes[i]].name , 
                    value: radioInputs[errorIndexes[i]].value
                })
            }

            // this.showToast('Error', 'Please correct the errors before proceeding.', 'error');
        } else {
            // If valid, mark current step as completed and prepare for next step
            this.stepperSteps[this.currentStepIndex] = {
                ...this.stepperSteps[this.currentStepIndex],
                active: false,  
                completed: false,
                error: false
            };
        }

        const allCoreCheckbox = currentStep.querySelectorAll('* > c-core-checkbox');
        const allValidCheckbox = Array.from(allCoreCheckbox).map(input => options["noCheckRequired"] ? (input.value ? input.checkValidity() : true ) : input.checkValidity());

        if (!allValidCheckbox.every(input => input === true)) {
            // Set error on the current step
            this.stepperSteps[this.currentStepIndex] = {
                ...this.stepperSteps[this.currentStepIndex],
                active: false,
                completed: false,
                error: true
            };

            // add errors
            const errorIndexes = allValidCheckbox.map((value, index) => !value ? index : null).filter(index => index!== null);
            
            for(let i=0; i < errorIndexes.length ; i++){
                errorFields.push({
                    label:allCoreCheckbox[errorIndexes[i]].getErrorLabel, 
                    name: allCoreCheckbox[errorIndexes[i]].name , 
                    value: allCoreCheckbox[errorIndexes[i]].value
                })
            }

            // this.showToast('Error', 'Please correct the errors before proceeding.', 'error');
        } else {
            // If valid, mark current step as completed and prepare for next step
            this.stepperSteps[this.currentStepIndex] = {
                ...this.stepperSteps[this.currentStepIndex],
                active: false,  
                completed: false,
                error: false
            };
        }

        const allTeamMembers = currentStep.querySelectorAll('* > c-raise-team-member-component');
        const allValidTeamMembers = Array.from(allTeamMembers).map(input => options["noCheckRequired"] ? (input.hasValue ? input.checkValidity() : true ) : input.checkValidity());

        if (!allValidTeamMembers.every(input => input === true)) {
            // Set error on the current step
            this.stepperSteps[this.currentStepIndex] = {
                ...this.stepperSteps[this.currentStepIndex],
                active: false,
                completed: false,
                error: true
            };

            // add errors
            const errorIndexes = allValidTeamMembers.map((value, index) => !value ? index : null).filter(index => index!== null);
            
            for(let i=0; i < errorIndexes.length ; i++){
                errorFields.push({
                    label:allTeamMembers[errorIndexes[i]].sectionTitle, 
                    name: allTeamMembers[errorIndexes[i]].sectionTitle , 
                    value: allTeamMembers[errorIndexes[i]].sectionTitle
                })
            }

            // this.showToast('Error', 'Please correct the errors before proceeding.', 'error');
        } else {
            // If valid, mark current step as completed and prepare for next step
            this.stepperSteps[this.currentStepIndex] = {
                ...this.stepperSteps[this.currentStepIndex],
                active: false,  
                completed: false,
                error: false
            };

        }


        const errorsEvent = new CustomEvent('errorsfound', {
            detail: { 
                errorFields : errorFields,
                errors: errorFields.length > 0 ? true : false,
            },
            bubbles: true,
            composed: true,
        });
        this.dispatchEvent(errorsEvent);
        

        return isValid.every(input => input === true) && isValidRadio.every(input => input === true) && allValidCheckbox.every(input => input === true) && allValidTeamMembers.every(input => input === true);
    }

    completeStepsBeforeIndex(arr,index){
        for (let i = 0; i < index; i++) {
            arr[i].completed = true;
            arr[i].active = false;
            arr[i].error = false;
        }
        return arr;
    }

    /**
     * Callback function called when the component is rendered.
     * Initializes the component and retrieves stepper data.
     */
    _rendering;
    async renderedCallback(){
        if(this.hasRendered === false){
            this.getSteps();

            
            this.getStepperData();
            
            //set the first title text as the active one
            this.stepperSteps[this.currentStepIndex].active = true;
            
            //set previous steps as false
            if(this.currentStepIndex > 0){
                this.stepperSteps = this.completeStepsBeforeIndex(this.stepperSteps,this.currentStepIndex);
            }

            //prefill form with existing formData if any
            for(let key in this.formData){
                this.setInputFields(key, this.formData[key])
            }

            // set hasRendered = true
            this.hasRendered = true;

            this.isNotFirstStep();
            this.isLastStep();
            this.scrollToTop();
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
     * Emits an event requesting to handle the additional button.
     */
    handleAdditionalButton() {
        const event = new CustomEvent('additionalbuttonevent', {
            bubbles: true,
            composed: true,
        });
        this.dispatchEvent(event);
    }

    /**
     * Emits an event requesting to navigate to the previous step.
     */
    requestNavigatePrev(){
        // Perform validation before requesting navigation
        if(this.validateCurrentStep({"noCheckRequired" : true})){
            const event = new CustomEvent('requestpreviousstep', {
                detail: { 
                    formData: this._formData,
                    currentStepIndex: this.currentStepIndex,
                },
                bubbles: true,
                composed: true,
            });
            this.dispatchEvent(event);
        }
    }

    /**
     * Emits an event requesting to navigate to the next step.
     */
    requestNavigateNext(){
        if(this.validateCurrentStep({})){
            const event = new CustomEvent('requestnextstep', {
                detail: { 
                    formData: this._formData,
                    currentStepIndex: this.currentStepIndex,
                },
                bubbles: true,
                composed: true,
            });
            this.dispatchEvent(event);
        }
    }


    /**
     * Public method to navigate to the previous step.
     */
    @api
    goToPreviousStep(){
        if(this.hasPrev()){
            // Update stepper state
            this.stepperSteps[this.currentStepIndex].active = false;
            this.stepperSteps[this.currentStepIndex].error = false;

            // Decrement step index
            this.currentStepIndex -= 1;
            this.displayStep(this.currentStepIndex);
            this.stepperSteps[this.currentStepIndex].active = true;
            this.stepperSteps[this.currentStepIndex].completed = false;

            // Update flags
            this.isNotFirstStep();
            this.isLastStep();
            this.scrollToTop();
        }
    }

    /**
     * Public method to navigate to the next step.
     */
    @api
    goToNextStep(){
        if(this.hasNext()){
            // Update stepper state
            this.stepperSteps[this.currentStepIndex].completed = true;
            this.stepperSteps[this.currentStepIndex].active = false;
            this.stepperSteps[this.currentStepIndex].error = false;

            // Increment step index
            this.currentStepIndex += 1;
            this.displayStep(this.currentStepIndex);
            this.stepperSteps[this.currentStepIndex].active = true;

            // Update flags
            this.isNotFirstStep();
            this.isLastStep();
            this.scrollToTop();
        }
    }

    @api
    focusField(fieldLabel){
        const currentStep = this.steps[this.currentStepIndex];

        const inputs = [
            ...currentStep.querySelectorAll('c-core-input'),
            ...currentStep.querySelectorAll('c-core-radio'),
            ...currentStep.querySelectorAll('* > c-core-checkbox'),
            ...currentStep.querySelectorAll('* > c-raise-team-member-component'),
        ];

        const matchingInputs = Array.from(inputs).filter((value) => {
            if(value.label){
                return value.label === fieldLabel
            }else if(value.sectionTitle){
                return value.sectionTitle === fieldLabel;
            }else if(value.getErrorLabel){
                return value.getErrorLabel === fieldLabel;
            }else if (value.name){
                return value.name === fieldLabel;
            }

            return false;
            
        });
        
        
        if(matchingInputs.length > 0){
            matchingInputs[0].setFocus();
        }
    }
}