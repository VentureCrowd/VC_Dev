import { LightningElement,api,track } from 'lwc';

export default class InvestmentFeatures extends LightningElement {
    @api columnWidth;
    @api featureValues;
    @api componentBackgroundColor;
    @track displayFeatures;
    features;
    layoutSize = '6';

    connectedCallback() {
        if (this.featureValues) {
            try {
                let features = JSON.parse(this.featureValues),
                    featureSplit = Array.from({ length: features.length / parseInt(this.columnWidth) }, (_, i) => features.slice(i * parseInt(this.columnWidth), i * parseInt(this.columnWidth) + parseInt(this.columnWidth))),
                    featureArray = [];

                    //Create Feature Array
                    featureSplit.forEach((number, index) => {
                        featureArray.push({'Id':index,'feature':number});
                    });

                this.features = featureArray;
                this.displayFeatures = true;
                
            } catch (error) {
                console.log(error);
            }
        }
    }

    get getSectionStyle() {
        return `background-color:${this.componentBackgroundColor}`;
    }

    get getGridClass() {

        switch (this.columnWidth) {
            case '1':
                return 'col-12'; 
                break;
            case '2':
                return 'col-6'; 
                break;    
            case '3':
                return 'col-4'; 
                break;
            default:
                return 'col'; 
                break;
        }
        
    }
    
}