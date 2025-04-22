/**
 * @description Lightning Web Component (LWC) for the investor portfolio view in the PIPO Project.
 * This component retrieves and displays investment details, handles user verification,
 * and manages investment statuses such as "pending" and "active."
 * 
 * @dependencies 
 * LWC components:
 * - coreLoadingSpinner
 * - coreIcon
 * - corePipoInvestmentSupport
 * - coreAlert
 * - coreButton
 * - coreStepper
 * - coreTooltip
 * - pipoInvestmentSupport
 * - pipoYieldingView
 * - pipoInvestmentTabs
 * 
 * @apexControllers
 * - PipoController.getInvestmentDetails
 * - PipoController.portfolioAccountInformation
 * 
 * @createdBy Cesar
 * @createdDate 2024-10-18
 * @version 1.1
 */

import { LightningElement, api, track } from 'lwc';
import apex_retrieveInvestmentDetails from '@salesforce/apex/PipoController.getInvestmentDetails';
import userId from '@salesforce/user/Id';
import apex_retrieveAccountData from '@salesforce/apex/PipoController.portfolioAccountInformation';
import { NavigationMixin } from 'lightning/navigation';

export default class InvestmentViewPipo extends NavigationMixin(LightningElement) {
    @track _userId = userId; // Current user ID from Salesforce

    investorUpdates; // Variable to store investor updates
    financialDocuments; // Variable to store financial documents
    investmentCertificates; // Variable to store investment certificates
    productName; // Name of the product associated with the investment
    investmentDetails; // Stores detailed investment information

    @api recordId; // Salesforce record ID passed to the component

    @track productView; // View type of the product (e.g., grid, detailed view)
    @track productLogo; // Logo of the product
    @track investmentData; // Aggregated investment-related data

    isLoading = false; // Flag to show loading spinner
    isPending; // Flag to indicate if the investment is pending
    isActive; // Flag to indicate if the investment is active
    showUserVerification; // Flag to display user verification step

    refundRequested;
    ableToRefund = false; // Salesforce record for request Refund
    errorTitle;    

    // Data for stepper component to show investment progress
    stepperData = [ 
        {
            index: 1,
            title: 'Application received',
            status: 'completed',
            name: 'Step 1',
        },
        {
            index: 2,
            title: 'Payment received',
            name: 'Step 2',
            status: 'inactive',
        },
        {
            index: 3,
            title: 'ID verified',
            name: 'Step 3',
            shortDesc: '(if not already verified)',
            status: 'inactive',
        },
        {
            index: 4,
            name: 'Step 4',
            title: 'Investment offer closed',
            shortDesc: 'We are now settling your investment and will be in touch shortly with confirmation.',
            status: 'inactive'
        }
    ];

    /**
     * Retrieves investment details for a specific investment ID.
     * @param {string} investmentId - The ID of the investment to fetch details for.
     * @returns {Promise<void>}
     */
    async getInvestmentDetails(investmentId) {
        try {
            // Call Apex to fetch investment details
            let data = await apex_retrieveInvestmentDetails({ investmentId: investmentId });
            // Format and store the investment details
            this.investmentDetails = [
                { fieldName: 'Investment amount', value: '$' + data.InvestmentAmt.toLocaleString(), tooltip: 'The original amount you invested in this investment opportunity.' },
                { fieldName: 'Investment date', value: new Date(data.InvestmentDate).toLocaleString('en-AU', { day: '2-digit', month: 'short', year: 'numeric' }), tooltip: 'The date your investment in this opportunity is settled.' },
                { fieldName: 'Investment ID', value: data.InvestmentID, tooltip: 'The personalised reference number helps identify you as an investor and the investment opportunity you have invested in.' },
                { fieldName: 'Series', value: data.Series, tooltip: 'This refers to the phase or round of funding that relates to the product you have invested in, at that time.' },
                { fieldName: 'Sector', value: data.Sector, tooltip: 'This refers to the specific part or function of the economy that you have invested in, at that time.' },
                { fieldName: 'Term', value: data.Term, tooltip: 'This refers to the original forecast term of your investment, upon original investment. ' },
                { fieldName: 'Security Price', value: data.UnitPrice, tooltip: 'Security price represents the cost to buy one security in the associated product. This price may be different to the underlying share price of an asset.' },
                { fieldName: 'Securities Held', value: data.SecuritiesHeld, tooltip: 'Securities held refers to the financial asset, (such as units in a trust, ordinary shares, notes, etc) that you own.' },
                { fieldName: 'Holding Value', value: data.HoldingValue.toLocaleString(), tooltip: 'The holding value of an investment is its current market worth, based on VentureCrowd’s pricing policies. Any repricing occurs annually or upon a material event. Please refer to VentureCrowd’s pricing policies for more information.' }
            ];
            this.productLogo = data.ProductImage; // Store the product image URL
            this.productView = data.DistributionType || data.ProductView || null; // Determine the view type
            this.productName = data.Name; // Store the product name
            this.investmentData = { // Consolidate investment data
                productLogo: data.ProductImage,
                productView: data.DistributionType || data.ProductView || null,
                totalInvestment: data.InvestmentAmt
            };
        } catch (error) {
            console.error('Error fetching investment details:', error); // Log any errors
            throw error; // Re-throw the error to propagate it up the stack
        }
    }

    /**
     * Retrieves pending investment details for a specific investment ID.
     * @param {string} investmentId - The ID of the investment to fetch details for.
     * @returns {Promise<boolean>} - Resolves to a boolean indicating whether funds have been received.
     */
    async getPendingInvestmentDetails(investmentId) {
        try {
            // Call Apex to fetch pending investment details
            let data = await apex_retrieveInvestmentDetails({ investmentId: investmentId }); 
            // Format and store the investment details
            this.investmentDetails = [
                { fieldName: 'Application amount', value: '$' + data.InvestmentAmt.toLocaleString(), tooltip: 'Your paid or outstanding investment application amount.' },
                { fieldName: 'Application date', value: new Date(data.InvestmentDate).toLocaleString('en-AU', { day: '2-digit', month: 'short', year: 'numeric' }), tooltip: 'Date the investment application was received.' },
                { fieldName: 'Investment ID', value: data.InvestmentID, tooltip: 'Unique identifier for your investment.' },
                { fieldName: 'Series', value: data.Series, tooltip: 'The funding phase associated with this investment.' },
                { fieldName: 'Sector', value: data.Sector, tooltip: 'The economic sector related to the investment.' }
            ];
            // Track the refund to display the badge
            this.refundRequested = data.RefundRequested;
            this.productLogo = data.ProductImage; // Store the product image URL
            this.productName = data.Name; // Store the product name
            // Check if a product is not wholesale and if the refund has not been requested
            if (data.Family === 'Retail' && !data.RefundRequested) {
                this.ableToRefund = true;
            }
            return data.FundsReceived; // Return whether funds have been received
        } catch (error) {
            console.error('Error fetching pending investment details:', error); // Log any errors
            throw error; // Re-throw the error to propagate it up the stack
        }
    }

    /**
     * Retrieves and processes account data for the current user.
     * @param {string} _userId - The Salesforce user ID.
     * @returns {Promise<boolean>} - Resolves to a boolean indicating whether the user's ID is verified.
     */
    async getAccountData(_userId) {
        try {
            // Call Apex to fetch account data
            let data = await apex_retrieveAccountData({ userId: _userId });
            this.showUserVerification = !data.IdVerified; // Update user verification flag
            this.userName = data.Name; // Store the user's name
            return data.IdVerified; // Return whether the user's ID is verified
        } catch (error) {
            console.error('Error fetching account data:', error); // Log any errors
            throw error; // Re-throw the error to propagate it up the stack
        }
    }

    /**
     * Extracts query parameters from the current page's URL.
     * @returns {Promise<Object>} - Resolves to an object containing query parameters.
     */
    getQueryParameters() {
        return new Promise((resolve, reject) => {
            let params = {};
            let search = location.search.substring(1); // Extract the query string from the URL
            if (search) {
                // Parse the query string into an object
                params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
                    return key === "" ? value : decodeURIComponent(value);
                });
            }
            resolve(params); // Resolve with the parsed parameters
        });
    }

    /**
     * Lifecycle hook that executes when the component is inserted into the DOM.
     * Retrieves query parameters and fetches investment data based on the current status.
     */
    connectedCallback() {
        this.isLoading = true; // Set loading state to true
        this.getQueryParameters().then((result) => {
            let fundsReceived = false; // Flag to track funds received status
            if (result.investmentStatus === 'pending') {
                this.isPending = true; // Set pending status
                this.getPendingInvestmentDetails(this.recordId).then((data) => {
                    if (data) {
                        fundsReceived = data; // Update funds received flag
                        // Mark the second step as completed
                        this.stepperData = this.stepperData.map((step, index) => (index === 1 ? { ...step, status: 'completed' } : step));
                    }
                });
                this.getAccountData(this._userId).then((data) => {
                    if (data && fundsReceived) {
                        // Mark the third step as completed
                        this.stepperData = this.stepperData.map((step, index) => (index === 2 ? { ...step, status: 'completed' } : step));
                    }
                }).finally(() => {
                    // Reset loading state
                    this.isLoading = false;
                });
                return;
            } else if (result.investmentStatus === 'active') {
                // Set active status
                this.isActive = true; 
            }
            this.getInvestmentDetails(this.recordId).then(() => {
                // Reset loading state
                this.isLoading = false; 
            });
            // Store the record ID
            this.investmentId = this.recordId; 
        });
    }

    /**
     * Navigates the user back to the portfolio page.
     */
    handleReturnPage() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'my_portfolio__c'
            }
        });
    }

    handleErrorRefund(event) {
        event.stopPropagation();
        this.errorTitle = "There is an error processing your refund request.";
        this.template.querySelector('c-core-toast-message').showToast()
    }

    handleSuccessRefund(event) {
        event.stopPropagation();
        this.refundRequested = true;
        
    }
}