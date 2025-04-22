/**
 * @description Container to iterate over all the cards
 * @dependencies coreButton, pipoInvestmentCard
 * @createdBy Cesar
 * @createdDate 2024-09-26
 * @version 1.1
 */

import { LightningElement, track, api} from 'lwc';
import { NavigationMixin } from "lightning/navigation";

export default class PipoInvestmentCardContainer extends NavigationMixin(LightningElement) {
    @track _investmentDetails;
    @track _userName;
    @api isEoi;
    @api investmentStatus;
    // Expose to check the loading animation
    @api loadingButton;
    // Entities card
    @api showMoreButton;

    mainCards;

    /**
     * Sets the investment details and updates the card display logic.
     * If the number of investment details exceeds 4, it shows a "Show More" button
     * and stores the first 4 items separately.
     *
     * @param {Array} value - The array of investment details passed from the parent component.
     */
    @api
    set investmentsDetails(value) {
        // Handle any logic when data is passed from parent to child
        this._investmentsDetails = value;
        // Slice and store the first 4 items, or keep the full array if length is <= 4
        this.mainCards = value;
    }

    // Getter for investmentsDetails
    get investmentsDetails() {
        return this._investmentsDetails;
    }

    // Setter for userName
    @api
    set userName(value) {
        this._userName = value;
    }

    // Getter for userName
    get userName() {
        return this._userName;
    }


    /**
     * Handles the "Show More" button click event.
     * Dispatches a custom event to notify the parent component to fetch the next set of data.
     *
     * @returns {void}
     */
    handleShowMore() {
        // Dispatch a custom event to notify the parent to fetch the next set of data
        const showMoreEvent = new CustomEvent('loadmore', {
            bubbles: true,
            composed: false,
        });
        this.dispatchEvent(showMoreEvent);
    }

    /**
     * Handles the investment detail click event.
     * Navigates to the Opportunity record page in Salesforce when an investment detail is clicked.
     * 
     * @param {Event} event - The click event triggered by the investment detail.
     * @returns {void}
     */
    handleInvestmentDetail(event) {
        event.stopPropagation();
        let fieldName = event.detail;    
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: fieldName.investmentId,
                objectApiName: 'Investment',
                actionName: "view",
            },
            state: {
                // Send the investment if it's pending or active
                investmentStatus: this.investmentStatus
            }
        })
    }
}