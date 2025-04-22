import { LightningElement, track, api } from 'lwc';
// Dummy data import

import apex__getRaisePageFields from '@salesforce/apex/RaiseController.getRaisePageDetailsRaiseId';
import apex_getTeamMembersList from '@salesforce/apex/RaiseTeamController.getTeamMembersByRaiseId';
import apex_getPublicImageUrl from '@salesforce/apex/FileUploadController.getPublicImageUrl';
import apex_getMediaLink from '@salesforce/apex/MediaLinkController.getMediaLinksByRaiseId';
import apex_getRaiseStatus from '@salesforce/apex/RaiseController.getRaiseStatuses';

import get_documents from '@salesforce/apex/FileUploadController.getDocumentsUrl';
import get_user from '@salesforce/apex/RaiseController.userLoggedIn'

import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { investProductTypeMapping } from './overviewTypeFields'; 
import { getOfferTextMapping } from './offerSectionText';

/**
 * Add this to fire an event to send the GTA data (Experience Builder - Head Markup)
 * document.addEventListener('lwc_investgtaevent', (e) => {
        // Trigger Google Analytics Event
        window.gtag('event', 'InvestmentConversion', {
            event_category: 'Investment Conversion',
            // Track the full URL for attribution
            event_label: e.detail.url,  
            ...e.detail.urlParameters,
            product_name: e.detail.productName,
        });
    });
 */

export default class RaiseFund extends NavigationMixin(LightningElement) {
    @track raiseDetails = {};
    @track productId;
    @api isLoading = false;
    @track error;

    //Stores record ID from the object page
    @api recordId
    
    //Store an array of objects of social media icons.
    @track socialMedia

    //Store an array of object of the team members
    @track managementTeam;
    @track advisors;
    
    //Store an array of object of the media links
    @track mediaLinks =[];
    @track closeDate;

    //Use this variable for fields
    @track files;
    // Use this for track if its whole sale or retail
    @track investType;

    //Used to track the investmentProductType
    @track investProductType

    // This is used to get the values of the overview table
    @track overviewData;

    @track userLogged = false;

    // Used to know if the deal is live or not
    @track dealLive;

    // Set initial values
    @track values = { minimumTarget: 0, RaisedAmount: 0 };
    @track queryParameters;
    @track raiseStatus;
    @api isPreview;

    @track activeTab = 'fees';
    @track plannedUseFonds;
    @track capitalRequired;

    @track raiseId;

    // INFSD OFFER TEXT CHANGE
    @track offerText;

    // SHOW/HIDE COMMENTS
    showComments;

    // CORE TOAST MODIFICATION - KENDRICK
    errorTitle;
    errorBody;
    errorBodyFields = [];

    // NO FEES PAYABLE FEATURE
    noFeesPayable = false;

    // Navigation links for retail
    navLinksRetail = [
        { name: 'offer', label: 'The Offer' },
        { name: 'problem-market', label: 'Problem & Market' },
        { name: 'solution', label: 'The Solution' },
        { name: 'differentiation', label: 'Differentiation' },
        { name: 'intellectual-property', label: 'Intellectual Property' },
        { name: 'total-addressable-market', label: 'Total Addressable Market' },
        { name: 'progress', label: 'Progress' },
        { name: 'growth', label: 'Growth' },
        { name: 'valuation-capital-required', label: 'Capital Required' },
        { name: 'valuation-capital-required', label: 'Valuation' },
        { name: 'team-advisors', label: 'Team & Advisors' },
        { name: 'media', label: 'Media' },
        { name: 'fees', label: 'Fees' }
    ];

    // Navigation links for wholesale
    navLinksWholesale = [
        { name: 'offer', label: 'The Offer' },
        { name: 'problem-market', label: 'Problem & Market' },
        { name: 'solution', label: 'The Solution' },
        { name: 'differentiation', label: 'Differentiation' },
        { name: 'intellectual-property', label: 'Intellectual Property' },
        { name: 'total-addressable-market', label: 'Total Addressable Market' },
        { name: 'progress', label: 'Progress' },
        { name: 'growth', label: 'Growth' },
        { name: 'team-advisors', label: 'Team & Advisors' },
        { name: 'media', label: 'Media' },
        { name: 'fees', label: 'Fees' }
    ];

    get advisorsExist(){
        return this.advisors ? this.advisors.length > 0 : false;
    }

    get isConvertibleNote(){
        return this.investProductType === 'Convertible Note';
    }


    get isWholesaleOrdinaryShare() {
        return this.investProductType === 'Ordinary Shares' && this.investType==='Wholesale';
    }

    /**
     * Get method to check if the raise is live.
     * @returns {boolean} - True if the raise is live, otherwise false
     */
    get isLive(){
        return ((this.raiseStatus === 'Live' || this.raiseStatus === 'Live on VC Website') && (this.isPreview !== true)) || (this.isPreview === true);
    }

    /**
     * Get method to check if the raise is not live and not approved. | We used this if the user has
     * access to the live page if still not approved
     * @returns {boolean} - True if the raise is not live and not approved, otherwise false
     */
    get isNotLiveApproved(){
        return ((this.raiseStatus !== 'Live') && (this.isPreview !== false)) || (this.isPreview === false);
    }
    
    /**
     * Method to load document files related to the raise and store it in this.files.
     * @returns {void}
     */
    loadFiles() {
        Promise.all([
            get_documents({ fieldName: 'keyDocumentsFileId', recordId: this.raiseId }),
            get_documents({ fieldName: 'pitchDeckFileId', recordId: this.raiseId }),    
            get_documents({ fieldName: 'shareHolderAgreementFileId', recordId: this.raiseId })
        ])
        .then(results => {
            // Store results directly in this.files and then convert it into an array
            this.files = results.flat();
        })
        .catch(error => {
            this.error = error;
            console.error('Error loading files:', error);
        });
    }

    /**
     * Method to get the planned use of funds document and store it in the variable plannedUseOfFonds.
     * @returns {void}
     */
    getUseOfFonds() {
        get_documents({ fieldName: 'plannedUseOfFundsFileId', recordId: this.raiseId })
            .then(result => {
                this.plannedUseFonds = result[0].publicDownloadUrl;
                return result;
            })
            .catch(error => {
                this.error = error;
            });
    }
    
    /**
     * Method to handle the click event for investing where removes the dollar sign and set the parameters required for invest LWC.
     * @returns {void}
     */

    handleInvestClick() {
        let amount = this.raiseDetails.minInvestAmount;

        let utmSource = {
            utm_source: this.queryParameters.utm_source ? this.queryParameters.utm_source : 'null',
            utm_medium: this.queryParameters.utm_medium ? this.queryParameters.utm_medium : 'null',
            utm_campaign: this.queryParameters.utm_campaign ? this.queryParameters.utm_campaign : 'null',
            utm_content: this.queryParameters.utm_content ? this.queryParameters.utm_content : 'null',
            utm_term: this.queryParameters.utm_term ? this.queryParameters.utm_term : 'null'
        }

        this.handleGTAGEvent(utmSource);
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Invest_Now__c' 
            },
            state: {
                Id: this.productId,
                amount: amount,
                ...utmSource
            },
        });
    }

    /**
     * Method to display a toast notification.
     * @param {string} title - The title of the toast
     * @param {string} message - The message of the toast
     * @param {string} variant - The variant of the toast
     * @returns {void}
     */
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }


    /**
     * Method to validate the input for the raise amount.
     * @param {Event} event - The event triggered by user input
     */
    validateInput(event) {
        const input = event.target;
        // Remove any non-digit characters, like commas
        let value = input.value.replace(/[^0-9]/g, '');
        
        // Format the number with commas
        value = Number(value).toLocaleString();
        
        // Update the input value
        input.value = `$${value}`;
    }

    /**
     * Method to handle the change event for the deal live status.
     * @param {Event} event - The event triggered by the deal live change
     */
    handleDealLiveChange(event) {
        this.dealLive = event.detail.dealLive;
    }

    //TODO: Future improvement use salesforce built-in getUser
    /**
     * Method to get if the user is a guest or not .
     * @returns {void}
     */    
    getUser() {
        get_user().then(user => {
            this.userLogged = user;
        }).catch(error => {
            console.error('The state of the user throws an', error);
        });
    }

    /**
     * Fetches and processes data for a specific raise, including details, team members, media links, and other relevant information.
     * @param {Id} raiseId - The ID of the raise
     * @returns {Promise<Object>} - A promise that resolves with the formatted raise details
     * @throws {Error} - If an error occurs during data fetching or processing
     */
    async getRaiseDetails(raiseId){
        try {
            // Fetch raise details from Apex class
            let returnData = await apex__getRaisePageFields({raiseId : raiseId});
            // Fetch supporting images from Content Document
            let supportingImages = await get_documents({ fieldName: 'supportingImages', recordId: raiseId });
    
            // Fetch hero image from Content Document
            let heroImage = await get_documents({ fieldName: 'heroImageId', recordId: raiseId });
    
            // Fetch logo image from Content Document
            let logoImage = await get_documents({ fieldName: 'companyLogoId', recordId: raiseId });
    
            // Fetch raise status from Apex class
            let raiseStatus = await apex_getRaiseStatus({raiseId: raiseId});
            this.raiseStatus = raiseStatus.status;
            
            
            // Parse fetched raise details
            let raiseData = JSON.parse(returnData);
            // Format social media links
            if(raiseData.linkedInLink){
                raiseData.linkedInLink = this.formatUrl(raiseData.linkedInLink);
            }
            if(raiseData.facebookLink){
                raiseData.facebookLink = this.formatUrl(raiseData.facebookLink);
            }
            if(raiseData.instagramLink){
                raiseData.instagramLink = this.formatUrl(raiseData.instagramLink);
            }
            if(raiseData.websiteLink){
                raiseData.websiteLink = this.formatUrl(raiseData.websiteLink);
            }
    
            // Store retrieved images in raiseData
            raiseData.supportingImage1 = supportingImages[0].publicDownloadUrl;
            raiseData.supportingImage2 = supportingImages[1].publicDownloadUrl;
            raiseData.supportingImage3 = supportingImages[2].publicDownloadUrl;
            raiseData.heroImage = heroImage[0].publicDownloadUrl;
            raiseData.companyLogoId = logoImage[0].publicDownloadUrl;
    
            // Set close date and product ID
            this.closeDate = raiseData.offerCloseDate;
            this.productId = raiseData.productId;
    
            // Format YouTube video link
            if (raiseData.videoLink) {
                let videoLink = raiseData.videoLink;
                let videoId;
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
                    raiseData.videoLink = `https://www.youtube.com/embed/${videoId}`;
                }
            }
    
            // Determine investment type
            if(raiseData.investmentType){
                this.investType = raiseData.investmentType;
            }
    
            // Create skeleton for social media icons
            const socialMediaPlatforms = [
                { key: 'Website', url: raiseData.websiteLink },
                { key: 'Instagram', url: raiseData.instagramLink },
                { key: 'LinkedIn', url: raiseData.linkedInLink },
                { key: 'Facebook', url: raiseData.facebookLink },
            ];
    
            // Filter out null or undefined URLs and map to required format
            this.socialMedia = socialMediaPlatforms
                .filter(platform => platform.url)  
                .map((platform, index) => ({
                    id: index + 1,
                    url: platform.url,
                    icon: platform.key
                }));
    
            // Update progress bar values
            let targetAmt = 0;
            if(raiseData.investmentType === 'Wholesale'){
                targetAmt = raiseData.targetAmt;
                this.capitalRequired = this.formatNumber(raiseData.targetAmt);
            }else if(raiseData.investmentType === 'Retail'){
                targetAmt = raiseData.minTarget;
                this.capitalRequired = this.formatNumber(raiseData.minTarget);
            } 
            
            // Format the values to add a comma
            if (raiseData.valuation) {
                raiseData.valuation = this.formatNumber(raiseData.valuation);
            }
            if (raiseData.minInvestAmount) {
                raiseData.minInvestAmount = this.formatNumber(raiseData.minInvestAmount);
            }

            if (raiseData.sharePrice) {
                raiseData.sharePrice = this.formatNumber(raiseData.sharePrice);
            }
            /**  
            * Cesar Change 10/4/25 
            * If fund is active will override the productType
            * New field for additional text if it's empty
            */
            // Filter and map raise details to required format
            this.overviewData = investProductTypeMapping
            .filter(data => data.key === 'fund')
            .flatMap(data => data.fields)
            .filter(data => raiseData[data.value] !== null)
            .map((field, index) => {
                let value = this.formatValue(raiseData[field.value], field.format);
            
                // Add sharePriceCurrency if the field is 'Share Price' and the currency exists
                if ((field.value === 'sharePrice') && raiseData.sharePriceCurrency) {
                    value = `${value} ${raiseData.sharePriceCurrency}`;
                }
                return {
                    id: index + 1,
                    name: field.fieldName,
                    value: value + (field.additionalText || '')
                };
                    
            });
            

            // Set progress bar values
            this.values = { 
                minimumTarget: parseInt(targetAmt), 
                RaisedAmount: raiseData.amountRaised ?parseInt(raiseData.amountRaised) : 0  
            };

            // investment product type
            if(raiseData.investmentProductType){
                this.investProductType = raiseData.investmentProductType;
            }

            // The offer text
            if (['Ordinary Shares', 'Preference Shares'].includes(raiseData.investmentProductType)) {
                raiseData.offerText = `$${raiseData.sharePrice} per share`;
            }else {
                raiseData.offerText = `$${raiseData.pricePerNote} per note`;
            }

            //
            this.offerText = getOfferTextMapping(raiseData.investmentProductType,raiseData.investmentType,raiseData.name);
            
            raiseData.minInvInput = `$${raiseData.minInvestAmount}`

            // SHOW COMMENTS - PREVUP-82
            
            this.showComments = raiseData?.showComments;

            // NO FEES PAYABLE FEATURE
            this.noFeesPayable = raiseData?.noFeesPayable;

            // This will format the \n into a <br> tag
            let formattedText = this.replaceNewlinesWithBr(raiseData);
            return formattedText;
        } catch (error) {
            console.error('Error fetching data for raiseId:', raiseId, JSON.stringify(error));
            throw error;
        }
    }

    /**
     * Method to format a number with commas.
     * @param {number} number - The number to be formatted
     * @returns {string} - The formatted number
     */
    formatNumber(number) {
        return new Intl.NumberFormat('en-US').format(number);
    }

    /**
     * Method to format a value based on the specified format.
     * @param {any} value - The value to be formatted
     * @param {string} format - The format type (percentage, months, currency.)
     * @returns {string} - The formatted value
     */
    formatValue(value, format) {
        switch (format) {
            case 'currency':
                return `$${value}`;
            case 'per-annum':
                return `${value}% p.a.`
            case 'percentage':
                return `${value}%`;
            case 'months':
                return `${value} Months`;
            default:
                return value;
        }
    }

    /**
     * Method to scroll to a specific section of the page.
     * @param {Event} event - The event triggered by user interaction
     */
    scrollToSection(event) {
        const sectionName = event.target.dataset.target;
        const sectionElement = this.template.querySelector(`[data-section="${sectionName}"]`);
        if (sectionElement) {
            sectionElement.scrollIntoView({ behavior: 'smooth' });
        }
    }

    /**
     * Method to format a URL to ensure it starts with http:// or https://.
     * @param {string} url - The URL to be formatted
     * @returns {string} - The formatted URL
     */
    formatUrl(url) {
        // Check if the URL starts with http://, https://, or is a relative URL pointing to external sites
        if (!url.startsWith('http://') && !url.startsWith('https://')) {
            return 'https://' + url;
        }
        return url;
    }

    /**
     * Method to get the list of team members for a specific raise and category.
     * @param {Id} raiseId - The ID of the raise
     * @param {string} category - The category of the team members (Founder, Management Team, Advisors)
     * @returns {Promise<Array>} - The list of team members with image URLs
     */
    getTeamMembersList(raiseId, category){
        return new Promise(async(resolve,reject)=>{
            let result  = await apex_getTeamMembersList({raiseId: raiseId, category: category});
            if(result != null){
                result = result.map(member => {
                    if (member.linkedIn) {
                        member.linkedIn = this.formatUrl(member.linkedIn);
                    }
                    return member;
                });
                const teamWithImageUrl = await Promise.all(
                    result.map(async (teamMember)=>{
                        try{
                            if(teamMember.picture !== '' && teamMember.picture !== null && teamMember.picture !== undefined){
                                try {
                                    const imageUrl = await apex_getPublicImageUrl({ recordId : teamMember.id});
                                    return {...teamMember, imageUrl:imageUrl};
                                } catch(err){
                                    // url cant be retrieved
                                    return {...teamMember, imageUrl: teamMember.picture};
                                }
                            }else {
                                const imageUrl = await apex_getPublicImageUrl({ recordId : teamMember.id});
                                return {...teamMember, imageUrl: imageUrl};
                            }
                        } catch(error) {
                            console.error(error);
                            return teamMember;
                        }
                    })
                )
                if(teamWithImageUrl.length > 0){
                    resolve(teamWithImageUrl)
                }else{
                    resolve([]);
                }
            }else{
                resolve([]);
            }
            
        })
    }

    /**
     * Method to get the media link details for a specific raise.
     * @param {Id} recordId - The ID of the raise
     * @returns {Promise<Array>} - The list of media links
     */
    getMediaLinkDetails(recordId){
        return new Promise(async (resolve, reject)=>{
            let returnResult = await apex_getMediaLink({raiseId : recordId})
            if(returnResult){
                resolve(returnResult)
            }else{
                reject(returnResult)
            }
        })
    }
    /**
     * Get method to check if the investment type is retail.
     * @returns {boolean} - True if the investment type is retail, otherwise false
     */
    get isRetail(){
        if(this.investType==='Retail'){
            return true;
        }else{
            return false;
        }
    }

    /**
     * Get5 method to check if the investment type is wholesale.
     * @returns {boolean} - True if the investment type is wholesale, otherwise false
     */
    get isWholesale(){
        if(this.investType==='Wholesale'){
            return true;
        }else{
            return false;
        }
    }

    /**
     * Method to replace newline (\r\n) characters with <br> tags in a JSON string.
     * @param {Object} jsonData - The JSON data to be formatted
     * @returns {Object} - The formatted JSON data
     */
    replaceNewlinesWithBr(jsonData) {
        let jsonString = JSON.stringify(jsonData); // => Why if we remove the JSON stringify 
        jsonString = jsonString.replace(/\\r\\n|\\n/g, '<br>');
        return JSON.parse(jsonString);
    }

    /**
     * Method to get the query parameters from the URL.
     * @returns {Promise<Object>} - The URL parameters
     */    
    getQueryParameters() {
        return new Promise((resolve,reject)=>{
            var params = {};
            var search = location.search.substring(1);

            if (search) {
                params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
                    return key === "" ? value : decodeURIComponent(value)
                });
            }
            resolve(params);
        })
    }

    /**
     * Method to navigate to the edit raise page.
     * @returns {void}
     */
    returnToEdit(){
        //navigate to form
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Edit_Raise__c' 
            },
            state: {
                id : this.raiseId,
            }
        })
    }

    /**
     * Method to navigate to the register page.
     * @returns {void}
     */
    handleRegister(){
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/s/login/SelfRegister?startURL=%2Fs%2Fportal%2Fportfolio'
            },
            state: {
                id: this.raiseId
            }
        });
    }

    handleBookACall() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: 'https://calendly.com/d/d34-nsh-ryd/book-a-call-from-a-customer-relationship-coordinator'
            }
        });
    }

    /**  
        * Cesar Change 10/4/25 
        * Handle when fund button is pressed
        * 
    */
    handleDownloadIm() {
        // Scroll to documents container and close modal
        this.activeTab = 'key-documents';
        this.refs.fundFundOutMoreButton.handleClose();
        this.scrollToDiv('documents-container');
    }

    // Close the investment support tab as well

    scrollToDiv(divId) {
        const element = this.template.querySelector(`[data-id="${divId}"]`);
        if (element) {
            element.scrollIntoView({ behavior: 'smooth' });
        } else {
            console.error(`Element with data-id="${divId}" not found.`);
        }
    }

    /**
     * Get method to check if there are media links to display.
     * @returns {boolean} - True if there are media links, otherwise false
     */
    get displayMediaLinks(){
        return this.mediaLinks?.length > 0;
    }

    connectedCallback(){
        this.isLoading = true;


        this.getQueryParameters().then((result) => {
            this.queryParameters = {...result};

            if(!this.isPreview){
                this.raiseId = this.recordId;
            }else{
                let raiseId = result?.id;
                this.raiseId = raiseId;
            }

            // Parallelizing independent promises
            const raiseDetailsPromise = this.getRaiseDetails(this.raiseId)
                .then((result) => {
                    this.raiseDetails = result;
                }).catch((err) => {
                    console.error(err);
                });

            const mediaLinksPromise = this.getMediaLinkDetails(this.raiseId)
                .then((result) => {
                    this.mediaLinks = [...result];
                }).catch((e) => {
                    console.error("Unable to get media link: ", this.raiseId, e);
                });

            const managementTeamPromise = this.getTeamMembersList(this.raiseId, 'Management Team')
                .then((result) => {
                    this.managementTeam = [...result];
                }).catch((err) => {
                    console.error(err);
                });

            const advisorsPromise = this.getTeamMembersList(this.raiseId, 'Advisors')
                .then((result) => {
                    this.advisors = [...result];
                }).catch((err) => {
                    console.error(err);
                });

            // Wait for all promises to complete
            Promise.all([
                raiseDetailsPromise,
                mediaLinksPromise,
                managementTeamPromise,
                advisorsPromise,
            ]).finally(() => {
                this.isLoading = false;
            });

            // Load files and get user
            this.loadFiles();
            this.getUser();
            this.getUseOfFonds();

        }).catch((err) => {
            console.error('Error fetching query parameters', err);
            this.isLoading = false;
        });
    }

    /**
     * Get method to get the CSS class for the fees tab.
     * @returns {string} - The CSS class for the fees tab
     */
    get feesTabClass() {
        return this.activeTab === 'fees' ? 'tab tab-active' : 'tab';
    }

    /**
     * Get method to get the CSS class for the key documents tab.
     * @returns {string} - The CSS class for the key documents tab
     */
    get keyDocumentsTabClass() {
        return this.activeTab === 'key-documents' ? 'tab tab-active' : 'tab';
    }

    /**
     * Get method to check if the fees tab is active.
     * @returns {boolean} - True if the fees tab is active, otherwise false
     */
    get isFeesTabActive() {
        return this.activeTab === 'fees';
    }

    /**
     * Get method to check if the key documents tab is active.
     * @returns {boolean} - True if the key documents tab is active, otherwise false
     */
    get isKeyDocumentsTabActive() {
        return this.activeTab === 'key-documents';
    }


    /**
     * Method to handle the click event for tab navigation.
     * @param {Event} event - The event triggered by user interaction
     */
    handleTabClick(event) {
        this.activeTab = event.currentTarget.dataset.id;
    }

    /**  
        * Cesar Change 4/4/25 
        * Method to fire an event when the user clicks invest now
        * 
    */
    handleGTAGEvent(data){
        // Get the full current URL
        try{
            this.dispatchEvent(new CustomEvent('lwc_investgtaevent',
                { 
                    detail: {
                        url: window.location.href,
                        data: data
                    },
                    bubbles: true, 
                    composed: true
                }));
        }catch(error){
            console.error('Error logging gTag event:', JSON.stringify(error))
        }
    }
}