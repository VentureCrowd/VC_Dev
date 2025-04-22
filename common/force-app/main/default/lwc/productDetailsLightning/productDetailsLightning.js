import { LightningElement,track,api,wire } from 'lwc';
import { getRecord,updateRecord } from 'lightning/uiRecordApi';
import initDataMethod from "@salesforce/apex/RelatedListController.initData";
import createCreation from "@salesforce/apex/RelatedListController.createCreation";
import search from "@salesforce/apex/RelatedListController.search";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import PRODUCT_IMAGES from '@salesforce/resourceUrl/ProductImages';

const FIELDS = ['Masterplan__c.Plan_URL__c','Masterplan__c.Forecast_Registration_Date__c'];
export default class ProductDetailsLightning extends LightningElement {
    @track state = {};
    @track productData;
    @track retrievedData;
    @track showSubmission = false;
    @track showLoading = false;

    availableStatus = 'Available';
    intrestStatus = 'Expression Of Interest';
    soldStatus = 'Sold Out';
    reservedForDisplayStatus = 'Reserved for Display Home';
    draftStatus = 'Draft';
    reservedStatus = 'Reserved for Put and Call';
    reservedForBHandLP = 'Reserved for builder house and land package'
    


    @api notifyViaAlerts = false;

    isMultiEntry = false;
    maxSelectionSize = 4;
    initialSelection = [
        // {
        //     id: 'na',
        //     sObjectType: 'na',
        //     icon: 'standard:lightning_component',
        //     title: 'Inital selection',
        //     subtitle: 'Not a valid record'
        // }
    ];
    errors = [];
    recentlyViewed = [];
    newRecordOptions = [
    ];
    

    @wire(getRecord, { recordId: '$staggingPlanId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (data) {
            this.planUrl = data.fields.Plan_URL__c.value;
            this.registrationDate = data.fields.Forecast_Registration_Date__c.value;
        }else {
            console.log(error);
        }
    }

    @track showModal = false
    @api invokedFromVf = false;
    @track showPlan = false
    @track showProducts = false;
    @track planUrl;
    @track registrationDate;
    @track availableImage;
    @track inProgressImage;
    @track closedImage;
    @track reservedImage;
    @track reservedBHLPImage;
    @track brandLogo;
    recordId;
    masterPlanId;
    staggingPlanId;
    selectedProduct;


    //Connected callback
    connectedCallback() {
        let params    = new URLSearchParams(document.location.search.substring(1));
            this.recordId  = params.get("c__recordId") ? params.get("c__recordId") : this.recordId
            this.showModal  = params.get("c__showModal") ? params.get("c__showModal") : this.showModal

            this.availableImage = PRODUCT_IMAGES + '/Images/Available.jpeg';
            this.inProgressImage = PRODUCT_IMAGES + '/Images/InProgress.jpeg';
            this.closedImage = PRODUCT_IMAGES + '/Images/Closed.jpeg';
            this.reservedImage = PRODUCT_IMAGES + '/Images/Reserved.jpeg';
            this.reservedBHLPImage = PRODUCT_IMAGES + '/Images/reservedForBHandLP.jpeg';
            this.brandLogo = PRODUCT_IMAGES + '/Images/BrandLogo.jpeg';
    }    

    //Rendered Callback
    renderedCallback() {
        
    }

    @api show() {
        this.showModal = true;
    }

    handleClose() {
        this.showModal = false;     
        window.close();
    }
    handleDialogClose(){
        if(this.invokedFromVf) {
            window.location.assign(`${window.location.origin}/${this.recordId}`);
        }
        this.dispatchEvent(new CustomEvent('refreshdata'));
        this.handleClose();
        this.masterPlanId = null;
                    this.planUrl = null;
                    this.productData = null;
                    this.showLoading = false;
                    this.showPlan = false;
    }

    handleMasterPlanIdChange(event) {
        this.masterPlanId = event.detail.value[0];
        if (this.staggingPlanId) {
            this.template.querySelector('c-lookup').handleRemoveSelectiton(this.staggingPlanId);
            this.staggingPlanId = '';
            this.handleStagingPlanIdChange('');
        }
    }

    handleStagingPlanIdChange(stgId) {
        let updatedStaggingPlanId = stgId;
        this.showPlan = updatedStaggingPlanId ? true : false;
        this.state.recordId = updatedStaggingPlanId;
        this.state.showRelatedList = true;
        this.state.fields = 'Name,Status__c,Product_Number__c';
        this.state.relatedFieldApiName = 'Masterplan__c';
        // this.state.numberOfRecords = 100;
        this.state.sobjectApiName = 'Product2';
        this.state.sortedBy = 'Product_Number__c';
        this.state.sortedDirection = 'ASC';

        if (!this.showPlan) {
            this.planUrl = '';
            this.registrationDate = '';
        }
        
        let jsonData = Object.assign({}, this.state)
        // jsonData.numberOfRecords = this.state.numberOfRecords + 1
        jsonData = JSON.stringify(jsonData)
        initDataMethod({ jsonData })
            .then(response => {
                const data = JSON.parse(response)
                this.productData  = data.records.filter(ele => ele.Status__c && ele.Status__c != this.draftStatus ).map(x => {
                    let obj = {...x};
                        obj.link = `${window.location.origin}/${obj.Id}`;
                    return obj;
                  });
                this.productData.forEach(ele => {
                    ele.displayAvailable = false;
                    ele.displayInprogress = false;
                    ele.displayClosed = false;
                    ele.displayReserved = false;
                    // reservedImage
                    ele.displayReservedBHLP = false;
                    ele.displayDetails = false;
                    ele.itemSelected = false;
                    if(!ele.Status__c || ele.Status__c == this.availableStatus) ele.displayAvailable = true;
                    if(ele.Status__c && ele.Status__c == this.intrestStatus) ele.displayInprogress = true;
                    if(ele.Status__c && ele.Status__c == this.reservedStatus) ele.displayReserved = true;
                    if(ele.Status__c && ele.Status__c == this.reservedForBHandLP) ele.displayReservedBHLP = true;
                    if(ele.Status__c && (ele.Status__c == this.soldStatus || ele.Status__c == this.reservedForDisplayStatus)) ele.displayClosed = true;
                    
                })
                this.retrievedData = [...this.productData];
                this.showProducts = this.productData ? true : false;
                this.masterPlanId = updatedMasterPlanId;
            })
            .catch(error => {
                console.log(error);
            });
    }

    handleProductMouseover(event) {

        this.productData.forEach(ele => {
            if(ele.Id == event.currentTarget.dataset.value ) {
                ele.displayDetails = true;
            }
        })        
        

    }

    handleProductMouseout(event) {
        this.productData.forEach(ele => {
            if(ele.Id == event.currentTarget.dataset.value ) {
                ele.displayDetails = false;
            }
        })
    }

    handleProductSelection(event) {

        let currentElement = event.currentTarget.dataset.product;

        //Validate if selected product is Sold (opp- closed)
        let filteredData =  this.productData.filter(ele => ele.Id == currentElement);

        if (filteredData && (filteredData[0].Status__c == this.soldStatus || filteredData[0].Status__c == this.reservedForDisplayStatus || filteredData[0].Status__c == this.reservedForBHandLP)) {
         this.dispatchEvent(
             new ShowToastEvent({
                 title: 'Sold Product',
                 message: 'This product is sold and can\'t be selected!!',
                 variant: 'warning'
             })
         );
         return;
        }

        //Mark item as selected
        this.productData.forEach(ele => {
            if (ele.Id == currentElement) {
                this.selectedProduct = currentElement
                ele.itemSelected = true;
                this.showSubmission = true;
            } else {
                ele.itemSelected = false;
            }
        })
        
    }

    async handleProceed() {

        this.showLoading = true;
        
        //Opportunity TO be Updated
        const oppFields = {};
            oppFields['Id'] = this.recordId;

        const OpportunityFields = { fields: oppFields };

        //Line Item Record Input Fields (to be Created)
        const lineItemFields = {};
        lineItemFields['OpportunityId'] = this.recordId;
        lineItemFields['Product2Id'] = this.selectedProduct;
        lineItemFields['Quantity'] = 1;
        lineItemFields['UnitPrice'] = 1;
        // lineItemFields['PricebookEntryId'] = PRICE_BOOK_ID; 
            
        try {
            
            const processedLineItem = await createCreation({'lineItemRecord':lineItemFields});
            getRecordNotifyChange([{recordId: this.recordId}]);
            window.close();

        }
        catch (error) {
            console.log('toast');
            this.showLoading = false;
        }
    }


    handleKeyUp(evt) {
        let inputString = new RegExp(evt.target.value, 'gi')
        
        if (evt.target.value) {
            let filteredData = [...this.productData.filter(ele => ele.Product_Number__c?.match(inputString))];
            this.productData = [...filteredData];
        } else {
            this.productData = [...this.retrievedData];
        }
    }

    handleLookupSearch(event) {
        const lookupElement = event.target;
        event.detail.selectedIds = [this.masterPlanId];
        // Call Apex endpoint to search for records and pass results to the lookup
        search(event.detail)
            .then((results) => {
                lookupElement.setSearchResults(results);
            })
            .catch((error) => {
                this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
                // eslint-disable-next-line no-console
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
    }

    /**
     * Handles the lookup selection change
     * @param {event} event `selectionchange` event emmitted by the lookup.
     * The event contains the list of selected ids.
     */
    // eslint-disable-next-line no-unused-vars
    handleLookupSelectionChange(event) {
        debugger;
        console.log(event);
        this.staggingPlanId = event?.detail[0];
        this.handleStagingPlanIdChange(this.staggingPlanId);
        if (!this.staggingPlanId ) {
            this.handleStagingPlanIdChange('');
        }
    }
}