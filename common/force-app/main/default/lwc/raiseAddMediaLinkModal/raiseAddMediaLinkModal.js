/**
 * RaiseAddMediaLinkModal Component
 * @description The `RaiseAddMediaLinkModal` component provides a modal interface for adding and editing media links associated with a specific record (raise). It includes properties for record ID, media link ID, button label, and variation. The modal supports both adding new media links and editing existing ones based on the mode (Add or Edit). It handles form submissions, validation, and interaction with Apex controllers for CRUD operations on media links.
 * 
 * @example
 *  <c-raise-add-media-link-modal 
 *      record-id="a1B1r00000F5N3AEAV" 
 *      media-link-id="a1C1r00000G5N3BEAV"
 *      variation="primary"
 *      label="Add Media Link"
 *      name="Media Link Modal"
 *      onsaved={handleMediaLinkSave}
 *  >
 *  </c-raise-add-media-link-modal>
 * 
 * @example
 * // Example of listening to the saved event
 * handleMediaLinkSave(event) {
 *     const savedMediaLink = event.detail;
 *     console.log('Media link saved:', savedMediaLink);
 * }
 */


import { LightningElement , api, track} from 'lwc';
import apex_createMediaLink from '@salesforce/apex/MediaLinkController.createMediaLink';
import apex_editMediaLink  from '@salesforce/apex/MediaLinkController.editMediaLink'
import apex_getMediaLink from '@salesforce/apex/MediaLinkController.getMediaLinkById';

export default class RaiseAddMediaLinkModal extends LightningElement {
    //raise record ID
    @api recordId

    // ID of the media link
    @api mediaLinkId

    // controls the core-button variation
    @api variation

    // controls the button label
    @api label

    // controls the title of the modal
    @api name


    // Controls the mode (Add | Edit)
    @track mode = 'Add'
    @track isLoading = false;
    @track formData;

    /**
     * Handles the form submission.
     * Creates or edits a media link based on the current mode.
     * @param {Event} e - The form submission event.
     */
    handleFormSubmit(e){
        this.formData = {...e.detail.formData};
        if(this.mode==='Edit'){
            this.editMediaLink(this.mediaLinkId, this.formData.mediaTitle, this.formData.url).then((result)=>{
                this.dispatchSaveEvent(result)
            }).catch((err)=>{
                console.error('Unable to create media link')
            })
        }else if(this.mode === 'Add'){
            this.createMediaLink(this.recordId, this.formData.mediaTitle, this.formData.url).then((result)=>{
                this.dispatchSaveEvent(result)
            }).catch((err)=>{
                console.error('Unable to create media link')
            })
        }

        // close modal;
        this.refs.coremodal.handleClose();
    }

    /**
     * Dispatches a custom event when a media link is saved.
     * @param {Object} saveData - The saved media link data.
     */
    dispatchSaveEvent(saveData){
        const mediaLinkUpdated = new CustomEvent('saved',{
            detail: saveData,
            bubbles: true,
        });
        this.dispatchEvent(mediaLinkUpdated);
    }

    /**
     * Handles change events for form fields.
     * Updates the form data with the changed field value.
     * @param {Event} e - The change event.
     */
    handleChange(e){
        e.stopPropagation();
        
        let fieldName = e.detail.name;
        let fieldValue = e.detail.value;

        this.formData = {
            ...this.formData,
            [fieldName] : fieldValue
        }
    }

    /**
     * Creates a new media link.
     * @param {string} raiseId - The ID of the raise record.
     * @param {string} name - The name of the media link.
     * @param {string} url - The URL of the media link.
     * @returns {Promise} - Resolves with the created media link data.
     */
    createMediaLink(raiseId, name, url){
        return new Promise(async(resolve,reject)=>{
            let returnResult = await apex_createMediaLink({raiseId :raiseId, name : name, mediaUrl:url})
            if(returnResult){
                resolve(returnResult);
            }else{
                reject(returnResult);
            }
        })
    }

    /**
     * Edits an existing media link.
     * @param {string} mediaLinkId - The ID of the media link.
     * @param {string} name - The name of the media link.
     * @param {string} mediaUrl - The URL of the media link.
     * @returns {Promise} - Resolves with the edited media link data.
     */
    editMediaLink( mediaLinkId, name, mediaUrl){
        return new Promise(async(resolve,reject)=>{
            let returnResult = await apex_editMediaLink({
                mediaLinkId : mediaLinkId,
                name : name,
                mediaUrl : mediaUrl
            })
            if(returnResult){
                resolve(returnResult);
            }else{
                reject(returnResult)
            }
        })
    }

    /**
     * Retrieves media link details by ID.
     * @param {string} recordId - The ID of the media link.
     * @returns {Promise} - Resolves with the media link data.
     */
    getMediaLinkDetails(recordId){
        return new Promise(async (resolve, reject)=>{
            let returnResult = await apex_getMediaLink({mediaLinkId : recordId})

            if(returnResult){
                resolve(returnResult)
            }else{
                reject(returnResult)
            }
        })
    }

    /**
     * Lifecycle hook that runs when the component is connected to the DOM.
     * Initializes the component based on the record ID and media link ID.
     */
    connectedCallback(){
        if(this.recordId && this.mediaLinkId){
            this.mode = 'Edit'

            // get media link details
            this.isLoading = true;
            this.getMediaLinkDetails(this.mediaLinkId).then((result)=>{
                let newFormData  = {
                    mediaTitle : result.name,
                    url : result.link
                }

                this.formData = {...newFormData}
                this.isLoading = false;
            }).catch((e)=>{
                console.error("Unable to get media link: ", this.mediaLinkId, e)
                this.isLoading = false;
            });
        }else{
            this.mode = 'Add'
        }
    }
}