/**
 * @description LWC for the investor portfolio view - PIPO Project
 * @dependencies LWC pipoTabs,pipoInvestmentCard,pipoHelphub
 * @createdBy Cesar
 * @createdDate 2024-09-26
 * @version 1.1
 */

import { LightningElement, track } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import userId from "@salesforce/user/Id";
import apex_retrieveAccountData from '@salesforce/apex/PipoController.portfolioAccountInformation';
import apex_retrieveInvestmentData from '@salesforce/apex/PipoController.getAccountInvestments';
import apex_retrieveEntitiesInvestments from '@salesforce/apex/PipoController.getEntitiesInvestments';
import apex__getSpotlightData from '@salesforce/apex/PipoController.getSpotlightData';
import apex_retrieveEoiLeads from '@salesforce/apex/LeadControllerNew.getEOILeadsEmail';
import apex_getPendingActiveInvestments from '@salesforce/apex/PipoController.getPendingAndInactiveInvestments';
import apex_tourTaken from '@salesforce/apex/PipoController.tourTaken';
export default class PortfolioViewPipo extends NavigationMixin(LightningElement)  {
    @track _userId = userId;
    @track isEOI = true;
    email;
    isLoading = true;

    // This will get the length of the Array
    @track activeInvestmentsLength = 0;
    @track pendingInvestmentsLength = 0;
    @track closedInvestmentsLength = 0;
    @track eoiLength = 0;

    // Spotlight data
    totalAmountInvested;
    portfolioValue;

    // Active Investments
    activePersonalInvestments = [];
    activeEntitiesInvestments = [];

    renderActiveEntitiesText;
    renderActivePersonalIText;

    // This will handle the spotlight visibility 
    noInvestments = true;

    // This pass to the child component the Personal and Entities Investments
    @track closedInvestments;
    @track pendingInvestments;
    @track eoiCards;

    // Spotlight data
    showUserVerification;
    userName;

    // Handle limit size for retrieve person and entities investments
    offset = 0;
    entitiesOffset = 0;

    buttonLoading = false;

    // Handles the buttons for active investments
    showMoreButton = false;
    showMoreEntitiesButton = false;

    // Button for loading
    entitiesButtonLoading;

    // Variable to handle the show the banner
    showBanner;

    // Variable to handle CSF banner
    CSFBannerAcknowledged;
    retailInvestor;
    handleCsfBanner = false;
    showCSFBanner;
    isExpanded;


    /**
     * Retrieves and processes account data for the current user.
     *
     * @param {string} _userId - The Salesforce ID of the current user.
     * @returns {Promise<void>} - A promise that resolves when the data is successfully retrieved and processed.
     * @throws {Error} - If an error occurs during the data retrieval or processing.
     */
    async getAccountData(_userId) {
        try {
            // Call the Apex method to retrieve account data for the current user
            let data = await apex_retrieveAccountData({userId: _userId});

            // Update the showUserVerification property based on the retrieved data
            this.showUserVerification = !data.IdVerified;
            this.showCSFBanner = data.ShowCSFBanner;
            this.retailInvestor = data.RetailInvestor;
            this.showBanner = data.ShowBanner;
            // Update the userName property with the retrieved data
            this.userName = data.Name;
            this.email = data.Email;
            return data.Email;
        } catch (error) {
            // Log the error message to the console
            console.error('Error fetching data:', error);

            // Re-throw the error to propagate it up the call stack
            throw error;
        }
    }
    /**
     * Retrieves and processes personal investments data for the current user.
     *
     * @param {string} _userId - The Salesforce ID of the current user.
     * @returns {Promise<void>} - A promise that resolves when the data is successfully retrieved and processed.
     * @throws {Error} - If an error occurs during the data retrieval or processing.
     */
    async getPersonalInvestmentData(_userId) {
        try {
            let limitSize = 4;
            // Call the Apex method and wait for the result
            const result = await apex_retrieveInvestmentData({
                userId: _userId,
                limitSize: limitSize,
                offsetValue: this.offset
            });
            
          
            // If result.length < limitSize, no more records are left.
            if (result.length < limitSize) {
                this.showMoreButton = false;
            } else {
                this.showMoreButton = true;
            }
        
            // Process the result if it contains data
            if (result.length > 0) {
                this.offset += limitSize;
                // Increment the offset dynamically
                result.forEach(item => {
                    item.AccountName = this.userName;
                    item.Amount = item.Amount != null ? item.Amount.toLocaleString('en-US') : '0';
                    item.InvestmentDate = new Date(item.InvestmentDate).toLocaleDateString('en-AU');
                });
                // Append new result to the cards
                this.activePersonalInvestments = [...this.activePersonalInvestments, ...result];
                if (this.activePersonalInvestments.length > 0) {
                    this.renderActivePersonalIText = true;
                }
                // Show the button if there are more than 4 investments
            } else {
                this.showMoreButton = false;
            }

        } catch (error) {
            // Log the error message to the console
            console.error('Error retrieving investment data:', error);

            // Re-throw the error to propagate it up the call stack
            throw error;
        }
    }
    

    async getEntitiesInvestmentsData() {
        try {
            let limitSize = 4;
            // Call the Apex method and wait for the result
            const result = await apex_retrieveEntitiesInvestments({
                limitSize: limitSize,
                offsetValue: this.entitiesOffset
            });

            // If result.length < limitSize, no more records are left.
            if (result.length < limitSize) {
                this.showMoreEntitiesButton = false;
            } else {
                this.showMoreEntitiesButton = true;
            }

            // Process the result if it contains data
            if (result.length > 0) {
                this.entitiesOffset += limitSize;
                // Increment the offset dynamically
                result.forEach(item => {
                    item.Amount = item.Amount != null ? item.Amount.toLocaleString('en-US') : '0';
                    item.InvestmentDate = new Date(item.InvestmentDate).toLocaleDateString('en-AU');
                });
                // Append new result to the cards
                this.activeEntitiesInvestments = [...this.activeEntitiesInvestments, ...result];
                if (this.activeEntitiesInvestments.length > 0) {
                    this.renderActiveEntitiesText = true;
                }
                // Show the button if there are more than 4 investments
            } else {
                this.showMoreEntitiesButton = false;
            }
        } catch (error) {
            // Log the error message to the console
            console.error('Error retrieving investment data:', error);
            // Re-throw the error to propagate it up the call stack
            throw error;
        }
    }


    /**
     * Handles the 'loadmore' event from the child component.
     */
    handleLoadMore() {
        this.buttonLoading = true;
        this.getPersonalInvestmentData(this._userId).then(() => {
                this.buttonLoading = false;
            }
        );
    }


    /**
     * Handles the 'loadmore' event from the child component.
     */
    handleLoadMoreEntities() {
        this.entitiesButtonLoading = true;
        this.getEntitiesInvestmentsData().then(() => {
                this.entitiesButtonLoading = false;
            }
        );
    }
    

    /**
     * Retrieves and processes EOI leads data for the current user.
     *
     * @param {string} _userId - The Salesforce ID of the current user.
     * @returns {Promise<void>} - A promise that resolves when the data is successfully retrieved and processed.
     * @throws {Error} - If an error occurs during the data retrieval or processing.
     */
    async getEoiLeads(email) {
        try {
            // Call the Apex method to retrieve EOI leads data for the current user
            let data = await apex_retrieveEoiLeads({email: email});
            if (data.length === 0) {
                this.eoiCards = false;
                this.eoiLength = 0;
                return;
            }
            
            data.forEach(item => {
                // Check if the amount string is a number or an integer
                if (typeof item.InvestAmount === 'number') {
                    item.InvestAmount = item.InvestAmount.toLocaleString('en-US');
                } else {
                    item.InvestAmount = String(item.InvestAmount).replace(/^\$/, '');
                }
            });
            
            // Assign the retrieved data to the eoiCards property
            this.eoiCards = data;

            // Calculate and assign the length of the EOI leads data to the eoiLength property
            this.eoiLength = data.length;
        } catch (error) {
            // Log the error message to the console
            console.error('Error retrieving leads:', error);

            // Re-throw the error to propagate it up the call stack
            throw error;
        }
    }

    
    /**
     * This function calculates and prepares data for the portfolio spotlight section.
     * It combines personal and entities investments, calculates the total amount invested,
     * portfolio value, and counts the number of active, pending, and closed investments.
     *
     * @returns {void}
     */
    async getSpotlightData(_userId) {

        try {
            let data = await apex__getSpotlightData({userId: _userId});
            
            if (data.TotalInvestments > 0) {
                this.noInvestments = false;
            }
            // Assign the data to the spotlight view
            this.totalAmountInvested = data.TotalInvested.toLocaleString('en-US',  { minimumFractionDigits: 2, maximumFractionDigits: 2 });
            this.portfolioValue = data.HoldingValue.toLocaleString('en-US',  { minimumFractionDigits: 2, maximumFractionDigits: 2 });
            this.activeInvestmentsLength = data.TotalInvestments;

        } catch (error) {
            console.error('Error calculating spotlight data:', error);
        }
    }

    async getPendingAndInactiveInvestments(_userId) {
        try {
            let data = await apex_getPendingActiveInvestments({userId: _userId})
            data.forEach(item => {
                item.Amount = item.Amount != null ? item.Amount.toLocaleString('en-US') : '0';
            });
            // return false if it's null pending investment
            let filterPending = data.filter(item => item.InvestmentStage === 'Pending' || item.Stage === 'Application Received' || item.Stage === 'Receipt Issued');
            this.pendingInvestments = filterPending.length === 0  ? false : filterPending;
            let filterClosed = data.filter(item => item.InvestmentStage === 'Closed');
            filterClosed.forEach(item => {
                item.backgroundColor = '#F2F3F4';
            })
            this.closedInvestments = data.length === 0 ? false : filterClosed; 
            this.pendingInvestmentsLength = this.pendingInvestments.length || 0;
            this.closedInvestmentsLength = this.closedInvestments.length || 0;

        }
        catch (error) {
            console.error('Error calculating spotlight data:', error);
        }
    }

    /**
     * The connectedCallback lifecycle method is called when a component is inserted into the DOM.
     * It's used to initialize the component and perform any necessary setup.
     * In this case, it sets the isLoading flag to true, fetches data for the account, entities, and EOI leads,
     * then calculates and prepares data for the portfolio spotlight section.
     *
     * @returns {void}
     */
    connectedCallback() {
        this.isLoading = true;

        // Fetch account data
        this.getAccountData(this._userId).then(() => {
            // Fetch EOI leads data
            this.getEoiLeads(this.email);
        }); 

        // Get the spotlight data
        this.getSpotlightData(this._userId);
        
        // Fetch entities investments data
        this.getEntitiesInvestmentsData();

        this.getPendingAndInactiveInvestments(this._userId);

        // Fetch personal investments data and calculate spotlight data after it's resolved
        this.getPersonalInvestmentData(this._userId).finally(() => {
            this.isLoading = false;
        });
    }

    /**
     * Method to navigate to the edit raise page.
     * @returns {void}
    */
    handleVerificationNav(){
        //navigate to form
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'venture_verification__c' 
            }
        })
    }

    /**
     * Method to navigate to tour video.
     * @returns {void}
    */
    async handleTourButtonClick() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: 'https://www.youtube.com/watch?v=G-HzVM9A_4U&ab_channel=VentureCrowd' 
            }
        })
    }

    /**
     * Handles the closing of the banner by setting the showBanner property to false and calling the Apex method to mark the tour as taken.
     *
     * @returns {void}
     */
    handleCloseBannerButton() {
        // Update the showBanner property to hide the banner
        this.showBanner = false;

        // Call the Apex method to mark the tour as taken for the current user
        apex_tourTaken({userId: this._userId});
    }


    /**
     * Handles the 'inactive' tab click event by showing or hiding the CSF banner.
     *
     * @param {Event} event - The click event triggered by the 'inactive' tab.
     * @returns {void}
     */
    handleInactiveTab(event) {
        event.stopPropagation();
        let tabDetail = event.detail.tabDetail;
        // Check if the CSF banner should be shown based on the conditions
        if ((this.CSFBannerAcknowledged !== true) && (this.closedInvestments !== false) && (this.handleCsfBanner !== true) && this.showCSFBanner) {
            // Show the CSF banner
            this.handleCsfBanner = true;
        }  
        
        if (tabDetail !== 'inactive') {
            this.handleCsfBanner = false;
        }
    }

    /**
     * Handles the closing of the CSF banner by updating the component's properties.
     *
     * @function handleCloseCSFBanner
     * @memberof PortfolioViewPipo
     * @instance
     *
     * @returns {void}
     *
     * @fires PortfolioViewPipo#CSFBannerAcknowledged - Sets the CSFBannerAcknowledged property to true.
     * @fires PortfolioViewPipo#handleCsfBanner - Sets the showCsfBanner property to false.
     */
    handleCloseCSFBanner() {
        this.CSFBannerAcknowledged = true;
        this.handleCsfBanner = false;
    }


    /**
     * Handles the click event on the 'Inactive Investments' button.
     * It retrieves a reference to the 'coretabs' component and sets the active tab to 'inactive'.
     *
     * @function handleClickInactiveInvestment
     * @memberof PortfolioViewPipo
     * @instance
     *
     * @returns {void}
     *
     * @fires PortfolioViewPipo#refs.coretabs.setActiveTab - Sets the active tab to 'inactive' in the 'coretabs' component.
     */
    handleClickInactiveInvestment() {
        const childComponent = this.refs.coretabs;
        if (childComponent) {
            childComponent.setActiveTab('inactive');
        }
    }
    
    /**
     * Handles the click event on the 'Find Out More' button.
     * It sets the 'isExpanded' property to true, expanding the text content.
     *
     * @function handleFindOutText
     * @memberof PortfolioViewPipo
     * @instance
     *
     * @returns {void}
     *
     * @fires PortfolioViewPipo#isExpanded - Sets the 'isExpanded' property to true.
     */
    handleFindOutText() {
        this.isExpanded = true;
    }
}