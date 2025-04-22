public without sharing class OpportunitiesController {
    @TestVisible private static OpportunitiesService oppService = new OpportunitiesService();

    /**
     * Retrieves a paginated and sorted list of Opportunity records based on the provided parameters.
     * 
     * @param recordId      The ID of the record to filter Opportunities (if applicable).
     * @param pageSize      The number of records to retrieve per page.
     * @param pageNumber    The current page number to retrieve.
     * @param sortBy        The field to sort the results by.
     * @param sortDirection The direction to sort the results (ASC/DESC).
     * @param columnNames   The list of column names to retrieve for each Opportunity.
     * @return A RecordsWrapper object containing the paginated Opportunity records and metadata.
     * @throws AuraHandledException If a business logic error occurs during the operation.
     */

    @AuraEnabled
    public static OpportunitiesService.RecordsWrapper getRecords(Id recordId, Integer pageSize, Integer pageNumber, String sortBy, String sortDirection, List<String> columnNames){
        try {
            return oppService.getRecords(recordId, pageSize, pageNumber, sortBy, sortDirection, columnNames);
        } catch (AuraHandledException e) {
            Logger.logMessage('RaiseApp', 'OpportunitiesController', 'getRecords', e.getStackTraceString());
            throw e;
        }
    }

     /**
     * Updates an Opportunity record with the specified field values.
     * 
     * @param recordId      The ID of the Opportunity to update.
     * @param objectName    The name of the object to update (expected to be 'Opportunity').
     * @param fieldsToUpdate A map containing the field names and their new values to apply to the record.
     * @return A map of results or updated record data, as provided by the service layer.
     * @throws AuraHandledException If an error occurs during the update process.
     */
    @AuraEnabled
    public static Map<String,Object> updateOpportunity(Id recordId, String objectName, Map<String,Object> fieldsToUpdate){
        try {
            return oppService.updateOpportunity(recordId, objectName,fieldsToUpdate);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Retrieves the product IDs associated with a given Opportunity.
     * 
     * @param opportunityId The ID of the Opportunity whose product IDs are to be retrieved.
     * @return A list of Opportunity records containing the associated product IDs.
     * @throws AuraHandledException If an error occurs while retrieving the product IDs.
     */
    @AuraEnabled
    public static OpportunityLineItem getProductId(Id opportunityId){
        try {
            return oppService.getProductId(opportunityId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}