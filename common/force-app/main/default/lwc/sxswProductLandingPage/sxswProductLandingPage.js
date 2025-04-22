import { LightningElement, track, wire } from 'lwc';
import IMG_PATH from '@salesforce/resourceUrl/ventureCrowdTheme';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import apex_retrieveEOIOfferInformation from '@salesforce/apex/EOI_Controller.getEoiSXSWOfferInformation';


export default class SxswProductLandingPage extends LightningElement {
    
    @track isLoading;

    @track searchValue='';

     /**
     * Indicates whether the view is in mobile mode based on screen size.
     * @type {boolean}
     */
     isMobileView = false;

     /**
      * MediaQueryList object for handling responsive design.
      * @type {MediaQueryList}
      * @private
      */
     mediaQueryList;
 
     /**
      * Event listener function for media query changes.
      * @type {function}
      * @private
      */
     mediaQueryListener;
 
 
     /**
      * Getter for the list of logos.
      * @type {Array<{url: string}>}
      */
     get logoList() {
         return this._logoList;
     }
     
    @track _productCards = [];

    get productCards(){
        return this._productCards;
    }

    set productCards(value){
        this._productCards = value;
    }


    get cardExists(){
        return this._productCards.length > 0;
    }
    
 
     /**
      * Handles the event when a lead is successfully created.
      * Displays a success toast message and scrolls to the form element.
      * @param {CustomEvent} event - The event containing lead creation details.
      */
     handleLeadCreated(event) {
         // Example of expected data returned {"leadResult":{"Id":"00QIk000001DWmiMAG","unmapped":{}}}
         const eventDetails = event.detail;
 
         const evt = new ShowToastEvent({
             title: 'Thank you!',
             message: 'Your interest has been registered!',
             variant: 'success',
         });
 
         this.dispatchEvent(evt);
         this.handleScroll('[data-id="sxsw-form-ele"]');
     }
 
     /**
      * Handles the event when a lead creation fails.
      * Displays an error toast message.
      * @param {CustomEvent} event - The event containing error details.
      */
     handleLeadNotCreated(event) {
         const eventDetails = event.detail;
 
         const evt = new ShowToastEvent({
             title: 'Error',
             message: 'There was an error registering your interest. Please try again.',
             variant: 'error',
         });
         this.dispatchEvent(evt);
     }
 
     /**
      * Lifecycle hook called when the component is inserted into the DOM.
      * Initializes media query listener for responsive design.
      */
     connectedCallback() {
         // Initialize the media query
         this.mediaQueryList = window.matchMedia('(max-width: 800px)');
 
         // Set the initial value
         this.isMobileView = this.mediaQueryList.matches;
 
         // Bind the listener to the component instance
         this.mediaQueryListener = this.handleMediaChange.bind(this);
        

         // Add the listener
         this.mediaQueryList.addListener(this.mediaQueryListener);

         this.getEoiOfferInformation();

     }
 
     /**
      * Lifecycle hook called when the component is removed from the DOM.
      * Cleans up the media query listener.
      */
     disconnectedCallback() {
         // Clean up the listener when the component is destroyed
         this.mediaQueryList.removeListener(this.mediaQueryListener);
     }
 
     /**
      * Handles changes in the media query state.
      * Updates the isMobileView property based on screen size.
      * @param {MediaQueryListEvent} event - The event containing media query change details.
      */
     handleMediaChange(event) {
         // Update the isMobileView property when the media query state changes
         this.isMobileView = event.matches;
     }
 
     /**
      * Computes the inline CSS style for the background image.
      * @type {string}
      */
     get backgroundStyle() {
         return `background-image: linear-gradient(118deg, #000 31.77%, rgba(0, 0, 0, 0.27) 87.96%), url(${IMG_PATH}/Images/SXSW2024/SXSW-HeaderImg.jpg); background-size: cover; background-position: center;`;
     }
 
     /**
      * Scrolls smoothly to the element specified by the selector.
      * @param {string} selector - The CSS selector of the target element.
      */
     handleScroll(selector) {
         // Select the target element
         const target = this.template.querySelector(selector);
         if (target) {
             // Scroll the element into view smoothly
             target.scrollIntoView({ behavior: 'smooth' });
         } else {
             console.error('Element not found');
         }
     }


    /**
     * Retrieves EOI offer information from the server using the Apex controller.
     * Parses the returned JSON data, extracts the Banner and Logo URLs from the imagesUrl field,
     * adds an 'id' field to each item, and updates the component's data.
     * 
     * @async
     * @returns {Promise<Array>} A Promise that resolves with the parsed and processed EOI offer information.
     * @throws {Error} If an error occurs during the retrieval or parsing process.
     */
    async getEoiOfferInformation(){
        this.isLoading = true;
        try {
            const data = await apex_retrieveEOIOfferInformation({ searchTerm: this.searchValue });

            // Attempt to parse the returned data
            let parsedData;
            try {
                parsedData = JSON.parse(data);
            } catch (parseError) {
                throw new Error('Failed to parse server response as JSON.');
            }

            // Validate that parsedData is an array
            if (!Array.isArray(parsedData)) {
                throw new Error('Parsed data is not an array.');
            }
    
            // Process each item in the parsed data
            this.productCards = parsedData.map((item, index) => {
                let images = [];
                if (item.imagesUrl) {
                    try {
                        const parsedImages = JSON.parse(item.imagesUrl);
                        if (Array.isArray(parsedImages)) {
                            images = parsedImages;
                        } else {
                            console.warn(`imagesUrl is not an array for item with id ${item.id || index + 1}.`);
                        }
                    } catch (imageParseError) {
                        console.warn(`Failed to parse imagesUrl for item with id ${item.id || index + 1}:`, imageParseError);
                    }
                }
                // Create a map for faster lookup if images array is large
                const imageMap = images.reduce((acc, img) => {
                    if (img.title && typeof img.contentDownloadURL === 'string') {
                        acc[img.title.toLowerCase()] = img.contentDownloadURL;
                    }
                    return acc;
                }, {});

                // Ensure dealPageLink starts with 'http://' or 'https://'
                let dealPageLink = item.dealPageLink || '';
                if (dealPageLink && !/^https?:\/\//i.test(dealPageLink)) {
                    dealPageLink = `https://${dealPageLink}`;
                    console.warn(`dealPageLink for item with id ${item.id || index + 1} was missing protocol. Updated to: ${dealPageLink}`);
                }

                return {
                    ...item,
                    id: index + 1, // Ensure 'id' is unique and consistent
                    bannerURL: imageMap['banner'] || '',
                    logoURL: imageMap['logo'] || '',
                    dealPageLink: dealPageLink,
                    statusMessage: "Express your interest now"
                };
            });
        } catch (error) {
            console.error('Error retrieving EOI offer information:', error);
        } finally {
            console.log(JSON.stringify(this.productCards))
            this.isLoading = false;
        }
    }
    
    handleSearchChange(event){
        this.productCards = []
        this.searchValue = event.detail.value
        this.getEoiOfferInformation();
    }

     /**
     * Scrolls smoothly to the element specified by the selector.
     * @param {string} selector - The CSS selector of the target element.
     */
     handleScroll(selector) {
        // Select the target element
        const target = this.template.querySelector(selector);
        if (target) {
            // Scroll the element into view smoothly
            target.scrollIntoView({ behavior: 'smooth' });
        } else {
            console.error('Element not found');
        }
    }

    /**
     * Handles the button click event and initiates scrolling to the form container.
     */
    handleScrollToEOIs() {
        this.handleScroll('[data-id="sxsw-product-container"]');
    }


}