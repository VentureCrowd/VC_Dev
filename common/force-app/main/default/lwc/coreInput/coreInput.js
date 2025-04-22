/**
 * CoreInput Component
 * @description The `coreInput` component is a versatile input component for various data types, including text, number, date, dropdown, file, and more. It supports validation, file upload, and dynamic option handling for dropdowns.
 * 
 * @example
 *  <c-core-input 
 *      label="First Name"
 *      type="text"
 *      name="firstName"
 *      value={value}
 *      required
 *      onchange={handleChange}>
 *  </c-core-input>
 */

import { LightningElement, api, track} from 'lwc';
import { validateInput } from './inputValidation';
import apex_uploadFile from '@salesforce/apex/FileUploadController.uploadFile';
import apex_deleteFileById from '@salesforce/apex/FileUploadController.deleteFileById';
import apex_getFilesByName  from '@salesforce/apex/FileUploadController.getFilesByFieldName';

const DEFAULT_FILE_SIZE_LIMIT = 3 * 1024 * 1024; // 3MB in bytes

export default class CoreInput extends LightningElement {
    /**
     * Label for the input field.
     * @type {string}
     */
    @api label;

    @api errorLabel;

    @api
    get getErrorLabel(){
        return this.label ? this.label : this.errorLabel ? this.errorLabel : this.name;
    }


    
     /**
     * Type of the input field (e.g., text, number, date, dropdown, file, etc.).
     * @type {string}
     */
    @api type;

     /**
     * Name of the input field.
     * @type {string}
     */
    @api name;

    /**
     * Value of the input field.
     * @type {string}
     */
    @api _value='';


    /**
     * Help text for the input field.
     * @type {string}
     */
    @api help;

    /**
     * Character limit for the input field.
     * @type {number}
     */
    @api limit;

    /**
     * Indicates if the input field is required.
     * @type {boolean}
     */
    @api required = false; // Determines if the input is required

    /**
     * Options for dropdown input fields.
     * @type {Array}
     */
    @api options;

    /**
     * Record ID associated with the input field.
     * @type {string}
     */
    @api 
    get recordId(){
        return this._recordId;
    };

    set recordId(v){
        this._recordId = v;
    }
    
    /**
     * Subtext for the input field.
     * @type {string}
     */
    @api subtext;

    /**
     * Placeholder text for the input field.
     * @type {string}
     */
    @api placeholder; // New placeholder property

    /**
     * Flag to allow multiple file inputs.
     * @type {boolean}
     */
    @api multiple; // flag to trigger multiple file inputs

    /**
     * Text for the file input button.
     * @type {string}
     */
    @api fileText ='Upload a file';

    /**
     * Limit for multiple file inputs.
     * @type {number}
     */
    @api multiLimit = 3;

    /**
     * Disables the input field.
     * @type {boolean}
     */
    @api disabled

    /**
     * Minimum value for number or currency inputs.
     * @type {number}
     */
    @api minimumValue;

    /**
     * Type of file allowed for file inputs (e.g., image, document).
     * @type {string}
     */
    @api fileType = 'image';

    /**
     * Required value for radio inputs.
     * @type {string}
     */
    @api requiredValue;

    /**
     * Date to compare against for date inputs.
     * @type {string}
     */
    @api compareDate;

    /**
     * Name of the icon to display inside the input field.
     * Follows the 'utility:icon-name' format from SLDS.
     * @type {string}
     */
    @api iconName;

    /**
     * Position of the icon inside the input field.
     * Accepted values: 'left' or 'right'.
     * @type {string}
     */
    @api iconPosition = 'left'; // Default position

    @track processedOptions = []; // New property for internally processed options
    @track errorMessage = []; // To display validation errors
    @track fileFailedMessage = []; // to display file upload fails
    @api selectedOption = ''; // Track selected option for dropdown inputs
    @track _recordId;

    @track isLoading = false;

    @api
    get value(){
        return this._value
    }
    set value(v){
        this._value = v;
        if(this.isDropdown){
            this.selectedOption = v; // Ensure the selected option is updated
            this.updateProcessedOptions(); // Update the options whenever the value changes
        }
        this.validateInput();

        this._charactersLeft =  this.limit && this.value?.length ? this.limit - this.value.length : this.limit;

    }

    get isTextarea(){
        return this.type === 'textarea';
    }

    get inputClass() {
        return this.errorMessage.length > 0 ? 'input-error' : '';
    }

    // Check if the input is a dropdown
    get isDropdown() {
        return this.type === 'dropdown';
    }

    get isFile(){
        return this.type === 'file';
    }

    get isDate() {
        return this.type === 'date';
    }

    get isCurrency() {
        return this.type === 'currency';
    }

    get displayErr(){
        return this.errorMessage.length > 0;
    }

    get displayFileErr(){
        return this.fileFailedMessage.length > 0;
    }


    //character limit
    

    @track _charactersLeft = 0;
    
    get _charactersOver(){
        return this._charactersLeft * -1;
    }

    get overCharacterLimit(){
        return this._charactersLeft < 0;
    }

    handleKeyPress(event) {
        this.handleOnChange(event);
    }  

    // Handle change event for dropdown inputs
    handleSelectChange(event) {
        this.selectedOption = event.target.value;
        this.value = this.selectedOption; // Update value with selected option
        this.handleOnChange(event); // Dispatch change event
    }

    /**
     * Validates the input value.
     * Updates the errorMessage array based on validation results.
     * @returns {boolean} - Returns true if no error message, hence valid.
     */
    validateInput() {
        let errorOccured = false;
        this.errorMessage = [];

        const limit = this.limit;
        
        if(this.required && (!this._value || this._value.length<=0) && !this.disabled){
            // Check if the input is required and the value is empty
            this.errorMessage = ['This field is required.'];
            errorOccured  = true;
        }else if(this.required && this.requiredValue && this._value && this.type==='radio'){
            //return error message if the field is required, has a required value and is type radio
            const valueMap={
                'true' : 'Yes',
                'false' : 'No'
            }
            if(this.requiredValue !== this._value){
                this.errorMessage = [`You must select ${valueMap[this.requiredValue]} to proceed`];
                errorOccured = true;
            }
           
        }else if( this.minimumValue && (this.type==='number' || this.type === 'currency') && !this.disabled){
            // minimum check
            if(Number(this._value) < Number(this.minimumValue)){
                this.errorMessage = [`This field is must be at least ${this.type === 'currency'? "$" : ''}${this.minimumValue}.`];
                errorOccured = true;
            }
        }else if(this.minimumValue && this.isFile && this._value.length > 0){
            if(Number(this._value.length) < Number(this.minimumValue)){
                this.errorMessage = [`Select at least ${this.minimumValue} ${this.minimumValue === 1 ? 'file' : 'files'}.`];
                errorOccured = true;
            }
        }else if(this.isDate && this.compareDate){
            const thisDate = new Date(this._value);
            const compareToDate = new Date(this.compareDate);
            if(thisDate < compareToDate){
                this.errorMessage = [`Date must be after ${this.compareDate}`];
                errorOccured = true;
            }
        }else if(this._value && this._value !== '' && !this.disabled){
            let validationResult = this.isFile ? validateInput('files', this._value, limit) : validateInput(this.type, this._value, limit);

            if(validationResult === ''){
                errorOccured = false;
            }else{
                this.errorMessage = [validationResult];
                errorOccured = true;
            }
        }
      
        return !errorOccured; // Returns true if no error message, hence valid
    }

    @api
    setFocus(){
        let elementToFocus;
    
        if (this.isTextarea) {
            elementToFocus = this.template.querySelector('textarea');
        } else if(this.isDropdown){
            elementToFocus = this.template.querySelector('select');
        } else if (this.isDate) {
            elementToFocus = this.template.querySelector('input[type="date"]');
        } else if (this.isCurrency) {
            elementToFocus = this.template.querySelector('input[type="number"]');
        } else if (this.isFile) {
            elementToFocus = this.template.querySelector('.file-label');
        } else {
            elementToFocus = this.template.querySelector('input');
        }

        if (elementToFocus) {
            elementToFocus.focus();

            // Scroll to the center of the page
            elementToFocus.scrollIntoView({ block: 'center', behavior: 'smooth' });
        }


    }

    /**
     * Checks the validity of the input.
     * Sets focus on the invalid input if validation fails.
     * @returns {boolean} - Returns true if the input is valid, otherwise false.
     */
    @api
    checkValidity() {

        let isValid =  this.validateInput(); // Ensure the latest validation state is checked

        if (!isValid) {
            // Optionally set focus on the invalid input
            this.setFocus()
        }

        return isValid;
    }

    /**
     * Validates the file input based on specified criteria.
     * @param {File} file - The file to validate.
     * @returns {boolean} - Returns true if the file is valid, otherwise false.
     */
    validateFileInput(file){
            const limit = this.isFile ? DEFAULT_FILE_SIZE_LIMIT : null;

            let errorOccured = false;
            let errorMessage = [];
    
            if (this.isFile && file  && file !== null && this.fileType) {
                let validationResult = validateInput(this.type, file, limit, this.fileType)
                if(validationResult != ''){
                    errorMessage = [validationResult];
                    errorOccured = true;
                }
                this.fileFailedMessage = [...this.fileFailedMessage, ...errorMessage];
            
            }
    
            return !errorOccured;
       
    }

    /**
     * Clears the file input value.
     */
    clearFileInput() {
        // Clear the file input value
        const fileInput = this.template.querySelector('[data-id="file-input"]');
        if (fileInput) {
            fileInput.value = '';
        }
    }

    /**
     * Processes a list of files and returns an array of file objects.
     * @param {FileList} fileList - List of files to process.
     * @returns {Array} - Array of file objects.
     */

    processFileList(fileList) {
        const filesArray = [];
    
        for (let i = 0; i < fileList.length; i++) {
            const file = fileList[i];
            const fileObject = {
                index: i,
                fileName: file.name,
                files: file
            };
            filesArray.push(fileObject);
        }
    
        return filesArray;
    }

    /**
     * Handles file change events.
     * Uploads selected files and updates the value property.
     * @param {Event} event - The file change event.
     */
    handleFileChange(event){
        
        const files = event.target.files;
        
        //get the existing files

        let existingFiles = [...this.value];

        let fileLimit = this.multiple ? Number(this.multiLimit) : 1;

        const fileLimitValidation  = (files.length + existingFiles.length) <= fileLimit
        // if the record ID doesnt exist, then we need to hold the file in the _value field, then call the upload file method from the parent
        // check if the selected files + existing files are over the limit? - if so, dont allow upload

        if (files.length > 0 && fileLimitValidation) {
            this.isLoading = true;
            this.doUpload(files);
            
        }else if(!fileLimitValidation){
            console.error(`You may only upload ${fileLimit} ${fileLimit === 1 ? 'file' : 'files'}`)
            this.errorMessage = [...this.errorMessage, `You may only upload ${fileLimit} ${fileLimit === 1 ? 'file' : 'files'}`]
        }
       
        this.clearFileInput();
    }

    /**
     * Handles file upload to the server.
     * Processes selected files and updates the value property with uploaded file information.
     * @param {FileList} files - List of files to upload.
     */
    doUpload(files){

        this.uploadFileToServer(files).then((response) => {
            if(this.multiple){
                const currentValues = [...this.value];
                this.value = [...currentValues,...response];
            }else{
                this.value = [...response];
            }
            const inputChanged = new CustomEvent('change',{
                detail:{ 
                    name: this.name,
                    label: this.label,
                    value: this.value,
                    type: this.type,
                },
                bubbles: true,
            });
            this.dispatchEvent(inputChanged);
        }).then( () => {
            this.isLoading = false;
        }).catch((failedFile)=>{
            console.error('File failed to upload: ', JSON.stringify(failedFile));
            this.isLoading = false;
        });
    }


    /**
     * Handles the onchange event.
     * Updates parent component with the target.value when the onchange event fires.
     * @param {Event} event - The change event.
     * @event change - Dispatches { detail: value, bubbles: true, composed: false }
     */
    handleOnChange(event){
        this.value = event.target.value;
        
        this._charactersLeft =  this.limit && this.value.length ? this.limit - this.value.length : this.limit;

        const inputChanged = new CustomEvent('change',{
            detail:{ 
                name: this.name,
                label: this.label,
                value: this.value,
                type: this.type,
                recordId : this.recordId,
            },
            bubbles: true,
        });
        this.dispatchEvent(inputChanged);

    }

    /**
     * Updates the processed options for dropdown inputs.
     */
    updateProcessedOptions() {
        if (Array.isArray(this.options)) {
            this.processedOptions = this.options.map(option => ({
                ...option,
                selected: option.value === this.selectedOption
            }));
        }
    }

    /**
     * Uploads files to the server.
     * @param {FileList} files - List of files to upload.
     * @returns {Promise} - Resolves with an array of uploaded file information.
     */    
    uploadFileToServer(files) {
            return new Promise( async (resolve,reject )=> {
                let returnValues = [];
                this.fileFailedMessage = [];
                let uploadPromises = [];

              
                for (let i = 0; i < files.length; i++){
                    let file = files.item(i);
                    // check if file is valid
                    if(this.validateFileInput(file)){       
                        let uploadPromise = this.uploadFileProcess(file)
                        .then(result=>{
                            returnValues.push(
                                {
                                    index : i,
                                    fileName : file.name,
                                    internalName : file.name,
                                    fileId : result ? result : '',
                                }
                            )
                        })
                        .catch(err => {
                            returnValues.push(
                                {
                                    index : i,
                                    fileName : file.name,
                                    internalName : file.name,
                                    fileId : '',
                                    error: err,
                                });
                        });
                        uploadPromises.push(uploadPromise);
                    }
                }

                try{
                    await Promise.all(uploadPromises);
                    resolve(returnValues);
                }catch(err){
                    reject(err);
                    console.error(err);
                }
           });
    }


    /**
     * Uploads a single file to the server.
     * @param {FileList} files - List of files to upload.
     * @returns {Promise} - Resolves with an array of uploaded file information.
     */
    uploadFileProcess(file){
        return new Promise(async (resolve,reject)=>{
           try {
                let base64 = await this.readFileAsBase64(file);
                let result = await this.uploadFile(file.name, base64, this.recordId, this.name);
                resolve(result);
            } catch (error) {
                reject(error);
            }
        });
    }

    /**
     * Uploads a file to the server.
     * @param {string} fileName - The name of the file.
     * @param {string} base64FileContents - The Base64 encoded file contents.
     * @param {string} recordId - The ID of the record to associate the file with.
     * @param {string} fieldName - The field name associated with the file.
     * @returns {Promise} - Resolves with the file ID after upload.
     */
    uploadFile(fileName, base64FileContents, recordId, fieldName){
        return new Promise(async(resolve, reject)=>{
            try {
                let result = await apex_uploadFile({ fileName: fileName, base64FileContents: base64FileContents, recordId: recordId , fieldName: fieldName});
                resolve(result);
            } catch (error) {
                reject(error);
            }
        });
    }


    findFileInValues(fileId){
        return this.value.find(file => file.fileId === fileId);
    }

    /**
     * Removes a file from the server and updates the value property.
     * @param {Event} e - The event triggered by the file removal.
     */
    async removeFile(e){
        this.isLoading = true;
        try{
            // call apex to remove file
            let fileId = e.target.dataset.id;
            let result = await apex_deleteFileById({ fileId: fileId});

            
            // remove file from list
            if(result){
                let newValues = this.value.filter((ele) => {
                    return ele.fileId !== fileId
                });
                this.value = [...newValues];
                const inputChanged = new CustomEvent('change',{
                    detail:{ 
                        name: this.name,
                        label: this.label,
                        value: this.value,
                        type: this.type,
                    },
                    bubbles: true,
                });
                this.dispatchEvent(inputChanged);
                this.isLoading = false;
            }else{
                console.error('File cannot be deleted');
                this.isLoading = false;

            }
        }catch(err){
            console.error(err);
            this.isLoading = false;
        }
        

    }

    /**
     * Reads a file as a Base64 encoded string.
     * @param {File} file - The file to read.
     * @returns {Promise} - Resolves with the Base64 encoded string.
     */
    readFileAsBase64(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.readAsDataURL(file);
            reader.onload = () => resolve(reader.result.split(',')[1]); // Split to get base64 part
            reader.onerror = err => reject(err);
        });
    }

    connectedCallback(){
        this._charactersLeft = this.limit

        this.updateProcessedOptions();

        //get files by file name
        if(this.name && this.recordId && this.isFile){
            this.isLoading = true;
            this.getFilesByName(this.name, this.recordId).then((result)=>{
                this.value = [...result];
                const inputChanged = new CustomEvent('change',{
                    detail:{ 
                        name: this.name,
                        label: this.label,
                        value: this.value,
                        type: this.type,
                    },
                    bubbles: true,
                });
                this.dispatchEvent(inputChanged);
                
    
            }).catch((result)=>{
                console.error(result);
            }).finally(()=>{
                this.isLoading = false;
            });
        }

    }

    /**
     * Retrieves files by field name from the server.
     * @param {string} name - The field name.
     * @param {string} recordId - The ID of the record.
     * @returns {Promise} - Resolves with the files associated with the field name.
     */
    async getFilesByName(name,recordId){
        return new Promise(async (resolve, reject)=>{
            try {
                let files = await apex_getFilesByName({fieldName: name, recordId: recordId});
                if(files.length > 0){
                    resolve(files);
                } else {
                    reject('No files found');
                }
            } catch (error) {
                reject(error);
            }
        });

    }

    // Computed property to determine if an icon should be displayed
    get hasIcon() {
        return this.iconName && (this.iconPosition === 'left' || this.iconPosition === 'right');
    }

    // Determine the appropriate CSS class based on icon position
    get inputContainerClass() {
        return `input-container ${this.hasIcon ? `with-icon ${this.iconPosition}` : ''}`;
    }

    // Determine if the icon is on the left
    get isIconLeft() {
        return this.iconPosition === 'left';
    }

    // Determine if the icon is on the right
    get isIconRight() {
        return this.iconPosition === 'right';
    }


}