import { LightningElement, wire, track } from 'lwc';
import addUpdateTeamMember from '@salesforce/apex/MyEOIController.addUpdateTeamMember';
import getAdvisors from '@salesforce/apex/MyEOIController.getTeamMembers';
import deleteRecord from '@salesforce/apex/Utils.deleteRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';

export default class AddEditAdvisor extends LightningElement {
    isAddModelOpen = false;
    isEditModelOpen = false;
    hasAdvisor = false;
    showSpinner = false;
    showTeam = true;
    disableSaveBtn = true;
    disableUpdateBtn = false;

    eoiId = '';
    datamap = {};
    @track advisorList;
    @track advisorToUpdate = [];
    @track teamMemberId;
    @track wiredAdvisorLst;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.eoiId = currentPageReference.state.edit;
        }
    }

    @wire(getAdvisors, { category: 'Advisors', eoiId: '$eoiId' })
    advisors(result) {
        this.showTeam = false;
        this.wiredAdvisorLst = result;
        if (result.data) {
            this.hasAdvisor = true;
            this.advisorList = [];
            this.advisorList = result.data;
            this.showTeam = true;
        } else if (result.error) {
            this.showTeam = true;
            console.error('Error in getting advisors', result.error);
        }
    }

    handleRemoveAdvisor(event) {
        this.showTeam = false;
        this.showSpinner = true;
        if (event && event.target.dataset && event.target.dataset.id) {
            let founderId = event.target.dataset.id;
            deleteRecord({ recordId: founderId })
                .then((result) => {
                    if (result) {
                        if (result && result == 'Success') {
                            this.showTeam = false;
                            this.handleRefreshView();
                            this.showtoast('Wider Team deleted successfully.', 'success');
                            this.showSpinner = false;
                        }
                    }
                })
                .catch((e) => {
                    this.showSpinner = false;
                    console.log('error getting team members');
                });
        }
    }

    addAdvisor() {
        this.showTeam = false;
        this.showSpinner = true;
        let isformvalid = true;
        if (this.datamap && this.datamap.hasOwnProperty('Id')) {
            delete this.datamap.Id;
        }
        this.datamap['Team_Related_EOI__c'] = this.eoiId;
        let datamap = this.datamap;
        if (isformvalid) {
            addUpdateTeamMember({ datamap })
                .then((r) => {
                    if (r == 'Success') {
                        this.isAddModelOpen = false;
                        this.showTeam = true;
                        this.showtoast('Advisor added successfully.', 'success');
                        this.showSpinner = false;
                        this.handleRefreshView();
                    } else {
                        this.showtoast(r, 'error');
                        this.showSpinner = false;
                    }
                })
                .catch((e) => {
                    this.showtoast('Unable to add profile (advisor, ambassador, and/or key investor).', 'error');
                    this.showSpinner = false;
                });
        } else {
            this.showSpinner = false;
            this.showtoast('Please fill in all the details', 'error');
        }
    }

    handleEditAdvisor(event) {
        this.showTeam = false;
        this.isEditModelOpen = true;
        if (event && event.target.dataset && event.target.dataset.id) {
            this.teamMemberId = event.target.dataset.id;
            this.handleRefreshView();
            this.advisorToUpdate = this.advisorList.find((founder) => founder.Id === this.teamMemberId);
            if (this.advisorToUpdate && this.advisorToUpdate != undefined) {
                this.disableUpdateBtn = false;
            }
            this.datamap['Id'] = this.teamMemberId;
            this.datamap['Category__c'] = 'Advisors';
            this.datamap['Name'] = this.advisorToUpdate.Name;
            this.datamap['Member_Role__c'] = this.advisorToUpdate.Member_Role__c;
            this.datamap['Team_Member_Description__c'] = this.advisorToUpdate.Team_Member_Description__c;
        }
    }

    updateAdvisor() {
        this.showTeam = false;
        this.showSpinner = true;
        let isformvalid = true;
        if (this.datamap && this.datamap.hasOwnProperty('Team_Related_EOI__c')) {
            delete this.datamap.Team_Related_EOI__c;
        }
        let datamap = this.datamap;
        if (isformvalid) {
            addUpdateTeamMember({ datamap })
                .then((r) => {
                    if (r == 'Success') {
                        this.showTeam = true;
                        this.isEditModelOpen = false;
                        this.handleRefreshView();
                        this.showtoast('Advisor, ambassador and/or key investor updated.', 'success');
                        this.showSpinner = false;
                    } else {
                        this.showtoast(r, 'error');
                        this.showSpinner = false;
                    }
                })
                .catch((e) => {
                    this.showtoast('Unable to update advisor, ambassador and/or key investor.', 'error');
                    this.showSpinner = false;
                    this.showTeam = true;
                });
        } else {
            this.showSpinner = false;
            this.showTeam = true;
            this.showtoast('Please fill in all the details', 'error');
        }
    }

    handleChange(event) {
        if (event.target.name == 'Name') {
            this.datamap['Name'] = event.target.value;
        }
        if (event.target.name == 'Member_Role__c') {
            this.datamap['Member_Role__c'] = event.target.value;
        }
        if (event.target.name == 'Team_Member_Description__c') {
            this.datamap['Team_Member_Description__c'] = event.target.value;
        }
        this.validateInputs();
    }

    validateInputs() {
        this.disableSaveBtn = this.disableUpdateBtn = [this.datamap['Name'], this.datamap['Member_Role__c'], this.datamap['Team_Member_Description__c']].some((value) => !value);
    }

    handleRefreshView() {
        refreshApex(this.wiredAdvisorLst);
    }

    openAddModel() {
        this.disableSaveBtn = true;
        this.datamap = {};
        this.datamap['Category__c'] = 'Advisors';
        this.isAddModelOpen = true;
    }

    closeAddModel() {
        this.disableSaveBtn = true;
        this.datamap = {};
        this.isAddModelOpen = false;
    }

    closeEditModel() {
        this.isEditModelOpen = false;
        this.showTeam = true;
    }

    showtoast(m, k) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: m,
                variant: k
            })
        );
    }
}