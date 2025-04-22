/**
 * Represents an alert component that displays warning or neutral messages.
 * Usage:
 * ```html
 * <c-core-alert type="warning" box_style="style_1">
 *     <div slot="body">SOME ALERT TEXT!</div>
 * </c-core-alert>
 * ```
 * Available Types: warning | neutral
 */
import { LightningElement, api } from 'lwc';

export default class CoreAlert extends LightningElement {

    /**
     * The style of alert. Defaults to 'neutral'.
     * @type {'style_1' | 'style_2'}
     * @style_1 This style is rounded and the icon is in the corner of the container
     * @style_2 This style is squared and the icon is inside the container
     */
    @api box_style = 'style_2'

    /**
     * Object mapping alert types to corresponding icon names.
     */
    _types={
        'warning': 'warning',
        'information' : 'information',
        'pending' : 'clockCircle'
    }
    /**
     * The type of alert. Defaults to 'neutral'.
     * @type {'warning' | 'neutral'}
     */
    @api type = 'neutral';

    /**
     * Generates the CSS class for the alert based on the type.
     * @returns {string} The CSS class.
     */
    get className(){
        return this.box_style + " " + this.type;
    }

    /**
     * Retrieves the icon name based on the alert type.
     * @returns {string} The icon name.
     */
    get iconName(){
        return this._types[this.type];
    }
}