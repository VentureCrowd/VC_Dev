/**
 * @module c/sxswQrCode
 * @author KENDRICK KAM
 * @date 26/09/2024
 */

import { LightningElement , api, track} from 'lwc';
import IMG_PATH from '@salesforce/resourceUrl/ventureCrowdTheme';

/**
 * SxswQrCode component generates a QR code with dynamic UTM parameters.
 * It constructs a URL with UTM parameters based on provided input and displays logos.
 */
export default class SxswQrCode extends LightningElement {

    /**
     * List of logo image URLs to be displayed.
     * @type {Array<{url: string}>}
     * @private
     */
    @track _logoList = [
        {url: IMG_PATH  + "/Images/SXSW2024/SXSW-logos1.png"},
        {url: IMG_PATH + "/Images/SXSW2024/SXSW-logos2.png"}
    ];
    
    /**
     * Getter for the list of logos.
     * @type {Array<{url: string}>}
     */
    get logoList(){
        return this._logoList;
    }

    /**
     * The type of user, used as an identifier in the URL.
     * @type {string}
     * @default "investor"
     * @api
     */
    @api userType = "investor"

     /**
     * The base URL to which UTM parameters are appended.
     * @type {string}
     * @default "https://venturecrowd.com.au"
     * @api
     */
    @api targetUrl = "https://venturecrowd.com.au"

    /**
     * UTM campaign parameter.
     * @type {string}
     * @api
     */
    @api utmCampaign
     /**
     * UTM content parameter.
     * @type {string}
     * @api
     */
     @api utmContent;

     /**
      * UTM keyword (term) parameter.
      * @type {string}
      * @api
      */
     @api utmKeyword;
 
     /**
      * UTM medium parameter.
      * @type {string}
      * @api
      */
     @api utmMedium;
 
     /**
      * UTM source parameter.
      * @type {string}
      * @api
      */
     @api utmSource;
 
     /**
      * Constructs the URL to redirect to, including UTM parameters if they are provided.
      * Only parameters with values are included in the final URL.
      * @type {string}
      * @readonly
      */
    get urlToRedirect(){
        const params = {};

        // Always include 'id' parameter
        if (this.userType) {
            params['id'] = this.userType;
        }

        // Conditionally include UTM parameters if they have values
        if (this.utmCampaign) {
            params['utm_campaign'] = this.utmCampaign;
        }
        if (this.utmContent) {
            params['utm_content'] = this.utmContent;
        }
        if (this.utmKeyword) {
            params['utm_term'] = this.utmKeyword;
        }
        if (this.utmMedium) {
            params['utm_medium'] = this.utmMedium;
        }
        if (this.utmSource) {
            params['utm_source'] = this.utmSource;
        }

        // Build the query string from the params object
        const queryString = new URLSearchParams(params).toString();

        // Return the full URL
        return `${this.targetUrl}?${queryString}`;    }

}