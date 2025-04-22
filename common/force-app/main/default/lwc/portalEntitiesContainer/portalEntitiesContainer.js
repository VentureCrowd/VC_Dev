import { LightningElement ,track,api} from 'lwc';
import apex_getEntities from '@salesforce/apex/EntitiesController.getRelatedBusinessAccounts';
import apex_contactId from '@salesforce/apex/EntitiesController.getContactId';

import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class PortalEntitiesContainer extends NavigationMixin(LightningElement){

    @track contactId;
    @track entities=[];
    @track isLoading;

    get noEntities(){
        return this.entities.length <= 0;
    }

    connectedCallback(){
        this.isLoading = true;
        apex_contactId().then((res)=>{
            this.contactId = res;
            console.log('cid',res);

            this.getEntities(this.contactId).then((res)=>{
                console.log("Entities:", JSON.stringify(res));

                this.entities = [...res];

                this.isLoading = false;

            }).catch((err)=>{
                this.showToast('Error','Error getting accounts. Please contact your system administrator','error')
                this.isLoading = false
            })

        }).catch((err)=>{
            this.showToast('Error','Error getting accounts. Please contact your system administrator','error')
            this.isLoading = false
        })
       
    }

    getEntities(contactId){
        return new Promise(async(resolve,reject)=>{
            try{
                let retData = await apex_getEntities({contactId: contactId});

                resolve(retData);

            }catch(err){        
                reject(err);
            }
        })
    }

    navigateToRecordDetail(e){

        console.log('navigate',JSON.stringify(e.currentTarget.dataset));
        const accId = e?.currentTarget?.dataset?.id;

        if(accId){
            console.log(accId);
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId : accId,
                    objectApiName : 'Account_Detail__c',
                    actionName : 'view'
                },
            })
        }else{
            this.showToast('Error', 'Error viewing account details. Please contact your system administrator', 'error');
        }
        
    }

    /**
     * Displays a toast message.
     * @param {string} title - The title of the toast message.
     * @param {string} message - The message content of the toast.
     * @param {string} variant - The variant of the toast message, e.g., 'error', 'success'.
     */
    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(toastEvent);
    }
}