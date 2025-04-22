/**
 * @description Core component for stepper
 * @createdBy Cesar
 * @createdDate 2024-10-17
 * @version 1.0
 */

import { LightningElement, api} from 'lwc';

export default class CoreStepper extends LightningElement {
      /**
   * Core RadioButton component
   * @example 
   *                    
   *  <c-core-stepper
      steps={stepperData}>
      </c-core-stepper>
      @DataExample
   * stepperData = [
         {
               index: 1,
               title: 'Application received',
               status: 'completed',
               name: 'Step 1',
         },
         {
               index: 2,
               title: 'Payment received',
               name: 'Step 2',
               status: 'inactive',
         },
         {
               index: 3,
               title: 'ID verified',
               name: 'Step 3',
               shortDesc: '(if not already verified)',
               status: 'inactive',
         },
         {
               index: 4,
               name: 'Step 4',
               title: 'Investment offer closed',
               shortDesc: 'We are now settling your investment and will be in touch shortly with confirmation.',
               status: 'inactive'
         }
      ]
      }
   **/

    /**
       * An array of steps to be displayed in the stepper.
       * Each step should be an object with properties like 'index', 'title', 'shortDesc', 'subDescription', and 'completed'.
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
}