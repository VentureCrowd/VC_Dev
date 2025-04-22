/**
 * coreDataTable Component
 * @description The `coreDataTable` component is a customizable Lightning Web Component designed to display 
 * and manage tabular data within Salesforce. It provides functionality for data fetching, sorting, pagination, 
 * and inline editing. This component is ideal for scenarios where users need to view, sort, and edit data 
 * within a table format, such as displaying a list of records, paginating through large datasets, enabling 
 * inline editing, and providing sorting capabilities.
 * @example
 * <c-core-data-table
 *     record-id="001xxxxxxx"
 *     apex-method={apexMethod}
 *     update-method={updateMethod}
 *     object-name="Contact"
 *     picklist-fields={picklistFields}
 *     columns={columns}
 *     page-size="10">
 * </c-core-data-table>
 */
import { LightningElement, api, track, wire } from 'lwc';
import apex_getPicklistValues from '@salesforce/apex/RaiseController.getPicklistValues';
// NOTE: the apex method to retrieve records must follow the same format as the OpportunitiesController.getRecords to work with this datatable
// 
export default class CoreDataTable extends LightningElement {
     /**
     * Record ID - The ID of the record being displayed
     * @type {string}
     */
    @api recordId

    /**
     * Record Data - Data of the records to be displayed in the datatable
     * @type {Array}
     */
    @api _recordData = [];
    get recordData(){
        return this._recordData;
    }

    set recordData(v){
        this._recordData = v;
        if(this._recordData?.records.length > 0){
            this.formatData(this._recordData);

        }
    }

     /**
     * Data - Formatted data to be displayed in the datatable
     * @type {Array}
     */
    @track data = [];

    /**
     * Apex Method - Method to fetch records
     * @type {Function}
     */
    @api apexMethod;

    /**
     * Update Method - Method to update records
     * @type {Function}
     */
    @api updateMethod;

    /**
     * Object Name - The name of the object being queried
     * @type {string}
     */
    @api objectName;


    /**
     * Picklist Fields - Fields that require picklist values
     * @type {Array}
     */
    @api picklistFields =[]

    /**
     * Page Size - Number of records to be displayed per page
     * @type {number}
     */
    @api pageSize = 10;

     /**
     * Columns - Columns to be displayed in the datatable
     * @type {Array}
     */
    @api columns = [];

    /**
     * Page - Current page number
     * @type {number}
     */
    @track page = 1;
    @track callBackOptions;
    @track founderStatusOptions;
    /**
     * Total Records - Total number of records
     * @type {number}
     */
    @track totalRecords;

    /**
     * Total Pages - Total number of pages
     * @type {number}
     */
    @track totalPages;

     /**
     * Sorted By - Field by which the records are sorted
     * @type {string}
     */
    @track sortedBy;

    /**
     * Sorted Direction - Direction of sorting (asc or desc)
     * @type {string}
     */
    @track sortedDirection = 'asc';

    /**
     * Loading Indicator - Shows loading spinner
     * @type {boolean}
     */
    @track _isLoading = false;
    get isLoading(){
        return this._isLoading;
    }
    set isLoading(v){
        this._isLoading = v;
        
    }

    /**
     * Saving Indicator - Shows saving spinner
     * @type {boolean}
     */
    @track _isSaving = false;
    get isSaving(){
        return this._isSaving;
    }
    set isSaving(v){
        this._isSaving = v;
        // dispatch loading event
        const event = new CustomEvent('loadingchange', {
            detail: { isLoading: this._isSaving },
            bubbles: true,
            composed: true,
        });
        this.dispatchEvent(event);
    }

    /**
     * Fetches picklist values and loads data when the component is initialized
     */
    connectedCallback() {
        this.getPicklistValues(this.picklistFields).then((result)=>{
            this.loadData();
        }).catch(err => console.error(JSON.stringify(err)))

    }

    /**
     * Column Field Names - Gets the field names from columns
     * @returns {Array} - List of field names
     */
    get columnFieldNames() {
        return this.columns.map(column => column.fieldName);
    }

    /**
     * No Data - Checks if there are no records to display
     * @returns {boolean} - True if no data, else false
     */
    get noData(){
        return this.data.length <= 0;
    }
    
   
    /**
     * Loads data using the specified Apex method
     */
    loadData() {
        if(this.apexMethod){
            this.isLoading = true;
            this.apexMethod({
                recordId : this.recordId,
                pageSize: this.pageSize,
                pageNumber: this.page,
                sortBy: this.sortedBy,
                sortDirection: this.sortedDirection,
                columnNames: this.columnFieldNames
            }).then(result => {
                    this.formatData(result)
                    this.isLoading = false;
                })
                .catch(error => {
                    console.error('Error fetching records:', JSON.stringify(error));
                    this.isLoading = false;
                });
        }
    }

    /**
     * Formats the data for display in the datatable
     * @param {Object} loadedData - Data fetched from the server
     */
    formatData(loadedData){
        this.data = loadedData.records.map(row => {
            let formattedRow = { ...row , cols:[]};
            this.columns.forEach((col)=>{
                let tempData = {
                    fieldName : col.fieldName,
                    value :  row[col.fieldName] ? (col.type === 'date' ? this.formatDate(row[col.fieldName]) : row[col.fieldName]) : '',
                    isInput : col?.type ==='input' ? true : false,
                    inputType : col?.attributes?.inputType,
                    inputName : col?.attributes?.name,
                    inputSelectOpts : this[col?.attributes?.selectOptions],
                    recordId : row?.Id,
                    colWidth : `width: ${col.width}%`
                }
                formattedRow.cols.push(tempData);
            })
            return formattedRow;
        });

        this.totalRecords = loadedData.totalRecords[0]?.expr0;
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
    }

    /**
     * Formats a date string to a readable format
     * @param {string} dateString - Date string to format
     * @returns {string} - Formatted date string
     */
    formatDate(dateString) {
        const date = new Date(dateString);
        const options = { year: 'numeric', month: 'long', day: 'numeric' };
        return new Intl.DateTimeFormat('en-US', options).format(date);
    }

    /**
     * Handles pagination to the previous page
     */
    handlePrevious() {
        if (this.page > 1) {
            this.page -= 1;
            this.loadData();
        }
    }

    /**
     * Handles pagination to the next page
     */
    handleNext() {
        if (this.page < this.totalPages) {
            this.page += 1;
            this.loadData();
        }
    }

    /**
     * Handles sorting of the records
     * @param {Event} event - The sort event
     */
    handleSort(event) {
        const { fieldName } = event.currentTarget.dataset;
        this.sortedDirection = this.sortedDirection === 'asc' ? 'desc' : 'asc';
        this.sortedBy = fieldName;
        this.loadData();
    }

     /**
     * Checks if the previous button should be disabled
     * @returns {boolean} - True if the previous button should be disabled, else false
     */
    get disablePrevious() {
        return this.page <= 1;
    }

    /**
     * Checks if the previous button should be shown
     * @returns {boolean} - True if the previous button should be shown, else false
     */
    get shoePrevious(){
        return this.page > 1;
    }

    /**
     * Checks if the next button should be disabled
     * @returns {boolean} - True if the next button should be disabled, else false
     */
    get disableNext() {
        return this.page >= this.totalPages;
    }

    /**
     * Checks if the next button should be shown
     * @returns {boolean} - True if the next button should be shown, else false
     */
    get showNext(){
        return this.page < this.totalPages;
    }

    /**
     * Handles input change events for the datatable inputs
     * @param {Event} event - The input change event
     */
    handleInputChange(event) {
        this.isSaving = true;

        let recordId = event.detail.recordId
        let fieldName = event.detail.name
        let changedValue = event.detail.value

        if(fieldName && changedValue && recordId){
            let fieldsToUpdate = {}
            fieldsToUpdate[fieldName] = changedValue
            if(this.updateMethod){
                this.updateMethod({ recordId : recordId, objectName:this.objectName,fieldsToUpdate : fieldsToUpdate}).then((res)=>{
                    this.isSaving = false;
                }).catch(err=>{
                    console.error(err)
                    this.isSaving = false;
                })
            }
        }

    }

    /**
     * Fetches picklist values for specified fields
     * @param {Array} fields - List of fields to fetch picklist values for
     * @returns {Promise} - Resolves with picklist values
     */
    getPicklistValues(fields){
        return new Promise(async (resolve, reject)=>{
            this.isLoading = true;
            let promiseArray =  [];
            let returnValues = [];
            fields.forEach(async(field,index,array) => {
                try{
                    let promiseResult = this.getPicklist(this.objectName, field.fieldName)
                    .then(result=>{
                        this[field.variableName] = [...result]
                        returnValues.push({
                            fieldName: field.variableName,
                            value: result
                        })
                    }).catch(err => {
                       console.error(err)
                    })
                    promiseArray.push(promiseResult)
                }catch(error){
                    console.error(error);
                } 
            
                
            })

            try{
                await Promise.all(promiseArray);
                this.isLoading = false;
                resolve(returnValues);
            }catch(err){
                this.isLoading = false;
                reject(err)
            }


        })
        


    }

    getPicklist(objectName, fieldName){
        return new Promise(async( resolve, reject) => {
            let picklistValues = await apex_getPicklistValues({objectName: objectName, fieldName : fieldName});
            resolve(picklistValues)
        })
    }
}