import { LightningElement, api } from 'lwc';
import apex__getRecordType from '@salesforce/apex/RaiseController.getRaiseRecordType';


export default class RaiseContainer extends LightningElement {
    @api recordId;
    @api isPreview;
    isFund;
    isVenturesRaise;

    getRecordType(raiseId) {
        apex__getRecordType({raiseId: raiseId})
            .then(result => {
                this.assignRaiseType(result);
            })
    }

    getQueryParameters() {
        return new Promise((resolve,reject)=>{
            var params = {};
            var search = location.search.substring(1);

            if (search) {
                params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
                    return key === "" ? value : decodeURIComponent(value)
                });
            }
            resolve(params);
        })
    }
    async connectedCallback() {
        let raiseId = this.recordId;
        if (this.isPreview) {
            await this.getQueryParameters().then((result) => {
                raiseId = result?.id;
            });
        }
        this.getRecordType(raiseId);
    }

    assignRaiseType(value) {
        switch (value) {
            case 'Fund':
                this.isFund = true;
                break;
            case 'Primary_Raise':
                this.isVenturesRaise = true;
                break;
            default:
                this.isVenturesRaise = true;
        }
    } 
}