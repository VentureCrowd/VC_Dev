// Importing necessary decorators and modules from LWC
import { LightningElement, wire, track, api } from 'lwc';
// Importing the NavigationMixin module for navigating to different pages
import { NavigationMixin } from 'lightning/navigation';
// Importing the ShowToastEvent module for displaying toast notifications
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// Importing CurrentPageReference to get current page reference
import { CurrentPageReference } from 'lightning/navigation';
// Importing refreshApex to refresh data provided by a wired Apex method
import { refreshApex } from '@salesforce/apex';
import { loadStyle } from 'lightning/platformResourceLoader';
import VC_MasterCss_New from '@salesforce/resourceUrl/VC_MasterCss_NewTemp';
// Importing Apex methods for updateEoi, deleteRecord , getEoiDetails , getSalesforceFilesDownloadUrls and upsertFounderImage
import updateEoi from '@salesforce/apex/MyEOIController.updateEoi';
import deleteRecord from '@salesforce/apex/Utils.deleteRecord';
import getEoiDetails from '@salesforce/apex/MyEOIController.getEoiDetails';
import { Utility } from 'c/utils';
import getSalesforceFilesDownloadUrls from '@salesforce/apex/ContentDownloadURL.getSalesforceFilesDownloadUrls';
import upsertFounderImage from '@salesforce/apex/MyCompaniesController.upsertFounderImage';

export default class CreateUpdateEoi extends NavigationMixin(LightningElement) {
    currentPageReference = null;
    eoiId = '';
    activeSections = ['companyOverview'];
    // activeSections = ['team'];
    // activeSections = ['socialAndMediaLinks'];
    // activeSections = ['intendedRaise'];
    openSections = [];
    datamap = {};
    validityMap = {};
    socialMediaValidityMap = {};
    intendedRaisedValidityMap = {};
    companyAccountName = '';
    @track eoiData = [];
    wiredEoiData;
    totalMandatoryOrBadValuesFields = 0;
    mandatoryFieldsMessage = '';

    // Initializing boolean properties for controlling modal visibility, spinner, and button states
    @track missingRequiredDetails = true;
    @track disableSaveButton = true;
    showTitleError = false;
    showOneLinerError = false;
    showOfferOverviewError = false;
    showYoYGrowthError = false;
    showKeyPartnershipsError = false;
    showKeyCustomersError = false;
    showARRError = false;
    showCompetitiveAdvError = false;
    showAddressableMarketError = false;
    showGrowthStrategyError = false;
    showFounderError = false;
    showContactRaiseEmailError = false;
    showInstagramError = false;
    showYouTubeError = false;
    showFacebookError = false;
    showTwitterError = false;
    showLinkedInError = false;
    showMissingFieldsError = false;
    intendedRaisedCompleted = true;
    showIntendedRaisedError = false;
    showConfirmSubmissionPopup = false;
    showConfirmSubmitMessage = false;
    checkbox1 = false;
    checkbox2 = false;
    checkbox3 = false;
    checkbox4 = false;
    isEoiSubmittedForPublished = false;
    stageNotSelected = false;
    screenWidth;
    @track showSpinner = false;
    
    // banner api controlling variables
    @track _bannerLink;

    @api get bannerLink(){
        return this._bannerLink
    }
    set bannerLink(v){
        if (v && !/^https?:\/\//i.test(v)) {
            this._bannerLink = `https://${v}`;
            console.warn(`${v} was missing protocol. Updated to: ${this._bannerLink}`);
        }
    }

    @api showBanner;
    @api titleText;
    @api secText;
    
    @track helpTextMapping = {
        pitchVideo : `https://${window.location.host}/articles/module/Raise-About-Us#pitch-video`,
    }

    // options for company stage picklist
    companyStageOptions = [
        { label: '--None--', value: '' },
        { label: 'Pre-seed', value: 'Pre-seed' },
        { label: 'Seed', value: 'Seed' },
        { label: 'Series A', value: 'Series A' },
        { label: 'Series B +', value: 'Series B +' },
        { label: 'Pre-IPO', value: 'Pre-IPO' },
        { label: 'IPO', value: 'IPO' }
    ];

    // wire method to get eoiId from current url
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        // Check if currentPageReference is available
        if (currentPageReference) {
            // Extract the 'edit' parameter from the state of the current page reference
            // and assign it to the 'eoiId' property of the component
            this.eoiId = currentPageReference.state.edit;
        }
    }

    @wire(getEoiDetails, { eoiId: '$eoiId' })
    wiredData(result) {
        // Assign the result of the wire adapter to the wiredEoiData property
        this.wiredEoiData = result;
        // Check if the result contains data
        if (result.data) {
            this.companyAccountName = result.data.Account__r.Name;
            this.eoiStatus = result.data.EOI_Status__c;
            if (this.eoiStatus == 'Submitted to be Published' || this.eoiStatus == 'Published' || this.eoiStatus == 'Publishing') {
                this.isEoiSubmittedForPublished = true;
            }
            // Extract specific fields from the result data and assign them to component properties
            this.eoiData.EOI_Title__c = result.data.EOI_Title__c;
            this.eoiData.One_liner_about_business__c = result.data.One_liner_about_business__c;
            this.eoiData.Offer_Overview__c = result.data.Offer_Overview__c;
            this.eoiData.Problem_or_opportunity__c = result.data.Problem_or_opportunity__c;
            this.eoiData.Solution__c = result.data.Solution__c;
            this.eoiData.Differentiation__c = result.data.Differentiation__c;
            this.eoiData.Intellectual_Property__c = result.data.Intellectual_Property__c;
            this.eoiData.Total_addressable_market__c = result.data.Total_addressable_market__c;
            this.eoiData.Progress__c = result.data.Progress__c;
            this.eoiData.Growth_plan__c = result.data.Growth_plan__c;
            this.eoiData.Instagram_link__c = result.data.Instagram_link__c;
            this.eoiData.Youtube_link__c = result.data.Youtube_link__c;
            this.eoiData.Facebook_link__c = result.data.Facebook_link__c;
            this.eoiData.Linkedin_link__c = result.data.Linkedin_link__c;
            this.eoiData.Twitter_X_link__c = result.data.Twitter_X_link__c;
            this.eoiData.Company_Stage__c = result.data.Company_Stage__c;
            this.eoiData.Youtube_Video_Link__c = result.data.Youtube_Video_Link__c;
            this.eoiData.Minimum_Investment_amount__c = result.data.Minimum_Investment_amount__c;
            if(this.eoiData.Company_Stage__c) { 
                this.stageNotSelected = true;
            }
            this.eoiData.Target_Raise_Amount__c = result.data.Target_Raise_Amount__c;
            this.eoiData.Planned_used_of_funds__c = result.data.Planned_used_of_funds__c;
            this.eoiData.Raise_Contact_email__c = result.data.Raise_Contact_email__c;
            this.handleIntendedRaisedValidity();
            this.handleIntendedRaisedValidity();
            this.eoiData.SupportImages1 = '';
            this.eoiData.SupportImages2 = '';
            this.eoiData.SupportImages3 = '';

            this.eoiData.DocumentId1 = '';
            this.eoiData.DocumentId2 = '';
            this.eoiData.DocumentId3 = '';
            this.eoiData.DocumentId4 = '';
            this.eoiData.DocumentId5 = '';
            // Process ContentDocumentLinks to extract URLs and document IDs for images
            if (result.data.ContentDocumentLinks !== undefined) {
                for (var key in result.data.ContentDocumentLinks) {
                    if (result.data.ContentDocumentLinks[key].ContentDocument.Title === 'logo') {
                        this.eoiData.logo = result.data.ContentDocumentLinks[key].ContentDocument.LatestPublishedVersion.VersionDataUrl;
                        this.eoiData.DocumentId4 = result.data.ContentDocumentLinks[key].ContentDocumentId;
                    }
                    if (result.data.ContentDocumentLinks[key].ContentDocument.Title === 'Banner') {
                        this.eoiData.Banner = result.data.ContentDocumentLinks[key].ContentDocument.LatestPublishedVersion.VersionDataUrl;
                        this.eoiData.DocumentId5 = result.data.ContentDocumentLinks[key].ContentDocumentId;
                    }
                    if (result.data.ContentDocumentLinks[key].ContentDocument.Title === 'supportingImage1') {
                        this.eoiData.SupportImages1 = result.data.ContentDocumentLinks[key].ContentDocument.LatestPublishedVersion.VersionDataUrl;
                        this.eoiData.DocumentId1 = result.data.ContentDocumentLinks[key].ContentDocumentId;
                    }
                    if (result.data.ContentDocumentLinks[key].ContentDocument.Title === 'supportingImage2') {
                        this.eoiData.SupportImages2 = result.data.ContentDocumentLinks[key].ContentDocument.LatestPublishedVersion.VersionDataUrl;
                        this.eoiData.DocumentId2 = result.data.ContentDocumentLinks[key].ContentDocumentId;
                    }
                    if (result.data.ContentDocumentLinks[key].ContentDocument.Title === 'supportingImage3') {
                        this.eoiData.SupportImages3 = result.data.ContentDocumentLinks[key].ContentDocument.LatestPublishedVersion.VersionDataUrl;
                        this.eoiData.DocumentId3 = result.data.ContentDocumentLinks[key].ContentDocumentId;
                    }
                }
            }
        } else if (result.error) {
            // Log error if there's an error fetching data
            console.error('Error fetching data', result.error);
        }
        // Validate all elements after data retrieval
        this.validateAllElements(false);
        this.validateAllElements(false);
    }

    connectedCallback() {
        // Initialize the social media validity map for various social media links
        this.socialMediaValidityMap['Instagram_link__c'] = { isValid: true };
        this.socialMediaValidityMap['Youtube_link__c'] = { isValid: true };
        this.socialMediaValidityMap['Facebook_link__c'] = { isValid: true };
        this.socialMediaValidityMap['Twitter_X_link__c'] = { isValid: true };
        this.socialMediaValidityMap['Linkedin_link__c'] = { isValid: true };

        // eoiId to eoiId to make sure that the wire will have data
        this.eoiId = this.eoiId;
        // Load CSS file using loadStyle method from the Lightning platform resource loader
        // The VC_MasterCss_New resource is loaded
        Promise.all([loadStyle(this, VC_MasterCss_New)])
            .then(() => {
                // console.log('CSS New Files loaded');
            })
            .catch((error) => {
                if (error && error.body && error.body.message) {
                    console.error('error ', error.body.message);
                } else {
                    console.error('error in loading VC_MasterCss_New style', error);
                }
            });

            window.addEventListener('resize', this.updateSize);
     
            // Add event listener for window resize
        // this.resizeObserver = new ResizeObserver(this.handleResize);
        // this.resizeObserver.observe(this.template.querySelector('body'))
    }
    renderedCallback(){
        this.updateSize();
    }

    updateSize = () => {
        this.screenWidth = window.innerWidth;
    }

    handleRemoveSupportingImage(event) {
        // Set the spinner to show loading state
        this.showSpinner = true;
        // Check if the event and its target contain necessary data
        if (event && event.target.dataset && event.target.dataset.id) {
            // Call the deleteRecord Apex method to delete the record with the specified Id
            deleteRecord({ recordId: event.target.dataset.id })
                .then((result) => {
                    if (result === 'Success') {
                        // Refresh the view to reflect the changes
                        this.handleRefreshView();
                        this.showSpinner = false;
                        // Show a success toast message indicating successful deletion
                        this.showToast('Supporting image deleted successfully.', 'success');
                    }
                })
                .catch((e) => {
                    // Handle errors that occur during deletion
                    // Set the spinner to hide loading state
                    this.showSpinner = false;
                    console.error('Error while deleting supporting image:' + JSON.stringify(e));
                });
        }
    }

    /**
     * Updates the 'datamap' property and validate element on change
     */
    handleChange(event) {
        if (event.target.name == 'EOI_Title__c') {
            this.datamap['EOI_Title__c'] = event.target.value;
            this.validateElement('EOI_Title__c', 'lightning-input');
            if (this.showTitleError && this.validityMap['EOI_Title__c'].isValid == true) {
                this.showTitleError = false;
            }
        } else if (event.target.name == 'One_liner_about_business__c') {
            this.datamap['One_liner_about_business__c'] = event.target.value;
            this.validateElement('One_liner_about_business__c', 'lightning-input');
            if (this.showOneLinerError && this.validityMap['One_liner_about_business__c'].isValid == true) {
                this.showOneLinerError = false;
            }
        } else if (event.target.name == 'Offer_Overview__c') {
            this.datamap['Offer_Overview__c'] = event.target.value;
            this.validateElement('Offer_Overview__c', 'textarea');
            if (this.showOfferOverviewError && this.validityMap['Offer_Overview__c'].isValid == true) {
                this.showOfferOverviewError = false;
            }
        } else if (event.target.name == 'Youtube_Video_Link__c') {
            this.datamap['Youtube_Video_Link__c'] = event.target.value;
            if (event.target.value && event.target.value != '' && event.target.value != undefined) {
                this.validateElement('Youtube_Video_Link__c', 'lightning-input');
            } else {
                this.showYouTubeError = false;
                this.socialMediaValidityMap['Youtube_Video_Link__c'] = { isValid: true };
            }
        } else if (event.target.name == 'Problem_or_opportunity__c') {
            this.datamap['Problem_or_opportunity__c'] = event.target.value;
            this.validateElement('Problem_or_opportunity__c', 'textarea');
            if (this.showYoYGrowthError && this.validityMap['Problem_or_opportunity__c'].isValid == true) {
                this.showYoYGrowthError = false;
            }
        } else if (event.target.name == 'Solution__c') {
            this.datamap['Solution__c'] = event.target.value;
            this.validateElement('Solution__c', 'textarea');
            if (this.showKeyPartnershipsError && this.validityMap['Solution__c'].isValid == true) {
                this.showKeyPartnershipsError = false;
            }
        } else if (event.target.name == 'Differentiation__c') {
            this.datamap['Differentiation__c'] = event.target.value;
            this.validateElement('Differentiation__c', 'textarea');
            if (this.showKeyCustomersError && this.validityMap['Differentiation__c'].isValid == true) {
                this.showKeyCustomersError = false;
            }
        } else if (event.target.name == 'Intellectual_Property__c') {
            this.datamap['Intellectual_Property__c'] = event.target.value;
            this.validateElement('Intellectual_Property__c', 'textarea');
            if (this.showARRError && this.validityMap['Intellectual_Property__c'].isValid == true) {
                this.showARRError = false;
            }
        } else if (event.target.name == 'Total_addressable_market__c') {
            this.datamap['Total_addressable_market__c'] = event.target.value;
            this.validateElement('Total_addressable_market__c', 'textarea');
            if (this.showCompetitiveAdvError && this.validityMap['Total_addressable_market__c'].isValid == true) {
                this.showCompetitiveAdvError = false;
            }
        } else if (event.target.name == 'Progress__c') {
            this.datamap['Progress__c'] = event.target.value;
            this.validateElement('Progress__c', 'textarea');
            if (this.showAddressableMarketError && this.validityMap['Progress__c'].isValid == true) {
                this.showAddressableMarketError = false;
            }
        } else if (event.target.name == 'Growth_plan__c') {
            this.datamap['Growth_plan__c'] = event.target.value;
            this.validateElement('Growth_plan__c', 'textarea');
            if (this.showGrowthStrategyError && this.validityMap['Growth_plan__c'].isValid == true) {
                this.showGrowthStrategyError = false;
            }
        } else if (event.target.name == 'Instagram_link__c') {
            this.datamap['Instagram_link__c'] = event.target.value;
            if (event.target.value && event.target.value != '' && event.target.value != undefined) {
                this.validateElement('Instagram_link__c', 'lightning-input');
            } else {
                this.showInstagramError = false;
                this.socialMediaValidityMap['Instagram_link__c'] = { isValid: true };
            }
        } else if (event.target.name == 'Youtube_link__c') {
            this.datamap['Youtube_link__c'] = event.target.value;
            if (event.target.value && event.target.value != '' && event.target.value != undefined) {
                this.validateElement('Youtube_link__c', 'lightning-input');
            } else {
                this.showYouTubeError = false;
                this.socialMediaValidityMap['Youtube_link__c'] = { isValid: true };
            }
        } else if (event.target.name == 'Facebook_link__c') {
            this.datamap['Facebook_link__c'] = event.target.value;
            if (event.target.value && event.target.value != '' && event.target.value != undefined) {
                this.validateElement('Facebook_link__c', 'lightning-input');
            } else {
                this.showFacebookError = false;
                this.socialMediaValidityMap['Facebook_link__c'] = { isValid: true };
            }
        } else if (event.target.name == 'Linkedin_link__c') {
            this.datamap['Linkedin_link__c'] = event.target.value;
            if (event.target.value && event.target.value != '' && event.target.value != undefined) {
                this.validateElement('Linkedin_link__c', 'lightning-input');
            } else {
                this.showLinkedInError = false;
                this.socialMediaValidityMap['Linkedin_link__c'] = { isValid: true };
            }
        } else if (event.target.name == 'Twitter_X_link__c') {
            this.datamap['Twitter_X_link__c'] = event.target.value;
            if (event.target.value && event.target.value != '' && event.target.value != undefined) {
                this.validateElement('Twitter_X_link__c', 'lightning-input');
            } else {
                this.showTwitterError = false;
                this.socialMediaValidityMap['Twitter_X_link__c'] = { isValid: true };
            }
        } else if (event.target.name == 'Company_Stage__c') {
            this.datamap['Company_Stage__c'] = event.target.value;
            this.eoiData.Company_Stage__c = this.datamap['Company_Stage__c'];
            if(event.target.value) { 
                this.stageNotSelected = true;
            } else if(!event.target.value) { 
                this.eoiData.Target_Raise_Amount__c = '';
                this.eoiData.Planned_used_of_funds__c = '';
                this.datamap['Target_Raise_Amount__c'] = null;
                this.datamap['Planned_used_of_funds__c'] = null;
                this.stageNotSelected = false;
            }
            this.handleIntendedRaisedValidity();
        } else if (event.target.name == 'Target_Raise_Amount__c') {
            this.datamap['Target_Raise_Amount__c'] = parseFloat(event.target.value);
            this.eoiData.Target_Raise_Amount__c = this.datamap['Target_Raise_Amount__c'];
            this.handleIntendedRaisedValidity();
        } else if (event.target.name == 'Minimum_Investment_amount__c') {
            this.datamap['Minimum_Investment_amount__c'] = parseFloat(event.target.value);
            this.eoiData.Minimum_Investment_amount__c = this.datamap['Minimum_Investment_amount__c'];
            this.handleIntendedRaisedValidity();
        } else if (event.target.name == 'Planned_used_of_funds__c') {
            this.datamap['Planned_used_of_funds__c'] = event.target.value;
            this.eoiData.Planned_used_of_funds__c = this.datamap['Planned_used_of_funds__c'];
            this.handleIntendedRaisedValidity();
        } else if (event.target.name == 'Raise_Contact_email__c') {
            this.datamap['Raise_Contact_email__c'] = event.target.value;
            if (event.target.value && event.target.value != '' && event.target.value != undefined) {
                this.showContactRaiseEmailError = Utility.validateEmail(this.datamap['Raise_Contact_email__c']);
                if (Utility.validateEmail(this.datamap['Raise_Contact_email__c'])) {
                    this.showContactRaiseEmailError = false;
                } else {
                    this.showContactRaiseEmailError = true;
                }
            } else {
                this.showContactRaiseEmailError = false;
            }
            this.eoiData.Raise_Contact_email__c = this.datamap['Raise_Contact_email__c'];
            this.handleIntendedRaisedValidity();
        }
        if (this.showMissingFieldsError) {
            this.checkMissingAndMismatchFields();
        }
        let booleanVarFirstMap = false;
        let booleanVarForSecondMap = false;
        booleanVarFirstMap = Object.values(this.validityMap).every((field) => field.isValid);
        booleanVarForSecondMap = Object.values(this.socialMediaValidityMap).every((field) => field.isValid);

        if (booleanVarForSecondMap && !this.showContactRaiseEmailError) {
            this.disableSaveButton = true;
        } else {
            this.disableSaveButton = false;
        }

        if (booleanVarFirstMap && booleanVarForSecondMap && this.intendedRaisedCompleted) {
            this.missingRequiredDetails = true;
        } else {
            this.missingRequiredDetails = false;
        }
    }

    handleShowErrorOnSubmit() {
        this.validateAllElements(true);
    }

    // Method for validate elements - this is parent method to handle validity (enable disable save , submit to be publish button)
    validateAllElements(runValidityCheck) {
        let inputelements = this.template.querySelectorAll('lightning-input');
        let allelements = Array.from(inputelements);
        let isInputElementValid = false;
        allelements.forEach((ele) => {
            if (!['Facebook_link__c', 'Instagram_link__c', 'Linkedin_link__c', 'Twitter_X_link__c', 'Youtube_link__c','Minimum_Investment_amount__c', 'Target_Raise_Amount__c', 'Raise_Contact_email__c'].includes(ele.name)) {
                ele.dataset.value = ele.dataset.value ? ele.dataset.value.trim() : ele.dataset.value;
                isInputElementValid = ele.checkValidity();
                this.validityMap[ele.name] = { eleName: ele.name, isValid: isInputElementValid, section: ele.dataset.section };
            }
        });

        //validate all textarea
        let allTextareaElement = this.template.querySelectorAll('textarea');
        let textareaElementArray = Array.from(allTextareaElement);
        let istextAreaElementValid = false;

        textareaElementArray.forEach((ele) => {
            ele.dataset.value = ele.dataset.value ? ele.dataset.value.trim() : ele.dataset.value;
            istextAreaElementValid = ele.checkValidity();
            this.validityMap[ele.name] = { eleName: ele.name, isValid: istextAreaElementValid, section: ele.dataset.section };
        });

        this.validityMap['Planned_used_of_funds__c'] = { isValid: true };

        let booleanVarFirstMap = false;
        booleanVarFirstMap = Object.values(this.validityMap).every((field) => field.isValid);
        let booleanVarForSecondMap = false;
        booleanVarForSecondMap = Object.values(this.socialMediaValidityMap).every((field) => field.isValid);

        if (runValidityCheck) {
            this.showTitleError = !this.validityMap['EOI_Title__c'].isValid ? true : false;
            this.showOneLinerError = !this.validityMap['One_liner_about_business__c'].isValid ? true : false;
            this.showOfferOverviewError = !this.validityMap['Offer_Overview__c'].isValid ? true : false;
            this.showYoYGrowthError = !this.validityMap['Problem_or_opportunity__c'].isValid ? true : false;
            this.showKeyPartnershipsError = !this.validityMap['Solution__c'].isValid ? true : false;
            this.showKeyCustomersError = !this.validityMap['Differentiation__c'].isValid ? true : false;
            this.showARRError = !this.validityMap['Intellectual_Property__c'].isValid ? true : false;
            this.showCompetitiveAdvError = !this.validityMap['Total_addressable_market__c'].isValid ? true : false;
            this.showAddressableMarketError = !this.validityMap['Progress__c'].isValid ? true : false;
            this.showGrowthStrategyError = !this.validityMap['Growth_plan__c'].isValid ? true : false;
            this.showFounderError = !this.validityMap['founder'].isValid ? true : false;
            this.showIntendedRaisedError = !this.intendedRaisedCompleted;
            const validityArray = Object.values(this.validityMap);
            const invalidElements = validityArray.filter((ele) => ele.isValid === false);
            let invalidSections = invalidElements.map((ele) => ele.section);
            invalidSections = invalidSections.filter((value, index, self) => self.indexOf(value) === index);
            if (!booleanVarForSecondMap) {
                invalidSections.push('socialAndMediaLinks');
            }
            if (this.showContactRaiseEmailError || !this.intendedRaisedCompleted) {
                invalidSections.push('intendedRaise');
            }
            if (this.openSections) {
                invalidSections = invalidSections.concat(this.openSections);
            }
            if (invalidSections) {
                this.activeSections = Utility.removeDuplicates(invalidSections, 'Array');
            }
            this.checkMissingAndMismatchFields();
        }
        if (booleanVarFirstMap && booleanVarForSecondMap && this.intendedRaisedCompleted) {
            this.missingRequiredDetails = true;
        } else {
            this.missingRequiredDetails = false;
        }
    }

    validateElement(elementName, elementType) {
        let element;
        if (elementType == 'lightning-input') {
            element = this.template.querySelectorAll('lightning-input');
        } else if (elementType == 'textarea') {
            element = this.template.querySelectorAll('textarea');
        }
        let allelements = Array.from(element);
        let isElementValid = false;
        allelements.forEach((ele) => {
            if (!['Facebook_link__c', 'Instagram_link__c', 'Linkedin_link__c', 'Twitter_X_link__c', 'Youtube_link__c', 'Target_Raise_Amount__c','Minimum_Investment_amount__c', 'Raise_Contact_email__c'].includes(ele.name)) {
                if (elementType == 'lightning-input') {
                    ele.dataset.value = ele.dataset.value ? ele.dataset.value.trim() : ele.dataset.value;
                } else if (elementType == 'textarea') {
                    ele.dataset.value = ele.dataset.value ? ele.dataset.value.trim() : ele.dataset.value;
                }
                // check the validity of specific element
                if (ele.name == elementName) {
                    isElementValid = ele.checkValidity();
                    this.validityMap[ele.name].isValid = isElementValid;
                }
            } else if (ele.name == elementName) {
                let booleanVar = false;
                if (elementName == 'Instagram_link__c') {
                    booleanVar = Utility.isValidSocialMediaUrl(this.datamap['Instagram_link__c'], 'Instagram_link__c');
                    this.socialMediaValidityMap['Instagram_link__c'] = { isValid: booleanVar };
                    this.showInstagramError = !booleanVar;
                }
                if (elementName == 'Youtube_link__c') {
                    booleanVar = Utility.isValidSocialMediaUrl(this.datamap['Youtube_link__c'], 'Youtube_link__c');
                    this.socialMediaValidityMap['Youtube_link__c'] = { isValid: booleanVar };
                    this.showYouTubeError = !booleanVar;
                }
                if (elementName == 'Facebook_link__c') {
                    booleanVar = Utility.isValidSocialMediaUrl(this.datamap['Facebook_link__c'], 'Facebook_link__c');
                    this.socialMediaValidityMap['Facebook_link__c'] = { isValid: booleanVar };
                    this.showFacebookError = !booleanVar;
                }

                if (elementName == 'Twitter_X_link__c') {
                    booleanVar = Utility.isValidSocialMediaUrl(this.datamap['Twitter_X_link__c'], 'Twitter_X_link__c');
                    this.socialMediaValidityMap['Twitter_X_link__c'] = { isValid: booleanVar };
                    this.showTwitterError = !booleanVar;
                }

                if (elementName == 'Linkedin_link__c') {
                    booleanVar = Utility.isValidSocialMediaUrl(this.datamap['Linkedin_link__c'], 'Linkedin_link__c');
                    this.socialMediaValidityMap['Linkedin_link__c'] = { isValid: booleanVar };
                    this.showLinkedInError = !booleanVar;
                }
            }
        });
    }

    // method to check if there is at least one founder
    handleValidateFounder(event) {
        let hasFounder = false;
        if (event && event.detail) {
            hasFounder = event.detail.hasFounder;
        }
        if (!this.validityMap['founder']) {
            this.validityMap['founder'] = { eleName: 'founder', isValid: hasFounder, section: 'team' };
        } else {
            this.validityMap['founder'].isValid = hasFounder;
        }
        if (this.showFounderError && this.validityMap['founder'].isValid == true) {
            this.showFounderError = false;
        }
        this.validateAllElements(false);
    }

    // method to handle validity for intended raised section
    handleIntendedRaisedValidity() {
        if (!this.stageNotSelected || (this.stageNotSelected && this.eoiData.Planned_used_of_funds__c && this.eoiData.Company_Stage__c && this.eoiData.Target_Raise_Amount__c && this.eoiData.Raise_Contact_email__c) || (!this.eoiData.Company_Stage__c && !this.eoiData.Target_Raise_Amount__c && !this.eoiData.Raise_Contact_email__c)) {
            this.intendedRaisedCompleted = true;
            this.showIntendedRaisedError = false;
        } else {
            this.intendedRaisedCompleted = false;
        }
        if (this.showContactRaiseEmailError) {
            this.intendedRaisedCompleted = false;
        }
    }

    // method to get count of missing required fields
    checkMissingAndMismatchFields() {
        this.totalMandatoryOrBadValuesFields = 0;
        let badValueFieldsCount = 0;
        Object.values(this.socialMediaValidityMap).forEach((field) => {
            if (!field.isValid) {
                badValueFieldsCount++;
            }
        });

        let mandatoryFieldsCount = 0;
        Object.values(this.validityMap).forEach((field) => {
            if (!field.isValid) {
                mandatoryFieldsCount++;
            }
        });

        this.totalMandatoryOrBadValuesFields = badValueFieldsCount + mandatoryFieldsCount;

        if (this.totalMandatoryOrBadValuesFields > 1) {
            this.showMissingFieldsError = true;
            this.mandatoryFieldsMessage = ' fields have missing or invalid values.';
        } else if (this.totalMandatoryOrBadValuesFields === 1) {
            this.showMissingFieldsError = true;
            this.mandatoryFieldsMessage = ' field has a missing or invalid value.';
        } else {
            this.showMissingFieldsError = false;
        }
    }

    // refreshApex to show updated data
    handleRefreshView() {
        refreshApex(this.wiredEoiData);
    }

    // handleSectionToggle used to expand/collapse toggle sections
    handleSectionToggle(event) {
        this.openSections = event.detail.openSections;
    }

    // here we save EOI details to salesforce
    save() {
        this.showSpinner = true;
        upsertFounderImage({
            eoiId: this.eoiId
        });
        // cesar code on update SalesforceFilesDownloadUrls
        getSalesforceFilesDownloadUrls({ recordId: this.eoiId });
        return updateEoi({ datamap: this.datamap, eoiId: this.eoiId })
            .then((r) => {
                let success = false;
                if (r === 'Success') {
                    this.handleRefreshView();
                    success = true;
                    // here showing save success toast message
                    this.showToast('Information has been saved.', 'success');
                } else {
                    this.showToast(r, 'error');
                }
                return success;
            })
            .catch((e) => {
                this.showToast('Error saving expression of interest.', 'error');
                return false;
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }

    // handleSave get call on click of save button
    handleSave() {
        // invoke save() method
        this.save();
    }

    // When user click on preveiw button this method helps in redirect on preview page.
    handlePreview() {
        upsertFounderImage({
            eoiId: this.eoiId
        });
        // cesar code on update SalesforceFilesDownloadUrls
        getSalesforceFilesDownloadUrls({ recordId: this.eoiId });
        this.save().then((success) => {
            if (success === true) {
                this[NavigationMixin.Navigate]({
                    type: 'comm__namedPage',
                    attributes: {
                        name: 'eoipreview__c'
                    },
                    state: {
                        id: this.eoiId
                    }
                });
            }
        });
    }

    // This method is used to show popup of confiem submit EOI , on click of Submitted to be Published button the popup will be shown
    handleSubmit() {
        this.save().then((success) => {
            if (success) {
                this.showConfirmSubmissionPopup = true;
            }
        });   
    }

    // This method has logic to handle 'Submitted to be Published' and if the EOI is submitted successfully then we show congratulations popup.
    handlePublishEoi() {
        if (this.checkbox1 && this.checkbox2 && this.checkbox3 && this.checkbox4) {
            let datamap = {};
            this.showSpinner = true;
            datamap['EOI_Status__c'] = 'Submitted to be Published';
            updateEoi({
                datamap,
                eoiId: this.eoiId
            })
                .then((r) => {
                    if (r == 'Success') {
                        this.showConfirmSubmissionPopup = false;
                        this.showConfirmSubmitMessage = false;
                        this.checkbox1 = this.checkbox2 = this.checkbox3 = this.checkbox4 = false;

                        this.showToast('EOI submitted to be published', 'success');
                        this.showCongratulationsPage();
                        this.showSpinner = false;
                    } else {
                        this.showConfirmSubmissionPopup = false;
                        this.showConfirmSubmitMessage = false;
                        this.checkbox1 = this.checkbox2 = this.checkbox3 = this.checkbox4 = false;
                        this.showToast(r, 'error');
                        this.showSpinner = false;
                    }
                })
                .catch((e) => {
                    this.showConfirmSubmissionPopup = false;
                    this.checkbox1 = this.checkbox2 = this.checkbox3 = this.checkbox4 = false;
                    this.showConfirmSubmitMessage = false;
                    this.showToast('Error in submitting EOI for published', 'error');
                    this.showSpinner = false;
                });
        } else {
            this.showConfirmSubmitMessage = true;
        }
    }

    closePopup() {
        this.checkbox1 = this.checkbox2 = this.checkbox3 = this.checkbox4 = false;
        this.showConfirmSubmitMessage = false;
        this.showConfirmSubmissionPopup = false;
    }

    // This function is triggered when a checkbox is checked or unchecked.
    handleCheck(event) {
        // Update the value of checkboxs property based on its name and checked state.
        if (event.target.name == 'checkbox1') {
            this.checkbox1 = event.target.checked;
        }
        if (event.target.name == 'checkbox2') {
            this.checkbox2 = event.target.checked;
        }
        if (event.target.name == 'checkbox3') {
            this.checkbox3 = event.target.checked;
        }
        if (event.target.name == 'checkbox4') {
            this.checkbox4 = event.target.checked;
        }

        // Check if all checkboxes are checked.
        if (this.checkbox1 && this.checkbox2 && this.checkbox3 && this.checkbox4) {
            this.showConfirmSubmitMessage = false;
        }
    }

    showCongratulationsPage() {
        this.isEoiSubmittedForPublished = true;
    }

    // This function is used to navigate back to the 'my_companies__c' page.
    returnToMyCompanies() {
        // Use the NavigationMixin to navigate to a specific page.
        // The type specifies the type of navigation, here it's 'comm__namedPage'.
        // The attributes object contains additional parameters for the navigation.
        // In this case, it specifies the name of the page to navigate to as 'my_companies__c'.
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'my_companies__c'
            }
        });
    }

    // function to show toast messages of diffrent variant
    showToast(message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: message,
                variant: variant
            })
        );
    }

    // function to open FAQ page in new tab
    openFaqPage() {
        // URL to open in a new tab
        const url = 'https://www.venturecrowd.com.au/s/learn/faq/founder-portal';

        // Open URL in a new tab
        window.open(url, '_blank');
    }

    // function to open See example page in new tab
    openSeeExamplePage() {
        const url = 'https://www.venturecrowd.com.au/s/lp/example-eoi ';

        // Open URL in a new tab
        window.open(url, '_blank');
    }

    get responsivecssForHeader(){
        return  this.screenWidth < 530 ? "slds-media slds-wrap slds-truncate slds-media_center slds-has-flexi-truncate": "slds-media slds-media_center slds-has-flexi-truncate";
    }

    get responsivecssForSubmitToBePublishBtn(){
        return  this.screenWidth < 530 ? "slds-size_12-of-12 slds-media__body": "slds-media__body";
    }

    get responsivecssForPreviewAndSavetn(){
        return  this.screenWidth < 530 ? "slds-media__figure slds-m-top_small slds-size_10-of-12 slds-media__figure_reverse header-button-group-right": "slds-media__figure slds-media__figure_reverse header-button-group-right";
    }

    get responsivecssForPreviewOrSavetn(){
        return  this.screenWidth < 530 ? "slds-size_3-of-6 slds-media__body": "slds-media__body";
    }

    handleNavigateLearning(e){
        // console.log("Button clicker: ", JSON.stringify(e));
    }
    
}