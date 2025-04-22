public with sharing class InvestmentController {

    @TestVisible private static InvestmentService investmentService = new InvestmentService();

    /**
     * Retrieves detailed investment information associated with a given accountId.
     * This method is exposed to Aura components and utilizes the investmentService to fetch the data.
     * 
     * @param accountId The Id of the account for which investment information is being retrieved.
     * @return A list of Investment__c records with detailed information related to the accountId.
     * @throws AuraHandledException if an error occurs during the process, which will be logged.
     */
    @AuraEnabled
    public static List<Investment__c> getInvestmentInformation(List<Id> accountId,Integer limitSize, Integer offsetValue){
        return investmentService.getInvestmentInfo(accountId,limitSize,offsetValue);
    }

    /**
     * Retrieves a list of investment Ids associated with a given accountId.
     * This method is exposed to Aura components and utilizes the investmentService to fetch the data.
     * 
     * @param accountId The Id of the account for which investment Ids are being retrieved.
     * @return A list of Investment__c records containing only Id details related to the accountId.
     * @throws AuraHandledException if an error occurs during the process, which will be logged.
     */
    @AuraEnabled
    public static List<Investment__c> getInvestmentIds(Id accountId){
        try{
            return investmentService.getInvestmentIds(accountId);
        }catch (Exception e) {
            Logger.logError('InvestmentApp', 'InvestmentController', 'getInvestmentIds', null, null, null, null, e, 'Failed to get Id details for accountId: ' + accountId);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Retrieves detailed information for a specific investment identified by its Id.
     * This method is designed to be accessed by Aura components and leverages the investmentService
     * to fetch the necessary investment details. 
     *
     * @param investmentId The Id of the investment record to retrieve details for.
     * @return A list of Investment__c records containing detailed information for the given investmentId.
     * @throws AuraHandledException If an error occurs during the retrieval process, the exception is logged and re-thrown.
     */
    @AuraEnabled
    public static List<Investment__c> getInvestmentDetails(Id investmentId){
        try{
            return investmentService.getInvestmentDetails(investmentId);
        }catch (Exception e) {
            Logger.logError('InvestmentApp', 'InvestmentController', 'getInvestmentDetails', null, null, null, null, e, 'Failed to get details for investmentId: ' + investmentId);
            throw new AuraHandledException(e.getMessage());
        }
    }
}