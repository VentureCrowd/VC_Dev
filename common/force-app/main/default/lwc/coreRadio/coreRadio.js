import { LightningElement, api, track} from 'lwc';
import CoreInput from 'c/coreInput';

export default class CoreRadio extends CoreInput{

/**
 * Core RadioButton component
 * @example 
 *  <c-core-radio
        name="RadioButton1"
        values={values}
        size="medium"
        alignment-position="horizontal">
    </c-core-radio>
**/

    @api name;    
    
    /**
    Values - values to be displayed on the button
    @type array
    @parameter id, value and bool checked
    @example [ { id: 1, value: 'Option 1', label: 'Option 1', checked: true}
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
    Icon variables - both must be defined to display an icon
    @param alignmentPosition = position of the icon on the button (left | right)
    @type string
     */

    @api alignmentPosition;

    @api textPosition;

    @api label

    @api required=false;

    @api help;

    @api subtext;

    @track _value;

    @api
    get value(){
        return this._value;
    }

    set value(v){
        this._value = v;
        this.markChecked(this._value);
        this.validateInput()
    }

    markChecked(v){
        // Create a copy of the values array
        const valuesCopy = this.values.map(ele => {
            if(ele.value === v){
                return { ...ele, checked: true  };
            }else{
                return { ...ele, checked: false  };
            }
        });

        // Assign the modified array back to this.values
        this.values = [...valuesCopy];
    }


    /**
     * Handle for onchange event
     * Updates parent component with the target.value when the onchange event fires
     * @param {*} event 
     * @event change -> dispatches { detail: value, bubbles: true, composed: false }
     */

    handleOnChange(event){
        this.value = event.target.value;
        // console.log(this.value);
        const radioBoxChanged = new CustomEvent('change',{
            detail:{ 
                name: this.name,
                value: this.value,
            },
            bubbles: true,
        });
        this.dispatchEvent(radioBoxChanged);
    }

    /** 
     * horizontal and vertical are logical getters to decide which button template to display
     * @returns true/false value depending on position */     
    get horizontal(){
        if(this.alignmentPosition==='horizontal'){
            return true
        }else{
            return false;
        }
    }

    get vertical(){
        if(this.alignmentPosition==='vertical'){
            return true
        }else{
            return false;
        }
    }

    get textPositionClass(){
        if(this.textPosition==='horizontal'){
            return 'horizontal-layout'
        }else{
            return 'vertical-layout'
        }
    }

    /** 
     * @returns the size of the box | Css */ 
    get boxSize(){
        return 'box ' + this.size;
    }

    connectedCallback(){
        this.type = 'radio';
    }
}