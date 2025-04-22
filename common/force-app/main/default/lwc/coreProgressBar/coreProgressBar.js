import { LightningElement, api, track} from 'lwc';

/**
 * Core Checkbox component
 * @example 
 * <c-core-progress-bar
        values={values}>
    </c-core-progress-bar>
**/

export default class CoreProgressBar extends LightningElement {
    
    /**
    Values - Used to control the position of the progress bar
    **/
    percentageBar;
    targetPosition;
    targetTextPosition;
    
    /**
    Values - values to be displayed on the button
    @type array
    @parameter int
    @example [ { minimumTarget: 5000, RaisedAmount: 2500}
    **/
    @track _values;

    /**
     * Public set method to update the values property
     * @api decorator exposes the values property as a public API
     * @param {any} value - The new value to be set to the internal _values property
     * Calls the updateStyles method after setting the new value
     */    
    @api
    set values(value) {
        this._values = value;
        this.updateStyles();
    }

    /**
     * Public get method to access the values property
     * @returns {any} - The current value of the internal _values property
     */
    get values() {
        return this._values;
    }

    /**
     * Calculates the value of the minTarget and RaisedAmount then returns the offset value.
     *
     * @param {Number} minimumTarget The minimum target amount.
     */
    get progressPercentage() {
        return parseInt((this.values.RaisedAmount / this.values.minimumTarget) * 100);
    }
    
    /**
     * Calculates difference between the Raised and the Min Target and multiply by 100
     * This result we need to reduce from 100 because the progress bar is inverted
     *
     * @param {Number} minimumTarget The minimum target amount.
     */
    get progressOver() {
        return 100 - (((this.values.RaisedAmount - this.values.minimumTarget) / this.values.RaisedAmount) * 100) ;
    }

    /**
     * Renders if the progress bar should be round or square
     * @param {String} border radius.
     */
    get borderRadius() {
        if (this.values.minimumTarget === this.values.RaisedAmount) {
            return '1em';
        } else {
            return '0em';
        }
    }

    /**
     * Calculates if the raised amount is higher than the minimum target
     * If it's higher will render the over-raise progress bar otherwise the base progress bar
     * @returns {Bool}.
     */
    get renderOverTarget(){
        if (this.values.RaisedAmount > this.values.minimumTarget) {
            return true;
        } else {
            return false;
        }
    }


    /**
     * Format the integer number to decimal using commas.
     * @returns {Number} formatted
     */
    get formattedMinimumTarget() {
        const formatter = Intl.NumberFormat("en", { notation: "compact" });
        return formatter.format(this.values.minimumTarget);
    }

    /**
     * Format the integer number to decimal using commas.
     * @returns {Number} formatted
     */
    get formattedRaisedAmount() {
        return this.values.RaisedAmount.toLocaleString('en-US');
    }

    /**
     * Lifecycle hook that runs when the component is connected to the DOM.
     * Initializes styles for different elements based on component properties.
     */
    connectedCallback() {
        this.updateStyles();
    }

    // Update all the styles depending on the calculation of the fields
    updateStyles() {
        this.percentageBar = `--border-radius: ${this.borderRadius}; --width: ${this.progressPercentage}%;`;
        if (this.progressOver <= 7) {
            this.targetTextPosition = `--targetText: 7%; --width: 7%;`
            this.targetPosition = `--targetPosition: 7%;`
        } else {
            this.targetTextPosition = `--targetText: ${this.progressOver}%; --width: ${this.progressOver}%;`
            this.targetPosition = `--targetPosition: ${this.progressOver}%;`
        }
    }

}