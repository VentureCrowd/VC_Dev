import { LightningElement, wire, track } from 'lwc';
// Importing the Apex method for adding or updating team members
import addUpdateTeamMember from '@salesforce/apex/MyEOIController.addUpdateTeamMember';
// Importing the Apex method for retrieving management team members
import getManagementTeamMember from '@salesforce/apex/MyEOIController.getTeamMembers';
// Importing the Apex method for deleting records using the Utils class
import deleteRecord from '@salesforce/apex/Utils.deleteRecord';
// Importing the ShowToastEvent class from the Lightning Platform
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// Importing the CurrentPageReference class from the Lightning Navigation module
import { CurrentPageReference } from 'lightning/navigation';
// Importing the refreshApex function from the Apex module
import { refreshApex } from '@salesforce/apex';

export default class AddEditWiderTeam extends LightningElement {
    // Initializing boolean properties for controlling modal visibility, spinner, and button states
    isAddModelOpen = false;
    isEditModelOpen = false;
    hasTeamMember = false;
    showSpinner = false;
    showTeam = true;
    disableSaveBtn = true;
    disableUpdateBtn = false;

    // Initializing a variable to store the EOI (Expression of Interest) Id
    eoiId = '';
    // Initializing an empty object to store data related to team members
    datamap = {};

    // Using @track decorator to make property reactive
    @track teamMemberLst;
    @track teamMemberToUpdate = [];
    @track teamMemberId;
    @track wiredTeamMemberLst;

    // Method to retrieve state parameters from the page reference
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        // Check if the current page reference exists
        if (currentPageReference) {
            // Extract the 'edit' parameter from the state and assign it to the component's 'eoiId' property
            this.eoiId = currentPageReference.state.edit;
        }
    }

    // Method to retrieve management team members using a wired Apex method
    @wire(getManagementTeamMember, { category: 'Management Team', eoiId: '$eoiId' })
    managementTeamMember(result) {
        // Hide the team section
        this.showTeam = false;
        this.wiredTeamMemberLst = result;
        if (result.data) {
            this.hasTeamMember = true;
            // Initialize and populate the teamMemberLst array with the retrieved data
            this.teamMemberLst = [];
            this.teamMemberLst = result.data;
            this.showTeam = true;
        } else if (result.error) {
            // Show the team section
            this.showTeam = true;
            // If there is an error, show the team section and log the error
            console.error('Error in getting mamagement team members', result.error);
        }
    }

    // Method to handle the removal of a management team member
    handleRemoveTeamMember(event) {
        // Hide the team section and show the loading spinner
        this.showTeam = false;
        this.showSpinner = true;
        // Check if the event, target, and dataset contain the 'id' property
        if (event && event.target.dataset && event.target.dataset.id) {
            let founderId = event.target.dataset.id;
            //Call the Apex method to delete the team member record
            deleteRecord({ recordId: founderId })
                .then((result) => {
                    if (result) {
                        if (result && result == 'Success') {
                            // Hide the team section, refresh the view, show success toast, and hide the spinner
                            this.showTeam = false;
                            this.handleRefreshView();
                            this.showTeam;
                            this.showtoast('Management team member deleted successfully.', 'success');
                            this.showSpinner = false;
                        }
                    }
                })
                .catch((e) => {
                    // Log an error if there is an issue and hide the spinner
                    this.showSpinner = false;
                    console.log('error in getting team members');
                });
        }
    }

    // Method to add a new management team member
    addTeamMember() {
        // Hide the team section and show the loading spinner
        this.showTeam = false;
        this.showSpinner = true;

        // Flag to check the validity of the form
        let isformvalid = true;

        // Check if the data map has an 'Id' property and remove it
        if (this.datamap && this.datamap.hasOwnProperty('Id')) {
            delete this.datamap.Id;
        }
        this.datamap['Team_Related_EOI__c'] = this.eoiId;
        let datamap = this.datamap;

        // Check if the form is valid
        if (isformvalid) {
            // Call the Apex method to add/update the team member
            addUpdateTeamMember({ datamap })
                .then((r) => {
                    if (r == 'Success') {
                        // Close the add model, show the team section, display success toast, hide the spinner, and refresh the view
                        this.isAddModelOpen = false;
                        this.showTeam = true;
                        this.showtoast('Management team member added.', 'success');
                        this.showSpinner = false;
                        this.handleRefreshView();
                    } else {
                        // Show the team section, display an error toast, and hide the spinner
                        this.showTeam = true;
                        this.showtoast(r, 'error');
                        this.showSpinner = false;
                    }
                })
                .catch((e) => {
                    // Display an error toast, show the team section, and hide the spinner
                    this.showtoast('Unable to add profile (management team member).', 'error');
                    this.showTeam = true;
                    this.showSpinner = false;
                });
        } else {
            // If the form is not valid, hide the spinner, show the team section, and display an error toast
            this.showSpinner = false;
            this.showTeam = true;
            this.showtoast('Please fill in all the details', 'error');
        }
    }

    // Method to handle the editing of a management team member
    handleEditTeamMember(event) {
        // Hide the team section and open the edit model for a management team member
        this.showTeam = false;
        this.isEditModelOpen = true;

        // Check if the event and its target have data attributes
        if (event && event.target.dataset && event.target.dataset.id) {
            this.teamMemberId = event.target.dataset.id;
            
            // Refresh the view to update the data
            this.handleRefreshView();
            
            // Find the team member to update using their ID
            this.teamMemberToUpdate = this.teamMemberLst.find((founder) => founder.Id === this.teamMemberId);
            
            // If the team member is found, enable the update button
            if (this.teamMemberToUpdate && this.teamMemberToUpdate != undefined) {
                this.disableUpdateBtn = false;
            }

            // Populate the data map with the team member's information
            this.datamap['Id'] = this.teamMemberId;
            this.datamap['Category__c'] = 'Management Team';
            this.datamap['Name'] = this.teamMemberToUpdate.Name;
            this.datamap['Member_Role__c'] = this.teamMemberToUpdate.Member_Role__c;
            this.datamap['Team_Member_Description__c'] = this.teamMemberToUpdate.Team_Member_Description__c;
        }
    }

    // Method to update an existing management team member
    updateTeamMember() {
        // Hide the team section and show the spinner while processing the update
        this.showTeam = false;
        this.showSpinner = true;

        // Flag to check the form's validity
        let isformvalid = true;

        // Check if the 'Team_Related_EOI__c' property exists in the data map and remove it
        if (this.datamap && this.datamap.hasOwnProperty('Team_Related_EOI__c')) {
            delete this.datamap.Team_Related_EOI__c;
        }
        let datamap = this.datamap;

        // Proceed with the update if the form is valid
        if (isformvalid) {
            // Call the server-side method to update the team member's information
            addUpdateTeamMember({ datamap })
                .then((r) => {
                    if (r == 'Success') {
                        // If successful, show the team section, close the edit model, refresh the view, show a success toast, and hide the spinner
                        this.showTeam = true;
                        this.isEditModelOpen = false;
                        this.handleRefreshView();
                        this.showtoast('Management team member updated.', 'success');
                        this.showSpinner = false;
                    } else {
                        // If not successful, show the team section, show an error toast, and hide the spinner
                        this.showTeam = true;
                        this.showtoast(r, 'error');
                        this.showSpinner = false;
                    }
                })
                .catch((e) => {
                    // If there's an error, show an error toast, hide the spinner, and show the team section
                    this.showtoast('Unable to update management team member.', 'error');
                    this.showSpinner = false;
                    this.showTeam = true;
                });
        } else {
            // If the form is not valid, hide the spinner, show the team section, and show an error toast
            this.showSpinner = false;
            this.showTeam = true;
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
        if (event.target.name == 'Member_Role__c') {
            // Update the 'Member_Role__c' property in the data map with the new value
            this.datamap['Member_Role__c'] = event.target.value;
        }
        if (event.target.name == 'Team_Member_Description__c') {
            // Update the 'Team_Member_Description__c' property in the data map with the new value
            this.datamap['Team_Member_Description__c'] = event.target.value;
        }
        // Validate inputs after updating datamap properties
        this.validateInputs();
    }

    // Method to validate inputs and enable/disable save and update buttons
    validateInputs() {
        // Check if any of the required fields are empty
        // If any field is empty, disable both save and update buttons
        this.disableSaveBtn = this.disableUpdateBtn = [this.datamap['Name'], this.datamap['Member_Role__c'], this.datamap['Team_Member_Description__c']].some((value) => !value);
    }

    // Method to refresh the view by calling refreshApex
    handleRefreshView() {
        //Refresh the view by calling refreshApex after changing values inside the wiredTeamMemberLst variable
        refreshApex(this.wiredTeamMemberLst);
    }

    // Method to open the add model for adding a new team member
    openAddModel() {
        this.disableSaveBtn = true;
        this.datamap = {};
        this.datamap['Category__c'] = 'Management Team';
        this.isAddModelOpen = true;
    }

    // Method to close the add model
    closeAddModel() {
        this.disableSaveBtn = true;
        this.datamap = {};
        this.isAddModelOpen = false;
    }

    // Method to close the edit model
    closeEditModel() {
        this.isEditModelOpen = false;
        this.showTeam = true;
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