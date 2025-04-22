/**
 * @description Child component to control the Helphub
 * @createdBy Cesar
 * @createdDate 2024-09-26
 * @version 1.1
 */

import { LightningElement} from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import apex_retrieveTaxStatements from '@salesforce/apex/PipoController.getTaxDocuments';
import userId from "@salesforce/user/Id";

export default class PipoHelpHub extends NavigationMixin(LightningElement) {

    // Track the selected option
    selectedOption = '';
    // Menu visibility
    isMenuOpen = false;
    // Handle loading
    isLoading;
    _handler;
    taxStatements;
    helpText = 'Retrieving your tax documents. Should only take a few seconds.';

    loaded = false;
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
                name: 'InvestorFAQS__c',

            }
        }).then(url => {
            window.open(url, '_blank');
        })        
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
    get isContactSelected() {
        return this.selectedOption === 'contact';
    }

    get isDocumentsSelected() {
        return this.selectedOption === 'documents';
    }

    get isFaqSelected() {
        return this.selectedOption === 'faqs';
    }

    get isPortalSelected() {
        return this.selectedOption === 'portal';
    }


    /**
     * Handles the download button click event.
     * If the tax documents have not been loaded yet, it triggers the retrieval of tax documents.
     *
     * @function handleDownload
     * @param {Event} event - The click event triggered by the download button.
     * @param {string} event.target.dataset.option - The option selected for download.
     * @param {boolean} loaded - A flag indicating whether the tax documents have been loaded.
     * @param {string} selectedOption - The selected option for download.
     * @param {boolean} isLoading - A flag indicating whether the component is currently loading data.
     * @param {function} getPDFLinks - A function to retrieve and process tax documents.
     * @param {string} userId - The Salesforce user ID for which to retrieve tax documents.
     *
     * @returns {void}
     */
    handleDownload(event) {
        this.selectedOption = event.target.dataset.option;
        if (!this.loaded) {
            this.isLoading = true;
            this.getPDFLinks(userId)
                .finally(() => {
                    this.isLoading = false;
                });
            this.loaded = true;
        }
    }

    /**
     * Retrieves and processes tax documents for a given user, grouping them by fiscal year.
     *
     * @function getPDFLinks
     * @param {string} _userId - The Salesforce user ID for which to retrieve tax documents.
     * @returns {Promise<void>} A promise that resolves when the tax documents have been processed and grouped.
     *
     * @throws Will throw an error if there is an issue fetching or parsing the PDF data.
     */
    async getPDFLinks(_userId) {
        let data = await apex_retrieveTaxStatements({
            userId: _userId,
            fileName: '_Tax_Statement',
            base64: false
        });
            try {
                if(data.length === 0) {
                    this.helpText = 'It looks like you don\'t have any tax documents to download yet. Once you do, they will be downloadable here.';
                }
                // Grouping the data by fiscal year
                const groupedData = data.reduce((groupedFiles, fileObj) => {
                    const fy = this.extractFiscalYear(fileObj.FileName); // Get the fiscal year
                    if (!groupedFiles[fy]) {
                        groupedFiles[fy] = {
                            label: 'Financial Year ' + (fy - 1) + '/' +  fy,
                            year: fy
                        };
                    }
                    return groupedFiles;
                }, {});
                let finalData = Object.values(groupedData);
                this.taxStatements = finalData.reverse();
                this.helpText = 'We\'ve grouped all of your tax statements to your portfolio'
            } catch (error) {
                console.error('Error fetching or parsing PDF data:', error);
                this.helpText = 'There is an error fetching or parsing PDF data, please try again later.';
            }
    }

    /**
     * Extracts the fiscal year from a given file name.
     * @function extractFiscalYear
     * @param {string} fileName - The name of the file from which to extract the fiscal year.
     * @returns {string} The fiscal year extracted from the file name. If no fiscal year is found, returns 'Unknown'.
     */
    extractFiscalYear(fileName) {
        const match = fileName.match(/FY(\d{2})/);
        // Return 'Unknown' if no FY is found
        return match ? `${match[1]}` : 'Unknown'; 
    }

    /**
     * Method to navigate to tour video.
     * @returns {void}
    */
    handleTourButtonClick() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: 'https://www.youtube.com/watch?v=G-HzVM9A_4U&ab_channel=VentureCrowd' 
            }
        })
    }

}