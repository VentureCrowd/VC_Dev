/**
 * @module c/sxswLandingPageContainer
 * @author KENDRICK KAM
 * @date 26/09/2024
 */

import { LightningElement, track, wire, api } from 'lwc';
import IMG_PATH from '@salesforce/resourceUrl/ventureCrowdTheme';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from 'lightning/navigation';

/**
 * SxswLandingPageContainer component handles the display logic for the SXSW landing page.
 * It manages responsive design, URL parameters, and user interactions such as lead creation.
 */
export default class SxswLandingPageContainer extends NavigationMixin(LightningElement) {
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
     * The form type, determines which form to display ('founder' or 'investor').
     * @type {string}
     * @default 'founder'
     * @track
     */
    @track formType = 'founder';

    /**
     * List of logo image URLs to display.
     * @type {Array<{url: string}>}
     * @private
     * @track
     */
    @track _logoList = [
        { url: IMG_PATH + '/Images/SXSW2024/SXSW-logos1.png' },
        { url: IMG_PATH + '/Images/SXSW2024/SXSW-logos2.png' }
    ];

    @api redirectPageName; // Name of the page to redirect to, set via Experience Builder

    get isFounder(){
        return this.formType === 'founder';
    }

    get formTitleText(){
        if (this.formType === 'founder') {
            return 'RAISE CAPITAL SMARTER NOT HARDER';
        }

        if (this.formType === 'investor') {
            return 'BACK WHAT YOU BELIEVE IN TODAY';
        }

        return 'BACK WHAT YOU BELIEVE IN TODAY';
    }
    
    /**
     * Returns the subtext for the form based on the form type.
     * @type {string}
     */
    get formSubtext() {
        if (this.formType === 'founder') {
            return 'Get Started as a Founder';
        }

        if (this.formType === 'investor') {
            return 'Get Started as an Investor';
        }

        return 'Get Started as an Investor';
    }

    /**
     * Getter for the list of logos.
     * @type {Array<{url: string}>}
     */
    get logoList() {
        return this._logoList;
    }

    /**
     * Retrieves the current page reference and sets the form type based on URL parameters.
     * @param {Object} pageReference - The current page reference object.
     * @wire
     */
    @wire(CurrentPageReference)
    getPageReference(pageReference) {
        if (pageReference) {
            this.formType = pageReference.state.id;
            // Perform additional logic based on the id parameter
        }
    }

    /**
     * Handles the event when a lead is successfully created.
     * Displays a success toast message, scrolls to the form element,
     * waits for 2 seconds, and then redirects to the EOI Finalists page.
     * @param {CustomEvent} event - The event containing lead creation details.
     */
    async handleLeadCreated(event) {
        // Example of expected data returned {"leadResult":{"Id":"00QIk000001DWmiMAG","unmapped":{}}}
        const eventDetails = event.detail;

        const evt = new ShowToastEvent({
            title: 'Thank you!',
            message: 'Your interest has been registered!',
            variant: 'success',
        });

        this.dispatchEvent(evt);
        
        // Scroll to the form element
        this.handleScroll('[data-id="sxsw-form-ele"]');

        // Wait for 2 seconds (2000 milliseconds)
        await this.delay(2000);

        // Redirect to the specified page
        this.navigateToRedirectPage();
    }

    /**
     * Redirects the user to the specified page.
     */
    navigateToRedirectPage(){
        if(this.redirectPageName){
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: this.redirectPageName
                }
            });
        } else {
            console.error('Redirect page name is not defined.');
        }
    }

    /**
     * Returns a Promise that resolves after the specified number of milliseconds.
     * @param {number} ms - The number of milliseconds to wait.
     * @returns {Promise} - A Promise that resolves after the delay.
     */
    delay(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
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
     * Gets the form image URL based on the form type.
     * @type {string}
     */
    get formImage() {
        return this.formType === 'founder'
            ? `${IMG_PATH}/Images/SXSW2024/SXSW-FounderImg.jpg`
            : `${IMG_PATH}/Images/SXSW2024/SXSW-InvestorImg.jpg`;
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
    handleButtonClick() {
        this.handleScroll('[data-id="formContainer"]');
    }
}