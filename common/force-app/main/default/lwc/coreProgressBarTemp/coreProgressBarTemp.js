import { LightningElement,track,api } from 'lwc';
/**
 * Core Checkbox component
 * @example 
 * <c-core-progress-bar
        values={values}>
    </c-core-progress-bar>
**/
export default class CoreProgressBarTemp extends LightningElement {
        
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

    // We update the styles if we set the values after
    @api
    set values(value) {
        this._values = value;
        this.updateStyles();
    }

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
        // We reduce the progressOver to match the X position of the text
        if (this.progressOver <= 7) {
            this.targetTextPosition = `--targetText: 7%; --width: 7%;`
            this.targetPosition = `--targetPosition: 7%;`
        } else {
            this.targetTextPosition = `--targetText: ${this.progressOver}%; --width: ${this.progressOver}%;`
            this.targetPosition = `--targetPosition: ${this.progressOver}%;`
        }
    }

}