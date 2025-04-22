import { LightningElement, api, track } from 'lwc';
import CoreInput from 'c/coreInput';

/**
 * Core Checkbox component
 * @example 
    <c-core-checkbox
        name="checkbox testing"
        flex-position="right" -> Optional
        font-family="light" -> Optional
        values={values} -> This need to be an array
        mode="light" -> Optional
        text-position="left"
        size="large"
        alignment-position="horizontal"
        required> -> Optional
    </c-core-checkbox>
**/

export default class CoreCheckbox extends CoreInput {

    @api name

    /**
    Values - values to be displayed on the button
    @type array
    @parameter id, value and bool checked
    @example [ { id: 1, value: 'Option 1', checked: true}
    **/
    @api values;

    /**
     * Controls the size of the icon
     * @values ( xsmall | small | medium | large | xlarge | xxlarge | xxxlarge )
    */
    @api size;

    /**
    Return the values of the checked values
     */
    @api checked;

    /**
    Return the values of the checked values
    * @values ( light | regular | vold )
     */
    @api fontFamily = 'regular';


    /**
    Display mode - changes the display mode of the button between a light and dark theme
    @type string
    @param mode = ('light' | 'dark')
     */
    @api mode='light';


    /**
    Position of the boxes
    @param alignmentPosition = position of the checkboxes on the button (horizontal | vertical)
    @type string
     */
    @api alignmentPosition;

    /**
    @param Flex position = Position of the container based on the error message (left | right)
    @type string
     */
    @api flexPosition = 'left';

    get alignmentStyle() {
        if (this.flexPosition === 'right')
        return 'justify-content: flex-end';
    }

    /**
    * Public get method to access the value
    * @api decorator exposes the value property as a public API
    * @returns {any} - The current value of the internal _value property
    */
    @track _value;
    @api
    get value(){
        return this._value;
    }

    /**
     * Public set method to update the value
     * @api decorator exposes the value property as a public API
     * @param {any} v - The new value to be set to the internal _value property
     * Calls the validateInput method after setting the new value
     */
    set value(v){
        this._value = v;
        this.validateInput()
    }

    /**
    Text position - Set the position of the text by default is right
    @param textPosition = position of the text (left | right)
    @type string
     */
    @api textPosition='left';

    /**
     * Handle for onchange event
     * Update only the checkbox that was interacted with and then update the checked status based on interaction and 
     * store only the values of checked items
     * @param {*} event 
     * @event change -> dispatches { detail: value, bubbles: true, composed: false }
     */
    handleOnChange(event) {
        this.values = this.values.map(item => {
            if (item.id.toString() === event.target.dataset.id) { 
                return {...item, checked: event.target.checked}; 
            }
            return item;
        });
    
        this.value = this.values.filter(item => item.checked).map(item => item.value); 
        const checkboxes = new CustomEvent('change', {
            detail: { 
                name: this.name,
                value: this.value
            },
            bubbles: true,
        });
        this.dispatchEvent(checkboxes);
    }


    /** 
     * Font family variation of Suisse
     * @returns the font family depending on the variation */  
    get fontStyle() {
        return 'font-' + this.fontFamily;
    }


    /** 
     * horizontal and vertical are logical getters to decide which button template to display
     * @returns true/false value depending on position */     
    get horizontalLeft() {
        return this.alignmentPosition === 'horizontal' && this.textPosition === 'left';
    }
    
    get horizontalRight() {
        return this.alignmentPosition === 'horizontal' && this.textPosition === 'right';
    }

    get verticalLeft() {
        return this.alignmentPosition === 'vertical' && this.textPosition === 'left';
    }
    
    get verticalRight() {
        return this.alignmentPosition === 'vertical' && this.textPosition === 'right';
    }

    /** 
     * Styling of the checkbox as mode light or dark and the size of the
     * checkbox
     * @returns true/false value depending on position */     
    
    get variationClass(){
        return this.mode + ' ' + 'box ' + this.size;
    }

    //error handling
    @api errorLabel;

    @api
    get getErrorLabel(){
        return this.errorLabel ? this.errorLabel : this.name;
    }


    connectedCallback(){
        this.type = 'checkbox'
    }
}