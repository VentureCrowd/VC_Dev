/**
 * @description Controller class for all the Products Offers.
 * @dependencies portfolioViewPipo LWC
 * @createdBy Cesar
 * @createdDate 2024-09-26
 * @version 1.0
 */

import { LightningElement, api } from 'lwc';

export default class PipoTabs extends LightningElement {
    @api totalActiveInvestments;
    @api totalPendingInvestments;
    @api totalExpressionsInvestments;
    @api totalInactiveInvestments;

    // Default tab
    activeTab = 'active';
    // Handle the visibility of the dropdown menu
    isDropdownVisible = false;
    // Stores the width value of the tab indicator
    widthValue;

    /**
     * @description Retrieves the count of investments for the currently active tab.
     * @returns {number} The count of investments for the selected tab.
     */
    get activeBadgeTotalInvestments() {
        switch (this.activeTab) {
            case 'active':
                return this.totalActiveInvestments || 0;
            case 'pending':
                return this.totalPendingInvestments || 0;
            case 'expressions':
                return this.totalExpressionsInvestments || 0;
            case 'inactive':
                return this.totalInactiveInvestments || 0;
            default:
                return 0;
        }
    }

    /**
     * @description Getters to check which tab is currently active.
     * @returns {boolean} Returns true if the specified tab is active, otherwise false.
     */
    get isActiveTab() {
        return this.activeTab === 'active';
    }

    get isPendingTab() {
        return this.activeTab === 'pending';
    }

    get isExpressionsTab() {
        return this.activeTab === 'expressions';
    }

    get isInactiveTab() {
        return this.activeTab === 'inactive';
    }

    /**
     * @description Retrieves the label for the active tab.
     * @returns {string} The label for the currently selected tab.
     */
    get activeTabLabel() {
        switch (this.activeTab) {
            case 'active':
                return 'Active';
            case 'pending':
                return 'Pending';
            case 'expressions':
                return 'Expressions of interest';
            case 'inactive':
                return 'Inactive investments';
            default:
                return 'Active';
        }
    }

    /**
     * @description Handles tab selection and updates the active tab.
     * Stores the selected tab in session storage for persistence.
     *
     * @param {Event} event - The event that triggered the tab selection.
     * The event must have a `currentTarget` property with a `dataset` property containing a `tab` property.
     */
    selectTab(event) {
        const selectedTab = event?.currentTarget?.dataset?.tab || 'inactive';
        this.setActiveTab(selectedTab);
    }


    /**
     * @description Updates the width value based on the selected tab.
     * @param {string} tabName - The name of the tab for which to set width.
     */
    updateWidthValue(tabName) {
        switch (tabName) {
            case 'active':
                this.widthValue = '28%';
                break;
            case 'pending':
                this.widthValue = '32%';
                break;
            case 'expressions':
                this.widthValue = '60%';
                break;
            case 'inactive':
                this.widthValue = '55%';
                break;
            default:
                this.widthValue = '24%';
                break;
        }

        // Apply the updated width value to the DOM
        this.template.host.style.setProperty('--tab-width', this.widthValue);
    }


    /**
     * @description Updates the active tab and applies necessary styles.
     * Dispatches an event to notify parent components.
     *
     * @param {string} tabName - The name of the tab to be activated.
     */
    @api 
    setActiveTab(tabName) {
        this.activeTab = tabName;

        // Store the selected tab in session storage
        sessionStorage.setItem('lastActiveTab', tabName);

        // Dispatch event to notify parent components about tab change
        const selectTabEvent = new CustomEvent('inactivetab', { 
            detail: { tabDetail: tabName },
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(selectTabEvent);

        // Update the width dynamically
        this.updateWidthValue(tabName);

        // Apply width value to the tab indicator
        this.template.host.style.setProperty('--tab-width', this.widthValue);

        // Hide dropdown if it was open
        this.isDropdownVisible = false;

        // Remove 'active' class from all tabs and add it to the selected one
        const tabs = this.template.querySelectorAll('.tab');
        tabs.forEach(tab => {
            tab.classList.remove('active');
        });

        const activeTabElement = this.template.querySelector(`[data-tab="${this.activeTab}"]`);
        if (activeTabElement) {
            activeTabElement.classList.add('active');
        }
    }

    /**
     * @description Toggles the dropdown menu visibility.
     */
    toggleDropdown() {
        this.isDropdownVisible = !this.isDropdownVisible;
    }

    /**
     * @description Getters to dynamically apply the 'active' class to the selected tab.
     * @returns {string} Returns 'tab active' for the active tab and 'tab' for inactive tabs.
     */
    get activeClassActive() {
        return this.activeTab === 'active' ? 'tab active' : 'tab';
    }

    get activeClassPending() {
        return this.activeTab === 'pending' ? 'tab active' : 'tab';
    }

    get activeClassExpressions() {
        return this.activeTab === 'expressions' ? 'tab active' : 'tab';
    }

    get activeClassInactive() {
        return this.activeTab === 'inactive' ? 'tab active' : 'tab';
    }

    /**
     * @description Lifecycle hook that runs when the component is initialized.
     * Retrieves the last active tab from session storage to maintain state after navigation.
     */
    connectedCallback() {
        // Retrieve the last active tab from sessionStorage
        const lastActiveTab = sessionStorage.getItem('lastActiveTab');
        if (lastActiveTab) {
            this.activeTab = lastActiveTab;
            this.updateWidthValue(lastActiveTab);
        } else {
            // Use default activeTab if no session storage value exists
            this.updateWidthValue(this.activeTab); 
        }
    }
    
}