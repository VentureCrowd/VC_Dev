// Importing base Lightning web component functionality
import { LightningElement, wire, track } from 'lwc';
// Importing Apex method for adding or updating media links
import addUpdateMediaLinks from '@salesforce/apex/MyEOIController.addUpdateMediaLinks';
// Importing Apex method for retrieving media links
import getMediaLinks from '@salesforce/apex/MyEOIController.getMediaLinks';
// Importing Apex method for deleting records
import deleteRecord from '@salesforce/apex/Utils.deleteRecord';
// Importing the standard Lightning Web Component event for displaying toasts
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// Importing the module to obtain the current page reference
import { CurrentPageReference } from 'lightning/navigation';
// Importing a custom utility module
import { Utility } from 'c/utils';
// Importing Apex method for refreshing data
import { refreshApex } from '@salesforce/apex';

export default class AddEditMediaLinks extends LightningElement {
    // Initializing boolean properties for controlling modal visibility, spinner, and button states
    isAddModelOpen = false;
    isEditModelOpen = false;
    hasMedia = false;
    showSpinner = false;
    showRecords = true;
    disableSaveBtn = true;
    disableUpdateBtn = false;
    nameNotEmpty = false;
    urlIsValid = false;

    // Initializing a variable to store the EOI (Expression of Interest) Id
    eoiId = '';
    // Initializing an empty object to store data related to team members
    datamap = {};
    // Using @track decorator to make property reactive
    @track mediaLst = [];
    @track mediaToUpdate = [];
    @track mediaLinkId;
    wiredMediaLinks;

    /**
      * Wire method that listens for changes in the current page reference, specifically the 'edit' state parameter.
      * Updates the component's 'eoiId' property when the 'edit' state parameter is available.
      *
      */
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        // Check if the current page reference is available
        if (currentPageReference) {
            // Update the component's 'eoiId' property with the 'edit' state parameter
            this.eoiId = currentPageReference.state.edit;
        }
    }

    /**
      * Wire method that retrieves media links based on the provided EOI Id.
    */
    @wire(getMediaLinks, { eoiId: '$eoiId' })
    mediaLinks(result) {
         // Hide the records initially   
        this.showRecords = false;
        // Assign the result to the wiredMediaLinks property
        this.wiredMediaLinks = result;
        if (result.data) {
            // Set hasMedia to true, populate mediaLst, and show records
            this.hasMedia = true;
            this.mediaLst = [];
            this.mediaLst = result.data;
            this.showRecords = true;
        } else if (result.error) {
            // Show records and log an error if there's an issue with the wired method
            this.showRecords = true;
            console.error('Error in getting media links', result.error);
        }
    }

    /**
      * Handles the removal of a media link.
      * Hides records, displays the spinner, deletes the media link using Apex method deleteRecord,
      * and shows success or error messages based on the result.
      * Refreshes the view to reflect the updated list of media links.
      *
    */
    handleRemoveMedia(event) {
        this.showRecords = false;
        this.showSpinner = true;
        if (event && event.target.dataset && event.target.dataset.id) {
            let mediaLinkId = event.target.dataset.id;
            // Trigger the Apex method to delete the media link
            deleteRecord({ recordId: mediaLinkId })
                .then((result) => {
                    if (result) {
                        // Check the result and show appropriate messages
                        if (result && result == 'Success') {
                            this.showRecords = false;
                            this.handleRefreshView();
                            this.showRecords;
                            this.showtoast('Media link deleted successfully.', 'success');
                            this.showSpinner = false;
                        }
                    }
                })
                .catch((e) => {
                     // Show error message if deletion fails
                    this.showSpinner = false;
                    console.log('error in deleting media link');
                });
        }
    }

    /**
      * Handles the addition of a new media link.
      * Hides records, displays the add modal, sets the appropriate data map values,
      * and triggers the addition of the media link through the Apex method.
      * Shows success or error messages based on the result.
    */
    addMedia() {
        // Hide the records and display the add modal
        this.showRecords = false;
        this.showSpinner = true;
        let isformvalid = true;
        // Check if the data map contains the 'Id' property and remove it
        if (this.datamap && this.datamap.hasOwnProperty('Id')) {
            delete this.datamap.Id;
        }
        this.datamap['EOI__c'] = this.eoiId;
        let datamap = this.datamap;
        if (isformvalid) {
            addUpdateMediaLinks({ datamap })
                .then((r) => {
                    if (r == 'Success') {
                        // Check the result and show appropriate messages
                        this.isAddModelOpen = false;
                        this.showRecords = true;
                        this.showtoast('Media link added.', 'success');
                        this.showSpinner = false;
                        this.handleRefreshView();
                    } else {
                        this.showtoast(r, 'error');
                        this.showRecords = true;
                        this.showSpinner = false;
                    }
                })
                .catch((e) => {
                    this.showtoast('Unable to add media link.', 'error');
                    this.showSpinner = false;
                    this.showRecords = true;
                });
        } else {
             // Display error message for incomplete form details
            this.showSpinner = false;
            this.showRecords = true;
            this.showtoast('Please fill in all the details', 'error');
        }
    }

    /**
      * Handles the editing of a media link based on the selected event.
      * Hides records, displays the edit modal, retrieves the media link details,
      * and enables or disables the update button based on the retrieved information.
    */
    handleEditMedia(event) {
        // Hide the records and display the edit modal
        this.showRecords = false;
        this.isEditModelOpen = true;
         // Check if the event contains the required data attributes
        if (event && event.target.dataset && event.target.dataset.id) {
            this.mediaLinkId = event.target.dataset.id;
            // Refresh the view to ensure updated data is displayed
            this.handleRefreshView();
            // Find the media link details based on the retrieved id
            this.mediaToUpdate = this.mediaLst.find((founder) => founder.Id === this.mediaLinkId);
             // Enable the update button if media link details are retrieved
            if (this.mediaToUpdate && this.mediaToUpdate != undefined) {
                this.disableUpdateBtn = false;
            }
            // Set the media link id and details in the data map for editing
            this.datamap['Id'] = this.mediaLinkId;
            this.datamap['Name'] = this.mediaToUpdate.Name;
            this.datamap['Media_URL__c'] = this.mediaToUpdate.Media_URL__c;
        }
    }

    /**
      * Updates media links based on the provided data map.
      * Hides records, displays a spinner during the update process,
      * and handles success or error scenarios with appropriate toasts.
    */
    updateMedia() {
        // Hide the records and display a spinner during the update process
        this.showRecords = false;
        this.showSpinner = true;
        let isformvalid = true;
        // Check if the data map has the 'EOI__c' property and remove it
        if (this.datamap && this.datamap.hasOwnProperty('EOI__c')) {
            delete this.datamap.EOI__c;
        }
        let datamap = this.datamap;
        if (isformvalid) {
            addUpdateMediaLinks({ datamap })
                .then((r) => {
                    // Show records, close the edit modal, refresh the view, and display success toast
                    if (r == 'Success') {
                        this.showRecords = true;
                        this.isEditModelOpen = false;
                        this.handleRefreshView();
                        this.showtoast('Media link updated.', 'success');
                        this.showSpinner = false;
                    } else {
                        // Display an error toast if the update was not successful
                        this.showtoast(r, 'error');
                        this.showSpinner = false;
                    }
                })
                .catch((e) => {
                    // Display an error toast if there was an issue with the update
                    this.showtoast('Unable to update media link.', 'error');
                    this.showSpinner = false;
                    this.showRecords = true;
                });
        } else {
            // If the form is not valid, hide the spinner, show records, and display an error toast
            this.showSpinner = false;
            this.showRecords = true;
            this.showtoast('Please fill in all the details', 'error');
        }
    }
    // Method to handle input changes and validate the inputs
    handleChange(event) {
        // Check the name attribute of the target element to determine which property to update
        if (event.target.name == 'Name') {
            // Update the 'Name' property in the data map with the new value
            this.datamap['Name'] = event.target.value;
        }
        if (event.target.name == 'Media_URL__c') {
            // Update the 'Media_URL__c' property in the data map with the new value
            this.datamap['Media_URL__c'] = event.target.value;
        }
        // Validate URL after updating datamap properties
        this.urlIsValid = Utility.validateUrl(this.datamap['Media_URL__c']);
        // Validate inputs after updating datamap properties
        this.validateInputs();
    }
    // Method to validate inputs and enable/disable save and update buttons
    validateInputs() {
        this.nameNotEmpty = [this.datamap['Name']].some((value) => value);
        if (this.urlIsValid && this.nameNotEmpty) {
            this.disableSaveBtn = this.disableUpdateBtn = false;
        } else {
            this.disableSaveBtn = this.disableUpdateBtn = true;
        }
    }

    // Method to refresh the view by calling refreshApex
    handleRefreshView() {
        //Refresh the view by calling refreshApex after changing values inside the wiredTeamMemberLst variable
        refreshApex(this.wiredMediaLinks);
    }

    // Method to open the add model for adding a new media
    openAddModel() {
        this.disableSaveBtn = true;
        this.datamap = {};
        this.nameNotEmpty = false;
        this.urlIsValid = false;
        this.isAddModelOpen = true;
    }
    // Method to close the add model
    closeAddModel() {
        this.disableSaveBtn = true;
        this.datamap = {};
        this.nameNotEmpty = false;
        this.urlIsValid = false;
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