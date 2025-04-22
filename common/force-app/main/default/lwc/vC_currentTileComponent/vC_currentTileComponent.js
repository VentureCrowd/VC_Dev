import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class VC_currentTileComponent extends NavigationMixin(LightningElement)  {
    @api tile;
    connectedCallback(){
        this.tile = JSON.parse(JSON.stringify(this.tile));
        console.log(this.tile);
    }
    handleClick(evt){
        if(evt.target.dataset.redirecttype == 'filesRelatedlist'){
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name : 'file_Preview_test__c'
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
    redirectrToRecord(evt){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: evt.target.dataset.id,
                actionName: 'view'
            },
        });
    }
}