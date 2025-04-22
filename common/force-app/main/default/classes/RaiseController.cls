/**
 * Apex controller for the Raise process.
 * The goal is to not have any business logic living in this layer,
 * but merely translate the callers input to match that of the service class
 */
public without sharing class RaiseController {
    @TestVisible private static RaiseService raiseService = new RaiseService();

	@AuraEnabled()
    public static Raise__c createRaiseRecord(String companyId, String investType){
        try{
            return raiseService.createRaiseRecord(companyId,investType);
        }catch (Exception e) {
            Logger.logError('RaiseApp', 'RaiseController', 'createRaiseRecord', null, null, null, null, e, 'Failed to create raise record for companyId: ' + companyId);
            throw e;
        }
    }
    
    @AuraEnabled()
    public static Boolean raiseExists(String companyId){
        try{
            return raiseService.raiseExists(companyId);
        }catch (Exception e) {
            Logger.logError('RaiseApp', 'RaiseController', 'raiseExists', null, null, null, null, e, 'Failed to check if raise exists for companyId: ' + companyId);
            throw e;
        }
    }
    
    @AuraEnabled()
    public static String getRaiseDetails(String raiseId){
        try{
            return raiseService.getRaiseDetails(raiseId);
        }catch (Exception e) {
            Logger.logError('RaiseApp', 'RaiseController', 'getRaiseDetails', null, null, null, null, e, 'Failed to get raise details for raiseId: ' + raiseId);
            throw e;
        }
    }

    @AuraEnabled()
    public static Map<String,Object> getRaiseStatuses(String raiseId){
        try{
            return raiseService.getRaiseStatuses(raiseId);
        }catch (Exception e) {
            Logger.logError('RaiseApp', 'RaiseController', 'getRaiseDetails', null, null, null, null, e, 'Failed to get raise details for raiseId: ' + raiseId);
            throw e;
        }
    }

    @AuraEnabled()
    public static Map<String,Object> unlockRaiseCourse(String raiseId){
        try{
            return raiseService.unlockRaiseCourse(raiseId);
        }catch (Exception e) {
            Logger.logError('RaiseApp', 'RaiseController', 'unlockRaiseCourse', null, null, null, null, e, 'Failed to unlock course for raiseId: ' + raiseId);
            throw e;
        }
    }

    @AuraEnabled
    public static Map<String,Object> createLearningForRaise(Id raiseId){
        try {
            return raiseService.createLearningForRaise(raiseId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled()
    public static String getRaiseDetailsFromCompanyId(String companyId){
        try{
            return raiseService.getRaiseDetailsFromCompanyId(companyId);
        }catch (Exception e) {
            Logger.logError('RaiseApp', 'RaiseController', 'getRaiseDetailsFromCompanyId', null, null, null, null, e, 'Failed to get raise details for companyId: ' + companyId);
            throw e;
        }
    }
    
    @AuraEnabled()
    public static String getRaisePageDetailsRaiseId(String raiseId){
        try{
            return raiseService.getRaisePageDetailsRaiseId(raiseId);
        }catch (Exception e) {
            Logger.logError('RaiseApp', 'RaiseController', 'getRaisePageDetailsRaiseId', null, null, null, null, e, 'Failed to get raise details for raiseId: ' + raiseId);
            throw e;
        }
    }

    @AuraEnabled()
    public static Map<String,Object> updateRaiseDetails(Id raiseId, Map<String, Object> fieldsToUpdate){
        try{
            return raiseService.updateRaiseData(raiseId,fieldsToUpdate);
        }catch (Exception e) {
            Logger.logError('RaiseApp', 'RaiseController', 'updateRaiseDetails', null, null, null, null, e, 'Failed to update raise details for Raise:' + raiseId);
            throw e;
        }
    }

    @AuraEnabled()
    public static Map<String,Object> getRaiseDetailsForm(Id raiseId){
        try{
            return raiseService.getRaiseDetailsForm(raiseId);
        }catch (Exception e) {
            Logger.logError('RaiseApp', 'RaiseController', 'getRaiseDetailsForm', null, null, null, null, e, 'Failed to get raise details for Raise:' + raiseId);
            throw e;
        }
    }
    @AuraEnabled()
    public static  List<Map<String, String>> getPicklistValues(String objectName, String fieldName){
        try{
            return raiseService.getPicklistValues(objectName, fieldName);
        }catch (Exception e) {
            Logger.logError('RaiseApp', 'RaiseController', 'getPicklistValues', null, null, null, null, e, 'Failed to get picklist values for field:' + fieldName);
            throw e;
        }
    }

    @AuraEnabled
    public static Map<String,Object> getSummaryStatistics(Id raiseId, Id eoiId){
        // try {
            return raiseService.getSummaryStatistics(raiseId, eoiId);
        // } catch (Exception e) {
        //     Logger.logError('RaiseApp', 'RaiseController', 'getSummaryStatistics', null, null, null, null, e, 'Failed to get summary statistics for raise: ' + raiseId);
        //     throw e;
        // }
    }

    //! Change it in the future
    @AuraEnabled()
    public static Boolean userLoggedIn(){
        return raiseService.isUserLoggedIn();
    }

    @AuraEnabled
    public static Raise__c updateRaiseStatus(Id raiseId, String status){
        try{
            return raiseService.updateRaiseStatus(raiseId, status);
        }catch (Exception e) {
            Logger.logError('RaiseApp', 'RaiseController', 'updateRaiseStatus', null, null, null, null, e, 'Failed to update raise record for companyId: ' + raiseId);
            throw new AuraHandledException('An error occurred while updating the raise record: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static string getRaiseRecordType(Id raiseId){
        try{
            return raiseService.getRaiseRecordType(raiseId);
        } catch (Exception e) {
            Logger.logError('RaiseApp', 'RaiseController', 'getRaiseRecordType', null, null, null, null, e, 'Failed to get raise record type for raiseId: ' + raiseId);
            throw new AuraHandledException('An error occurred while updating the raise record: ' + e.getMessage());
        }
    }
}