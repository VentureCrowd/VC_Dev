/**
 * @description LWC for the yielding distributions view - PIPO Project
 * @dependencies LWC coreLoadingSpinner,coreBadges,coreTooltip,coreIcon,coreModal,coreCard
 * @createdBy Cesar
 * @createdDate 2024-10-18
 * @version 1.1
 */

import { LightningElement, api, track } from 'lwc';
import apex_retrieveDistributions from '@salesforce/apex/PipoController.getInvestmentTransactions';

export default class PipoYieldingView extends LightningElement {
    @api companyName; // Name of the company
    @api productView; // View or details of the product
    @api productLogo; // Logo of the product
    @api investmentId; // Unique identifier for the investment

    // Spotlight views
    totalDistributions; // Total distributions amount
    latestDistributions; // Amount of the latest distribution
    yieldingValue; // Yielding percentage value
    iconColor;
    totalInvestment; // Total investment amount

    @track _investmentData; // Stores investment data with reactive tracking
    isLoading = false; // Indicates if the component is loading data
    yieldingView = false; // Stores the current yielding view details
    transactionsData; // Stores the processed transactions data
    hideOpenButton = false;
    /**
     * Setter for investment data. Performs operations when the value is updated.
     * @param {Object} value - The investment data object.
     */
    @api
    set investmentData(value) {
        if (value) {
            this._investmentData = value;
        }
    }

    /**
     * Getter for investment data.
     * @returns {Object} The current investment data.
     */
    get investmentData() {
        return this._investmentData;
    }

    // Mapping for yielding types with their respective configurations
    yieldingMapping = {
        'Int_IP': {
            spotlightView: true,
            iconName: 'dollarCircle',
            label: 'Interest paid',
            color: '#27B48A',
            backgroundColor: '#D9FFE5',
            helpText: 'This is interest paid out directly to you in cash. This is deposited into your nominated bank account.'
        },
        'Int_ACC': {
            spotlightView: true,
            iconName: 'accruing',
            label: 'Accruing interest',
            color: '#407FFF',
            backgroundColor: '#E2EBFF',
            helpText: 'An Accruing distribution means that interest is earned but not yet paid out. The amount accumulates over time and may be paid at a later date or upon specific conditions being met. If you have multiple Accrued distributions, these may be paid out as one lump sum.'
        },
        'Int_COM': {
            spotlightView: false,
            iconName: 'compounding',
            label: 'Compounding Interest',
            color: '#F3A73B',
            backgroundColor: '#FFEDC8',
            helpText: 'Compounding distributions are reinvested back into the investment rather than paid out, allowing you to earn returns on both the original investment and the reinvested distributions. For your latest remittance advice, please check your emails.'
        },
        'Int_CAP': {
            spotlightView: false,
            iconName: 'clockCircle',
            label: 'Capitalised Interest',
            color: '#D95BAA',
            backgroundColor: '#F9E6F2',
            helpText: 'Capitalised distributions are paid on completion (or redemption). For your latest remittance advice, please check your emails.'
        },
        'Red_PT': {
            spotlightView: true,
            iconName: 'dollarCircle',
            label: 'Partially redeemed',
            color: '#CFCECC',
            backgroundColor: '#F0F1F2',
            helpText: 'A portion of the investment has been redeemed, meaning you have received part of the investment back as cash, while the remaining portion continues to be invested.'

        },
        'Red_FULL': {
            spotlightView: false,
            iconName: 'dollarCircle',
            label: 'Fully redeemed',
            color: '#CFCECC',
            backgroundColor: '#F0F1F2',
            helpText: 'This means your original investment has either been paid out in full, your holding has been transferred to another nominee or has been rolled into another product and this one has closed.'
        }
    };

    /**
     * Retrieves distribution data for a specific investment ID from the Apex controller.
     * Processes the data and updates component variables.
     *
     * @param {string} investmentId - The unique identifier of the investment.
     * @returns {Promise<void>} A promise that resolves once the data has been retrieved and processed.
     */
    async getDistributionsData(investmentId) {
        try {
            const data = await apex_retrieveDistributions({ investmentId: investmentId });
            if (!data || data.length === 0) {
                return;
            }

            // Map transactions with yielding data and format the transaction amount
            this.transactionsData = data.map(transaction => {
                const yieldingData = this.yieldingMapping[transaction.YieldingType];
                return {
                    ...transaction,
                    ...yieldingData,
                    formatNumber: this.formatNumber(transaction.TransactionAmount)
                };
            });
            // Update yielding view with the first transaction's data
            this.yieldingView = this.transactionsData[0];
            this.iconColor = 'color: ' + this.yieldingView.color + ';';
            // Calculate total distributions and yielding value for interest paid or accruing ones
            let sumDistributions = data
            .filter(item => item.YieldingType === ('Int_IP'))
            .reduce((acc, curr) => acc + curr.TransactionAmount, 0);
            let lastDistribution = data[0].TransactionAmount;
            const investmentValue = this.investmentData.totalInvestment;
            let yieldValue = (sumDistributions / investmentValue) * 100;

            // Assign values to variables
            this.yieldingValue = yieldValue.toFixed(2);
            this.totalDistributions = this.formatNumber(sumDistributions);
            this.latestDistributions = this.formatNumber(lastDistribution);
        } catch (error) {
            console.error(error);
        }
    }

    /**
     * Formats a number with two decimal places and comma separators.
     *
     * @param {number} value - The number to format.
     * @returns {string} The formatted number as a string.
     */
    formatNumber(value) {
        return value.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
    }

    /**
     * Lifecycle hook executed when the component is inserted into the DOM.
     * Initiates data retrieval for distributions.
     */
    connectedCallback() {
        if (window.innerWidth < 768) {
            this.hideOpenButton = true;
        }
        this.isLoading = true;
        this.getDistributionsData(this.investmentId).finally(() => {
            this.isLoading = false;
        });
    }


    handleOpenModal() {
        this.refs.coremodal.openModal();
    }
}