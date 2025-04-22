/**
Raise factory class that is used to create the Raise__c object without exposing the object
creation logic to the client
*/
public class RaiseFactory implements IRaiseFactory{

    /**
Creates a raise record given the Account Id for a Business account.
@param companyId The Id of the Business Account to create the raise.
@return Newly created Raise record.
*/ 
    public Raise__c createRaise(String companyId, String investType){
        try{
            // Get business account detailss
            Account companyDetails = getCompanyDetails(companyId);
            
            // Create raise record 
            Raise__c newRaiseRecord = New Raise__c();

            if(companyDetails != null){
                newRaiseRecord.Name = companyDetails.Name;
                newRaiseRecord.Account__c = companyDetails.Related_Person_Account__r.Id;
                newRaiseRecord.Company__c = companyId;
                newRaiseRecord.Status__c = 'In Progress';
                newRaiseRecord.Preraise_completed__c = true;
                newRaiseRecord.Form_Investment_type__c = investType;
                newRaiseRecord.Form_VentureCrowd_trust_unit_price__c = 1.00;
                newRaiseRecord.Form_Current_page_number__c = 0;

                // set OwnerId - INFSD-539 - KKAM
                List<User> jasonQuery = [SELECT Id, Name, Email FROM User WHERE Name='Jason Kennewell' AND Profile_Name__c='Head Of  Capital'];
                if(jasonQuery.size() > 0){
                    newRaiseRecord.OwnerId = jasonQuery[0].Id;
                    newRaiseRecord.Owner__c = jasonQuery[0].Id;

                }
                
                // Get EOI if exists
                EOI__c eoi = getEOIDetailsFromCompanyId(companyId);
                if(eoi != null){
                    newRaiseRecord.EOI__c = eoi.Id;
                }
                
                // Insert raise record
                insert newRaiseRecord;

                // return raise record
                Logger.logMessage('RaiseApp', 'RaiseFactory', 'createRaise', 'Successfully created Raise record for companyId: ' + companyId);
                return newRaiseRecord;
            }else{
                // return null if not found
                Logger.logError('RaiseApp', 'RaiseFactory', 'createRaise', companyId, null, null, null, null, 'Failed to create raise record for companyId: ' + companyId);
                throw new AuraHandledException('Business cannot be found!');
            }
        }catch(Exception e){
            Logger.logError('RaiseApp', 'RaiseFactory', 'createRaise', companyId, null, null, null, e, 'Failed to create raise record for companyId: ' + companyId);
            throw new AuraHandledException('Business cannot be found!');
        }
    }
    
    /**
* Checks if there is a Raise already created for a Business Account.
* @param companyId The Id of the Business Account to create the raise.
* @return Boolean to indicate if a raise exists or not.
*/
    public Boolean checkRaiseExists(String companyId){
        try{
            List<Raise__c> raiseList = [SELECT Id FROM Raise__c WHERE Company__c=:companyId];
            if(raiseList.size()>0){
                Logger.logMessage('RaiseApp', 'RaiseFactory', 'checkRaiseExists', 'Raise exists for companyId: ' + companyId);
                return true;
            }else{
                Logger.logMessage('RaiseApp', 'RaiseFactory', 'checkRaiseExists', 'No raise exists for companyId: ' + companyId);
                return false;
            }
        }catch(Exception e){
            Logger.logError('RaiseApp', 'RaiseFactory', 'checkRaiseExists', companyId, null, null, null, e, 'Failed to check if raise exists for companyId: ' + companyId);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
* Gets the Business account details for a specific account ID.
* @param companyId The Id of the Business Account.
* @return Account record.
*/
    private Account getCompanyDetails(String companyId){
        try{
            List<Account> company = [SELECT Name,
                                 Related_Person_Account__r.Id
                                 FROM Account 
                                 WHERE Id=:companyId];
            if(company.size() > 0){
                Logger.logMessage('RaiseApp', 'RaiseFactory', 'getCompanyDetails', 'Successfully retrieved company details for companyId: ' + companyId);
                return company[0];
            }else{
                Logger.logMessage('RaiseApp', 'RaiseFactory', 'getCompanyDetails', 'No company details found for companyId: ' + companyId);
                return null;
            }
        }catch(Exception e){
            Logger.logError('RaiseApp', 'RaiseFactory', 'getCompanyDetails', companyId, null, null, null, e, 'Failed to get company details for companyId: ' + companyId);
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    /**
* Gets the Raise record given a raise ID.
* @param raiseId The Id of the Raise record.
* @return Raise__c record.
*/
    public Raise__c getRaiseRecord(String raiseId){
        try{
            List<Raise__c> raiseList = [SELECT Name,Learning__c,Account__c, Company__c, Company__r.Name,EOI__c, Status__c,Form_Investment_type__c, Form_Offer_launch_date__c, 
                                            Form_Target_amount__c,Value_of_Applications__c, Form_Minimum_target__c, Multiple_Devices_Acknowledgement__c, Product__c FROM Raise__c WHERE Id=:raiseId];
            if (raiseList.isEmpty()) {
                Logger.logMessage('RaiseApp', 'RaiseFactory', 'getRaiseRecord', 'No raise record found for raiseId: ' + raiseId);
                return null;
            } else {
                Logger.logMessage('RaiseApp', 'RaiseFactory', 'getRaiseRecord', 'Successfully retrieved raise record for raiseId: ' + raiseId);
                return raiseList[0];
            }
        }catch(Exception e){
            Logger.logError('RaiseApp', 'RaiseFactory', 'getRaiseRecord', raiseId, null, null, null, e, 'Failed to get raise record for raiseId: ' + raiseId);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
* Gets the Raise record given a company ID.
* @param companyId The Id of the Business Account.
* @return Raise__c record.
*/
    public Raise__c getRaiseRecordCompanyId(String companyId){
        try{
            List<Raise__c> raiseList = [SELECT Name,Account__c, Company__c, EOI__c, Status__c ,Form_Investment_type__c FROM Raise__c WHERE Company__c=:companyId];
            if (raiseList.isEmpty()) {
                Logger.logMessage('RaiseApp', 'RaiseFactory', 'getRaiseRecordCompanyId', 'No raise record found for companyId: ' + companyId);
                throw new AuraHandledException('No raise record found for companyId: ' + companyId);
            } else {
                Logger.logMessage('RaiseApp', 'RaiseFactory', 'getRaiseRecordCompanyId', 'Successfully retrieved raise record for companyId: ' + companyId);
                return raiseList[0];
            }
        }catch(Exception e){
            Logger.logError('RaiseApp', 'RaiseFactory', 'getRaiseRecordCompanyId', companyId, null, null, null, e, 'Failed to get raise record for companyId: ' + companyId);
            throw new AuraHandledException(e.getMessage());
        }
    }

    public Raise__c getRaiseStatuses(String raiseId){
        try{

            Raise__c raiseRecord = [SELECT Name,
             Status__c ,
             Payment_received__c,
             Content_approved__c,
             Course_unlocked__c,
             Learning_completed__c
            FROM Raise__c WHERE Id=:raiseId];
            
            Logger.logMessage('RaiseApp', 'RaiseFactory', 'getRaiseStatuses', 'Successfully retrieved raise statuses for raiseId: ' + raiseId);
            return raiseRecord;
            
        }catch(Exception e){
            Logger.logError('RaiseApp', 'RaiseFactory', 'getRaiseStatuses', raiseId, null, null, null, e, 'Failed to get raise statuses for raiseId: ' + raiseId);
            throw new AuraHandledException(e.getMessage());
        }
    }

    public Raise__c unlockRaiseCourse(String raiseId){
        try{
            Raise__c raiseRecord = [SELECT Id, Name, Payment_received__c, Course_unlocked__c FROM Raise__c WHERE Id=:raiseId];

            if(raiseRecord != null){
                if(raiseRecord.Payment_received__c == true && raiseRecord.Course_unlocked__c == false){
                    raiseRecord.Course_unlocked__c = true;
                    update raiseRecord;
                }
            }

            return raiseRecord;

        }catch(Exception e){
            Logger.logError('RaiseApp', 'RaiseFactory', 'unlockRaiseCourse', raiseId, null, null, null, e, 'Failed to unlock raise course for raiseId: ' + raiseId);
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
* Gets the EOI__c details for a specific Business account ID.
* @param companyId The Id of the Business Account to be queried.
* @return EOI__c record.
*/
    public EOI__c getEOIDetailsFromCompanyId(String companyId){
        try{
            List<EOI__c> eoi = [SELECT Name, Id, EOI_Status__c, EOI_Published_Date__c FROM EOI__c WHERE Account__c=:companyId];
            if (eoi.size() > 0) {
                Logger.logMessage('RaiseApp', 'RaiseFactory', 'getEOIDetailsFromCompanyId', 'Successfully retrieved EOI details for companyId: ' + companyId);
                return eoi[0];
            } else {
                Logger.logMessage('RaiseApp', 'RaiseFactory', 'getEOIDetailsFromCompanyId', 'No EOI details found for companyId: ' + companyId);
                return null;
            }
        }catch(Exception e){
            Logger.logError('RaiseApp', 'RaiseFactory', 'getEOIDetailsFromCompanyId', companyId, null, null, null, e, 'Failed to get EOI details for companyId: ' + companyId);
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
    * Gets the Raise record given a raise ID. These records are neccesary to render the raise deal page
    * @param companyId The Id of the Business Account.
    * @return Raise__c record. getRaiseRecordCompanyId
    */
    public Raise__c getRaisePageRecordRaiseId(String raiseId){
        List<Raise__c> raiseList = [SELECT Name,Account__c, Company__c, EOI__c, Status__c, Form_Problem_or_Opportunity__c,
                                    Form_Solution__c, Form_Differentiation__c, Form_Intellectual_Property__c, Form_Total_addressable_market__c,
                                    Form_Progress__c, Form_Growth_plan__c, Form_Valuation__c, Form_Company_one_liner__c, Form_Stage__c, Form_Company_Overview__c,Form_Youtube__c,
                                    Form_Offer_close_date__c,Form_Target_amount__c, Form_Minimum_target__c,Form_Maximum_target__c, Form_Minimum_Investment_amount__c, Product__c, Form_Offer_launch_date__c,
                                    Form_Instagram__c,Form_Facebook__c,Form_Website__c,Form_LinkedIn__c,Form_Investment_type__c,Form_Share_price__c, Form_Sector__c,Form_Investment_Product_Type__c,
                                    Form_Coupon_rate__c,Form_Term_Months__c,Form_Conversion_terms__c,Form_Interest_rate__c,Form_Security__c,Form_Valuation_cap__c,Form_Discount_rate__c,Form_Planned_use_of_funds__c,
                                    Form_Price_per_note__c,Form_Price_per_share__c,Value_of_Applications__c,Form_Video_Link__c,Show_Comments__c,Form_Share_price_currency__c,No_Fees_Payable__c, Fund_name__c,
                                    Fund_one_liner__c, Target_Return__c, Distribution_frequency__c, Investment_term__c, Entry_exit_fees__c,Fund_the_offer__c
                                    FROM Raise__c WHERE Id=:raiseId];
        if (raiseList.isEmpty()) {
            Logger.logMessage('RaiseApp', 'RaiseFactory', 'getRaisePageRecordRaiseId', 'No raise record found for raiseId: ' + raiseId);
            throw new AuraHandledException('No raise record found for raiseId: ' + raiseId);
        } else { 
            Logger.logMessage('RaiseApp', 'RaiseFactory', 'getRaisePageRecordRaiseId', 'Successfully retrieved raise record for raiseId: ' + raiseId);
            return raiseList[0];
        }
    }
    
    /**
    * Gets the full Raise__c record for a specific Raise ID.
    * @param raiseId The Id of the Raise record.
    * @return Raise__c record.
    */
    public Raise__c getFullRaiseRecord(String raiseId) {
        try {
            Raise__c raiseRecord = [SELECT Id, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, 
                           LastModifiedById, SystemModstamp, LastActivityDate, 
                           Status__c, Account__c, EOI__c, Product__c, Preraise_completed__c, Content_approved__c, 
                           Payment_received__c, Course_unlocked__c, Offer_document_approved__c, Learning_completed__c, 
                           Company__c, Form_Company_Legal_Trading_Name__c, Form_Registered_Aus__c, Form_ABN__c, 
                           Form_ACN__c, Form_Website__c, Form_Sector__c, Form_Company_one_liner__c, Form_Video_Link__c, 
                           Form_Company_Overview__c, Form_Problem_or_Opportunity__c, Form_Solution__c, 
                           Form_Differentiation__c, Form_Intellectual_Property__c, Form_Total_addressable_market__c, 
                           Form_Progress__c, Form_Raise_Contact_Email__c, Form_Consent_for_individuals__c, 
                           Form_Facebook__c, Form_Instagram__c, Form_LinkedIn__c, Form_Youtube__c, Form_X_Twitter__c, 
                           Form_Growth_plan__c, Form_Business_strategy__c, Form_Business_model__c, 
                           Form_Organisation_structure__c, Form_Proprietary_company__c, Form_Public_company__c, 
                           Form_Stage__c, Form_Planned_use_of_funds__c, Form_Offer_launch_date__c, Form_Offer_close_date__c, 
                           Form_Investment_type__c, Form_Investment_Product_Type__c, Form_Number_of_shares_on_issue__c, 
                           Form_Valuation__c, Form_Share_price__c, Form_Rights_associated_with_shares__c, 
                           Form_VentureCrowd_trust_unit_price__c, Form_Target_amount__c, Form_Minimum_target__c, 
                           Form_Maximum_target__c, Form_Minimum_Investment_amount__c, Form_Financial_information_summary__c, 
                           Form_Financial_information_URL__c, Form_Debt_funding_and_other_funding__c, 
                           Form_Funds_raised_to_date__c, Form_Legal_or_disciplinary_action__c, 
                           Form_Risks_facing_the_business__c, Form_Risk_warning__c, Form_Cooling_off_rights__c, 
                           Form_Glossary__c, Founder_Information_is_correct__c, Form_Terms_and_Conditions__c, Owner__c
                           FROM Raise__c WHERE Id = :raiseId LIMIT 1];

            if (raiseRecord != null) {
                Logger.logMessage('RaiseApp', 'RaiseFactory', 'getFullRaiseRecord', 'Successfully retrieved full raise record for raiseId: ' + raiseId);
                return raiseRecord;
            } else {
                Logger.logMessage('RaiseApp', 'RaiseFactory', 'getFullRaiseRecord', 'No raise record found for raiseId: ' + raiseId);
                throw new AuraHandledException('No raise record found for raiseId: ' + raiseId);
            }
        } catch (Exception e) {
            Logger.logError('RaiseApp', 'RaiseFactory', 'getFullRaiseRecord', raiseId, null, null, null, e, 'Failed to get full raise record for raiseId: ' + raiseId);
            throw new AuraHandledException(e.getMessage());
        }
    }

    public Raise__c getRaiseRecordDetailsForm(Id raiseId){
        try{
            //loop through the valueSet to build a list of fields to query
            String fieldsToQuery = String.join(RaiseService.raiseObjectMapping.valueSet(),',');

            String queryString = 'SELECT ' + fieldsToQuery + ' FROM Raise__c WHERE Id=:raiseId LIMIT 1';

            Raise__c raiseRecord = Database.query(queryString);

            System.debug(raiseRecord);
            return raiseRecord;
        }catch(Exception e){
            Logger.logError('RaiseApp', 'RaiseFactory', 'getRaiseRecordDetailsForm', raiseId, null, null, null, e, 'Failed to get Raise record: ' + raiseId);
            // throw new AuraHandledException('Failed to get Raise record: ' + e.getMessage());
            throw e;
        }
    }

    /**
    * Update the raise record
    */
    public Map<String,Object> updateRaiseRecord(Id raiseId, Map<String, Object> fieldsToUpdate) {
        // Perform the update DML operation
        try {
            Raise__c raiseRecord = new Raise__c();
            raiseRecord.put('Id', raiseId);

            Map<String, Object> unmappedFields = new Map<String,Object>();

            Map<String, SObjectField> raiseFieldsMap = raiseRecord.getSObjectType().getDescribe().fields.getMap();

            for(String field : fieldsToUpdate.keySet()){
                if(RaiseService.raiseObjectMapping.containsKey(field)){
                    String sObjectFieldName = RaiseService.raiseObjectMapping.getValue(field);
                    // get field type
                    if(raiseFieldsMap.containsKey(sObjectFieldName)){
                        SObjectField sObjectField = raiseFieldsMap.get(sObjectFieldName);

                        if(sObjectField.getDescribe().isCalculated()){
                            unmappedFields.put(field, fieldsToUpdate.get(field));
                        }else{
                            Schema.DisplayType fieldType = sObjectField.getDescribe().getType();
                            Object fieldValue = fieldsToUpdate.get(field);

                            // convert value to field type
                            Object convertedValue = convertFieldValue(fieldType, fieldValue);

                            // put
                            raiseRecord.put(sObjectFieldName, convertedValue);
                        }

                    }else{
                        unmappedFields.put(field, fieldsToUpdate.get(field));
                    }
                    
                }else{
                    unmappedFields.put(field, fieldsToUpdate.get(field));
                }
            }

            update raiseRecord;
            Logger.logMessage('RaiseApp', 'RaiseFactory', 'updateRaiseRecord', 'Successfully updated Raise record: ' + raiseRecord.Id);

            Map<String,Object> returnResult = new Map<String,Object>();

            returnResult.put('Id', raiseRecord.Id);
            returnResult.put('unmapped', unmappedFields);

            return returnResult;
        } catch (Exception e) {
            Logger.logError('RaiseApp', 'RaiseFactory', 'updateRaiseRecord', raiseId, null, null, null, e, 'Failed to update Raise record: ' + raiseId);
            // throw new AuraHandledException('Failed to update Raise record: ' + e.getMessage());
            throw e;
        }
    }

    public Raise__c linkLearningToRaise(Id raiseId, Id learningId){
        try{
            Raise__c raiseRecord = [SELECT Id, Learning__c FROM Raise__c WHERE Id=:raiseId LIMIT 1];
            raiseRecord.Learning__c = learningId;

            update raiseRecord;

            return raiseRecord;
        }catch(Exception e){
            throw e;
        }
    }


    public Map<String,Object> getSummaryStatistics(Id raiseId, Id eoiId){
        // try{
            Map<String,Object> returnJSON = new Map<String,Object>();

            // get count of opportunities related to a raise
            List<AggregateResult> resultsOpp = [SELECT COUNT(Id) total FROM Opportunity WHERE Raise__c = :raiseId];

            // Extract the count from the AggregateResult
            Integer opportunityCount = (resultsOpp.size() > 0) ? (Integer)resultsOpp[0].get('total') : 0;
            returnJSON.put('raise',raiseId);
            returnJSON.put('opportunities', opportunityCount);

            // get leads associated to an EOI
            // get count of opportunities related to a raise
            List<AggregateResult> resultsLeads = [SELECT COUNT(Id) total FROM Lead WHERE Related_EOI__c = :eoiId];

            // Extract the count from the AggregateResult
            Integer LeadsCount = (resultsLeads.size() > 0) ? (Integer)resultsLeads[0].get('total') : 0;
            returnJSON.put('eoi',eoiId);
            returnJSON.put('leads', LeadsCount);

            Raise__c raiseCloseDate  = [SELECT Id, Form_Offer_close_date__c FROM Raise__c WHERE Id =:raiseId LIMIT 1];
            Date today = Date.today();
            Date closeDate = raiseCloseDate.Form_Offer_close_date__c;

            Integer daysBetween = today.daysBetween(closeDate);
            returnJSON.put('daysLeft', daysBetween);

            return returnJSON;
        // }catch(Exception e){
        //     throw e;
        // }
    }

    /**
    * Update the raise Status 
    * @param raiseId The Id of the Raise record. 
    * @param status The new status of the raise record.
    * @return Raise__c record.
    */

    public Raise__c updateRaiseStatus(Id raiseId, String status){
       // try{
            Raise__c raiseRecord = [SELECT Id, Status__c FROM Raise__c WHERE Id = :raiseId LIMIT 1];
            raiseRecord.Status__c = status;

            update raiseRecord;
            Logger.logMessage('RaiseApp', 'RaiseFactory', 'updateRaiseStatus', 'Raise record updated successfully ' + raiseId);
            return raiseRecord;
        // }catch(Exception e){
        //     Logger.logError('RaiseApp', 'RaiseFactory', 'updateRaiseStatus', raiseId, null, null, null, e, 'Failed to update raise record for raiseId: ' + raiseId + ' and the status: ' + status);
        //     throw new AuraHandledException(e.getMessage());
        // }
    }

    /**
     * Converts a field value to the appropriate type based on the field description.
     * @param fieldType The field type.
     * @param fieldValue The value to convert.
     * @return The converted value.
     */
    @TestVisible
    private Object convertFieldValue(Schema.DisplayType fieldType, Object fieldValue) {
        if (fieldValue == null || String.isBlank((String)fieldValue)) {
            return null;
        }
    
        switch on fieldType {
            when BOOLEAN {
                return Boolean.valueOf((String) fieldValue);
            }
            when DATE {
                return Date.valueOf((String) fieldValue);
            }
            when DATETIME {
                return Datetime.valueOfGmt((String) fieldValue);
            }
            when INTEGER {
                return Integer.valueOf((String) fieldValue);
            }
            when DOUBLE, CURRENCY, PERCENT {
                return Double.valueOf((String) fieldValue);
            }
            when STRING, TEXTAREA, URL, EMAIL, PHONE {
                return (String) fieldValue;
            }
            when ID {
                return (Id) fieldValue;
            }
            when REFERENCE {
                return (Id) fieldValue;
            }
            when else {
                return (String) fieldValue;
            }
        }
    }

    public Raise__c getRaiseRecordType(Id raiseId) {
        Raise__c raiseRecords = [SELECT RecordType.DeveloperName FROM Raise__c WHERE Id = :raiseId LIMIT 1];
        return raiseRecords;
    }
}