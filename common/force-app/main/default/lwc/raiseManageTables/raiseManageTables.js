/**
 * RaiseManageTables Component
 * @description This component manages the display and interaction of tabs for "Leads" and "Opportunities". It allows users to switch between these tabs and handles the loading state for the data tables displayed within each tab.
 */

import { LightningElement , api, track} from 'lwc';

export default class RaiseManageTables extends LightningElement {
    @api recordId; // The record ID associated with the component.

    @track tabs = [
        {
            label: 'Leads',
            name: 'leads',
            objectName : 'Lead',
            active : true,
        },
        {
            label: 'Opportunities',
            name: 'opportunities',
            objectName : 'Opportunity',
            active : false,
        }
    ]// An array of tab objects with label, name, objectName, and active status.

    @track activeTab; // The name of the currently active tab.

    @track isLoading; // Boolean indicating whether the component is in a loading state.

    /**
     * Checks if the "Opportunities" tab is active.
     * @returns {boolean} - True if the "Opportunities" tab is active, false otherwise.
     */
    get isOpportunitiesActive(){
        return this.activeTab === 'opportunities';
    }

    /**
     * Checks if the "Leads" tab is active.
     * @returns {boolean} - True if the "Leads" tab is active, false otherwise.
     */
    get isLeadsActive(){
        return this.activeTab === 'leads';
    }

    /**
     * Handles the click event on a tab, sets the clicked tab as active, and updates the active tab state.
     * @param {Event} e - The click event.
     */
    handleClickTab(e){
        const clickedTabName = e.target.dataset.id;

        this.tabs.forEach(item => {
            item.active = (item.name === clickedTabName);
        });

        this.activeTab = this.findActiveTab();
    }

    /**
     * Finds and returns the name of the currently active tab.
     * @returns {string|undefined} - The name of the active tab or undefined if no tab is active.
     */
    findActiveTab(){
        const activeTab = this.tabs.find(item => item.active);
        return activeTab ? activeTab.name : undefined;
    }

    /**
     * Lifecycle hook that runs when the component is inserted into the DOM. Initializes the active tab.
     */
    connectedCallback(){
        this.activeTab = this.findActiveTab();
    }

    /**
     * Handles the loading state change event from the child components.
     * @param {Event} e - The loading change event.
     */
    handleLoadingChange(e){
        e.stopPropagation();
        this.isLoading = e.detail.isLoading;
    }
}