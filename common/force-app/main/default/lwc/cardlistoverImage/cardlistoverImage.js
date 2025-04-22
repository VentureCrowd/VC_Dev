import { LightningElement,api, track } from 'lwc';

class card {
    constructor(imageUrl, header, description) {
        this.imageUrl = imageUrl;
        this.header = header;
        this.description = description;
    }
}

export default class CardlistoverImage extends LightningElement {
    @api backgroungimage;
    @api masterHeading;
    @api masterDescription;

    @api imageUrlList;
    @api headingList;
    @api descriptionList;

    imageUrlSplit=[];
    headingListSplit=[];
    descriptionSplit=[];
    cardsArray=[];
    @track windowWidth;

    get backgroundImgStyling() {
        if(this.backgroungimage) {
            return `background-image:url('${this.backgroungimage}')`;
        } else {
            return 'background-color: rgba(227, 233,237, 1);';
        }
    }

    @track hasRendered = true;
    connectedCallback(){
        this.imageUrlSplit = this.imageUrlList != undefined ? this.imageUrlList.split(','): undefined;
        this.headingListSplit = this.headingList != undefined ? this.headingList.split(',') : undefined;
        this.descriptionSplit = this.descriptionList != undefined ? this.descriptionList.split(',,') : undefined;

        if(this.imageUrlSplit.length > 0 && this.imageUrlList.length != undefined) {
            for(let i = 0; i < this.imageUrlSplit.length; i++) {
                this.cardsArray.push(new card(
                    this.imageUrlSplit[i], this.headingListSplit[i], this.descriptionSplit[i]
                    ));
                console.log('pushed ' + i);
            }
            console.log('this.cardsArray.length ' + this.cardsArray.length);
            console.log(this.cardsArray);
        }

        window.addEventListener('resize', this.computeformfactor.bind(this));
        this.windowWidth = window.innerWidth;
    }

    computeformfactor() {
        this.windowWidth = window.innerWidth;
        eval("$A.get('e.force:refreshView').fire();");
        console.log('window.width ' + this.windowWidth);
    }

    get cardClass() {
        let cardClass = 'slds-card__body slds-card__body_inner slds-grid slds-p-vertical_large ';
        if(this.windowWidth < 439) {
            return cardClass + 'cardOverride';
        } else {
            return cardClass;
        }
    }
    get imageClass() {
        let imageColSize = 'slds-col slds-size_2-of-12 ';

        if(this.windowWidth > 767) {
            return imageColSize + 'slds-p-right_x-large';
        } if(this.windowWidth <= 767 && this.windowWidth > 575) {
            return imageColSize + 'slds-p-right_medium';
        } else if (this.windowWidth <= 575 && this.windowWidth > 486) {
            return imageColSize + 'slds-p-right_small';
        } else if (this.windowWidth <= 486) {
            return imageColSize + 'slds-p-right_xx-small';
        }
    }

    renderedCallback() {
        if (this.hasRendered) {
            this.hasRendered = false;
        }
    }

}