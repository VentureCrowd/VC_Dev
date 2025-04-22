//Importing Lightning Web Components essentials
import { LightningElement, wire, track } from 'lwc';
// Importing the Apex method for adding/updating team members
import addUpdateTeamMember from '@salesforce/apex/MyCompaniesController.addUpdateTeamMember';
// Importing the Apex method for fetching team members
import getTeamMembers from '@salesforce/apex/MyCompaniesController.getTeamMembers';
// Importing the Apex method for deleting records using a utility class
import deleteRecord from '@salesforce/apex/Utils.deleteRecord';
// Importing the ShowToastEvent for displaying toast messages
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// Importing CurrentPageReference to get parameters from the current page
import { CurrentPageReference } from 'lightning/navigation';
// Importing a utility class
import { Utility } from 'c/utils';


export default class AddEditFounders extends LightningElement {
    // Various properties and flags for controlling component behavior
    isAddModelOpen = false;
    isEditModelOpen = false;

    hasFounder = false;
    showSpinner = false;
    showTeam = true;
    disableSaveBtn = true;
    disableUpdateBtn = false;
    urlIsValid = false;
    founderHasImage = false;

    // Data and state variables
    eoiId = '';
    datamap = {};
    FounderLength = []; // This will hold the options for your combobox
    @track advisorList;
    @track advisorToUpdate = [];
    @track teamMemberId;
    @track imgUrl;
    lengthFounder = 0;
    
    /**
     * Wire service to get the current page reference and extract parameters.
     * Sets the 'eoiId' property based on the 'edit' parameter in the page reference.
     */
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.eoiId = currentPageReference.state.edit;
        }
    }

    /**
     * ConnectedCallback lifecycle hook to initialize the component.
     * Fetches the founders when the component is connected to the DOM.
     */
    connectedCallback() {
        //Call getFounders methods to get the founder's
        this.getFounders();
    }

    /**
     * Fetches the founders (team members with category 'Founder') asynchronously &
     * Updates the 'advisorList' property with the retrieved data.
     */
    async getFounders() {
        this.showTeam = false;
        //Invoking getTeamMembers apex method to retrieve team members with founder category'
        await getTeamMembers({
            category: 'Founder',
            eoiId: this.eoiId
        }).then( (res) => {
                
                let result = JSON.parse(res);

                if (result && result.length) {
                    this.lengthFounder = result.length;
                    this.hasFounder = true;
                    this.advisorList = result;
                    this.showTeam = true;
                  
                } else {
                    this.hasFounder = false;
                }
            })
            .catch((e) => {
                this.showTeam = true;
                console.log('error in getting founder', e);
            });
        /*Call fireEvent method to Fires a custom event to communicate 
          the presence of founders to parent components*/
        this.fireEvent();
    }
    
    //$ Get the combobox values which we are getting from the length of the array of lengthFounder in
    updateFounderLength(value) {
        this.FounderLength = [...Array(this.lengthFounder + value).keys()].map(i => {
            let value = i + 1;
            return { label: `${value}`, value: `${value}` };
        });
    }

    /**
     * Event handler for removing a founder.
     * Initiates the deletion of a founder and updates the UI accordingly.
     */
    handleRemoveFounder(event) {
        this.showSpinner = true;
        this.showTeam = false;
        if (event && event.target.dataset && event.target.dataset.id) {
            let founderId = event.target.dataset.id;
            //deletion of a founder on the basis of founderId
            deleteRecord({ recordId: founderId })
                .then((result) => {
                    if (result) {
                        if (result && result == 'Success') {
                            // this.showTeam = false;
                            //Get founders List to show on UI
                            this.getFounders();
                            //Show toast message after founder deleted successfully
                            this.showtoast('Founder deleted successfully.', 'success');
                            this.showSpinner = false;
                        }
                    }
                })
                //If Exception is occures while deleting the founder ,then catch block will be executed.
                .catch((e) => {
                    this.showSpinner = false;
                    console.log('error in getting founder');
                });
        }
    }

    /**
     * Event handler for adding a founder.
     * Validates the form, adds or updates the founder, and updates the UI.
     */
    handleAddFounder() {
        this.showTeam = false;
        this.showSpinner = true;
        let isformvalid = true;

        if (this.datamap && this.datamap.hasOwnProperty('Id')) {
            delete this.datamap.Id;
        }
        this.datamap['Team_Related_EOI'] = this.eoiId;
        let datamap = this.datamap;
        if (isformvalid) {
            //If form is valid,then invoke Apex Method for add or updates the founder
            addUpdateTeamMember({ datamap })
                .then((r) => {
                    if (r == 'Success') {
                        this.isAddModelOpen = false;
                        this.showTeam = true;
                        this.showtoast('Founder added.', 'success');
                        this.showSpinner = false;
                        this.getFounders();
                    } else {
                        this.showtoast(r, 'error');
                        this.showSpinner = false;
                    }
                })
                // If an exception occurs, a toast message will be shown to the user.
                .catch((e) => {
                    this.showtoast('Unable to add profile (founder).', 'error');
                    this.showSpinner = false;
                });
        } else {
            this.showSpinner = false;
            // If an form is not valid , a toast message will be shown to the user.
            this.showtoast('Please fill in all the details', 'error');
        }
    }

    /**
     * Event handler for editing a founder.
     * Retrieves the details of the selected founder and opens the edit modal 
     * & set datamap property values.
     */
    handleEditFounder(event) {
        this.showTeam = false;
        this.isEditModelOpen = true;
        // clear data map
        this.datamap = {};
        
        if (event && event.target.dataset && event.target.dataset.id) {
            this.teamMemberId = event.target.dataset.id;
            //call getFounders to get the fouder's list
            this.getFounders();
            this.updateFounderLength(0);
            //filter the advisorList where the founderId & teamMemberId are the same & assign to advisorToUpdate
            this.advisorToUpdate = this.advisorList.find((founder) => founder.Id === this.teamMemberId);
            if (this.advisorToUpdate && this.advisorToUpdate != undefined) {
                this.disableUpdateBtn = false;
                this.urlIsValid = true;
            }
            if(this.advisorToUpdate.urLink) { 
                this.founderHasImage = true;
            } else { 
                this.founderHasImage = true;
            }

            //update value of the datamap variable
            
            this.datamap['Id'] = this.teamMemberId;
            this.datamap['Category'] = 'Founder';
            this.datamap['Name'] = this.advisorToUpdate.Name;
            this.datamap['Member_Role'] = this.advisorToUpdate.Member_Role;
            this.datamap['Team_Member_Description'] = this.advisorToUpdate.Team_Member_Description;
            this.datamap['Order'] = this.advisorToUpdate.Order;
            this.datamap['Team_member_Linkedin'] = this.advisorToUpdate.Team_member_Linkedin;
            this.imgUrl = this.advisorToUpdate.urLink;
            
            console.log("DATAMAP==>", JSON.stringify(this.datamap))
        }
    }

    /**
     * Event handler for submitting a file (image) for a founder.
     * Updates the 'datamap' and 'imgUrl' properties based on the submitted file.
     */
    handleFileSubmit(event) {
        const { base64, filename } = event.detail.filedata;
        this.datamap['base64'] = base64;
        this.datamap['filename'] = filename;
        this.imgUrl = event.detail.imgurl;
        if(filename) { 
            this.founderHasImage = true;
        } else { 
            this.founderHasImage = false;
        }
        //To validate given input are correct using validateInputs method
        this.validateInputs();
    }

    /**
     * Event handler for updating an existing founder.
     * Validates the form, updates the founder, and updates the UI.
     */
    handleUpdateFounder() {
        this.showTeam = false;
        this.showSpinner = true;
        let isformvalid = true;
        if (this.datamap && this.datamap.hasOwnProperty('Team_Related_EOI')) {
            delete this.datamap.Team_Related_EOI;
        }

        let datamap = this.datamap;
        console.log(JSON.stringify(datamap))
        if (isformvalid) {
            //If the form is valid,then update the add/update team member's
            addUpdateTeamMember({ datamap })
                .then((r) => {
                    if (r == 'Success') {
                        this.showTeam = true;
                        this.isEditModelOpen = false;
                        this.getFounders();
                        //toast will show the success message
                        this.showtoast('Founder updated.', 'success');
                        this.showSpinner = false;
                    } else {
                        this.showtoast(r, 'error');
                        this.showSpinner = false;
                    }
                })
                .catch((e) => {
                    //toast will show the error message
                    this.showtoast('Unable to update founder.', 'error');
                    this.showSpinner = false;
                    this.showTeam = true;
                });
        } else {
            this.showSpinner = false;
            this.showTeam = true;
            //toast will show the error message
            this.showtoast('Please fill in all the details', 'error');
        }
    }

    /**
     * Event handler for input field changes.
     * Updates the 'datamap' property and performs input validation.
     */
    handleChange(event) {
        if (event.target.name == 'Name') {
            
            this.datamap['Name'] = event.target.value;
            //To validate given input are correct using validateInputs method
            this.validateInputs('Name');
        }
        //$ Handle the new one
        if (event.target.name == 'Order') {
            this.datamap['Order'] = event.target.value;
            // this.datamap['Order'] = parseInt(event.target.value);
            //To validate given input are correct using validateInputs method
            this.validateInputs('Order');
        }
        if (event.target.name == 'Member_Role') {
            this.datamap['Member_Role'] = event.target.value;
            //To validate given input are correct using validateInputs method
            this.validateInputs('Member_Role');
        }
        if (event.target.name == 'Team_Member_Description') {
            this.datamap['Team_Member_Description'] = event.target.value;
            //To validate given input are correct using validateInputs method
            this.validateInputs('Team_Member_Description');
        }
        if (event.target.name == 'Team_member_Linkedin') {
            this.datamap['Team_member_Linkedin'] = event.target.value;
            this.urlIsValid = Utility.isValidSocialMediaUrl(this.datamap['Team_member_Linkedin'], 'Linkedin_link__c');
            console.log(this.datamap['Team_member_Linkedin'] , this.urlIsValid)
            //To validate given input are correct using validateInputs method
            this.validateInputs('Team_member_Linkedin');
        }
    }

    /**
     * Validates the input fields and determines the state of save and 
     * update button's validity as per given input.
     */
    validateInputs(fieldType) {
        //get all lightning-input fields
        let inputelements = this.template.querySelectorAll('lightning-input');
        //Covert to array format
        let allelements = Array.from(inputelements);
        let isformvalid = true;
        //Iterate over the allelements and check input field name and item name of iteration matches/not.
        allelements.forEach((ele) => {
            ele.value = ele.value ? ele.value : ele.value;
            if (ele.name == fieldType) {
                ele.reportValidity();
            }

            isformvalid = isformvalid & ele.checkValidity();
        });

        //get all lightning-input fields where type equals to textarea
        let textarea = this.template.querySelectorAll('textarea');
        //Covert to array format
        let alltextarea = Array.from(textarea);
        let isformvalidtextarea = true;
        //Iterate over the allelements and check input field name and item name of iteration matches/not.
        alltextarea.forEach((ele) => {
            ele.value = ele.value ? ele.value : ele.value;
            if (ele.name == fieldType) {
                ele.reportValidity();
            }
            isformvalidtextarea = isformvalidtextarea & ele.checkValidity();
        });

        console.log(isformvalid, this.urlIsValid, isformvalidtextarea, this.founderHasImage)
        //If form,url,text area is valid and founder has image,then disableSaveBtn and disableUpdateBtn will be false otherwise true.
        if (isformvalid && this.urlIsValid && isformvalidtextarea && this.founderHasImage) {
            this.disableSaveBtn = this.disableUpdateBtn = false;
        } else {
            this.disableSaveBtn = this.disableUpdateBtn = true;
        }
    }

    /**
     * Fires a custom event to communicate the presence of founders to parent components.
     */
    fireEvent() {
        //instantiate CustomEvent
        const customEvent = new CustomEvent('validatefounder', {
            detail: { hasFounder: this.hasFounder }
        });
        //dispatch event to parent components
        this.dispatchEvent(customEvent);
    }

    /**
     * Opens the modal for adding a new founder.
     * Resets relevant properties and sets initial state for the modal like disable save button.
     */
    openAddModel() {
        this.founderHasImage = false;
        this.disableSaveBtn = true;
        this.datamap = {};
        this.urlIsValid = false;
        this.datamap['Category'] = 'Founder';
        this.isAddModelOpen = true;
        this.showSpinner = false;
        this.imgUrl = '';
        this.updateFounderLength(1);

    }

    /**
     * Closes the modal for adding a new founder.
     * Resets relevant properties and sets initial state for the modal.
     */
    closeAddModel() {
        this.founderHasImage = false;
        this.disableSaveBtn = true;
        this.datamap = {};
        this.urlIsValid = false;
        this.isAddModelOpen = false;
        this.imgUrl = '';
    }

    /**
     * Closes the modal for editing an existing founder.
     * Resets relevant properties and sets initial state for the modal.
     */
    closeEditModel() {
        this.isEditModelOpen = false;
        this.showTeam = true;
        this.imgUrl = '';
        this.datamap = {};
    }

    /**
     * Displays a toast notification with the given message and variant.
     */
    showtoast(m, k) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: m,
                variant: k
            })
        );
    }
}