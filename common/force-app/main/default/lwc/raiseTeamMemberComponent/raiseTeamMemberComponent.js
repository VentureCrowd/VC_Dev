/**
 * RaiseTeamMemberComponent
 * @description This component manages the display, editing, and deletion of team members, advisors, and directors associated with a raise. It fetches team members' data, validates inputs, and handles user interactions.
 */

import { LightningElement , api, track} from 'lwc';
import apex_getTeamMembersList from '@salesforce/apex/RaiseTeamController.getTeamMembersByRaiseId';
import apex_deleteTeamMember from '@salesforce/apex/RaiseTeamController.deleteTeamMember'
import apex_getPublicImageUrl from '@salesforce/apex/FileUploadController.getPublicImageUrl';

export default class RaiseTeamMemberComponent extends LightningElement {
    @api raiseId; // ID of the raise
    @api sectionTitle; // Title of the section
    @api helptext; // Help text for the section
    @api subtext; // Subtext for the section
    @api category; // Category of the team members (e.g., advisors, directors)
    @api requiredMembers; // Number of required members
    @api required; // Flag to indicate if the section is required
    
    @track values; // List of team members
    @track isLoading = false; // Loading state
    @track errorMessage = []; // Error messages for validation

    get displayErr(){
        return this.errorMessage.length > 0;
    }

    @api 
    get hasValue(){
        return this.values.length > 0
    }

    /**
     * Validates the input and checks if the required conditions are met.
     * @returns {Boolean} - True if input is valid, false otherwise.
     */
    validateInput(){

        let errorOccured = false;
        this.errorMessage = [];

        const requiredMembers = Number(this.requiredMembers);

        if(this.required && (!this.values || this.values.length<=0)){
            // Check if the input is required and the value is empty
            this.errorMessage = ['This field is required.'];
            errorOccured  = true;
        }else if(requiredMembers){
            if(this.values.length >= requiredMembers){
                errorOccured = false;
            }else{
                this.errorMessage = [`Please select at least ${requiredMembers} members`];
                errorOccured = true;
            }
        }
      
        return !errorOccured; // Returns true if no error message, hence valid
    }

    /**
     * Checks the validity of the input.
     * @returns {Boolean} - True if input is valid, false otherwise.
     */
    @api
    checkValidity(){
        
        let isValid =  this.validateInput(); // Ensure the latest validation state is checked

        if (!isValid) {
            // Optionally set focus on the invalid input
            this.scrollToElement()
        }
        return isValid;
    }

    /**
     * Scrolls to the first invalid element in the form.
     */
    scrollToElement() {
        const formContainer = this.template.querySelector('*');
        if (formContainer) {
            formContainer.scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
    }

    /**
     * Handles the removal of a team member.
     * @param {Event} e - The event containing the team member ID to be removed.
     */
    handleRemoveLink(e){
        let memberId = e.target.dataset.id;
        // logic to remove
        this.isLoading = true;
        this.deleteTeamMember(memberId).then((result)=>{
            this.getTeamMembersList(this.raiseId, this.category).then((result)=>{
                this.values = [...result];
                this.isLoading = false;
            }).catch((err)=>{
                console.error(err);
                this.isLoading = false;
            })
        });
    }

    /**
     * Handles the refresh of the team members list.
     * @param {Event} e - The event to refresh the team members list.
     */
    handleRefreshList(e){
        e.stopPropagation()
       // get team members and re-assign to this.values
       this.isLoading = true;
       this.getTeamMembersList(this.raiseId, this.category).then((result)=>{
            this.values = [...result];
            this.isLoading = false;
            this.checkValidity();
        }).catch((err)=>{
            console.error(err);
            this.isLoading = false;
        })
       
    }

    /**
     * Fetches the list of team members for the specified raise and category.
     * @param {String} raiseId - The ID of the raise.
     * @param {String} category - The category of the team members.
     * @returns {Promise} - A promise that resolves to the list of team members.
     */
    getTeamMembersList(raiseId, category){
        return new Promise(async(resolve,reject)=>{
            let result  = await apex_getTeamMembersList({raiseId: raiseId, category: category});
            if(result != null){
                const teamWithImageUrl = await Promise.all(
                    result.map(async (teamMember)=>{
                        try{

                            if(teamMember.picture !== '' && teamMember.picture !== null && teamMember.picture !== undefined){
                                try{
                                    const imageUrl = await apex_getPublicImageUrl({ recordId : teamMember.id});
                                    return {...teamMember, imageUrl: imageUrl};
                                }catch(err){
                                    // url cant be retrieved
                                    return {...teamMember, imageUrl: teamMember.picture};
                                }
                            }else{
                                const imageUrl = await apex_getPublicImageUrl({ recordId : teamMember.id});
                                return {...teamMember, imageUrl: imageUrl};
                            }
                            
                        }catch(error){
                            console.error(error);
                            return teamMember;
                        }
                    })
                )
                if(teamWithImageUrl.length > 0){
                    resolve(teamWithImageUrl)
                }else{
                    resolve([]);
                }
            }else{
                resolve([]);
            }
            
        })
    }

    /**
     * Deletes a team member.
     * @param {String} memberId - The ID of the team member to be deleted.
     * @returns {Promise} - A promise that resolves to the result of the deletion.
     */
    deleteTeamMember(memberId){
        return new Promise(async(resolve,reject)=>{
            let result = await apex_deleteTeamMember({teamMemberId:memberId});
            if(result){
                resolve(result)
            }else{
                reject("Team members not found");
            }
        })
    }

    /**
     * Lifecycle hook that is invoked when the component is connected to the DOM.
     */
    connectedCallback(){

        this.isLoading = true;
        if(this.raiseId && this.category){
            // set this.values after retrieiving 
            this.getTeamMembersList(this.raiseId, this.category).then((result)=>{
                this.values = [...result];
                this.isLoading = false;
            }).catch((err)=>{
                console.error(err);
                this.isLoading = false;
            })
        }
        
    }
    @api
    setFocus(){
        const formContainer = this.template.querySelector('*');
        if (formContainer) {
            formContainer.scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
    }
}