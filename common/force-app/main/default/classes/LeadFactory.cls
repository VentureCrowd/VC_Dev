/**
 * LeadFactory class provides the implementation for fetching, creating, and updating Lead records.
 * It leverages dynamic SOQL and field mappings to handle these operations efficiently.
 */

public inherited sharing class LeadFactory {

    public List<Lead> getLeadById(Id leadId){
        return [SELECT FirstName,LastName, Email, MobilePhone, Comments__c, Company, Web_Source__c, LeadSource, Related_EOI__c FROM Lead WHERE Id=:leadId];
    }

    /**
     * Retrieves a paginated list of Lead records associated with a specific Raise record.
     * Constructs a dynamic SOQL query based on the provided parameters.
     *
     * @param recordId       The ID of the Raise record to filter the Leads.
     * @param pageSize       The number of records to return per page.
     * @param pageNumber     The current page number to retrieve.
     * @param sortBy         The field by which to sort the records.
     * @param sortDirection  The direction of sorting (ASC or DESC).
     * @param columnNames    The list of columns to include in the result.
     * @return               A LeadService.RecordsWrapper object containing the list of Lead records and the total record count.
     * @throws AuraHandledException If the associated EOI does not exist or if any error occurs during the query execution.
     */
    public LeadService.RecordsWrapper getRecords(Id recordId, Integer pageSize, Integer pageNumber, String sortBy, String sortDirection, List<String> columnNames){
        try{

            List<Raise__c> raiseRecord = [SELECT EOI__c FROM Raise__c WHERE Id=:recordId];


            if(!raiseRecord.isEmpty()){
                Id eoiId = raiseRecord[0].EOI__c;

                   // Construct the SOQL query dynamically based on column names
                Integer offset = (pageNumber - 1) * pageSize;

                // Manually join column names into a single string
                String fields = '';
                for (String column : columnNames) {
                    fields += column + ', ';
                }
                fields = fields.removeEnd(', ');

                String query = 'SELECT ' + fields + ' FROM Lead WHERE Related_EOI__c=:eoiId' ;

                if (sortBy != null && sortDirection != null) {
                    query += ' ORDER BY ' + sortBy + ' ' + sortDirection;
                }

                query += ' LIMIT :pageSize OFFSET :offset';

                List<sObject> records = Database.query(query);

                List<AggregateResult> totalRecords = [SELECT COUNT(Id) FROM Lead WHERE Related_EOI__c =: eoiId];

                return new LeadService.RecordsWrapper(records, totalRecords);  
            }else{
                throw new AuraHandledException('EOI does not exist for this raise');
            }
           
        }catch(Exception e){
            throw new AuraHandledException(e.getStackTraceString());
        }
      
    }

    /**
     * Creates a new Lead record with the provided field values using a predefined field mapping.
     *
     * @param fieldsToAdd    A map of field names and their respective values to create a new Lead.
     * @return               A map containing details of the created Lead record.
     */
    public Map<String,Object> createLead(Map<String,Object> fieldsToAdd){
        GenericObjectFactory factory = new GenericObjectFactory();
        BidiMap fieldMapping = new BidiMap(new Map<String,String>{
            'firstName'=>'FirstName',
            'middleNames'=>'MiddleName',
            'lastName'=>'LastName',
            // OwnerId added as part of INFSD-651 KKAM
            'OwnerId'=>'OwnerId',
            'webSource'=>'Web_Source__c',
            'email' => 'Email',
            'mobileCodeFormatted' => 'MobilePhone',
            'isWholesale' => 'Wholesale_Status__c',
            'investmentAmount' => 'Investment_Amount_Currency__c',
            'ausResident' => 'Are_you_located_in_Australia__c',
            'comments' => 'Comments__c',
            'source' => 'LeadSource',
            'company' => 'Company',
            'emailOptIn' => 'Email_Opt_In__c',
            'utm_campaign' => 'utm_campaign__c',
            'utm_content' => 'utm_content__c',
            'utm_term' => 'utm_keyword__c',
            'utm_medium' => 'utm_medium__c',
            'utm_source' => 'utm_source__c',
            'utm_keyword' => 'utm_keyword__c',
            'recordTypeId' => 'RecordTypeId',
            'relatedEOI' => 'Related_EOI__c'
        });

        Map<String,Object> returnData = factory.createRecord(
            'Lead', 
            fieldsToAdd, 
            fieldMapping
        );

        return returnData;
     
    }

    /**
     * Updates an existing Lead record with the provided field values using a predefined field mapping.
     *
     * @param recordId       The ID of the Lead record to be updated.
     * @param objectName     The name of the object being updated (usually 'Lead').
     * @param fieldsToUpdate A map of field names and their respective values to update the Lead.
     * @param fieldMap       A BidiMap containing the mapping between UI field names and Salesforce API field names.
     * @return               A map containing the result of the update operation, including unmapped fields.
     */
    public Map<String,Object> updateLead(Id recordId, String objectName, Map<String, Object> fieldsToUpdate, BidiMap fieldMap){
        Map<String,Object> returnData = new Map<String,Object>();
        // Opportunity recordToUpdate = new Opportunity();
        SObject recordToUpdate = Schema.getGlobalDescribe().get(objectName).newSObject();
        
        recordToUpdate.put('Id',recordId);

        Map<String, SObjectField> objectFieldsMap = recordToUpdate.getSObjectType().getDescribe().fields.getMap();
        Map<String, Object> unmappedFields = new Map<String,Object>();

        for(String field : fieldsToUpdate.keySet()){
            if(fieldMap.containsKey(field)){
                // get api field name
                String sObjectFieldName = fieldMap.getValue(field);

                // check if field exists in the object
                if(objectFieldsMap.containsKey(sObjectFieldName)){
                    //get the field type
                    SObjectField sObjectField = objectFieldsMap.get(sObjectFieldName);
                    // check if its a calculated field
                    if(sObjectField.getDescribe().isCalculated()){
                        unmappedFields.put(field, fieldsToUpdate.get(field));
                    }else{
                        Schema.DisplayType fieldType = sObjectField.getDescribe().getType();
                        Object fieldValue = fieldsToUpdate.get(field);

                        // convert value to field type
                        Object convertedValue = convertFieldValue(fieldType, fieldValue);

                        // put
                        recordToUpdate.put(sObjectFieldName, convertedValue);
                    }
                }else{
                    unmappedFields.put(field, fieldsToUpdate.get(field));
                }

            }else{
                unmappedFields.put(field, fieldsToUpdate.get(field));
            }
        }
        update recordToUpdate;
        returnData.put('Id', recordId);
        returnData.put('unmapped', unmappedFields);
        
        return returnData;
    }


    /**
     * Converts a field value to the appropriate type based on the field description.
     * @param fieldType The field type.
     * @param fieldValue The value to convert.
     * @return The converted value.
     */
    @TestVisible
    private Object convertFieldValue(Schema.DisplayType fieldType, Object fieldValue) {
        if (fieldValue == null) {
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

    // get EOI Leads emails
    public List<Lead> getEOILeadsEmail(String email) {
        // Fetch Investments
        List<Lead> leadRecords = [SELECT Name, Investment_Amount_Currency__c, Investment_Amount__c,Related_EOI__c FROM Lead WHERE IsConverted = false AND Email=:email AND Related_EOI__c != null];
        
        if (!leadRecords.isEmpty()) {
            Logger.logMessage('OpportunityApp', 'OpportunitiesFactory', 'getEOILeadsEmail', 'Successfully retrieved lead records for: ' + email);
        } else {
            Logger.logMessage('OpportunityApp', 'OpportunitiesFactory', 'getEOILeadsEmail', 'No lead record found for email: ' + email);
        }
        return leadRecords;  // Return empty list instead of null
        
    }
}