/**
 * RaiseManageStatisticCards Component
 * @description This component is responsible for displaying summary statistics related to a raise, such as the number of leads, opportunities, and days left. It fetches the required data from the server and updates the UI accordingly. The component also provides a navigation button to access resources related to the capital raising process.
 * 
 * @example
 * <c-raise-manage-statistic-cards ids={summaryDetailIds}></c-raise-manage-statistic-cards>
 */

import { LightningElement, api , track} from 'lwc';
import ventureCrowdTheme from "@salesforce/resourceUrl/ventureCrowdTheme";
import apex_getStats from "@salesforce/apex/RaiseController.getSummaryStatistics";
import { NavigationMixin } from 'lightning/navigation';

export default class RaiseManageStatisticCards extends NavigationMixin(LightningElement) {
    @track raiseId; // The ID of the raise.
    @track eoiId; // The ID of the expression of interest.
    @track hasLoaded = false; // Indicates whether the data has been loaded.
    @track stats; // Stores the summary statistics.

    needHelpImgSrc = ventureCrowdTheme + '/Images/raiseMgmtNeedHelp.png'; // Image source for the help section.

    /**
     * Gets the IDs related to the raise.
     * @returns {Object} An object containing the raiseId and eoiId.
     */
    @api 
    get ids(){
        return {
            raiseId : this.raiseId,
            eoiId : this.eoiId,
        }
    }
    /**
     * Sets the IDs related to the raise and fetches the statistics if not already loaded.
     * @param {Object} v - The object containing raiseId and eoiId.
     */
    set ids(v){
        this.raiseId = v?.raiseId;
        this.eoiId = v?.eoiId;
        if(!this.hasLoaded && this.raiseId && this.eoiId){
            this.getStats(this.raiseId, this.eoiId).then((result)=>{
                this.stats = {...result};
                this.updateCardData();
            }).finally(()=>{
                this.hasLoaded  = true;
            });
        }
    };

    /**
     * Updates the statistics displayed on the cards.
     */
    updateCardData(){
        this.cards.forEach(card => {
            if(card.name==='leads'){
                card.statistic = this.stats?.leads;
            }

            if(card.name==='opportunities'){
                card.statistic = this.stats?.opportunities;
            }

            if(card.name==='daysLeft'){
                card.statistic = this.stats?.daysLeft;
            }
        })
    }

    @track cards = [
        {
            name:"leads",
            iconName:"circleStar",
            statistic:"N/A",
            label:"Leads",
        },
        {
            name:"opportunities",
            iconName:"tickCircleDone",
            statistic:"N/A",
            label:"Opportunities",
        },
        {
            name:"daysLeft",
            iconName:"timer",
            statistic:"N/A",
            label:"Days left!",
        },
    ]


    /**
     * Fetches summary statistics for the specified raise and EOI IDs.
     * @param {string} raiseId - The ID of the raise.
     * @param {string} eoiId - The ID of the expression of interest.
     * @returns {Promise} A promise that resolves to the summary statistics.
     */
    getStats(raiseId, eoiId){
        return new Promise(async(resolve,reject)=>{
            let returnData = await apex_getStats({raiseId : raiseId, eoiId: eoiId});
            resolve(returnData);
        })
    }

    /**
     * Navigates to the Capital Raising 101 resource page.
     * @param {Event} e - The event that triggered the navigation.
     */
    handleAccessResources(e){
        e.preventDefault()
        this[NavigationMixin.Navigate]({
            // Define navigation type and target page name
            type: 'comm__namedPage',
            attributes: {
                name: 'Capital_Raising_101__c' // Page name for my Companies
            },
            state:{
                id : this.raiseId
            }
        });
    }
}