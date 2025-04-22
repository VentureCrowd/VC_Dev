import { api, LightningElement } from 'lwc';

export default class VcProductLwc extends LightningElement {

@api product;
@api showOfferButton;

get bannerstyle(){
    return `background-image: url(${this.product.Tile_Banner__c})`;
}
}