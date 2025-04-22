import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class VC_genericTileComponent extends NavigationMixin(LightningElement)  {
    @api tile;
    @track fieldArrayLength;

    connectedCallback(){
        this.tile = JSON.parse(JSON.stringify(this.tile));
        this.fieldArrayLength=(100/this.tile.fieldDataSet.length) + "%";
    }
    get divStyle() {
        if(this.tile?.fieldDataSet?.length > 4){
            this.fieldArrayLength = '25%';
            return `width:25%;padding-bottom: 10px;`;
        }else{
            return `width:25%`;
        }
       
    }

    handleClick(evt){
        if(evt.target.dataset.redirecttype == 'filesRelatedlist'){
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name : 'Files__c'
                },
                state: {
                    id: evt.target.dataset.id
                }
            });
        }else{
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: evt.target.dataset.id,
                    objectApiName: 'Investment__c',
                    actionName: 'view'
                },
            });
        }
    }
}