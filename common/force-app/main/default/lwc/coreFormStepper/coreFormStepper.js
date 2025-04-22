/**
 * CoreFormStepper Component
 * @description Represents a stepper component for guiding users through a multi-step form.
 * It displays a sequence of steps and indicates the current step. This component can be displayed
 * either vertically or horizontally based on the provided configuration.
 * 
 * @example
 *  <c-core-form-stepper
 *      steps={steps}
 *      vertical>
 *  </c-core-form-stepper>
 */

import { LightningElement, api, track } from 'lwc';

export default class CoreFormStepper extends LightningElement {
   /**
     * An array of steps to be displayed in the stepper.
     * Each step should be an object with properties like 'index', 'name', 'active', 'completed', and 'shortDesc'.
     * @type {Object[]}
     */
    @api steps  = [];

   /**
     * Determines whether the stepper should be displayed vertically or horizontally.
     * When set to true, the stepper will be displayed vertically.
     * Default value is false (horizontal).
     * @type {boolean}
     */
    @api vertical

    /**
     * Flag to track if the component has been rendered.
     * Used to perform initialization tasks in the renderedCallback.
     * @type {boolean}
     */
    hasRendered = false;

     /**
     * Lifecycle hook that runs after the component's elements have been rendered.
     * Performs initialization tasks if the component has not been rendered before.
     */
    renderedCallback(){
        if(this.hasRendered === false){
            this.hasRendered = true;
        }
    }

     connectedCallback() {
        console.log(JSON.stringify(this.steps));
    }

}