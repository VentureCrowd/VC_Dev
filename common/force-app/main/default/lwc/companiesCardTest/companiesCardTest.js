/*********************************************************************************************************************************************
Author		 :	 Prakash Borade
Description	 :   CompaniesCard LWC is used to show Companies tile , where we show companies with EOI on left and companies without EOI on right.
                 This is child component of MyCompaniesTiles LWC
Child Component   :  -
----------------------------------------------------------------------------------------------------------------------------------------------
Version      Date                 Author               Details
1            12/21/2023           Prakash Borade       Initial Development
**********************************************************************************************************************************************/
import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPicklistValuesEoiStatus from '@salesforce/apex/MyCompaniesController.getPicklistvalues';
import getMyCompanies from '@salesforce/apex/MyCompaniesController.getMyCompanies';
import editCompany from '@salesforce/apex/MyCompaniesController.editCompany';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import getRecordTypeId from '@salesforce/apex/Utils.getRecordTypeId';
import SECTOR_FIELD from '@salesforce/schema/Account.Sector__c';
import Id from '@salesforce/user/Id';

export default class CompaniesCardTest extends NavigationMixin(LightningElement) {
    @api companies;
    @api recordTypeId;

    @track companiesWithEOI;
    @track lstCompaniesWithEOI = [];
    @track statusValues = [];
    @track isEditModelOpen = false;
    @track notAusBasedCompany = false;
    @track companyId;
    @track companyToUpdate = [];
    @track sectorOptions = [];
    @track showSpinner = false;
    @track loggedInUserId = Id;
    datamap = {};
    radioSelectedvalue = 'yes';

    /*
        getRecordTypeId - Method used to get Record Type Id for specific record type.
    */
    getRecordTypeId() {
        getRecordTypeId({ objectName: 'Account', recordTypeLabel: 'Ventures Company Account' })
            .then((result) => {
                if (result) {
                    this.recordTypeId = result;
                }
            })
            .catch((e) => {
                console.log('error in getting recordTypeId');
            });
    }

    /*
        getPicklistValues - Its a wire method used to get values of SECTOR_FIELD picklist.
    */
    @wire(getPicklistValues, {
        recordTypeId: '$recordTypeId',
        fieldApiName: SECTOR_FIELD
    })
    wireObjectInfo({ error, data }) {
        if (data) {
            this.objectInfoData = data;
            this.sectorOptions = this.objectInfoData.values;
        } else if (error) {
            console.log(Error, ' Error while getting SECTOR_FIELD picklist values');
        }
    }

    connectedCallback() {
        this.getRecordTypeId();
    }

    editEoi(event) {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'my_eoi__c'
            },
            state: {
                edit: event.target.dataset.id
            }
        });
    }

    manageEoi(event) {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'manage_eoi__c'
            },
            state: {
                id: event.target.dataset.id
            }
        });
    }
    
    previewEoi(event) {

        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'EoiPreviewTest__c'
            },
            state: {
                id: event.target.dataset.id
            }
        });
    }

    trackEoi() {}

    @wire(getPicklistValuesEoiStatus) checkSTatus({ error, data }) {
        let tempStatus = [];
        if (data) {
            let i = 0;
            for (let key in data) {
                i++;
                tempStatus.push({
                    value: data[key],
                    key: key,
                    className: 'slds-path__item slds-is-incomplete',
                    index: i
                });
            }
            this.companiesWithEOI = this.companies.filter((company) => company.EOI_s__r && company.EOI_s__r.length > 0);
            this.companiesWithEOI.forEach((item) => {
                this.statusValues = JSON.parse(JSON.stringify(tempStatus));
                let statusValueObj = this.statusValues.find((obj) => obj.key === item['EOI_s__r'][0].EOI_Status__c);
                if (statusValueObj) {
                    this.statusValues
                        .filter((statusObj) => statusObj.index <= statusValueObj.index)
                        .forEach((v) => {
                            v.className = 'slds-path__item slds-is-active';
                        });
                }
                let isPublished = false;
                let isSubmittedToPublished = false;
                if (item['EOI_s__r'][0].EOI_Status__c == 'Published' || item['EOI_s__r'][0].EOI_Status__c == 'Closed') {
                    isPublished = true;
                }
                if (item['EOI_s__r'][0].EOI_Status__c == 'Submitted to be Published') {
                    isSubmittedToPublished = true;
                }
                this.lstCompaniesWithEOI.push({
                    companyName: item['Name'],
                    companyId: item['Id'],
                    sector: item['Sector__c'],
                    website: item['Website'],
                    ABN: item['ACN__c'],
                    eoiId: item['EOI_s__r'][0].Id,
                    eoiStatus: this.statusValues,
                    isPublished: isPublished,
                    isSubmittedToPublished: isSubmittedToPublished,
                    status : item['EOI_s__r'][0].EOI_Status__c
                });
            });
        }
    }

    handleChange(event) {
        if (event.target.name == 'Name') {
            this.datamap['Name'] = event.target.value;
        }
        if (event.target.name == 'Website') {
            this.datamap['Website'] = event.target.value;
        }
        if (event.target.name == 'Sector__c') {
            this.datamap['Sector__c'] = event.target.value;
        }
        if (event.target.name == 'ACN__c') {
            this.datamap['ACN__c'] = event.target.value;
        }
    }

    handleEditCompany(event) {
        this.isEditModelOpen = true;
        if (event && event.target.dataset && event.target.dataset.id) {
            this.companyId = event.target.dataset.id;
            this.companyToUpdate = this.lstCompaniesWithEOI.find((founder) => founder.companyId === this.companyId);
            this.datamap['Id'] = this.companyId;
            this.datamap['Name'] = this.companyToUpdate.companyName;
            this.datamap['Website'] = this.companyToUpdate.website;
            this.datamap['Sector__c'] = this.companyToUpdate.sector;
            this.datamap['ACN__c'] = this.companyToUpdate.ABN;
        }
    }

    updateCompany() {
        this.showSpinner = true;
        let isformvalid = true;
        let datamap = this.datamap;
        if (isformvalid) {
            editCompany({ datamap })
                .then((r) => {
                    if (r == 'Success') {
                        this.isEditModelOpen = false;
                        this.getMyCompanies();
                        this.showtoast('Company details updated successfully.', 'success');
                        this.showSpinner = false;
                    } else {
                        this.showtoast(r, 'error');
                        this.showSpinner = false;
                    }
                })
                .catch((e) => {
                    this.showtoast('Unable to update company details.', 'error');
                    this.showSpinner = false;
                });
        } else {
            this.showSpinner = false;
            this.showTeam = true;
            this.showtoast('Please fill in all the details', 'error');
        }
    }

    getMyCompanies() {
        getMyCompanies({ loggedInUserId: this.loggedInUserId })
            .then((result) => {
                if (result) {
                    if (result.length) {
                        this.companiesWithEOI = [];
                        this.companies = [];
                        this.lstCompaniesWithEOI = [];

                        this.companies = result;
                        this.companiesWithEOI = this.companies.filter((company) => company.EOI_s__r && company.EOI_s__r.length > 0);
                        this.companiesWithEOI.forEach((item) => {
                            this.lstCompaniesWithEOI.push({
                                companyName: item['Name'],
                                companyId: item['Id'],
                                sector: item['Sector__c'],
                                website: item['Website'],
                                ABN: item['ACN__c'],
                                eoiId: item['EOI_s__r'][0].Id,
                                eoiStatus: this.statusValues
                            });
                        });
                    }
                }
            })
            .catch((e) => {
                console.log('error in getting companies');
            });
    }

    handleRadioSelection(event) {
        if (event && event && event.target.value) {
            this.radioSelectedvalue = event.target.value;
            if (this.radioSelectedvalue == 'no') {
                this.notAusBasedCompany = true;
            } else {
                this.notAusBasedCompany = false;
            }
        }
    }

    closeEditModel() {
        this.isEditModelOpen = false;
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