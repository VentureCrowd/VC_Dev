// Importing required methods and standars standard component start here
import { LightningElement, wire, track } from 'lwc';
import addUpdateTeamMember from '@salesforce/apex/MyEOIController.addUpdateLeadInvestor';
import getLeadInvestors from '@salesforce/apex/MyEOIController.getLeadInvestor';
import deleteRecord from '@salesforce/apex/Utils.deleteRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
// Importing required methods and standars standard component ends here

export default class AddEditLeadInvestor extends LightningElement {
    // Flags to control the visibility of add and edit modals
    isAddModelOpen = false;
    isEditModelOpen = false;

    // Flag to indicate whether lead investors are present
    hasLeadInvestor = false;
    showSpinner = false;

    // Flag to control the visibility of lead investor records
    showRecords = true;

    // Flags to control the availability of Save and Update buttons
    disableSaveBtn = true;
    disableUpdateBtn = false;

    // Variable to store the EOI Id
    eoiId = '';

    // Map to store lead investor data for add and update operations
    datamap = {};

    // Using @track decorator to make property reactive
    @track leadInvestorsLst;
    @track leadInvestorToUpdate = [];
    @track leadInvestorId;
    wiredLeadInvestors;

    // Wire method to retrieve state parameters from the current page reference
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        // Check if the current page reference is available
        if (currentPageReference) {
            // Extract the 'edit' parameter from the state, if present
            this.eoiId = currentPageReference.state.edit;
        }
    }

    // Wire method to retrieve lead investors based on the provided EOI ID
    @wire(getLeadInvestors, { eoiId: '$eoiId' })
    leadInvestors(result) {
        this.wiredLeadInvestors = result;
        this.showRecords = false;
        // Check if the result contains data
        if (result.data) {
            // Set flag to indicate the presence of lead investors
            this.hasLeadInvestor = true;

            // Initialize and populate the lead investors list with the retrieved data
            this.leadInvestorsLst = [];
            this.leadInvestorsLst = result.data;
            this.showRecords = true;
        } else if (result.error) {
            // Show records and log an error if there's an issue with data retrieval
            this.showRecords = true;
            console.error('Error in getting lead investors', result.error);
        }
    }

    // Method to remove a lead investor
    removeLeadInvestor(event) {
        // Hide existing records and show loading spinner
        this.showRecords = false;
        this.showSpinner = true;

        // Call Apex method to delete the lead investor record by ID
        if (event && event.target.dataset && event.target.dataset.id) {
            let leadInvestorId = event.target.dataset.id;
            deleteRecord({ recordId: leadInvestorId })
                .then((result) => {
                    if (result) {
                        // Show records, refresh the view, display success toast, and hide the spinner
                        if (result && result == 'Success') {
                            this.showRecords = false;
                            this.handleRefreshView();
                            this.showRecords = true;
                            this.showtoast('Lead investor deleted successfully.', 'success');
                            this.showSpinner = false;
                        }
                    }
                })
                .catch((e) => {
                    // Handle error by hiding the spinner and logging the error
                    this.showSpinner = false;
                    console.log('error in deleting lead investor');
                });
        }
    }

    /**
      * Method to handle the adding of a lead investor
      * Hides records, displays the edit modal 
    */
    addLeadInvestor() {
        // Hide existing records and show loading spinner
        this.showRecords = false;
        this.showSpinner = true;
        let isformvalid = true;
        if (this.datamap && this.datamap.hasOwnProperty('Id')) {
            delete this.datamap.Id;
        }
        this.datamap['Related_EOI__c'] = this.eoiId;
        let datamap = this.datamap;
        if (isformvalid) {
            // Call the Apex method to add or update the lead investor
            addUpdateTeamMember({ datamap })
                .then((r) => {
                    if (r == 'Success') {
                        // Close the add modal, show records, display success toast, hide spinner, and refresh the view
                        this.isAddModelOpen = false;
                        this.showRecords = true;
                        this.showtoast('Lead investor added.', 'success');
                        this.showSpinner = false;
                        this.handleRefreshView();
                    } else {
                        this.showtoast(r, 'error');
                        this.showSpinner = false;
                    }
                })
                .catch((e) => {
                    // Display error toast if there's an exception
                    this.showtoast('Unable to add lead investor.', 'error');
                    this.showSpinner = false;
                });
        } else {
            // Display error toast if the form is not valid
            this.showSpinner = false;
            this.showtoast('Please fill in all the details', 'error');
        }
    }

    /**
      * Method to handle the editing of a lead investor
      * Hides records, displays the edit modal 
    */
    editLeadInvestor(event) {
        // Hide the records section and open the Edit Model
        this.showRecords = false;
        this.isEditModelOpen = true;

        // Check if the event is valid and contains the lead investor's ID
        if (event && event.target.dataset && event.target.dataset.id) {
            // Get the lead investor's ID from the dataset
            this.leadInvestorId = event.target.dataset.id;

            // Refresh the view (potentially fetching updated data)
            this.handleRefreshView();

            // Find the lead investor to be updated in the list
            this.leadInvestorToUpdate = this.leadInvestorsLst.find((founder) => founder.Id === this.leadInvestorId);

            // Populate data map for use in the modal
            this.datamap['Id'] = this.leadInvestorId;
            this.datamap['Name'] = this.leadInvestorToUpdate.Name;
            this.datamap['Lead_Investor_Amount__c'] = this.leadInvestorToUpdate.Lead_Investor_Amount__c;
            this.datamap['Lead_Investor_Bio__c'] = this.leadInvestorToUpdate.Lead_Investor_Bio__c;
        }
    }

    /**
      * Updates lead investor based on the provided data map.
      * Hides records, displays a spinner during the update process,
      * and handles success or error scenarios with appropriate toasts.
    */
    updateLeadInvestor() {
        // Hide the records and display a spinner during the update process
        this.showRecords = false;
        this.showSpinner = true;
        let isformvalid = true;
        if (this.datamap && this.datamap.hasOwnProperty('Related_EOI__c')) {
            delete this.datamap.Related_EOI__c;
        }
        let datamap = this.datamap;
        if (isformvalid) {
            // Call the Apex method to update team members
            addUpdateTeamMember({ datamap })
                .then((r) => {
                    if (r == 'Success') {
                        // Show records, close the edit modal, refresh the view, and display success toast
                        this.showRecords = true;
                        this.isEditModelOpen = false;
                        this.handleRefreshView();
                        this.showtoast('Lead investor updated.', 'success');
                        this.showSpinner = false;
                    } else {
                        this.showtoast(r, 'error');
                        this.showSpinner = false;
                    }
                })
                .catch((e) => {
                    // Display an error toast if there was an issue with the update
                    this.showtoast('Unable to update lead investor.', 'error');
                    this.showSpinner = false;
                    this.showRecords = true;
                });
        } else {
            this.showSpinner = false;
            this.showRecords = true;
            this.showtoast('Please fill in all the details', 'error');
        }
    }

    // Method to handle input changes and validate the inputs
    handleChange(event) {
        // Check the name attribute of the target element to determine which property to update
        if (event.target.name == 'Name') {
            this.datamap['Name'] = event.target.value;
        }
        if (event.target.name == 'Lead_Investor_Amount__c') {
            this.datamap['Lead_Investor_Amount__c'] = parseInt(event.target.value);
        }
        if (event.target.name == 'Lead_Investor_Bio__c') {
            this.datamap['Lead_Investor_Bio__c'] = event.target.value;
        }

        // Validate inputs after updating datamap properties
        this.validateInputs();
    }

    // Method to validate inputs and enable/disable save and update buttons
    validateInputs() {
        // Check if any of the required fields are empty
        // If any field is empty, disable both save and update buttons
        this.disableSaveBtn = this.disableUpdateBtn = [this.datamap['Name'], this.datamap['Lead_Investor_Amount__c'], this.datamap['Lead_Investor_Bio__c']].some((value) => !value);
    }

    // Method to refresh the view by calling refreshApex
    handleRefreshView() {
        //Refresh the view by calling refreshApex after changing values inside the wiredTeamMemberLst variable
        refreshApex(this.wiredLeadInvestors);
    }

    // Method to open the add model for adding a new media
    openAddModel() {
        this.datamap = {};
        this.disableSaveBtn = true;
        this.isAddModelOpen = true;
    }

    // Method to close the add model
    closeAddModel() {
        this.disableSaveBtn = true;
        this.isAddModelOpen = false;
    }

    // Method to close the edit model
    closeEditModel() {
        this.isEditModelOpen = false;
        this.showRecords = true;
    }

    // Method to display a toast message
    showtoast(m, k) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: m,
                variant: k
            })
        );
    }
}