/**
 * Core Button component
 * @example 
 *  <c-core-button 
    label="Primary Button"
    variation="primary"
    mode="dark"
    onclick={handleClick}
    data-id="primary-button"
    icon="myPortfolio" 
    icon-position="right">
    </c-core-button>
*
 */
import { LightningElement ,api} from 'lwc';

export default class CoreButton extends LightningElement {
    /**
    Button label - Label to be displayed on the button
    @type string
     */
    @api label;

    /**
    Button variation - applies different styling based on the variation
    default variation is 'primary', if there is none specified
    @param variation = (primary | secondary | tertiary | disabled | solo-icon)
    @type string
     */
    @api variation='primary';

    /**
    Icon variables - both must be defined to display an icon
    @param icon = name of the icon found in the static resource ventureCrowdTheme/Icons/sprites.svg
    @param iconPosition = position of the icon on the button (left | right)
    @param iconSize = size of the icon (small | medium | large)
    @type string
     */
    @api icon;
    @api iconPosition;
    @api iconSize = 'large';

    /**
    Display mode - changes the display mode of the button between a light and dark theme
    @type string
    @param mode = ('light' | 'dark')
     */
    @api mode='light';

    /**
    boolean to disable/enable button
     */
    @api disabled

    /**
    boolean to set button to full width
     */
    @api fullWidth = false;

    @api isLoading = false;

    // Set by default this button option
    @api buttonSize;


    /** 
     * Get method to return the class name for the button styling
     * @param none
     * @returns variation & mode
     * @example 'primary dark'*/ 
    get variationClass(){
        return this.variation + ' ' + this.mode;
    }
    
    get iconName(){
        if(this.icon){
            return this.icon
        }
    }

    get buttonStyle(){
        return this.fullWidth ? 'width:100%' : 'width:auto';
    }

    /**
    * Logical getter to decide if no icon is present
    * @returns {boolean} - true if no icon is defined, false otherwise
    */
    get noIcon(){
        if(!this.icon){
            return true;
        }else{
            return false;
        }
    }
    /**
     * Logical getter to decide if the icon position is left
     * @returns {boolean} - true if icon position is left, false otherwise
     */
    get iconPositionLeft(){
        if(this.iconPosition==='left'){
            return true
        }else{
            return false;
        }
    }
    /**
     * Logical getter to decide if the icon position is right
     * @returns {boolean} - true if icon position is right, false otherwise
     */
    get iconPositionRight(){
        if(this.iconPosition==='right'){
            return true
        }else{
            return false;
        }
    }
    /**
     * Method to handle button click event
     * Dispatches a custom event 'buttonclick' with the button label
     * @event buttonclick
     * @param {Event} event - The event object
     */
    handleClick(){
        const buttonClicked = new CustomEvent('buttonclick',{
            detail: this.label,
            bubbles: true,
            composed : false,
        });

        this.dispatchEvent(buttonClicked);
    }

    renderedCallback() {
        if (this.buttonSize !== undefined) {
            this.style.setProperty('--button-padding-size', this.buttonSize);
        }
    }

}