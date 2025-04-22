/*********************************************************************************************************************************************
Author		 :	 Prakash Borade
Description	 :   CompaniesCard LWC is used to show Companies tile , where we show companies with EOI on left and companies without EOI on right.
                 This is child component of MyCompaniesTiles LWC
Child Component   :  -
----------------------------------------------------------------------------------------------------------------------------------------------
Version      Date                 Author               Details
1            21/12/2023           Prakash Borade       Initial Development
2            20/06/2024           Cesar Vaca           Refactoring companies card
**********************************************************************************************************************************************/
// Importing necessary decorators and modules from LWC
import { LightningElement, api, track } from 'lwc';
// Importing the NavigationMixin module for navigating to different pages
import { NavigationMixin } from 'lightning/navigation';
// Importing the ShowToastEvent module for displaying toast notifications
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getCompaniesCardData from '@salesforce/apex/CompaniesController.getCompaniesCardDetails'

// Importing the getRecordTypeId method from the Utils Apex class for retrieving the record type ID
// import getRecordTypeId from '@salesforce/apex/Utils.getRecordTypeId';

// Importing the current user's ID from the @salesforce/user module
import Id from '@salesforce/user/Id';

export default class CompaniesCard extends NavigationMixin(LightningElement) {
    @api companies;
    @api recordTypeId;
    @track isLoading;
    @track companyId;    
    @track loggedInUserId = Id;

    // New values
    @track raisePending = true;
    @track eoiLive = true;
    @track companiesData;

    eoiChevronStatus = [
        {value: 'Not Published'},
        {value: 'Submitted to be Published'},
        {value: 'Publishing'},
        {value: 'Published'},
        {value: 'Closed'}
    ]

    raiseChevronStatus = [
        { label: 'New'},
        { label: 'Raise Information'},
        { label: 'Approvals'},
        { label: 'Capital Raising 101 Course'},
        { label: 'Publish Page'}
    ];

    // Status mapping for EOI and Raise fields
    statusMap = {
        "Not Published" : "UNPUBLISHED",
        "Submitted to be Published" : "PENDING",
        "Publishing" : "PENDING",
        "Published" : "LIVE",
        "Closed" : "CLOSED",

        // Raise Fields
        "In Progress" : "UNPUBLISHED",
        "Ready for review" : "UNPUBLISHED",
        "In Review" : "UNPUBLISHED",
        "Waiting for payment" : "UNPUBLISHED",
        "Waiting to complete learning course" : "UNPUBLISHED",
        "Pending final approval" : "UNPUBLISHED",
        "Live on VC Website" : "LIVE",
        "Live" : "LIVE",
        "Closed" : "CLOSED"
    }

    // Chevron mapping for EOI and Raise fields
    chevronStatus = {
        "New" : "New",
        "In Progress" : "Raise Information",
        "Ready for review" : "Approvals",
        "In Review" : "Approvals",
        "Waiting for payment" : "Approvals",
        "Waiting to complete learning course" : "Capital Raising 101 Course",
        "Pending final approval" : "Publish Page",
    }

    /**
     * Method to format a date into a readable string.
     * @param {string} inputDate - The date to be formatted
     * @returns {string} - The formatted date string
     */
    formatDate(inputDate) {
        let date = new Date(inputDate);
        let options = { day: 'numeric', month: 'long', year: 'numeric' };
        let finalDate = date.toLocaleDateString('en-US', options);
        return finalDate;
    }

    /**
     * Method to get company data based on user ID.
     * @param {string} userId - The ID of the logged-in user
     * @returns {Promise<Object>} - The company data
     */
    async getData(userId) {
        try {
            let companiesCardData = await getCompaniesCardData({ userId: userId});
            return companiesCardData;
        } catch (error) {
            console.error('Error retrieving the data',error)
        }
    }

    /**
     * Get method to determine if EOI is pending.
     * @returns {boolean} - True if EOI is pending, otherwise false
     */
    get isEoiPending() {
        if ("Published" || "Not Published") {
            return true;
        }
        else {
            return false;
        }
    }

    /**
     * Method to preprocess the company status for raise and EOI.
     * @param {Array} returnData - The raw company data
     * @returns {Array} - The preprocessed company data
     */
    preProcessData(returnData) {
        return returnData.map((item) => {
            try {
                if (item.eoiExist) {
                    // Used badgeEoiStatus to have a copy of the status for not affect the chevrons
                    item.badgeEoiStatus = this.statusMap[item.eoiStatus];
                    item.eoiLive = item.badgeEoiStatus === "LIVE" ? true : false;
                    item.eoiClosed = item.badgeEoiStatus === "CLOSED" ? true : false;
                    item.eoiInProgress = item.badgeEoiStatus === "UNPUBLISHED" ?  true : false;
                    item.eoiPending = item.badgeEoiStatus === "PENDING" ? true : false;
                    item.eoiShowChevron = (item.eoiInProgress || item.eoiPending) && !item.eoiLive && !item.eoiClosed ? true : false;
                    item.showResumeButton = ((item.badgeEoiStatus === "LIVE" || item.badgeEoiStatus === "CLOSED") && !item.raiseExist) ? true : false;
                    item.eoiLaunchDate = item.eoiLaunchDate ? this.formatDate(item.eoiLaunchDate) : null;
                }

                if (item.raiseExist) {
                    // Used badgeEoiStatus to have a copy of the status for not affect the chevrons
                    item.badgeRaiseStatus = this.statusMap[item.raiseStatus];
                    item.chevronStatus = this.chevronStatus[item.raiseStatus];
                    item.raiseLive = item.badgeRaiseStatus === "LIVE" ? true : false;
                    item.raiseClosed = item.badgeRaiseStatus === "CLOSED" ? true : false;
                    item.raiseInProgress = item.raiseStatus === "In Progress" ? true : false;
                    item.awaitingPayment = item.raiseStatus === "Waiting for payment" ? true : false;
                    item.courseInProgress = item.raiseStatus === "Waiting to complete learning course" && !item.raiseCourseUnlocked? true : false;
                    item.raiseCourseUnlocked = item.raiseCourseUnlocked && !item.learningCompleted;
                    item.raiseCourseFinished = item.learningCompleted && item.raiseStatus === 'Waiting to complete learning course';
                    item.raisePending = item.badgeRaiseStatus === "PENDING" ? true : false;
                    item.showProgress = (item.badgeRaiseStatus !== "LIVE" && item.badgeRaiseStatus !== "CLOSED") ? true : false;
                    item.pendingFinalApproval = item.raiseStatus === "Pending final approval" ? true : false;
                    item.raiseLaunchDate = item.raiseLaunchDate ? this.formatDate(item.raiseLaunchDate) : null;
                    item.raiseEndDate = item.raiseEndDate ? this.formatDate(item.raiseEndDate) : null;
                }
                return item;
            } catch (error) {
                console.error('Error processing the data',error);
            }
        });
    }

    // Lifecycle hook to fetch data and preprocess it when the component is connected to the DOM
    connectedCallback() {
        this.isLoading = true;
        // Call the getRecordTypeId() method to retrieve the record type ID
        // this.getRecordTypeId();
        this.getData(this.loggedInUserId).then(result => {
            let processedData = this.preProcessData(result)
            this.companiesData = [...processedData];
            this.isLoading = false;
        })
        .catch(err =>{
            console.error("An error has occured retrieving company data: ", err)
        })
        .finally(()=>{
            this.isLoading = false;
            console.log(JSON.stringify(this.companiesData))
        })
        ;
        this.isLoading = false;
    }


    /**
     * Method to navigate to the page for editing an Expression of Interest (EOI).
     */
    editEoi(event) {
        this[NavigationMixin.Navigate]({
             // Define navigation type and target page name
            type: 'comm__namedPage',
            attributes: {
                name: 'my_eoi__c' // Page name for editing EOI
            },
            state: {
                edit: event.target.dataset.id // Pass the EOI id as a state parameter
            }
        });
    }

    /**
     * Method to navigate to the page for managing an Expression of Interest (EOI).
     */
    manageEoi(event) {
        this[NavigationMixin.Navigate]({
            // Define navigation type and target page name
            type: 'comm__namedPage',
            attributes: {
                name: 'manage_eoi__c' // Page name for managing EOI
            },
            state: {
                id: event.target.dataset.id // Pass the EOI id as a state parameter
            }
        });
    }

    /**
     * Method to navigate to the page for preview an Expression of Interest (EOI).
     */    
    previewEoi(event) {
        this[NavigationMixin.Navigate]({
            // Define navigation type and target page name
            type: 'comm__namedPage', 
            attributes: {
                name: 'eoipreview__c'  // Page name for previewing EOI
            },
            state: {
                id: event.target.dataset.id // Pass the EOI id as a state parameter
            }
        });
    }

     /**
     * Method to navigate to the live page for an Expression of Interest (EOI).
     */  
     viewEoi(event){
        const eoiId = event.target.dataset.id;

        let eoiToNavigateList = this.companiesData.filter((item) => item.eoiId===eoiId);

        if(eoiToNavigateList.length > 0){
            const eoiToNav = eoiToNavigateList[0];

            if(eoiToNav.eoiPublishURL){
                this[NavigationMixin.Navigate]({
                    // Define navigation type and target page name
                    type: 'standard__webPage', 
                    attributes: {
                        url: this.ensureHttp(eoiToNav.eoiPublishURL)
                    }
                });
            }else{
                console.error("Published EOI URL not found!")
            }

        }else{
            console.error('Error retrieiving EOI data: Cannot find EOI for this action ERR-CFE1')
        }


    }

    /**
     * Ensures a URL starts with "http://" or "https://".
     * If the input URL doesn't start with either, it prepends "http://".
     *
     * @param {string} url - The URL string to check and modify if necessary.
     * @returns {string} - The modified URL string with the correct protocol.
     *
     * @example
     * ensureHttp('example.com'); // returns 'http://example.com'
     * ensureHttp('https://example.com'); // returns 'https://example.com'
     * ensureHttp('http://example.com'); // returns 'http://example.com'
     */
    ensureHttp(url) {
        // Check if the URL starts with "http://" or "https://"
        if (!/^https?:\/\//i.test(url)) {
          // If not, prepend "http://"
          return 'http://' + url;
        }
        // Return the original URL if it already starts with "http://" or "https://"
        return url;
      }


      
    /**
     * Method to navigate to the page for managing an Expression of Interest (EOI).
     */
    previewRaise(event){
        //navigate to form
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId : event.target.dataset.id,
                objectApiName : 'Raise__c',
                actionName : 'view'
            },
        })
    }

    /**
     * Method to navigate to the page for managing a Raise.
     */
    manageRaise(event){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Manage_Raise__c'
            },
            state: {
                id: event.target.dataset.id // Pass the EOI id as a state parameter
            }
        })
    }

    /**
     * Method to navigate to the Learning course.
     */
    handlelearningCourse(event){
        const raiseId = event.target.dataset.id
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Capital_Raising_101__c'
            },
            state: {
                id: raiseId
            }
        })
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