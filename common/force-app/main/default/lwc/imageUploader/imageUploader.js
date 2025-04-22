import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import uploadFile from '@salesforce/apex/MyCompaniesController.uploadFile';
export default class FileUploaderCompLwc extends LightningElement {
    @api eoiId;
    @api fileName;
    @api fileLabel;
    @api helpText;
    @api required = false;
    @api dimensions;
    @api ratio;
    @track isModelOpen = false;
    fileData;
    @track imageClass = 'max-height: 220px; max-width: 220px;';
    @api imgUrl;
    @track tempImgUrl = '';
    @track showSpinner = false;
    @track showRecommendedText = false;

    get acceptedFormats() {
        return ['.png', '.jpg', '.jpeg', '.webp'];
    }

    connectedCallback() { 
        if(this.fileLabel == 'Company logo') { 
            this.showRecommendedText = true;
        }
    }

    openFileUpload(event) {
        const file = event.target.files[0];
        const maxSize = 300 * 1024;; // 1 MB in bytes
        if (file.size > maxSize) {
            this.toast('File size exceeds 300KB limit.', 'error');
        } else { 
            var reader = new FileReader();
            reader.onload = () => {
                this.tempImgUrl = '';
                var base64 = reader.result.split(',')[1];
                this.tempImgUrl = URL.createObjectURL(file);
                this.fileData = {
                    filename: this.fileName,
                    base64: base64,
                    recordId: this.eoiId
                };
            };
            reader.readAsDataURL(file);
        }
    }
    openUploaderModel() {
        this.fileData = null;
        this.tempImgUrl = '';
        this.isModelOpen = true;
    }
    closeUploaderModel() {
        this.fileData = null;
        this.tempImgUrl = '';
        this.isModelOpen = false;
    }
    
    handleSubmit() {
        
        if (this.eoiId !== undefined && this.eoiId !== '') {
            if(this.fileData) { 
                this.showSpinner = true;
                const { base64,filename,recordId } = this.fileData;
                uploadFile({ base64, filename, recordId})
                .then((result) => {
                    this.imgUrl = this.tempImgUrl;
                    this.imageClass = this.imageClass + 'height: 220px; width: 220px;';
                    this.isModelOpen = false;
                    this.fileData = null;
                    this.showSpinner = false;
                    let title = `${filename} uploaded successfully.`;
                    this.toast(title, 'success');
                    const selectedEvent = new CustomEvent('filesubmit', {
                      detail: {filedata: this.fileData, imgurl: this.tempImgUrl},
                      bubbles: false,
                      composed: false
                    });
                    // Dispatches the event with filedata, imgurl, bubbles and composed
                    this.dispatchEvent(selectedEvent);
                });
            } else { 
                let title = 'Select image to upload.';
                this.toast(title, 'error');
            }
        } else {
            if(!this.fileData) { 
                let title = 'Select image to upload.';
                this.toast(title, 'error');
            } else { 
                this.showSpinner = false;
                this.isModelOpen = false;
                const selectedEvent = new CustomEvent('filesubmit', {
                    detail: {filedata: this.fileData, imgurl: this.tempImgUrl},
                    imgUrl: this.tempImgUrl,
                    bubbles: false,
                    composed: false
                });
                // Dispatches the event.
                this.dispatchEvent(selectedEvent);
                this.fileData = null;
            }
            
         }
        
    }

    toast(title, variant) {
        const toastEvent = new ShowToastEvent({
            title,
            variant: variant
        });
        this.dispatchEvent(toastEvent);
    }
}