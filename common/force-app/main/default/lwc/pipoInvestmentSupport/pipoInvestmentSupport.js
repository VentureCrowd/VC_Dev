/**
 * @description LWC for the investor support button - PIPO Project
 * @dependencies LWC coreButton,coreInput,coreModal,coreIcon
 * @createdBy Cesar
 * @createdDate 2024-10-18
 * @version 1.1
 */

import { LightningElement, api } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import apex_requestRefund from '@salesforce/apex/PipoController.requestRefund';


export default class PipoInvestmentSupport extends NavigationMixin(LightningElement) {
    @api pendingInvestment;
    // Track the selected option
    selectedOption = '';
    // Menu visibility
    isMenuOpen = false;
    // Handle loading
    isLoading;
    taxStatements;
    refundReason;
    @api investmentId;
    coreInputState = true;

    // Form Data 
    formData = { }
    isFormLoading;

    _handler;


    // Track if the user already request a refund
    @api ableToRefund;
    
    // Toast message error message
    throwError = true



    // Toggle the menu visibility
    toggleMenu() {
        this.isMenuOpen = !this.isMenuOpen;
        if (!this.isMenuOpen) {
            this.selectedOption = ''; // Reset only when closing the menu
        }
    }

    // Handle the dropdown item click
    handleOptionClick(event) {
        // Get the option that was clicked using a custom data attribute
        this.selectedOption = event.target.dataset.option;
    }

    handleFaqClick() {
        // Get the option that was clicked using a custom data attribute
        this[NavigationMixin.GenerateUrl]({
            type: 'comm__namedPage',
            attributes: {
                name: 'FAQ__c',

            }
        }).then(url => {
            window.open(url, '_blank');
        })     
    }

    handleFinancialClick() {
        window.open('/articles/module/Financial-Hardship', "_self");
    }

    handleContactUs() {
        // Create a mailto link with subject and body (optional)
        const email = "hello@venturecrowd.com.au";        
        // Construct the mailto URL
        const mailtoLink = `mailto:${email}`;
        
        // Navigate to the mailto link to open the default mail client
        window.location.href = mailtoLink;
    }

    // Show default content with options
    showDefaultContent() {
        this.selectedOption = '';
    }

    // Determine if default content should be shown
    get isMenuDefault() {
        return this.selectedOption === '';
    }

    // Determine which content to show
    get isRequestRefundSelected() {
        return this.selectedOption === 'refund';
    }

    get isExploreInvestmentSelected() {
        return this.selectedOption === 'explore_investment';
    }

    get isGeneralEnquirySelected() {
        return this.selectedOption === 'general_enquiry';
    }

    get isReportIssueSelected() {
        return this.selectedOption === 'report_issue';
    }

    /**
     * Handles the refund request by calling the Apex method 'apex_requestRefund'.
     *
     * @function handleRefundRequest
     * @memberof PipoInvestmentSupport
     *
     * @description
     * This function is responsible for initiating a refund request for a specific investment.
     * It retrieves the investment ID and refund reason from the component's properties and
     * calls the Apex method 'apex_requestRefund' with these parameters.
     *
     * @param {void} - This function does not accept any parameters.
     *
     * @returns {void}
     *
     * @throws {Error} - If an error occurs during the Apex method call, it will be logged to the console.
     *
     */
    async handleRefundRequest() {
        this.isFormLoading = true;
        await apex_requestRefund({ investmentId: this.investmentId, reasonRefund: this.refundReason })
        .then(() => {
            this.refs.coremodal.openModal();
            this.ableToRefund = false;
            const refundSucess = new CustomEvent('refundsucess', {
                detail: true,
                bubbles: true,
                composed : false,
            })
            this.dispatchEvent(refundSucess);
        })
        .catch((error) => {
            console.error(error);
            const closebutton = new CustomEvent('refunderror',{
                detail: this.throwError,
                bubbles: true,
                composed : false,
            });
            this.dispatchEvent(closebutton);
        }).finally(() => {
            this.isFormLoading = false;
        });
    }


    /**
     * Handles the change event on the dropdown menu.
     * Updates the refund reason and toggles the input state based on the selected option.
     *
     * @param {Event} event - The change event triggered by the dropdown menu.
     * @property {string} event.target.value - The value of the selected option.
     * @property {HTMLElement} event.target - The HTML element that triggered the event.
     *
     * @returns {void}
     */
    handleOnChange(event){
        this.refundReason = event.target.value; // Update refund reason from the selected option
        if (event.target.value === 'Other') {
            this.coreInputState = false; // Enable the input field when 'Other' is selected
        } else {
            this.coreInputState = true; // Disable the input field for other options
        }
    }

    values = [
        {id: 1, value: 'Change of mind', label: 'Change of mind', checked: false},
        {id: 2, value: 'Change in financial position', label: 'Change in financial position', checked: false},
        {id: 3, value: 'Already Invested in this product', label: 'Already Invested in this product', checked: false},
        {id: 4, value: 'Other', label: 'Other (please specify)', checked: false},
    ]

    /**
     * Handles the change event on the form inputs.
     * Updates the form data and refund reason based on the selected option.
     *
     * @function handleFormChange
     * @memberof PipoInvestmentSupport
     *
     * @param {Event} event - The change event triggered by the form inputs.
     * @property {string} event.detail.name - The name of the input field that triggered the event.
     * @property {string} event.detail.value - The value of the input field.
     *
     * @returns {void}
     */
    handleFormChange(event) {
        const { name, value } = event.detail;
        this.refundReason = value;
        if (name) this.formData[name] = value;
        if (name === 'refundOptions') {
            if (value === 'Other') {
                this.coreInputState = false; // Enable the input field when 'Other' is selected
            } else {
                this.coreInputState = true; // Disable the input field for other options
            }
        }
    }

    // Close the investment support tab as well
    handleModalClose(event) {
        event.stopPropagation();
        this.toggleMenu();
    }


    /**
     * Adds an event listener to the document for the 'click' event.
     * When a click event occurs, it calls the 'close' method of the component.
     * This method is bound to the component instance using the 'bind' function.
     *
     * @function connectedCallback
     * @returns {void}
     */
    connectedCallback() {
        document.addEventListener('click', this._handler = this.close.bind(this));
    }
    /**
     * Removes the event listener for the 'click' event when the component is destroyed.
     * This ensures that the event listener is not left hanging and prevents memory leaks.
     * @function disconnectedCallback
     * @returns {void}
     */
    disconnectedCallback() {
        document.removeEventListener('click', this._handler);
    }

    /**
     * Closes the dropdown menu and resets the selected option.
     * This method is called when a click event occurs outside of the dropdown menu.
     *
     * @function close
     * @returns {void}
     */
    close() { 
        if (this.isMenuOpen) {
            this.isMenuOpen = false;
            this.selectedOption = '';
        }
    }

    /**
     * Handles the click event outside of the dropdown menu.
     * This method is used to close the dropdown menu when a click occurs outside of it.
     *
     * @function handleOutsideClose
     * @param {Event} event - The click event triggered outside of the dropdown menu.
     * @returns {boolean} Returns false to prevent the event from bubbling up.
     *
     */
    handleOutsideClose(event) {
        event.stopPropagation();
        return false;
    }

}