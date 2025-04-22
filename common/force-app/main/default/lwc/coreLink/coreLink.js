/**
    <!-- Use coreLink Component to create hyperlinks with icon -->
        <c-core-link 
        label="Submit"
        hyperlink="https://venturecrowd.com.au"
        target="_blank" -> If you want to open in a new tab
        icon="externalLink"
        size="medium"
        variation="tertiary"
        icon-position="left"  -> This is optional by default is right
>
 */

import { LightningElement, api} from 'lwc';

export default class CoreLink extends LightningElement {

    /**
    Link label - Label to be displayed on the text
    @type string
     */
    @api label;

    /**
    Link hyperlink - Link to redirect the user
    @type string
     */
    @api hyperlink;


    /**
    Link variation - applies different styling based on the variation
    default variation is 'primary', if there is none specified
    @param variation = (primary | secondary | tertiary)
    @type string
     */
    @api variation='primary';

    /**
    Link variables - both must be defined to display an icon
    @param icon = name of the icon found in the static resource ventureCrowdTheme/Icons/sprites.svg
    @param iconPosition = position of the icon on the link (left | right)
    @type string
     */
    @api icon;
    @api iconPosition='right';

    /**
     * Controls the size of the icon
     * @type {string}
     * @values { xsmall | small | medium | large | xlarge | xxlarge | xxxlarge }
     */
    @api size;

    /**
     * Controls to open the link in a new tab | This is optional
     * @type {string}
     * @values {_blank}
     */
    @api target;
    

    /** 
     * Get method to return the class name for the link styling
     * @param none
     * @returns variation
     * @example 'primary'*/ 
    get variationClass(){
        return this.variation;
    }

    /** 
     * Get method to return the icon
     * @param none
     * @returns icon
     * @example 'circle'*/ 
    get iconName(){
        if(this.icon){
            return this.icon
        }
    }

    /** 
     * iconPositionLeft and iconPositionRight are logical getters to decide which link template to display
     * @returns true/false value depending on icon|noIcons */ 
    get iconPositionLeft(){
        if(this.iconPosition==='left'){
            return true
        }else{
            return false;
        }
    }

    get iconPositionRight(){
        if(this.iconPosition==='right'){
            return true
        }else{
            return false;
        }
    }
}