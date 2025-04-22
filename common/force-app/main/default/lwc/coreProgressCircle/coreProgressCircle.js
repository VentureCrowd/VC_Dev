/**
 * @description Represents a circular progress indicator component. The circle's width and percentage filled can be customized.
 * @example 
 * <!-- Usage of CoreProgressCircle component -->
        <c-core-progress-circle 
            width={circleWidth} 
            percentage={circlePercentage}
        ></c-core-progress-circle>
 */

import { LightningElement, api, track } from 'lwc';

export default class CoreProgressCircle extends LightningElement {

    // Exposed property to set the width of the circle
    @api width = 70;

    // Exposed property to set the percentage filled in the circle
    @api percentage = 0;

    // Tracked properties
    @track dashArrayOffset
    @track hasRendered = false;

    // Fixed stroke value for the circle
    stroke = 10;

    // Styles for different elements of the circle
    outerCircleStyle=''
    innerCircleStyle=''
    wrapperStyle=''
    circleStyle=''
    circleRadius=''

    /**
     * Calculates the radius of the circle based on the width property.
     * @returns {Number} The radius of the circle.
     */
    get radius(){
        return this.width/2 - 5;
    }

    /**
     * Calculates the center point of the circle based on the width property.
     * @returns {Number} The center point of the circle.
     */
    get center(){
        return this.width/2;
    }

    /**
     * Calculates the dash array value for the circle's stroke.
     * @returns {Number} The dash array value.
     */
    get dashArrayValue(){
        return 2*this.radius*3.16;
    }

    /**
     * Calculates the offset value for the stroke to represent the percentage filled.
     * @returns {Number} The dash array offset value.
     */
    get circlePercentage(){
        return this.dashArrayValue - (this.percentage*this.dashArrayValue/100)
    }

    /**
     * Lifecycle hook that runs when the component is connected to the DOM.
     * Initializes styles for different elements based on component properties.
     */
    connectedCallback(){
        this.wrapperStyle = `height: ${this.width}px; width: ${this.width}px;`;
        this.outerCircleStyle = `height: ${this.width}px; width: ${this.width}px; padding:${this.stroke}px`;
        this.innerCircleStyle = `height: ${this.width - this.stroke - this.stroke}px; width: ${this.width - this.stroke - this.stroke}px;`;
        this.circleStyle = `stroke-width: ${this.stroke}px; stroke-dasharray: ${this.dashArrayValue}; stroke-dashoffset:${this.circlePercentage}`
    }
}