import { LightningElement, api, wire, track } from 'lwc';
import fetchNewsList from '@salesforce/apex/CustomBlogSideBarCntrl.fetchNewsList';
import { NavigationMixin } from 'lightning/navigation';

export default class CustomBlogSideBar extends NavigationMixin(LightningElement) {

    @api titleText;
    @api titleTextColor;
    @api eachLinkTextColor;
    @api redirectText;
    @api redirectURL;

    @track lstNewsListPages = [];
    @track lstArchiveMonthly = [];
    @track error;

    colorCombination = { 'Teal': '#05c5d1', 'Pink': '#dd5cff', 'Grey': '#999' };

    connectedCallback() {
        try {
            fetchNewsList()
                .then(result => {
                    if (result.hasOwnProperty('lstNewsListPages')) {
                        this.lstNewsListPages = result['lstNewsListPages'];
                    }

                    if (result.hasOwnProperty('mapArchiveMonthly')) {
                        let mapArchiveMonthly = result.mapArchiveMonthly;
                        let tempLstArc = [];
                        for(var key in mapArchiveMonthly) {
                            tempLstArc.push({'key' : key, 'value' : mapArchiveMonthly[key]});
                        }
                        this.lstArchiveMonthly = tempLstArc;
                    }
                })
                .catch(error => {
                    console.log('*** Error Occured in getting data from Salesforce. *** ', error.message);
                });
        } catch (ex) {
            console.log('*** Exception Occured on Connected Callback *** ', ex.message);
        }
    }

    redirectToMonthlyArchive(event) {
        let lstmonthParam = (event.target.dataset.url).split(' ');
        this[NavigationMixin.GenerateUrl]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'archivewithcategories'
            },
            state: {
                month : lstmonthParam[0],
                year : lstmonthParam[1]
            }
        }).then((url) => {
            console.log(url);
            window.location.href = url;
        });
    }

    get getTitleStyling() {
        return 'color:' + (this.titleTextColor ? (this.colorCombination)[this.titleTextColor] : 'black');
    }

    get getLinkStyling() {
        return 'color:' + (this.eachLinkTextColor ? (this.colorCombination)[this.eachLinkTextColor] : 'black');
    }
}