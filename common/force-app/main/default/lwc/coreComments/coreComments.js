import { LightningElement, track, api } from 'lwc';

import apex_publishComment from '@salesforce/apex/CommentController.createCommentRecord';
import apex_retrieveComments from '@salesforce/apex/CommentController.retrieveCommentsFromRaiseId';

import UserId from "@salesforce/user/Id";
import guestUser from '@salesforce/user/isGuest';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class CoreComments extends LightningElement {

    @track userId = UserId;
    @track _raiseId;
    @track isGuest = guestUser;
    @track inputUser;
    @track comments;
    /**
    * Public set method to update the closeDate property
    * @api decorator exposes the closeDate property as a public API
    * @param {any} value - The new value to be set to the internal _closeDate property
    * If the value is truthy, it calls the startCountdown method
    */
    @api
    set raiseId(value) {
        this._raiseId = value;
        //get comments
        if(this._raiseId){
            console.log("RAISEID2:", this._raiseId);
            this.getComments(this.raiseId)
            .then((result) => {
                // Assign the retrieved comments to the comments property
                this.comments = result;
                console.log(JSON.stringify(this.comments));
            })
            .catch((err) => {
                // Log any errors that occur during the retrieval process
                console.error('An error has occurred:', err);
            });
        }
    }
 
    /**
    * Public getter method to access the closeDate property
    * @returns {any} - The current value of the internal _closeDate property
    */
    get raiseId() {
        return this._raiseId;
    }

    /**
     * Asynchronously publishes a comment to the server using the provided Apex method.
     *
     * @function publishComment
     * @returns {Promise<any>} - A promise that resolves with the server response or rejects with an error.
     *
     * @throws {Error} - If an error occurs during the publishing process.
     */
    async publishComment() {
        try {
            // Prepare the data to be sent to the Apex method
            let data = {
                comment: this.inputUser,
                raiseId: this.raiseId,
                userId: this.userId
            };
    
            // Call the Apex method to publish the comment
            let returnResult = await apex_publishComment(data);
    
            if (returnResult) {
                // Handle the successful result
                this.showToast('Success', 'Comment submitted successfully for approval', 'success');
    
                return returnResult;
            } else {
                // Handle the case where no result is returned
                this.showToast('Error', 'Something happen please try again later', 'error');
            }
        } catch (error) {
            // Handle errors
            console.error('Error publishing comment:', error);
            throw error;
        }
    }
    /**
     * Handles the change event on the input field for comments.
     * Updates the inputUser property with the new value from the input field.
     * Logs the new value to the console.
     *
     * @param {CustomEvent} event - The event object containing the new value.
     * @property {any} event.detail.value - The new value of the input field.
     * @returns {void}
     */
    commentChange(event) {
        let changedValue = event.detail.value;
        this.inputUser = changedValue;
    }

    /**
     * Retrieves comments for a given raiseId from the server.
     *
     * @param {string} raiseId - The unique identifier for the raise record.
     * @returns {Promise<Array>} - A promise that resolves with an array of comments.
     * Each comment object contains the following properties:
     * - Id: The unique identifier for the comment.
     * - CommentBody: The content of the comment.
     * - CreatedBy.Name: The name of the user who created the comment.
     * - CreatedDate: The date and time when the comment was created.
     * - ResponseDate: The date and time when the comment was responded to.
     * - PublishedDate: The formatted date and time when the comment was published.
     * - ResponseDate: The formatted date and time when the comment was responded to.
     *
     * @throws {Error} - If an error occurs during the retrieval process.
     */
    async getComments(raiseId) {
        try {
            let comments = await apex_retrieveComments({raiseId: raiseId});
            // Loop through each comment and format the publishedDate
            comments = comments.map(comment => {
                return {
                    ...comment,
                    PublishedDate: this.formatDate(comment.PublishedDate),
                    ResponseDate: comment.ResponseDate ? this.formatDate(comment.ResponseDate) : null
                };
            });
            return comments;
        } catch (error) {
            if (!this.isGuest) {
                console.error('Error fetching data for raiseId:', error,);
                throw error;
            }
        }
    }

    /**
     * Method to format a date into a readable string.
     * @param {string} inputDate - The date to be formatted
     * @returns {string} - The formatted date string
     */
    formatDate(inputDate) {
        let date = new Date(inputDate);
        let options = { day: 'numeric', month: 'long', year: 'numeric' };
        let finalDate = date.toLocaleDateString('en-US', options);
        return finalDate;
    }
    


    /**
     * The connectedCallback lifecycle method is called when a component is inserted into the DOM.
     * It's used to initialize the component and perform any necessary operations.
     * In this case, it logs user information, retrieves comments for the raiseId,
     * and handles the promise returned by the getComments method.
     *
     * @returns {void}
     */
    connectedCallback() {    
        // Retrieve comments for the raiseId
        if(this.raiseId){
            this.getComments(this.raiseId)
            .then((result) => {
                // Assign the retrieved comments to the comments property
                this.comments = result;
                console.log(JSON.stringify(this.comments));
            })
            .catch((err) => {
                // Log any errors that occur during the retrieval process
                console.error('An error has occurred:', err);
            });
        }
        
    }

    /**
     * Method to display a toast notification.
     * @param {string} title - The title of the toast
     * @param {string} message - The message of the toast
     * @param {string} variant - The variant of the toast
     * @returns {void}
     */
        showToast(title, message, variant) {
            const event = new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            });
            this.dispatchEvent(event);
        }
}