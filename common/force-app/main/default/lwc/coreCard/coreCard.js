import { LightningElement , api} from 'lwc';

export default class CoreCard extends LightningElement {
    /**
    Display mode - changes the display mode of the card between light, dark and accent colours
    @type string
    @param mode = ('light' | 'dark' | 'accent' | 'gray' )
     */
    @api mode = 'light';

    /**
    Show or hide the card shadow - by default it is true
    @type boolean
     */
    @api shadow;

    /**
    Specify the wrapping for the card - by default it is 'xl'
    @type boolean
     */
    @api wrapping = 'xl';


    @api hideFooter;

    /**
     * Get method to return the shadow class for the card styling
     * @returns {string} - 'shadow' if shadow is true, otherwise an empty string
     */
    get hasShadow(){
        if (this.shadow){
            return 'shadow-card'
        }else{
            return ''
        }
    }

    /**
     * Get method to return the class name for the card styling
     * @returns {string} - concatenation of 'card-wrapper', mode, and hasShadow
     * @example 'card-wrapper light shadow'
     */
    get cardClass(){
        return 'card-wrapper ' + this.mode + ' ' + this.hasShadow + ' ' + this.wrapping;
    }

    /**
     * Get method to return the footer class for the card styling
     * @returns {Boolean}
     */
    get renderFooter() {
        return !this.hideFooter;
    }

}