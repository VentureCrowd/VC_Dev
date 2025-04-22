/**
 * * @description Controller class for handling lead-related operations in the Salesforce environment.
 * This class provides methods for retrieving and updating lead records, with support for pagination and sorting.
 * @dependencies LeadService class and AuraHandledException.
 * @createdBy Kendrick Kam
 * @version 1.2
 */
public without sharing class LeadControllerNew {
    @TestVisible private static LeadService leadService = new LeadService();

    @AuraEnabled
    public static Map<String,Object> getLeadById(Id leadId){
        try {  
            return leadService.getLeadById(leadId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static LeadService.RecordsWrapper getRecords(Id recordId, Integer pageSize, Integer pageNumber, String sortBy, String sortDirection, List<String> columnNames){
        try {
            return leadService.getRecords(recordId, pageSize, pageNumber, sortBy, sortDirection, columnNames);
        } catch (AuraHandledException e) {
            throw e;
        }
    }

    @AuraEnabled
    public static Map<String,Object> updateLead(Id recordId, String objectName, Map<String,Object> fieldsToUpdate){
        try {
            return leadService.updateLead(recordId, objectName,fieldsToUpdate);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    

    @AuraEnabled
    public static Map<String,Object> createLead( Map<String,Object> fieldsToAdd){
        return leadService.createLead(fieldsToAdd);
    }

    @AuraEnabled
    public static Map<String,Object> createLeadSXSW( Map<String,Object> fieldsToAdd){
        return leadService.createLead(fieldsToAdd);
      
    }

    @AuraEnabled
    public static List<Map<String, Object>> getLeads( String email){
        return leadService.getEOILeadsEmail(email);
    }

    // get EOI leads via Email
    @AuraEnabled
    public static List<Map<String,Object>> getEOILeadsEmail(String email){
        return leadService.getEOILeadsEmail(email);
    }
}