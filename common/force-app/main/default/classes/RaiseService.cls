/**
 * This is the service layer class associated with the Raise process. 
 * All of the business logic relevant to Raise will remain in this class.
*/
public without sharing class RaiseService {
    /**
     * Method to create a Raise record using the Account ID of a Business Account.
     * @param companyId The Id of the Business Account to create the raise.
     * @return Newly created Raise record.
     * @throws AuraHandledException when the business ID cannot be found OR if another error occurs
     */ 
    public Raise__c createRaiseRecord(String companyId, String investType){
        try{
            RaiseFactory factory = New RaiseFactory();
            Raise__c recordCreated = factory.createRaise(companyId, investType);
            if(recordCreated == null){
                throw new AuraHandledException('Business cannot be found!');
            }
            Logger.logMessage('RaiseApp', 'RaiseService', 'createRaiseRecord', 'Successfully created raise record for companyId: ' + companyId);
            return recordCreated;
        }catch (Exception e){
            Logger.logError('RaiseApp', 'RaiseService', 'createRaiseRecord', companyId, null, null, null, e, 'Failed to create raise record for companyId: ' + companyId);
            throw e;
        }
    }
    
    /**
     * Check if a Raise record exists for a Business account.
     * @param companyId The Id of the Business Account.
     * @return Boolean to indicate if the raise exists.
     * @throws AuraHandledException
     */ 
    public Boolean raiseExists(String companyId){
        try{
            RaiseFactory factory = New RaiseFactory();
            Boolean result = factory.checkRaiseExists(companyId);
            Logger.logMessage('RaiseApp', 'RaiseService', 'raiseExists', 'Checked existence of raise record for companyId: ' + companyId);
            return result;
        }catch (Exception e){
            Logger.logError('RaiseApp', 'RaiseService', 'raiseExists', companyId, null, null, null, e, 'Failed to check if raise exists for companyId: ' + companyId);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
     * Get the details of a raise record
     * @param raiseId The Id of the Raise record.
     * @return JSON.serialize string representation of the raise record.
     * @throws AuraHandledException
     */ 
    public String getRaiseDetails(String raiseId){
        try{
            RaiseFactory factory = New RaiseFactory();
            Raise__c raiseRecord = factory.getRaiseRecord(raiseId);
            if(raiseRecord != null){            
                RaiseData returnData = new RaiseData();
                returnData.id = raiseRecord.Id;
                returnData.name = raiseRecord.Name;
                returnData.account = raiseRecord.Account__c;
                returnData.eoi = raiseRecord.EOI__c;
                returnData.company = raiseRecord.Company__c;
                returnData.companyName = raiseRecord.Company__r.Name;
                returnData.status = raiseRecord.Status__c;
                returnData.learning = raiseRecord.Learning__c;
                returnData.investmentType = raiseRecord.Form_Investment_type__c;
                returnData.productId = raiseRecord.Product__c;
                returnData.launchDate = raiseRecord.Form_Offer_launch_date__c;
                returnData.amountRaised = raiseRecord.Value_of_Applications__c;
                returnData.targetAmt = raiseRecord.Form_Target_amount__c;
                returnData.minTarget = raiseRecord.Form_Minimum_target__c;
                returnData.multipleDevicesAcknowledged = raiseRecord.Multiple_Devices_Acknowledgement__c;

                Logger.logMessage('RaiseApp', 'RaiseService', 'getRaiseDetails', 'Successfully retrieved raise details for raiseId: ' + raiseId);
                return JSON.serialize(returnData);
            }else {
                throw new AuraHandledException('No raise record found for the given ID.');
            }
        }catch(Exception e){
            Logger.logError('RaiseApp', 'RaiseService', 'getRaiseDetails', raiseId, null, null, null, e, 'Failed to get raise details for raiseId: ' + raiseId);
            throw new AuraHandledException('An unexpected error occurred: ' + e.getMessage());

        }
        
    }

    public Map<String,Object> getRaiseStatuses(Id raiseId){
        try{
            RaiseFactory factory = New RaiseFactory();
            Raise__c raiseRecord = factory.getRaiseStatuses(raiseId);

            Map<String,Object> returnMap = new Map<String,Object>();
            if(raiseRecord != null){
                returnMap.put('name', raiseRecord.Name);
                returnMap.put('status', raiseRecord.Status__c);
                returnMap.put('paymentReceived', raiseRecord.Payment_received__c);
                returnMap.put('contentApproved', raiseRecord.Content_approved__c);
                returnMap.put('courseUnlocked', raiseRecord.Course_unlocked__c);
                returnMap.put('learningCompleted', raiseRecord.Learning_completed__c);
            }
            
            Logger.logMessage('RaiseApp', 'RaiseService', 'getRaiseStatuses', 'Successfully retrieved raise statuses for raiseId: ' + raiseId);
            return returnMap;
        }catch(Exception e){
            throw e;
        }
    }

    public Map<String,Object> unlockRaiseCourse(Id raiseId){
        try{
            RaiseFactory factory = New RaiseFactory();
            Raise__c raiseRecord = factory.unlockRaiseCourse(raiseId);

            Map<String,Object> returnMap = new Map<String,Object>();

            returnMap.put('id', raiseRecord.Id);
            returnMap.put('courseUnlocked',raiseRecord.Course_unlocked__c);
            returnMap.put('paymentReceived', raiseRecord.Payment_received__c);

            Logger.logMessage('RaiseApp', 'RaiseService', 'unlockRaiseCourse', 'Successfully unlocked course for raiseId: ' + raiseId);
            return returnMap;

        }catch(Exception e){
            throw e;
        }
    }
    
    /**
     * Get the details of a raise record given the Business Account ID
     * @param companyId The Id of the Business Account record.
     * @return JSON.serialize string representation of the raise record.
     * @throws AuraHandledException
     */ 
    public String getRaiseDetailsFromCompanyId(String companyId){
        try{
            RaiseFactory factory = New RaiseFactory();
            Raise__c raiseRecord = factory.getRaiseRecordCompanyId(companyId);
            if(raiseRecord != null){
                RaiseData returnData = new RaiseData();
                returnData.id = raiseRecord.Id;
                returnData.name = raiseRecord.Name;
                returnData.account = raiseRecord.Account__c;
                returnData.company = raiseRecord.Company__c;
                returnData.eoi = raiseRecord.EOI__c;
                returnData.status = raiseRecord.Status__c;
                returnData.investmentType = raiseRecord.Form_Investment_type__c;
                Logger.logMessage('RaiseApp', 'RaiseService', 'getRaiseDetailsFromCompanyId', 'Successfully retrieved raise details for companyId: ' + companyId);
                return JSON.serialize(returnData);
            }else{
                Logger.logMessage('RaiseApp', 'RaiseService', 'getRaiseDetailsFromCompanyId', 'No raise record found for companyId: ' + companyId);
                throw new AuraHandledException( 'No raise record found for companyId: ' + companyId);
            }
        }catch(Exception e){
            Logger.logError('RaiseApp', 'RaiseService', 'getRaiseDetailsFromCompanyId', companyId, null, null, null, e, 'Failed to get raise details for companyId: ' + companyId);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
 /**
     * Get the details of a raise record given the Business Account ID | This function is used to display the required field for the deal page
     * @param companyId The Id of the Business Account record.
     * @return JSON.serialize string representation of the raise record.
     * @throws AuraHandledException
     */
    public String getRaisePageDetailsRaiseId(String raiseId){
        try{
            RaiseFactory factory = New RaiseFactory();
            Raise__c raiseRecord = factory.getRaisePageRecordRaiseId(raiseId);
            if(raiseRecord != null){
                RaiseData returnData = new RaiseData();
                returnData.Id = raiseRecord.Id;
                returnData.name = raiseRecord.Name;
                returnData.account = raiseRecord.Account__c;
                returnData.company = raiseRecord.Company__c;
                returnData.eoi = raiseRecord.EOI__c;
                returnData.status = raiseRecord.Status__c;
                returnData.problem = raiseRecord.Form_Problem_or_Opportunity__c;
                returnData.solution = raiseRecord.Form_Solution__c;
                returnData.differentiation = raiseRecord.Form_Differentiation__c;
                returnData.intellectualProperty = raiseRecord.Form_Intellectual_Property__c;
                returnData.addressableMarket = raiseRecord.Form_Total_addressable_market__c;
                returnData.progress = raiseRecord.Form_Progress__c;
                returnData.growthPlan = raiseRecord.Form_Growth_plan__c;
                returnData.valuation = raiseRecord.Form_Valuation__c;
                returnData.companyOverview = raiseRecord.Form_Company_Overview__c;
                returnData.stage = raiseRecord.Form_Stage__c;
                returnData.companyOneLiner = raiseRecord.Form_Company_one_liner__c;
                returnData.minTarget = raiseRecord.Form_Minimum_target__c;
                returnData.maxTarget = raiseRecord.Form_Maximum_target__c;
                returnData.minInvestAmount = raiseRecord.Form_Minimum_Investment_amount__c;
                returnData.investmentType = raiseRecord.Form_Investment_type__c;
                returnData.offerCloseDate = raiseRecord.Form_Offer_close_date__c;
                returnData.instagramLink = raiseRecord.Form_Instagram__c;
                returnData.websiteLink = raiseRecord.Form_Website__c;
                returnData.facebookLink = raiseRecord.Form_Facebook__c;
                returnData.linkedInLink = raiseRecord.Form_LinkedIn__c;
                returnData.sharePrice = raiseRecord.Form_Share_price__c;
                returnData.sector = raiseRecord.Form_Sector__c;         
                returnData.coupon = raiseRecord.Form_Coupon_rate__c;
                returnData.term = raiseRecord.Form_Term_Months__c;
                returnData.conversion = raiseRecord.Form_Conversion_terms__c;
                returnData.interestRate = raiseRecord.Form_Interest_rate__c;
                returnData.security = raiseRecord.Form_Security__c;
                returnData.valuationCap = raiseRecord.Form_Valuation_cap__c;
                returnData.discountRate = raiseRecord.Form_Discount_rate__c;
                returnData.investmentProductType = raiseRecord.Form_Investment_product_type__c;
                returnData.useOfFunds = raiseRecord.Form_Planned_use_of_funds__c;
                returnData.productId = raiseRecord.Product__c;
                returnData.youtubeURL = raiseRecord.Form_Youtube__c;
                returnData.videoLink = raiseRecord.Form_Video_Link__c;
                returnData.launchDate = raiseRecord.Form_Offer_launch_date__c;
                returnData.amountRaised = raiseRecord.Value_of_Applications__c;
                returnData.targetAmt = raiseRecord.Form_Target_amount__c;
                returnData.pricePerShare = raiseRecord.Form_Price_per_share__c;
                returnData.pricePerNote = raiseRecord.Form_Price_per_note__c;
                returnData.showComments = raiseRecord.Show_Comments__c;
                returnData.sharePriceCurrency = raiseRecord.Form_Share_price_currency__c;
                returnData.noFeesPayable = raiseRecord.No_Fees_Payable__c;
                returnData.fundName = raiseRecord.Fund_name__c;
                returnData.fundOneLiner = raiseRecord.Fund_one_liner__c;
                returnData.targetReturn = raiseRecord.Target_Return__c;
                returnData.distributionFrequency = raiseRecord.Distribution_frequency__c;
                returnData.investmentTerm = raiseRecord.Investment_term__c;
                returnData.entryExitFees = raiseRecord.Entry_exit_fees__c;
                returNData.fundTheOffer = raiseRecord.Fund_the_offer__c;
                Logger.logMessage('RaiseApp', 'RaiseService', 'getRaisePageDetailsRaiseId', 'Successfully retrieved raise details for raiseId: ' + raiseId);
                return JSON.serialize(returnData);
            }else{
                Logger.logMessage('RaiseApp', 'RaiseService', 'getRaisePageDetailsRaiseId', 'No raise record found for raiseId: ' + raiseId);
                throw new AuraHandledException( 'No raise record found for raiseId: ' + raiseId);
            }
        }catch(Exception e){
            Logger.logError('RaiseApp', 'RaiseService', 'getRaisePageDetailsRaiseId', raiseId, null, null, null, e, 'Failed to get raise details for raiseId: ' + raiseId);
            throw new AuraHandledException(e.getMessage());
        }
    }

    public Map<String,Object> getRaiseDetailsForm(Id raiseId){
        try{
            RaiseFactory factory = New RaiseFactory();
            Raise__c raiseRecord = factory.getRaiseRecordDetailsForm(raiseId);

            if(raiseRecord != null){
                Map<String,Object> returnData = new Map<String,Object>();
                Map<String, SObjectField> raiseFieldsMap = Raise__c.SObjectType.getDescribe().fields.getMap();

                for(String field : raiseObjectMapping.valueSet()){
                    String mappedField = raiseObjectMapping.getKey(field);
                    Object fieldValue = raiseRecord.get(field);

                    Schema.DisplayType fieldType = raiseFieldsMap.get(field).getDescribe().getType();
                    if (fieldType == Schema.DisplayType.DATE && fieldValue!= null) {
                        returnData.put(mappedField,String.valueOf(fieldValue).split(' ')[0]);
                    }else if(fieldValue!= null){
                        returnData.put(mappedField,String.valueOf(fieldValue));
                    }

                    
                }

                System.debug(returnData);
                Logger.logMessage('RaiseApp', 'RaiseService', 'getRaiseDetailsForm', 'Successfully retrieved raise details for raiseId: ' + raiseId);
                return returnData;
            }else{
                throw new AuraHandledException('Raise record not found'); 
            }
            
        }catch(AuraHandledException e){
            Logger.logError('RaiseApp', 'RaiseService', 'getRaiseDetailsForm', raiseId, null, null, null, e, 'Failed to get raise details for raiseId: ' + raiseId);
            throw e;
        }
    }

    /**
    * Handles the Raise form data by deserializing the JSON input, fetching the existing Raise record, 
    * updating it using the mapper, and reporting any unmapped fields.
    * @param jsonData The JSON string containing the Raise form data.
    * @throws AuraHandledException if an error occurs during deserialization or update.
    */
    public Map<String,Object> updateRaiseData(Id raiseId, Map<String, Object> fieldsToUpdate){
        try{
            RaiseFactory factory = New RaiseFactory();
            Map<String,Object> raiseUpdatedId = factory.updateRaiseRecord(raiseId,fieldsToUpdate);
            Logger.logMessage('RaiseApp', 'RaiseService', 'updateRaiseData', 'Successfully udpated raise details for raiseId: ' + raiseId);
            return raiseUpdatedId;
        }catch(AuraHandledException e){
            Logger.logError('RaiseApp', 'RaiseService', 'updateRaiseData', raiseId, null, null, null, e, 'Failed to update raise details for raiseId: ' + raiseId);
            // throw new AuraHandledException('Failed to update record: ' + raiseId);
            throw e;
        }
    }

    /**
     * Fetches the picklist values for a given field on a given object.
     * @param objectName The name of the SObject (e.g., 'Account', 'Contact').
     * @param fieldName The API name of the picklist field (e.g., 'Industry', 'LeadSource').
     * @return A list of picklist values for the specified field.
     * @throws AuraHandledException If the object or field is not found or is not a picklist.
     */
    public  List<Map<String, String>> getPicklistValues(String objectName, String fieldName) {
        // setup return 
        List<Map<String, String>> picklistValues = new List<Map<String, String>>();

        // Describe the SObject
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        if (objectType == null) {
            throw new AuraHandledException('Object ' + objectName + ' not found.');
        }

        // Describe the field
        Schema.SObjectField field = objectType.getDescribe().fields.getMap().get(fieldName);
        if (field == null) {
            throw new AuraHandledException('Field ' + fieldName + ' not found on object ' + objectName + '.');
        }

        // Check if the field is a picklist
        Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
        if (fieldDescribe.getType() != Schema.DisplayType.Picklist) {
            throw new AuraHandledException('Field ' + fieldName + ' is not a picklist.');
        }

        // Get the picklist values
        List<Schema.PicklistEntry> picklistEntries = fieldDescribe.getPicklistValues();
        for (Schema.PicklistEntry entry : picklistEntries) {
            Map<String, String> valueMap = new Map<String, String>();
            valueMap.put('label', entry.getLabel());
            valueMap.put('value', entry.getValue());
            picklistValues.add(valueMap);
        }

        Logger.logMessage('RaiseApp', 'RaiseService', 'getPicklistValues', 'Successfully retrieved picklist values for: ' + fieldName);
        return picklistValues;
    }


    /**
     * Fetches the the currect user id.
     * @return Bool if the user is Guest.
     */    
    public Boolean isUserLoggedIn() {
        Id userId = UserInfo.getUserId();
        // Check if the userId is not the guest user Id
        return userId != '0052v00000iLq0AAAS';
    }

    /**
     * Updates the status of a Raise record.
     * 
     * @param raiseId The ID of the Raise record to be updated.
     * @param status The new status to be set on the Raise record.
     * @return The updated Raise__c record.
     * @throws AuraHandledException if the record cannot be found.
     * @throws Exception if any other error occurs during the update process.
     */
    public Raise__c updateRaiseStatus(Id raiseId, String status){
        // try{
            RaiseFactory factory = new RaiseFactory();
            Raise__c recordUpdated = factory.updateRaiseStatus(raiseId, status);
            if(recordUpdated == null){
                throw new AuraHandledException('Raise cannot be found!');
            }
            Logger.logMessage('RaiseApp', 'RaiseService', 'updateRaiseStatus', 'Successfully updated raise record for companyId: ' + raiseId);
            return recordUpdated;
        // }catch (AuraHandledException e){
        //     Logger.logError('RaiseApp', 'RaiseService', 'updateRaiseStatus', raiseId, null, null, null, e, 'Failed to update raise record for raiseId: ' + raiseId);
        //     throw e;
        // }catch (Exception e){
        //     Logger.logError('RaiseApp', 'RaiseService', 'updateRaiseStatus', raiseId, null, null, null, e, 'An unexpected error occurred while updating raise record for raiseId: ' + raiseId);
        //     throw new AuraHandledException('An unexpected error occurred: ' + e.getMessage());
        // }
    }

    public Map<String,Object> createLearningForRaise(Id raiseId){
        // get raise details
        Raise__c raiseRecord = [SELECT Id, Name FROM Raise__c WHERE Id=:raiseId];

        Map<String,Object> retData = new Map<String,Object>();
        LearningFactory factory = new LearningFactory();

        // courses to assign to raise
        List<String> coursesToAssign = new List<String>();
        coursesToAssign.add('Capital Raising 101 Course');

        // create learning, course link and learning progress
        Map<String,Object> learningData = factory.createLearning(raiseRecord.Name, coursesToAssign);
        retData.put('learningData', learningData);

        // link learning to raise
        RaiseFactory rFactory = new RaiseFactory();
        Learning__c learningRec = (Learning__c)learningData.get('learning');

        Raise__c linkedRaise = rFactory.linkLearningToRaise(raiseRecord.Id, learningRec.id);

        retData.put('raiseData', linkedRaise);

        return retData;
    }

    public Map<String,Object> getSummaryStatistics(Id raiseId, Id eoiId){
        // try{
            RaiseFactory factory = new RaiseFactory();
            return factory.getSummaryStatistics(raiseId, eoiId);
        // }catch(Exception e){
        //     Logger.logError('RaiseApp', 'RaiseService', 'getSummaryStatistics', raiseId, null, null, null, e, 'An error occurred while retrieving summary statistics. ' + e.getMessage());
        //     throw new AuraHandledException('An error occurred while retrieving summary statistics.');
        // }
    }

    // Get the record type of a raise
    public String getRaiseRecordType(Id raiseId) {        
        RaiseFactory factory = new RaiseFactory();
        Raise__c result = factory.getRaiseRecordType(raiseId);
        return result.RecordType.DeveloperName;
    }

    public static BidiMap raiseObjectMapping = new BidiMap(new Map<String, String>{
        'companyFullName' => 'Form_Company_Name__c',
        'companyOneLiner' => 'Form_Company_one_liner__c',
        'companyWebsite' => 'Form_Website__c',
        'resgisteredAus' => 'Form_Registered_Aus__c',
        'sector' => 'Form_Sector__c',
        'abn' => 'Form_ABN__c',
        'companyStreetAddress' => 'Form_Company_Street_Address__c',
        'companySuburb' =>  'Form_Company_Suburb__c',
        'companyState' =>  'Form_Company_State__c',
        'companyPostcode' =>  'Form_Company_Postcode__c',
        'videoUrl' => 'Form_Video_Link__c',
        'acn' => 'Form_ACN__c',
        //'companyLogoId' => null,  // No matching field
        //'heroImageId'=> null,
        // 'supportingImages' => null,
        'instagramUrl' => 'Form_Instagram__c',
        'linkedinUrl' => 'Form_LinkedIn__c',
        'twitterUrl' => 'Form_X_Twitter__c',
        'facebookUrl' => 'Form_Facebook__c',
        'youtubeUrl' => 'Form_Youtube__c',
        'companyOverview' => 'Form_Company_Overview__c',
        'problemOrOpp' => 'Form_Problem_or_Opportunity__c',
        'solution' => 'Form_Solution__c',
        'differentiation' => 'Form_Differentiation__c',
        'intellectualProperty' => 'Form_Intellectual_Property__c',
        'totalAddressableMarket' => 'Form_Total_addressable_market__c',
        'progress' => 'Form_Progress__c',
        'consentToIndividuals' => 'Form_Consent_for_individuals__c',
        'raiseManagerContact' => 'Form_Raise_Contact_Email__c',
        'growthPlan' => 'Form_Growth_plan__c',
        // 'growthPlanFileId' => null,  // No matching field
        'businessStrategy' => 'Form_Business_strategy__c',
        // 'businessStrategyFileId' => null,  // No matching field
        'businessModel' => 'Form_Business_model__c',
        // 'businessModelFileId' => null,  // No matching field
        'orgStructure' => 'Form_Organisation_structure__c',
        // 'orgStructureFileId' => null,  // No matching field
        'proprietaryCompany' => 'Form_Proprietary_company__c',
        'publicCompany' => 'Form_Public_company__c',
        'financialInformation' => 'Form_Financial_information_summary__c',
        'financialInformationUrl' => 'Form_Financial_information_URL__c',
        // 'financialInformationFileid' => null,  // No matching field
        // 'capitalStructureFileId' => null,  // No matching field
        'debtFunding' => 'Form_Debt_funding_and_other_funding__c',
        // 'debtFundingFileId' => null,  // No matching field
        'fundsRaisedToDate' => 'Form_Funds_raised_to_date__c',
        'legalOrDisciplanryActions' => 'Form_Legal_or_disciplinary_action__c',
        'risksFacingBusiness' => 'Form_Risks_facing_the_business__c',
        // 'optionalUploadForAnnexureFileId' => null,  // No matching field
        'stage' => 'Form_Stage__c',
        'plannedUseOfFunds' => 'Form_Planned_use_of_funds__c',
        'offerLaunchDate' => 'Form_Offer_launch_date__c',
        // 'publicLaunchDate' => null,  // No separate field for public launch date
        'offerCloseDate' => 'Form_Offer_close_date__c',
        'investType' => 'Form_Investment_type__c',
        'investProductType' => 'Form_Investment_Product_Type__c',
        'couponRate'=>'Form_Coupon_rate__c',
        'term'=>'Form_Term_Months__c',
        'dividendOption'=>'Form_Dividend_option__c',
        'redemption'=>'Form_Redemption__c',
        'conversionTerms'=>'Form_Conversion_terms__c',
        'interestRate'=>'Form_Interest_rate__c',
        'security'=>'Form_Security__c',
        'valuationCap'=>'Form_Valuation_cap__c',
        'discountRate'=>'Form_Discount_rate__c',
        'valuation' => 'Form_Valuation__c',
        'numberOfShares' => 'Form_Number_of_shares_on_issue__c',
        'sharePrice' => 'Form_Share_price__c', // auto calculated, This is needed to retrieve the field in the raise retail form
        'wholesaleSharePrice' => 'Share_Price__c', // Goes into a dummy field for wholesale
        'rightsAssociatedWithShares' => 'Form_Rights_associated_with_shares__c',
        // 'rightsAssociatedWithSharesFileId' => null,  // No matching field
        'detailsOfPreviousCsfOffers' => 'Form_Details_of_previous_CSF_offers__c',  // No matching field
        'targetAmount' => 'Form_Target_amount__c',
        'minTarget' => 'Form_Minimum_target__c',
        'maxTarget' => 'Form_Maximum_target__c',
        'minInvestAmount' => 'Form_Minimum_Investment_amount__c',
        // 'optionalUploadForAnnexureFileId2' => null,  // No matching field
        'termsAndConditions' => 'Form_Terms_and_Conditions__c',
        'founderSignOff' => 'Founder_Information_is_correct__c',
        'pricePerShare' => 'Form_Price_per_share__c',
        'pricePerNote' => 'Form_Price_per_note__c',
        'halfwayReached' => 'Form_Halfway_reached__c',
        'endReached'=>'Form_End_reached__c',
        'currentPageIndex'=>'Form_Current_page_number__c',
        'status' => 'Status__c',
        'multipleDevicesAcknowledged' => 'Multiple_Devices_Acknowledgement__c',
        'sharePriceCurrency' => 'Form_Share_price_currency__c'
    });
    
        /**
     * Class structure that abstracts the Raise record structure
     */ 
	public class RaiseData{
        String name;
        String account;
        String eoi;
        String id;
        String status;
        String companyName;
        String learning;
        String problem;
        String solution;
        String differentiation;
        String company;
        String intellectualProperty;
        String investmentType;
        String addressableMarket;
        String progress;
        String growthPlan;
        Decimal valuation;
        String companyOverview;
        String companyOneLiner;
        String stage;
        Decimal minTarget;
        Decimal maxTarget;
        Decimal minInvestAmount;
        Date offerCloseDate;
        String instagramLink;
        String linkedInLink;
        String websiteLink;
        String facebookLink;
        Decimal sharePrice;
        String useOfFunds;
        String sector;
        String investmentProductType;
        Decimal coupon;
        Decimal term;
        String conversion;
        Decimal interestRate;
        String security;
        Decimal valuationCap;
        Id productId;
        Decimal discountRate;
        String youtubeURL;
        Date launchDate;
        String videoLink;
        Decimal amountRaised;
        Decimal targetAmt;
        Decimal pricePerNote;
        Decimal pricePerShare;
        Boolean multipleDevicesAcknowledged;
        Boolean showComments;
        String sharePriceCurrency;
        Boolean noFeesPayable;
        String fundName;
        String fundOneLiner; 
        String targetReturn;
        String distributionFrequency;
        String investmentTerm;
        String entryExitFees;
        String fundTheOffer;
    }

}