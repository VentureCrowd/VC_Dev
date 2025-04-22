/**
 * LeadService class provides methods for interacting with Lead records.
 * It includes operations to fetch, create, and update Lead records using
 * a factory pattern to manage the operations.
 */

public inherited sharing class LeadService {

    public Map<String,Object> getLeadById(Id leadId){
        Map<String,Object> returnRecord = new Map<string,Object>();

        LeadFactory factory = new LeadFactory();
        List<Lead> res = factory.getLeadById(leadId);

        if(!res.isEmpty()){
            Lead tempLead = res[0];
            returnRecord.put('firstName',tempLead.FirstName);
            returnRecord.put('lastName',tempLead.LastName);
            returnRecord.put('email',tempLead.Email);
            returnRecord.put('mobileNumber',tempLead.MobilePhone);
            returnRecord.put('comments',tempLead.Comments__c);
            returnRecord.put('company',tempLead.Company);
            returnRecord.put('source', tempLead.LeadSource);
            returnRecord.put('webSource', tempLead.Web_Source__c);
            returnRecord.put('relatedEOI', tempLead.Related_EOI__c);
        }

        return returnRecord;

    }


      /**
     * Retrieves a paginated list of Lead records based on the provided criteria.
     *
     * @param recordId       The ID of the Lead record to filter the query. Can be null for fetching all records.
     * @param pageSize       The number of records to return per page.
     * @param pageNumber     The current page number to retrieve.
     * @param sortBy         The field by which to sort the records.
     * @param sortDirection  The direction of sorting (ASC or DESC).
     * @param columnNames    The list of columns to include in the result.
     * @return               A RecordsWrapper object containing the list of Lead records and total record count.
     * @throws Exception     If any error occurs during the record retrieval process.
     */
    public RecordsWrapper getRecords(Id recordId, Integer pageSize, Integer pageNumber, String sortBy, String sortDirection, List<String> columnNames){
        try{
            LeadFactory factory = new LeadFactory();

            return factory.getRecords(recordId, pageSize, pageNumber, sortBy, sortDirection, columnNames);
        }catch(Exception e){
            throw e;
        }
       
    }

    /**
     * Creates a new Lead record with the provided field values.
     *
     * @param fieldsToAdd    A map of field names and their respective values to create a new Lead.
     * @return               A map containing details of the created Lead record.
     */
    public Map<String,Object> createLead(Map<String,Object> fieldsToAdd){
        LeadFactory factory = new LeadFactory();

        // Add record type ID to the fields to add
        // INFSD-651 KKAM 14/01/2025
        // Changed record type to Ventures
        Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Ventures').getRecordTypeId();
        fieldsToAdd.put('recordTypeId', recordTypeId);

        User vcTeamUser = [SELECT Id FROM User WHERE Name = 'The VentureCrowd Team' LIMIT 1];
        if(vcTeamUser != null){
            fieldsToAdd.put('OwnerId', vcTeamUser.Id);
        }

        Map<String,Object> returnData = factory.createLead(fieldsToAdd);

        return returnData;

        
    }


    /**
     * Updates an existing Lead record with the provided field values.
     *
     * @param recordId       The ID of the Lead record to be updated.
     * @param objectName     The name of the object being updated (usually 'Lead').
     * @param fieldsToUpdate A map of field names and their respective values to update the Lead.
     * @return               A map containing the result of the update operation.
     */
    public Map<String,Object> updateLead(Id recordId, String objectName,Map<String,Object> fieldsToUpdate){
        LeadFactory factory = new LeadFactory();

        Map<String,Object> retResult = factory.updateLead(recordId, objectName,fieldsToUpdate, leadFieldMapping);

        return retResult;
    }


     /**
     * RecordsWrapper class acts as a container for returning records along with the total record count.
     */
    public class RecordsWrapper {
        @AuraEnabled public List<sObject> records { get; set; }
        @AuraEnabled public List<AggregateResult> totalRecords { get; set; }


          /**
         * Constructs a new RecordsWrapper.
         *
         * @param records       The list of Lead records retrieved.
         * @param totalRecords  The total number of Lead records matching the query.
         */
        public RecordsWrapper(List<sObject> records, List<AggregateResult> totalRecords) {
            this.records = records;
            this.totalRecords = totalRecords;
        }
    }

    /**
     * A BidiMap that provides a bidirectional mapping between field names and their corresponding API field names.
     */
    public static BidiMap leadFieldMapping = new BidiMap(new Map<String, String>{
        'comments' => 'Comments__c',
        'callBackReq' => 'Call_back_required__c',
        'founderStatus' => 'Founder_status__c',
        'status' => 'Status',
        'subStatus' => 'Lead_Sub_Status__c'
    });

        /**
     * Retrieves EOI Leads information for a given email.
     *
     * @param email The email address used to fetch EOI leads.
     * @return A List of Maps containing lead information, including lead ID, associated EOI details,
     *         investment amount, lead name, EOI title, and company logo URL.
     */
    public List<Map<String, Object>> getEOILeadsEmail(String email) {        
        LeadFactory factory = new LeadFactory();
        EOI_Service eoiService = new EOI_Service();

        // Fetch all lead records associated with the given email
        List<Lead> records = factory.getEOILeadsEmail(email);  
        List<Map<String, Object>> returnList = new List<Map<String, Object>>();

        if (!records.isEmpty()) {
            Integer recordId = 1;
            
            // Iterate over each retrieved Lead record
            for (Lead record : records) {  
                Map<String, Object> recordMap = new Map<String, Object>();

                // Assign an incremental record ID
                recordMap.put('Id', recordId++);
                recordMap.put('EoiId', record.Related_EOI__c);
                
                // Store investment amount (considering currency if available)
                if (record.Investment_Amount_Currency__c != null) {
                    recordMap.put('InvestAmount', record.Investment_Amount_Currency__c);
                } else {
                    String strAmount = record.Investment_Amount__c.split(' to ')[0];
                    recordMap.put('InvestAmount', strAmount);
                }

                // Store lead name
                recordMap.put('Name', record.Name);

                // Fetch the associated EOI information using the EOI Service
                List<EOI__c> eoiRecords = eoiService.getEoiInformation(record.Related_EOI__c);

                // Only show Active EOI's
                if (!eoiRecords.isEmpty() && eoiRecords[0].EOI_Status__c != 'Closed') {
                    // Store the EOI title
                    recordMap.put('EoITitle', eoiRecords[0].EOI_Title__c);

                    // Get the company logo if is there a raise
                    try {
                        Map<String,Object> getRaiseId = eoiService.getLiveRaiseFromEOI(record.Related_EOI__c);
                        String raiseId = getRaiseId.keySet().iterator().next();
                        // Get the product id from the Raise controller
                        String raiseDetails = RaiseController.getRaiseDetails(raiseId);
                        // Deserialize the JSON string into a Map object
                        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(raiseDetails);
                        // Get the productId based on the Raise Details
                        Id productId = (Id) jsonMap.get('productId');
                        // Get the displayURL from the product
                        Product2 getProductDetails = Product_V2_Controller.getProductInformation(productId);
                        // Put the displayURL into the map
                        recordMap.put('companyLogoEOI', getProductDetails.DisplayUrl);
                    } catch (Exception e) {
                        // Extract the company logo URL from the JSON field 'URL_Files_Img__c'
                        String images = eoiRecords[0].URL_Files_Img__c;
                        List<Object> imagesURLS = (List<Object>) JSON.deserializeUntyped(images);
                        // Iterate over image objects to find the logo
                        for (Object imageObj : imagesURLS) {
                            Map<String, Object> imageMap = (Map<String, Object>) imageObj;
                            if (imageMap.get('title').equals('logo')) {
                                // Use the default logo from EOI
                                recordMap.put('companyLogoEOI', (String) imageMap.get('contentDownloadURL'));
                                break;
                            }
                        }
                    }   
                    // Add the processed record to the result list
                    returnList.add(recordMap);
                }
            }
        }

        // Return the list of lead details
        return returnList;
    }

    
}