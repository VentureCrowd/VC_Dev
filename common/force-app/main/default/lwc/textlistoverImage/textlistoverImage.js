import { LightningElement,api } from 'lwc';

class text {
    constructor(imageUrl, header, description){
        this.imageUrl = imageUrl;
        this.header = header;
        this.description = description;
    }
}

export default class TextlistoverImage extends LightningElement {
    @api backgroungimage;
    @api masterHeading;
    @api masterDescription;

    @api headingList;
    @api descriptionList;
    
    count=['1','2','3','4','5','6','7','8','9','10'];

    imageUrlSplit=[];
    headingSplit=[];
    descriptionSplit=[];

    textArray=[];

    get backgroundImgStyling() {
        if(this.backgroungimage){
           return `background-image:url('${this.backgroungimage}')`; 
        } else {
            return 'background-color: Gainsboro;';
        }
    }

    connectedCallback(){

        this.imageUrlSplit = this.imageUrlList != undefined ? this.imageUrlList.split(','): undefined;
        this.headingSplit = this.headingList != undefined ? this.headingList.split(',') : undefined;
        this.descriptionSplit = this.descriptionList != undefined ? this.descriptionList.split('--tabSplit--') : undefined;

        if(this.headingList.length > 0 && this.headingList != undefined){
            for(let i = 0; i < this.headingSplit.length; i++){
                
                this.textArray.push(new text(
                   this.count[i], this.headingSplit[i], this.descriptionSplit[i]
                ));
            }

        } 
    }
    

}