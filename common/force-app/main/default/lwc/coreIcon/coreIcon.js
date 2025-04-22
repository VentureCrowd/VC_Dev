/**
 * Represents an icon component that displays an icon from a sprite sheet.
 * The icon name and size can be customized.
 * Usage:
 * <!-- Use CoreIcon Component -->
    <c-core-icon 
        iconName="account" 
        size="large"
    ></c-core-icon>

    <!-- Use CoreIcon Component with custom width and height -->
    <c-core-icon 
        iconName="contact" 
        size="medium"
        width="50" 
        height="50"
    ></c-core-icon>
 */

import { LightningElement, api} from 'lwc';
import SPRITE_SHEET from '@salesforce/resourceUrl/ventureCrowdTheme'

export default class CoreIcon extends LightningElement {
    /**
     * Name of the icon found in the sprite sheet
     * @type {string}
     */
    @api iconName;

   /**
     * Controls the size of the icon
     * @type {string}
     * @values { xsmall | small | medium | large | xlarge | xxlarge | xxxlarge }
     */
    @api size;

    /**
     * Controls the width of the icon (optional)
     * @type {number}
     */
    @api width;

    /**
     * Controls the height of the icon (optional)
     * @type {number}
     */
    @api height;

    //! Proposed change
    /**
     * Controls the height of the icon (optional)
     * @type {number}
     */
    @api linkUrl

     /**
     * Turns off the pointer cursor
     * default is false (e.g. there will always be a pointer unless you specify not)
     * @type {boolean}
     */
     @api noPointer=false

    /**
     * Getter to format the icon class name for size purposes & any general icon styling
     * @returns {string} The formatted icon class name.
     */
    get iconClass(){
        return 'icon ' + this.size;
    }

   /**
     * Getter to format the SVG link and select the icon from the sprite sheet
     * @returns {string} The SVG link for the icon.
     */
    get svgLink(){
        let returnLink = SPRITE_SHEET+'/Icons/sprites.svg#'+this.iconName;
        return returnLink
    }

    connectedCallback() {
        this.width = this.width; 
        this.height = this.height;
    }

    get style() {
        return `width: ${this.width}px; height: ${this.height}px; ${this.noPointer? '' : 'cursor: pointer;'} `;
    }

    get customSize() {
        if ((this.width !== undefined) && (this.height !== undefined)) {
            return true;
        }
        else { return false;}
    }

}