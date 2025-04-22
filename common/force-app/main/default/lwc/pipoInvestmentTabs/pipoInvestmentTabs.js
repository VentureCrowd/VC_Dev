/**
 * @description LWC for the investor portfolio view - PIPO Project
 * @dependencies LWC coreButton, - Apex FIleUploadController
 * @createdBy Cesar
 * @createdDate 2024-10-18
 * @version 1.1
 */

import { LightningElement,api } from 'lwc';
import apex_retrieveFiles from '@salesforce/apex/FileUploadController.getFilesByRecord';

/**
 * PipoInvestmentTabs is a Lightning Web Component that manages and displays investment-related files.
 * It retrieves files from an Apex controller and categorizes them into financial documents, investor updates, 
 * and investment certificates. The component also handles tab selection and dropdown visibility.
 * 
 * @property {string} investmentId - The ID of the investment record.
 * @property {Array} investorUpdates - Array of investor update files.
 * @property {Array} financialDocuments - Array of financial document files.
 * @property {Array} investmentCertificates - Array of investment certificate files.
 * @property {Object} lengthFiles - Object containing the count of each type of file.
 * @property {string} activeTab - The currently active tab ('updates', 'documents', or 'certificates').
 * @property {boolean} isDropdownVisible - Boolean indicating if the dropdown is visible.
 */
export default class PipoInvestmentTabs extends LightningElement {

    @api investmentId;

    investorUpdates;
    financialDocuments;
    investmentCertificates;

    lengthFiles = {};
    activeTab = 'updates';
    isDropdownVisible = false;
    isLoading;

    /**
     * Retrieves investment files related to a specific record ID from the Apex controller.
     *
     * @param {string} recordId - The record ID of the investment.
     * @returns {Promise<Array>} - A promise that resolves to an array of investment files.
     * Each file object contains properties like 'FileName', 'CreatedDate', etc.
     *
     * @throws Will throw an error if the Apex controller call fails.
     */
    async getInvestmentFiles(recordId) {
        try {
            const files = await apex_retrieveFiles({ recordId: recordId });
            // Filter all the documents that
            this.financialDocuments = (files.filter(file => file.FileName.match(/FY\d{2}_Tax_Statement/)).length > 0) 
            ? files.filter(file => file.FileName.match(/FY\d{2}_Tax_Statement/)) 
            : false;        
        
            this.investorUpdates = files.some(file => /(?:Investor|Fund)[_ ]update/i.test(file.FileName)) 
                ? files.filter(file => /(?:Investor|Fund)[_ ]update/i.test(file.FileName))
                : false;
        
            this.investmentCertificates = files.filter(file => 
                !/(?:Investor[_ ]Update|Fund[_ ]Update|Tax[_ ]Statement|FY)/i.test(file.FileName)
            );
        
            this.lengthFiles = {
                investorUpdates: this.investorUpdates.length > 0 ? this.investorUpdates.length : 0,
                financialDocuments: this.financialDocuments.length > 0 ? this.financialDocuments.length : 0,
                investmentCertificates: this.investmentCertificates.length > 0 ? this.investmentCertificates.length : 0
            }
        } catch (error) {
            console.error(error);
        }
    }

    /**
     * Lifecycle hook that is called when the component is inserted into the DOM.
     * If the investmentId property is set. It calls the getInvestmentFiles method to retrieve related files.
     *
     * @returns {void}
     */
    connectedCallback() {
        this.isLoading = true;
        if (this.investmentId) {
            this.getInvestmentFiles(this.investmentId).finally(() => {
                this.isLoading = false;
        });
        }
    }


    get isInvUpdates() {
        return this.activeTab === 'updates';
    }

    get isFinancial() {
        return this.activeTab === 'documents';
    }

    get isInvCertificates() {
        return this.activeTab === 'certificates';
    }

    get activeTabLabel() {
        switch (this.activeTab) {
            case 'updates':
                return 'Investment updates';
            case 'documents':
                return 'Financial documents';
            case 'certificates':
                return 'Investment certificates';
            default:
                return 'Updates';
        }
    }

    /**
     * Handles tab selection and active styling.
     *
     * @param {Event} event - The event object from the tab selection.
     * The event target should have a 'data-tab' attribute representing the selected tab.
     *
     * @returns {void}
     *
     * @fires selectTab - Fires a custom event 'selectTab' with the selected tab as the detail.
     */
    selectTab(event) {
        const selectedTab = event.currentTarget.dataset.tab;

        // Only update the active tab if it's different from the current one
        if (selectedTab !== this.activeTab) {
            this.activeTab = selectedTab;

            // Fire custom event 'selectTab' with the selected tab as the detail
            const selectTabEvent = new CustomEvent('selectTab', { detail: selectedTab });
            this.dispatchEvent(selectTabEvent);
        }

        // Hide dropdown if open
        this.isDropdownVisible = false;

        // Remove 'active' class from all tabs and add it to the selected tab
        const tabs = this.template.querySelectorAll('.tab');
        tabs.forEach(tab => tab.classList.remove('active'));
        event.currentTarget.classList.add('active');
    }

    /**
     * Toggles the visibility of the dropdown menu.
     *
     * @function toggleDropdown
     * @memberof PipoInvestmentTabs
     * 
     * @returns {void}
     * 
     * @fires PipoInvestmentTabs#toggleDropdown - Fires a custom event 'toggleDropdown' when the dropdown visibility is toggled.
     * 
     * @listens PipoInvestmentTabs#toggleDropdown - Listens for the 'toggleDropdown' custom event and updates the 'isDropdownVisible' property accordingly.
     */
    toggleDropdown() {
        this.isDropdownVisible = !this.isDropdownVisible;
        // Fire custom event 'toggleDropdown' when the dropdown visibility is toggled
        const toggleDropdownEvent = new CustomEvent('toggleDropdown');
        this.dispatchEvent(toggleDropdownEvent);
    }

    /**
     * Handles the click event on the component.
     * If the active tab is 'updates', 'documents', or 'certificates', it reverses the order of the corresponding files array.
     *
     * @function handleClick
     * @memberof PipoInvestmentTabs
     *
     *
     * @listens PipoInvestmentTabs#click - Listens for the 'click' event on the component.
     *
     * @fires PipoInvestmentTabs#click - Fires a custom event 'click' when the component is clicked.
     */
    handleClick() {
        if (this.isInvUpdates) {
            this.investorUpdates = [...this.investorUpdates].reverse();
        }
        if (this.isFinancial) {
            this.financialDocuments = [...this.financialDocuments].reverse();
        }
        if (this.isInvCertificates) {
            this.investmentCertificates = [...this.investmentCertificates].reverse();
        }
    }
}