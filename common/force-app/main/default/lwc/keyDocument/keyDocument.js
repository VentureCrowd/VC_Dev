import { LightningElement,api,track } from 'lwc';
import retrieveRelatedFiles from '@salesforce/apex/KeyDocumentController.retrieveRelatedFiles';
import PUBLICURL from '@salesforce/label/c.VC_CF_Public_URL';

export default class KeyDocument extends LightningElement {
    @api productId;
    @track productFiles;
    @track displayFiles = false;
    @track isModalOpen = false;
    registerURL = PUBLICURL + '/login/SelfRegister';
    async connectedCallback() {

        try {
            const retrievedRecords = await retrieveRelatedFiles({'ProductId':this.productId});
            this.productFiles = retrievedRecords;
            this.displayFiles = true;
            
        } catch (error) {
            console.log(error);
        }

    }

    handleLogin() {
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false
    }

    handleLoginClick() {
        //https://investor.venturecrowd.com.au/login?s
        let windoworigin = window.location.origin,
            refererUrl = window.location.href;
        window.location.assign(`${windoworigin}/s/login/?startURL=${refererUrl}`);
        // window.location.assign(`https://investor.venturecrowd.com.au/login?referer=${refererUrl}`);
        

        // https://investor.venturecrowd.com.au/login?referer=http://investor.venturecrowd.com.au/investor/dashboard/index
    }


}