import { LightningElement, api } from 'lwc';

export default class HeroBannerBlogDropdown extends LightningElement {

    @api backgroundimageurl;
    @api bannerTitle;
    @api HealthTech;
    @api FoodTech;
    @api Renewables;
    @api Lifestyle;
    @api Property;
    @api Crowdfunding;
    @api Invest;
    @api News;
    @api PropTech;
    @api PropertyFunds;
    @api PropertyResidential;
    @api Ventures;
    @api BioTech;
    @api MedTech;
    @api AgTech;
    @api FinTech;
    @api EdTech;
    @api CleanTech;
    @api ESG;
    @api investorHub;
    @api web3;
    @api HealthTechurl;
    @api FoodTechurl;
    @api Renewablesurl;
    @api Lifestyleurl;
    @api Propertyurl;
    @api Crowdfundingurl;
    @api Investurl;
    @api Newsurl;
    @api PropTechurl;
    @api PropertyFundsurl;
    @api PropertyResidentialurl;
    @api Venturesurl;
    @api BioTechurl;
    @api AgTechurl;
    @api MedTechurl;
    @api FinTechurl;
    @api EdTechurl;
    @api CleanTechurl;
    @api ESGurl;
    @api investorHuburl;
    @api web3url;
    

    get getbackgroundImgStyling() {
        return `background-image:url('${this.backgroundimageurl}')`;
    }
}