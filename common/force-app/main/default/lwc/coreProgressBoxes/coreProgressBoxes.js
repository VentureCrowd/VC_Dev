import { LightningElement, api } from 'lwc';

/**
 * Core Checkbox component
 * @example 
 * <c-core-progress-boxes
        values={values}>
    </c-core-progress-boxes>
    Review passed by - Kendrick
**/


export default class CoreProgressBoxes extends LightningElement {

    /**
     * Get the company ID
     * @values ( )
    */
    @api companyID = false;
    
    /**
    Values - values to be displayed on the button
    @type array
    @parameter id, value and bool checked
    @example [ { id: 1, label: 'Option 1', completed: true, active: true, variation: 'light'}
    **/

    @api values;

    /**
     * Public get method to get updated values with variations
     * @returns {Array} - An array of values with an additional 'variation' property
     */
    get updatedValues() {
        return this.values.map(value => ({
            ...value,
            // Add a new 'variation' property based on the 'completed' and 'active' status
            variation: `light ${value.completed ? 'completed' : value.active ? 'active' : ''}`
        }));
    }
}