/**
 * RaiseMediaLinks Component
 * @description This component handles the display and management of media links associated with a raise record. It allows users to add, edit, and delete media links while providing helpful information about media mentions.
 */


import { LightningElement , api, track} from 'lwc';
import apex_getMediaLinks from '@salesforce/apex/MediaLinkController.getMediaLinksByRaiseId';
import apex_deleteMediaLink from '@salesforce/apex/MediaLinkController.deleteMediaLink';

export default class RaiseMediaLinks extends LightningElement {
    @api recordId; // The ID of the raise record to which the media links are associated.
    @api values = []; // Array to store the media link values.

    @track isLoading = false; // Indicates whether the component is in a loading state.

    @track helpTextMapping = {
        mediaLinkText : `https://${window.location.host}/articles/module/Raise-About-Us#media-presence`,
    }; // Mapping for help text links.


    /**
     * Handles the removal of a media link.
     * @param {Event} e - The remove button click event.
     */
    handleRemoveLink(e){
        this.isLoading = true;
        let mediaLinkId = e.target.dataset.id;
        this.deleteMediaLink(mediaLinkId).then((result)=>{
            // update values list
            if(result){
                let newValues = this.values.filter((ele) => {
                    return ele.id !== mediaLinkId
                });
    
                this.values = [...newValues];
            }
           
            this.isLoading = false;

        }).catch((result)=>{
            console.error("Unable to delete media link")
            this.isLoading = false;
        })

    }

    /**
     * Handles the refresh of the media link list.
     * @param {Event} e - The refresh event.
     */
    handleRefreshList(e){
        e.stopPropagation()
        this.isLoading = true;
        this.getMediaLinks(this.recordId).then((result)=>{
            this.values = [...result]
            this.isLoading = false;
        }).catch((err)=>{
            this.isLoading = false;

        })
    }

    /**
     * Deletes a media link by ID.
     * @param {string} mediaLinkId - The ID of the media link to delete.
     * @returns {Promise} - A promise that resolves when the media link is deleted.
     */
    deleteMediaLink(mediaLinkId){
        return new Promise(async(resolve,reject)=>{
            let returnResult = await apex_deleteMediaLink({mediaLinkId : mediaLinkId})
            if(returnResult){
                resolve(returnResult);
            }else{
                reject(returnResult);
            }
        })
    }

    /**
     * Retrieves media links for the specified raise ID.
     * @param {string} raiseId - The ID of the raise record.
     * @returns {Promise} - A promise that resolves with the list of media links.
     */
    getMediaLinks(raiseId){
        return new Promise(async(resolve,reject)=>{
            let returnResult = await apex_getMediaLinks({raiseId:raiseId});
            if(returnResult.length > 0){
                resolve(returnResult);
            }
        })
    }

    /**
     * Lifecycle hook that is called when the component is inserted into the DOM.
     */
    connectedCallback(){
        // get media links attached to raise object
        this.isLoading = true;
        if(this.recordId){

            this.getMediaLinks(this.recordId).then((result)=>{
                this.values = [...result]
            })
        }

        this.isLoading = false;
    }
}