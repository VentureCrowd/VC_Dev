/**
 * RaiseManageContainer Component
 * @description This component manages the user interface for viewing and managing the details of a raise. It fetches and displays relevant raise data, including the company logo, raise progress, and statistics. It also provides navigation options to view the deal page and close the raise.
 */

import { LightningElement, track, api } from 'lwc';
import apex_getRaiseDetails from '@salesforce/apex/RaiseController.getRaiseDetails';
import apex_getImageUrl from '@salesforce/apex/FileUploadController.getDocumentsUrl';
import apex_updateRaiseData from '@salesforce/apex/RaiseController.updateRaiseDetails';
import apex_checkAccess from '@salesforce/apex/SecurityController.checkRaiseAccess';
// import apex_getRelatedAccounts from '@salesforce/apex/RaiseController.getRelatedAccounts';

import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// raise manage n track container
export default class RaiseManageContainer extends NavigationMixin(LightningElement)  {
    @track raiseId; // The ID of the raise.
    @track raiseData; // Stores the raise data.
    @track eoiId; // Expression of interest ID.
    @track raiseLaunchDate; // Launch date of the raise.
    
    @track companyName; // Name of the company.
    @track companyLogoUrl; // URL of the company logo.
    @track summaryDetailIds; // Stores summary detail IDs.
    @track valuesProgressBar = { minimumTarget: 0, RaisedAmount: 0 }; // Values for the progress bar.

    @track raiseAccessError = false;

    isLoading = true; // Indicates whether the component is in a loading state.
    /**
     * Handles the component's initialization and fetches necessary data when the component is inserted into the DOM.
     */
    connectedCallback(){
        // get raise data
        this.getQueryParameters().then((result)=>{
            this.isLoading = true;
            let raiseId = result.id
            this.raiseId = raiseId
            this.getRaiseDetails(result.id).then(async (raiseData)=>{
                this.raiseData = JSON.parse(raiseData);
                
                // check raise owner
                this.raiseAccountOwner = this.raiseData?.account;
                
                // check if the logged in user is the owner of the raise
                this.raiseAccessError = await apex_checkAccess({raiseId : this.raiseId}).then((result)=>{                    
                    return !result;
                }).catch((err)=>{
                    console.error('Error checking raise access!');
                    return true;
                })
               
                // Update values -
                let targetAmt = 0;
                if(this.raiseData.investmentType === 'Wholesale'){
                    targetAmt = this.raiseData.targetAmt;
                }else if(this.raiseData.investmentType === 'Retail'){
                    targetAmt = this.raiseData.minTarget;
                } 

                this.valuesProgressBar = { minimumTarget: parseInt(targetAmt), RaisedAmount: this.raiseData.amountRaised ?parseInt(this.raiseData.amountRaised) : 0  };
                this.raiseLaunchDate = this.raiseData.launchDate;
                this.companyName = this.raiseData.companyName;
                this.eoiId = this.raiseData.eoi;
                this.summaryDetailIds = {
                    raiseId : this.raiseId,
                    eoiId : this.eoiId,
                }
                // get company image
                this.getCompanyLogo(this.raiseId).then((result)=>{
                    this.companyLogoUrl = result;
                }).catch((err)=>console.error(err))


            }).catch((err)=>{
                console.error('Error fetching raise details');
            }).finally(()=>{
                this.isLoading = false;
            })
        }).catch((err)=>{
            console.error('Error fetching query parameters');
            this.isLoading = false;
        })



    }

    /**
     * Fetches the company logo URL based on the provided raise ID.
     * @param {string} raiseId - The ID of the raise.
     * @returns {Promise} A promise that resolves to the company logo URL.
     */
    async getCompanyLogo(raiseId){
        return new Promise(async(resolve,reject)=>{
            let imageUrlList = await apex_getImageUrl({fieldName:'companyLogoId', recordId:raiseId});
            if(imageUrlList.length > 0){
                resolve(imageUrlList[0].publicDownloadUrl);
            }else{
                reject('No company logo is attached to this Raise');
            }
        })
    }

    /**
     * Fetches the raise details for the specified raise ID.
     * @param {string} raiseId - The ID of the raise.
     * @returns {Promise} A promise that resolves to the raise details.
     */
    async getRaiseDetails(raiseId){
        return new Promise(async (resolve,reject)=>{
            let raiseDetails = await apex_getRaiseDetails({raiseId : raiseId});
            resolve(raiseDetails);
        })
    }
    /**
     * Retrieves query parameters from the URL.
     * @returns {Promise} A promise that resolves to an object containing the query parameters.
     */
    getQueryParameters() {
        return new Promise((resolve,reject)=>{
            var params = {};
            var search = location.search.substring(1);

            if (search) {
                params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
                    return key === "" ? value : decodeURIComponent(value)
                });
            }
            resolve(params);
        })
        
    }

    /**
     * Navigates back to the "My Companies" page.
     * @param {Event} event - The event that triggered the navigation.
     */
    returnToCompanies(event) {
        this[NavigationMixin.Navigate]({
            // Define navigation type and target page name
            type: 'comm__namedPage',
            attributes: {
                name: 'my_companies__c' // Page name for my Companies
            }
        });
    }

    /**
     * Navigates to the deal page for the current raise.
     * @param {Event} event - The event that triggered the navigation.
     */
    handleViewDealPage(e){
        e.preventDefault()
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId : this.raiseId,
                objectApiName : 'Raise__c',
                actionName : 'view'
            },
        })
    }

    /**
     * Handles the close raise action, updating the raise status to 'Closed'.
     * @param {Event} event - The event that triggered the action.
     */
    handleCloseRaise(e){
        e.preventDefault()
        this.isLoading = true;
        this.closeRaise(this.raiseId).then((res)=>{
            return res;
        }).catch(()=>{
            this.isLoading = false;
            this.showToast('Error', 'Error closing raise. Please contact your system admin', 'error');
        }).finally(()=>{
            this.isLoading = false;
            this.showToast('Success', 'Raise closed successfully', 'success');
        })
    }

    /**
     * Closes the raise by updating its status to 'Closed'.
     * @param {string} raiseId - The ID of the raise.
     * @returns {Promise} A promise that resolves to the result of the update operation.
     */
    closeRaise(raiseId){
        return new Promise(async(resolve,reject)=>{
            try{
                const closeData = {
                    status : 'Closed'
                }
                let result = await apex_updateRaiseData({raiseId : raiseId, fieldsToUpdate : closeData});
                resolve(result);
            }catch(err){
                reject(err);
            }
           
        })
    }

    /**
     * Displays a toast message.
     * @param {string} title - The title of the toast message.
     * @param {string} message - The message content of the toast.
     * @param {string} variant - The variant of the toast message, e.g., 'error', 'success'.
     */
    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(toastEvent);
    }

    handleContactUs(event){
        window.location.href = 'tel:1300039655';
    }
}