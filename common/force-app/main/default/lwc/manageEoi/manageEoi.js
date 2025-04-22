// Importing necessary decorators and modules from LWC
import { LightningElement, wire, track , api} from 'lwc';
// Importing the NavigationMixin module for navigating to different pages
import { NavigationMixin } from 'lightning/navigation';
// Importing CurrentPageReference to get current page reference
import { CurrentPageReference } from 'lightning/navigation';
// Importing the ShowToastEvent module for displaying toast notifications
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// Importing Apex methods for updateEoi, getInterestesLeads , getEoiDetails and Utility
import getEoiDetails from '@salesforce/apex/MyEOIController.getEoiDetails';
import updateEoi from '@salesforce/apex/MyEOIController.updateEoi';
import getInterestesLeads from '@salesforce/apex/MyEOIController.getInterestesLeads';
import { loadStyle } from 'lightning/platformResourceLoader';
import VC_MasterCss_New from '@salesforce/resourceUrl/VC_MasterCss_NewTemp';
import { Utility } from 'c/utils'

import apex_checkAccess from '@salesforce/apex/SecurityController.checkEoiAccess';


export default class ManageEoi extends NavigationMixin(LightningElement) {
    companyAccountName = '';
    @track eoiId;
    @track valueOfInvestmentInterest;
    @track interestedLeads;
    @track leadsExpressedInterest;
    @track publlishedEoiUrl;
    @track eoiProgress;
    @track wiredLst;
    @track targetRaise;
    @track endDate;
    @track havingInterestedLeads = false;
    @track showActions = false;
    @track showRequestEditPopup = false;
    @track showCloseEoiPopup = false;
    @track showConfirmSubmitMessage = true;
    @track checkbox1 = false;
    @track checkbox2 = false;
    @track showspinner = true;
    @track showProgress = false;
    @api companyId;

    eoiAccessError = false;
    
    dynamicProgress;

    leadsHeaders ={
        Name:"Name",
        Email:"Email",
        MobilePhone:"Mobile",
        Investment_Amount_Currency__c:"Investment Amount",
        // Status:"Status",
        CreatedDate:"Created Date",

    }

    // datatable columns
    columns = [
        { label: 'Name', fieldName: 'Name', type: 'text' },
        { label: 'Email', fieldName: 'Email', type: 'email' },
        { label: 'Mobile', fieldName: 'MobilePhone', type: 'phone' },
        // { label: 'Investment Range', fieldName: 'Investment_Amount__c', type: 'text' },
        { label: 'Investment Amount', fieldName: 'Investment_Amount_Currency__c', type: 'currency' },
        // {label: 'Minimum Investment Amount', fieldName: 'Min_Investment__c', type: 'currency'},
        // { label: 'Status', fieldName: 'Status', type: 'picklist' },
        { label: 'Created Date', fieldName: 'CreatedDate', type: 'date' , typeAttributes:{day:'numeric',month:'short',year:'numeric', hour:'2-digit',minute:'2-digit',hour12:true}}
    ];
    
    // wire method which get eoi id from currentPageReference
    @wire(CurrentPageReference)
    async getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.eoiId = currentPageReference.state.id;
            this.showspinner = true;
            // check if the logged in user is the owner of the raise
            if(this.eoiId){
                this.eoiAccessError = await apex_checkAccess({eoiId : this.eoiId}).then((result)=>{                    
                    return !result;
                }).catch((err)=>{
                    console.error('Error checking raise access!', JSON.stringify(err));
                    return true;
                })
            }
            this.showspinner = false;

        }
    }

    // method to details to currect eoi   
    @wire(getEoiDetails, { eoiId: '$eoiId' })
    wiredData(result) {
        this.wiredEoiData = result;
        if (result.data) {
            this.companyAccountName = result.data.Account__r.Name;
            this.companyId = result.data.Account__r.Id
            this.leadsExpressedInterest = result.data.Leads_expressed_interest__c;
            this.publlishedEoiUrl = result.data.Published_EOI_URL__c;
            let finalNumber;
            if(result && result.data.Value_of_investment_interest__c) { 
                finalNumber= result.data.Value_of_investment_interest__c.toLocaleString('en-US');
            }
            this.valueOfInvestmentInterest = finalNumber;
            let formatTargetRaise = result.data.Target_Raise_Amount__c.toLocaleString('en-US');
            this.targetRaise = formatTargetRaise;
            if(this.targetRaise && this.targetRaise != null) { 
                this.showProgress = true;
            }
            // calculate progress width
            this.eoiProgress = result.data.EOI_Progress__c;
            let progressStyle = "width:" + this.eoiProgress +'%;' + 'border-radius:0.9375rem;' ;
            this.dynamicProgress = progressStyle;
            let date;
            let dateObject;
            let formattedDateString
            if(result && result.data.EOI_Published_Date__c) { 
                date = result.data.EOI_Published_Date__c;
                dateObject = new Date(date);
                formattedDateString = dateObject.toLocaleDateString("en-GB");
            }
            this.endDate = formattedDateString;
        } else if (result.error) {
            console.error('Error fetching eoi detail', result.error);
        }

        this.showspinner = false;
    }

    // // get interestedLeads - we show this leads in datatabale
    // @wire(getInterestesLeads, { eoiId: '$eoiId' })
    // interestedLeads(result) {
    //     if (result.data) {
    //         if(result.data.length){
    //             this.interestedLeads = result.data
    //             this.havingInterestedLeads = true;

    //             console.log(JSON.stringify(this.interestedLeads));
    //         } else{
    //             this.havingInterestedLeads = false;
    //         }
            
    //     } else if (result.error) {
    //         this.havingInterestedLeads = false;
    //         console.error('Error fetching Interested Leads', result.error);
    //     }
    // }

    // load required styles
    async connectedCallback() { 
        Promise.all( [
            loadStyle( this, VC_MasterCss_New )
        ] ).then( () => {
            // console.log( 'CSS New Files loaded' );
        } )
        .catch( error => {
            if(error && error.body && error.body.message) {
                console.log( error.body.message );
            } else {
                console.log('error in loading VC_MasterCss_New style', error);
            }
        } );


        this.retrieveLeads();
    }

    async retrieveLeads(){
        try{
            const result = await getInterestesLeads({eoiId  : this.eoiId});
            // console.log('aftergetleads',JSON.stringify(result))
            if (result.length > 0) {
                this.interestedLeads = [...result]
                this.havingInterestedLeads = true;

                // console.log(JSON.stringify(this.interestedLeads));
              
                
            } else {
                this.havingInterestedLeads = false;
                console.error('Error fetching Interested Leads', result.error);
            }
        }catch(error){
            console.error(error)
        }
    }

    // handle download CSV
    downloadList(){
        Utility.exportCSVFile(this.leadsHeaders, this.interestedLeads, "leads list")
    }
    // show actions (Copy page URL,Request edits, Close permanently)
    openActions() { 
        this.showActions = !this.showActions;
    }

    copyPageUrl() {
        if (this.publlishedEoiUrl) {
            // Create a textarea element
            const textarea = document.createElement('textarea');
    
            // Set the value of the textarea to the URL you want to copy
            textarea.value = this.publlishedEoiUrl;
    
            // Append the textarea to the document
            document.body.appendChild(textarea);
    
            // Select the text inside the textarea
            textarea.select();
    
            try {
                // Execute the copy command
                document.execCommand('copy');
                this.showtoast('Link Copied to Clipboard', 'success');
            } catch (err) {
                this.showActions = false;
                console.error('Unable to copy to clipboard', err);
                this.showtoast('Unable to copy link to clipboard', 'error');
            } finally {
                // Remove the textarea from the document
                document.body.removeChild(textarea);
                this.showActions = false;
            }
        } else {
            this.showActions = false;
            this.showtoast('URL is not available', 'error');
        }
    }
    
    // method to show request edit popup 
    requestEdit() { 
        this.showRequestEditPopup = true;
        this.showActions = false;
    }
    // method to show close eoi popup 
    closeEoi() { 
        this.showCloseEoiPopup = true;
        this.showActions = false;
    }

    // method to close popup models
    closePopup() { 
        this.showCloseEoiPopup = false;
        this.showRequestEditPopup = false;
        this.showConfirmSubmitMessage = true;
    }

    // handle checkbox clicks
    handleCheck(event) { 
        if(event.target.name == 'checkbox1') { 
            this.checkbox1 = event.target.checked;
        }

        if(event.target.name == 'checkbox2') { 
            this.checkbox2 = event.target.checked;
        }

        if(this.checkbox1 && this.checkbox2) { 
            this.showConfirmSubmitMessage = false;
        } else { 
            this.showConfirmSubmitMessage = true;
        }
    }

    // method to handle close EOI 
    handleCloseEOI() {
        if(this.checkbox1 && this.checkbox2) { 
            this.showspinner = true;
            let datamap = {};
            // set EOI_Status__c to Closed
            datamap['EOI_Status__c'] = 'Closed';
             // calling apex method to update  EOI_Status__c
            updateEoi({
                  datamap,
                  eoiId: this.eoiId
               })
               .then((r) => {
                  if (r == 'Success') {
                    this.showtoast('EOI  Closed Successfully', 'success');
                    this.showspinner = false;
                    this[NavigationMixin.Navigate]({
                        type: 'comm__namedPage',
                        attributes: {
                            name: 'my_companies__c'
                        }
                    });
                  } else {
                    this.showspinner = false;
                    this.showtoast('Error in close EOI ', 'error');
                  }
               })
               .catch((e) => {
                this.showspinner = false;
                  this.showtoast('Error in close EOI ', 'error');
            });
        }
    }

    // method to open live page in new window
    viewLivePage() { 
        if(this.publlishedEoiUrl) { 
            window.open(this.publlishedEoiUrl, "_blank");
        } else { 
            this.showtoast('Unable to find live expression of interest page', 'error');
        }
    }

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