/**
 * RaiseAddTeamMemberModal Component
 * @description The `RaiseAddTeamMemberModal` component provides a modal interface for adding and editing team members associated with a specific raise record. It includes properties for record ID, team member ID, button label, and variation. The modal supports both adding new team members and editing existing ones based on the mode (Add or Edit). It handles form submissions, validation, and interaction with Apex controllers for CRUD operations on team members.
 * 
 * @example
 *  <c-raise-add-team-member-modal 
 *      record-id="a1B1r00000F5N3AEAV" 
 *      member-id="a1C1r00000G5N3BEAV"
 *      variation="primary"
 *      label="Add Team Member"
 *      name="Team Member Modal"
 *      category="Advisors"
 *      onsaved={handleTeamMemberSave}
 *  >
 *  </c-raise-add-team-member-modal>
 * 
 * @example
 * // Example of listening to the saved event
 * handleTeamMemberSave(event) {
 *     const savedTeamMember = event.detail;
 *     console.log('Team member saved:', savedTeamMember);
 * }
 */

import { LightningElement ,api, track } from 'lwc';
import apex_getTeamMemberDetails from '@salesforce/apex/RaiseTeamController.getTeamMemberById';
import apex_editTeamMemberDetails from '@salesforce/apex/RaiseTeamController.editTeamMember';
import apex_addTeamMember from '@salesforce/apex/RaiseTeamController.createTeamMember';
import apex_linkFileToTeamMember from '@salesforce/apex/FileUploadController.linkContentDocument';
export default class RaiseAddTeamMemberModal extends LightningElement {
    //raise record ID
    @api recordId

    // ID of the media link
    @api memberId

    // controls the core-button variation
    @api variation

    // controls the button label
    @api label

    // controls the title of the modal
    @api name

    @api category


    // Controls the mode (Add | Edit)
    @track mode = 'Add'
    @track isLoading = false;
    @track formData;

    roleOptions=[
        {id:1, label:"Advisor", value:'Advisor', checked:false},
        {id:2, label:"Ambassador", value:'Ambassador', checked:false},
        {id:3, label:"Key investor", value:'Key investor', checked:false},
    ]

     /**
     * Determines whether to display the role text input.
     * @returns {boolean} - Returns true if the category is not 'Advisors', otherwise false.
     */
    get displayRoleText(){
        if(this.category === 'Advisors'){
            return false
        }else{
            return true
        }
    }

    /**
     * Handles the form submission.
     * Creates or edits a team member based on the current mode.
     * @param {Event} e - The form submission event.
     */
    handleFormSubmit(e){
        this.isLoading = true;
        this.formData = {...e.detail.formData};
        if(this.mode==='Edit' && this.memberId){
            this.editTeamMemberDetail(this.memberId, this.formData.name, '', this.formData.description, this.formData.linkedIn, this.formData.role).then((result)=>{
                if(result){
                    this.dispatchSaveEvent(result)
                }else{
                    console.error("Failed to edit team member")
                }
            }).then(()=>{
                this.refs.coremodal.handleClose();
                this.isLoading = false;
            }).catch(err => console.error(err))
        }else if(this.mode === 'Add'){
            this.addTeamMember(this.recordId, this.formData.name, this.category, '', this.formData.description, this.formData.linkedIn, this.formData.role).then((result)=>{
                if(result){
                    this.memberId = result.id;
                }else{
                    console.error('Failed to add team member')
                }
            }).then(async ()=>{
                let fileData = [...this.formData.headshot]
                
                for(let file of fileData){
                    let linkFile = await apex_linkFileToTeamMember({contentDocumentId:file.fileId,recordId:this.memberId});
                }
            }).then(()=>{                
                this.dispatchSaveEvent()
                this.clearForm();
                // close modal;
                this.refs.coremodal.handleClose();
                this.isLoading = false;
            })
        }

        
    }

    /**
     * Clears the form data.
     */
    clearForm(){
        this.memberId = null;
        this.formData = {};
    }

    /**
     * Dispatches a custom event when a team member is saved.
     * @param {Object} saveData - The saved team member data.
     */
    dispatchSaveEvent(saveData){
        const mediaLinkUpdated = new CustomEvent('saved',{
            detail: saveData,
            bubbles: true,
        });
        this.dispatchEvent(mediaLinkUpdated);
    }

    createFileList(changedFiles){
        let files = [];
        if(this.changedFiles.length > 0){
            for(fileRecord of changedFiles){
                files.push(fileRecord.file)
            }
        }

        return files;
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
     * Retrieves team member details by ID.
     * @param {string} memberId - The ID of the team member.
     * @returns {Promise} - Resolves with the team member data.
     */
    getMemberDetails(memberId){
        return new Promise(async(resolve,reject)=>{
            let result  = await apex_getTeamMemberDetails({teamMemberId: memberId});
            if(result){
                resolve(result)
            }else{
                reject("Team member not found");
            }
        })
    }

    /**
     * Edits a team member's details.
     * @param {string} memberId - The ID of the team member.
     * @param {string} name - The name of the team member.
     * @param {string} picture - The picture of the team member.
     * @param {string} description - The description of the team member.
     * @param {string} linkedIn - The LinkedIn URL of the team member.
     * @param {string} role - The role of the team member.
     * @returns {Promise} - Resolves with the edited team member data.
     */
    editTeamMemberDetail(memberId, name,  picture, description, linkedIn, role){
        return new Promise(async(resolve,reject)=>{
            let result  = await apex_editTeamMemberDetails({
                teamMemberId: memberId,
                name : name,
                picture : '',
                description: description,
                linkedIn : linkedIn,
                role : role,
            });
            if(result){
                resolve(result)
            }else{
                reject("Team member not found");
            }
        })
    }

    /**
     * Adds a new team member.
     * @param {string} raiseId - The ID of the raise record.
     * @param {string} name - The name of the team member.
     * @param {string} category - The category of the team member.
     * @param {string} picture - The picture of the team member.
     * @param {string} description - The description of the team member.
     * @param {string} linkedIn - The LinkedIn URL of the team member.
     * @param {string} role - The role of the team member.
     * @returns {Promise} - Resolves with the added team member data.
     */
    addTeamMember(raiseId, name, category, picture, description, linkedIn, role){
        return new Promise(async(resolve,reject)=>{
            let result = await apex_addTeamMember({
                raiseId: raiseId,
                name : name, 
                category : category,
                picture : picture,
                description : description, 
                linkedIn: linkedIn, 
                role : role
            })

            if(result){
                resolve(result)
            }else{
                reject("Could not add team member")
            }
        })
    }
    
    /**
     * Lifecycle hook that runs when the component is connected to the DOM.
     * Initializes the component based on the record ID and team member ID.
     */
    connectedCallback(){

        if(this.memberId){
            this.mode = 'Edit'
            this.isLoading = true;
            this.getMemberDetails(this.memberId).then((result)=>{
                let newData = {
                    name : result.name,
                    role: result.role,
                    description : result.description,
                    linkedIn : result.linkedIn
                }
                this.formData = {...newData}
                this.isLoading = false;

            }).catch((err)=>{
                console.error(err);
                this.isLoading = false;

            })
        }else{
            this.mode = 'Add'
        }

    }
}