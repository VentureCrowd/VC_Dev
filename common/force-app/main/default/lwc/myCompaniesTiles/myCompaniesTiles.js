/*********************************************************************************************************************************************
Author		 :	 Prakash Borade
Description	 :   MyCompaniesTile is parent component used to create new company and show my companies tile.
Child Component   :   CreatedNewCompany LWC , CompaniesCard LWC
----------------------------------------------------------------------------------------------------------------------------------------------
Version      Date                 Author               Details
1            12/21/2023           Prakash Borade       Initial Development
2            06/06/2024           Cesar was here       Rebuild Companies Tiles
**********************************************************************************************************************************************/


import { LightningElement, track} from 'lwc';
import getMyCompanies from "@salesforce/apex/MyCompaniesController.getMyCompanies";
import Id from '@salesforce/user/Id';
import IMAGES from "@salesforce/resourceUrl/noCompanies";

export default class MyCompaniesTiles extends LightningElement {
    @track userHasCompanies = false;
    @track showCompaniesLst;
    @track loggedInUserId = Id;
    @track companies;
    @track companyLogo;

    connectedCallback() { 
        this.getMyCompanies();
        this.companies = this.showCompaniesLst;
        this.companyLogo = IMAGES + '/noCompanysimg.png'
    }

    // fetching all companies for logged in user using getMyCompanies apex method
    getMyCompanies() { 
        getMyCompanies({ loggedInUserId : this.loggedInUserId })
        .then(result =>{
            if(result) { 
                if(result.length) { 
                    this.userHasCompanies = true;
                    this.showCompaniesLst = result;
                    this.companies = this.showCompaniesLst;
                }
            }
        })
        .catch(e => {
            console.log('error in getting companies')
        })
    }

    // function to open FAQ page in new tab
    openFaqPage() {
        // URL to open in a new tab
        const url = 'https://www.venturecrowd.com.au/s/learn/faq/founder-portal';
        
        // Open URL in a new tab
        window.open(url, '_blank');
    }
    
     // function to open See example page in new tab
    openSeeExamplePage() { 
        const url = 'https://www.venturecrowd.com.au/s/lp/example-eoi ';
        
        // Open URL in a new tab
        window.open(url, '_blank');
    }
    
}