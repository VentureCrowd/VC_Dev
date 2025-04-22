/* eslint-disable dot-notation */
import { LightningElement, api, wire, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import { CurrentPageReference } from 'lightning/navigation';

import getEoiDetails from '@salesforce/apex/MyEOIController.getEoiDetails';
import getFounders from "@salesforce/apex/MyEOIController.getTeamMembers";
import getTeamMembers from "@salesforce/apex/MyEOIController.getTeamMembers";
import getMediaLinks from "@salesforce/apex/MyEOIController.getMediaLinks";
import getLeadInvestors from "@salesforce/apex/MyEOIController.getLeadInvestor";
import socialMediaIcons from "@salesforce/resourceUrl/SocialMediaIcons"

//? Import the Caxton and Monserrat fonts
import VC_MasterCss_New from '@salesforce/resourceUrl/VC_MasterCss_NewTemp';
export default class EoiPreviewFinal extends LightningElement {
    
    @track trust;
    @api EOI_ID;
    @api showPreview;
    @track eoiId;
    @track eoiData = {};
    @track lstAdvisor = [];
    @track lstManagementTeamMember = [];
    @track lstFounders = [];
    @track lstMediaLinks = [];
    @track lstLeadInvestors = [];
    @track EOI_Status__c;
    @track youtubeVideoLink;

    // TTIIASST-24 - KEN
    @track isFund;


    //* Url of the images
    @track logo;
    @track banner;
    @track SupportingImage1;
    @track SupportingImage2;
    @track SupportingImage3;

    @track urlJSON

    hasFounder = true;

    currentPageReference = null;

    //? Import the icons from static resources | SocialMediaIcons
    instagramIcon = socialMediaIcons + '/Orion_instagram.svg';
    xIcon = socialMediaIcons + '/Orion_X.svg';
    facebookIcon = socialMediaIcons + '/Orion_facebook.svg';
    websiteIcon = socialMediaIcons + '/Orion_world-globe.svg';
    youtubeIcon = socialMediaIcons + '/Orion_youtube.svg';
    linkedinIcon = socialMediaIcons + '/Orion_linkedin.svg';
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.eoiId = currentPageReference.state.id;
        }
    }

    @wire(getEoiDetails, { eoiId: '$eoiId' })
    wiredData(result) {
        if (result.data) {
            this.eoiData.EOI_Title__c = result.data.EOI_Title__c;
            this.eoiData.One_liner_about_business__c = result.data.One_liner_about_business__c;
            this.eoiData.EOI_Subtitle__c = result.data.EOI_Subtitle__c	;
            this.eoiData.Offer_Overview__c = result.data.Offer_Overview__c;
            this.eoiData.Problem_or_opportunity__c = result.data.Problem_or_opportunity__c;
            this.eoiData.Solution__c = result.data.Solution__c;
            this.eoiData.Differentiation__c = result.data.Differentiation__c;
            this.eoiData.Intellectual_Property__c = result.data.Intellectual_Property__c;
            this.eoiData.Total_addressable_market__c = result.data.Total_addressable_market__c;
            this.eoiData.Progress__c = result.data.Progress__c;
            this.eoiData.Growth_plan__c = result.data.Growth_plan__c;
            this.eoiData.Instagram_link__c = result.data.Instagram_link__c;
            this.eoiData.Youtube_link__c = result.data.Youtube_link__c;
            this.eoiData.Facebook_link__c = result.data.Facebook_link__c;
            this.eoiData.Linkedin_link__c = result.data.Linkedin_link__c;
            this.eoiData.Twitter_X_link__c = result.data.Twitter_X_link__c;
            this.eoiData.Company_Website_link__c = result.data.Company_Website_link__c;
            this.eoiData.Website_link__c = result.data.Website_Link__c;
            this.eoiData.Company_Stage__c = result.data.Company_Stage__c;
            this.eoiData.Target_Raise_Amount__c = result.data.Target_Raise_Amount__c;
            this.eoiData.Raise_Contact_email__c = result.data.Raise_Contact_email__c;
            this.eoiData.Planned_used_of_funds__c = result.data.Planned_used_of_funds__c;
            this.eoiData.EOI_Status__c = result.data.EOI_Status__c;
            this.eoiData.EOI_Published_Date__c = result.data.EOI_Published_Date__c;
            this.eoiData.URL_Files_Img__c = result.data.URL_Files_Img__c
            this.eoiData.Minimum_Investment_amount__c = result.data.Minimum_Investment_amount__c;

            // TTIIASST-24 - KEN
            this.isFund = result.data.Is_Fund__c;
            this.eoiData.Fund_Structure__c = result.data.Fund_Structure__c;
            this.eoiData.Tax_Concessions__c = result.data.Tax_Concessions__c;
            this.eoiData.Investment_Objective__c = result.data.Investment_Objective__c;
            this.eoiData.Investment_Strategy__c = result.data.Investment_Strategy__c;
            this.eoiData.Portfolio_Size__c = result.data.Portfolio_Size__c;
            this.eoiData.Investment_Period__c = result.data.Investment_Period__c;
            this.eoiData.Fund_Term__c = result.data.Fund_Term__c;
            this.eoiData.First_Close_Amount__c = result.data.First_Close_Amount__c;

            if (result.data.Youtube_Video_Link__c) {
                let videoLink = result.data.Youtube_Video_Link__c
                let videoId
                
                // Append the https if the link do not have it
                if (!videoLink.startsWith('http://') && !videoLink.startsWith('https://')) {
                    videoLink = 'https://' + videoLink;
                }
                
                const urlObj = new URL(videoLink);

                if (urlObj.hostname === 'youtu.be') {
                     // Extract video ID
                    videoId = urlObj.pathname.substring(1);
                } else if (urlObj.hostname.includes('youtube.com')) {
                    videoId = urlObj.searchParams.get('v');
                }

                if (videoId) {
                    this.youtubeVideoLink = `https://www.youtube.com/embed/${videoId}`;
                }
            }

            //* Parse the JSON from the field URL_Files_Img__c | The JSON thwrows a title and public url
            if (this.eoiData.URL_Files_Img__c !== undefined){
                const imagesArray = JSON.parse(this.eoiData.URL_Files_Img__c);
                //* Assign the images according to the title
                imagesArray.forEach(image => {
                    switch(image.title) {
                        case 'logo':
                            this.logo = image.contentDownloadURL;
                            break;
                        case 'Banner':
                            this.banner = image.contentDownloadURL;
                            break;
                        case 'supportingImage1':
                            this.SupportingImage1 = image.contentDownloadURL;
                            break;
                        case 'supportingImage2':
                            this.SupportingImage2 = image.contentDownloadURL;
                            break;
                        case 'supportingImage3':
                            this.SupportingImage3 = image.contentDownloadURL;
                            break;
                    }
                });
            }        
        } else if (result.error) {
            console.error('Error in fetching EOI data', result.error);
        }
    }

    //? Get and return true the status of the EOI

    get notPublished() {
        return this.eoiData.EOI_Status__c === 'Not Published' && this.showPreview;
    }
    
    get publishing() {
        return this.showPreview && this.eoiData.EOI_Status__c === 'Submitted to be Published';
    }


    //? Get the email of the EOI Company
    get mailtoLink() {
        return `mailto:${this.eoiData.Raise_Contact_email__c}`;
    }


    @wire(getMediaLinks, { eoiId: '$eoiId' })
    mediaLinks(result) {
        if (result.data) {
            
            this.lstMediaLinks = [];
            this.lstMediaLinks = result.data;
        } else if (result.error) {
            console.error('Error in getting media links', result.error);
        }
    }

    @wire(getLeadInvestors, { eoiId: '$eoiId' })
    leadInvestors(result) {
        if (result.data) {
            this.lstLeadInvestors = [];
            this.lstLeadInvestors = result.data;
        } else if (result.error) {
            console.error('Error in getting lead investors', result.error);
        }
    }

    @wire(getTeamMembers, { category:'Management Team', eoiId: '$eoiId' })
    managementTeamMembers(result) {
        if (result.data) {
            this.lstManagementTeamMember = [];
            this.lstManagementTeamMember = result.data;
        } else if (result.error) {
            console.error('Error in getting team member'. result.error);
        }
    }

    scrollToSection() {
        const topDiv = this.template.querySelector('[data-id="formSection"]');
        topDiv.scrollIntoView({behavior: "smooth", block: "center", inline: "nearest"});
    }

    @wire(getTeamMembers, { category:'Advisors', eoiId: '$eoiId' })
    advisors(result) {
        if (result.data) {
            this.lstAdvisor = [];
            this.lstAdvisor = result.data;
        } else if (result.error) {
            console.error('Error in getting team member', result.error);
        }
    }

    connectedCallback() {
        if (!this.showPreview) {this.eoiId = this.EOI_ID;}
        this.lstManagementTeamMember = [];
        this.lstAdvisor = [];
        this.getFounders();
        }

        
    // Prakash - use wire for this
    async getFounders() {
        await getFounders({
            category: 'Founder',
            eoiId: this.eoiId
            }).then(result => {
                this.lstFounders = [];
                if (result && result.length) {
                    // this.lstFounders = 
                    // Duplicating the existing array of founders and the sorting by the order field
                    this.lstFounders = result.map(item => ({ ...item })).sort((a, b) => a.Order__c - b.Order__c);
                } else {
                    this.hasFounder = false;
                }
        })
        .catch(error => {
            console.error('error in getting founders ',error)
        })
    }

    get websiteLink() {
        // Check if the Website_Link__c field exists and does not start with "https://"
        if (this.eoiData.Website_link__c && !this.eoiData.Website_link__c.startsWith('https://')) {
            // Add "https://" to the beginning of the Website_Link__c value
            return 'https://' + this.eoiData.Website_link__c;
        }
        // If the field already starts with "https://", return it as is
        return this.eoiData.Website_link__c;
    }
    


    //? Return true if all fields are completed - Cesar
    get isSectionVisible() {
        return this.eoiData && (
            this.eoiData.Company_Stage__c ||
            this.eoiData.Target_Raise_Amount__c ||
            this.eoiData.Planned_used_of_funds__c ||
            this.eoiData.Raise_Contact_email__c ||
            this.hasLeadInvestors
        );
    }

    get isCompanyHighlightsVisible() {
        return this.eoiData && (
            this.eoiData.Problem_or_opportunity__c || this.eoiData.Solution__c || this.eoiData.Differentiation__c || 
            this.eoiData.Intellectual_Property__c || this.eoiData.Total_addressable_market__c || this.eoiData.Progress__c ||
            this.eoiData.Growth_plan__c
        );
    }

    get isTeamVisible() {
        return this.eoiData && (
            this.lstFounders && this.lstFounders.length > 0  ||
            this.lstManagementTeamMember && this.lstManagementTeamMember.length > 0 ||
            this.lstAdvisor && this.lstAdvisor.length > 0
        );
    }

    get isMediaLinksVisible() {
        return this.eoiData && (
            this.lstMediaLinks || this.lstMediaLinks.length > 0 || this.eoiData.Website_link__c || this.eoiData.Facebook_link__c 
            || this.eoiData.Instagram_link__c ||this.eoiData.Linkedin_link__c || this.eoiData.Twitter_X_link__c || this.eoiData.Youtube_link__c
        );
    }

    get isIntendedRaiseVisible() {
        return this.eoiData && (
            this.eoiData.Intended_Raise_Amount__c || this.eoiData.Target_Raise_Amount__c || this.eoiData.Intended_used_of_funds__c ||
            this.eoiData.Raise_Contact_email__c || this.eoiData.Company_Stage__c
        );
    }
    get isFounderVisible() {return this.lstFounders && this.lstFounders.length > 0;}

    get isManagementTeamVisible() {return this.lstManagementTeamMember && this.lstManagementTeamMember.length > 0;}

    get isAdvisorVisible() {return this.lstAdvisor && this.lstAdvisor.length > 0;}

    get isLeadInvestorVisible() {return this.lstLeadInvestors && this.lstLeadInvestors.length > 0;}

    //? Return the background banner

    get bannerStyle() {
        return `background-image: url(${this.banner});`;
    }

    returnToEdit() {
        if (this.eoiData.EOI_Status__c === 'Not Published') {
            window.location.href = '/s/portal/my-companies/edit-eoi?edit=' + this.eoiId;
        } else {
            window.location.href = '/s/portal/my-companies'
        }
    }
}