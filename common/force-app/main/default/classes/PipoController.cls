/**
 * @description
 * Controller class for handling portfolio and investment-related operations in the Pipo App.
 * This class provides methods for retrieving and managing data related to portfolio accounts, investments,
 * tax documents, EOI leads, and refund requests. It integrates with the `PipoService` for business logic 
 * and data retrieval.
 * 
 * Each method is exposed to Aura and Lightning Web Components (LWC) using the `@AuraEnabled` annotation, 
 * enabling seamless interaction with the frontend.
 * 
 * @Author
 * Cesar Vaca
 * 
 * @date
 * 18-11-2024
 */
public with sharing class PipoController {
    @TestVisible private static PipoService pipoService = new PipoService();

    /**
     * Retrieves the portfolio account information for a given user.
     * This method is exposed to Lightning components via the @AuraEnabled annotation.
     * 
     * @param userId The Id of the user for whom portfolio account information is retrieved.
     * @return A Map containing portfolio account information (e.g., Name, IdVerified).
     */
    @AuraEnabled()
    public static Map<String, Object> portfolioAccountInformation(Id userId){
        try{
            return pipoService.portfolioAccountInformation(userId);
        }catch (Exception e) {
            Logger.logError('PipoApp', 'PipoController', 'portfolioAccountInformation', null, null, null, null, e, 'Failed to get pipo account details for userId: ' + userId);
            throw e;
        }
    }

    /**
     * Retrieves the investments for a person account based on the userId.
     * This method is exposed to Lightning components via the @AuraEnabled annotation.
     * 
     * @param userId The Id of the user for whom investment information is retrieved.
     * @return A List of Maps, each containing details about the investments (e.g., Stage, Amount, ProductName).
     */
    @AuraEnabled()
    public static List<Map<String, Object>> getAccountInvestments(Id userId, Integer limitSize, Integer offsetValue){
        return pipoService.getAccountInvestments(userId, limitSize, offsetValue);
    }

    /**
     * Retrieves the investments for business entities associated with the given user.
     * This method is exposed to Lightning components via the @AuraEnabled annotation.
     * 
     * @param userId The Id of the user whose associated entity investments are retrieved.
     * @return A List of Maps, each containing details about the entity's investments and related fields (e.g., EntityName, EntityId).
     */
    @AuraEnabled()
    public static List<Map<String, Object>> getEntitiesInvestments(Integer limitSize, Integer offsetValue){
        try{
            return pipoService.getEntitiesInvestments(limitSize, offsetValue);
        }catch (Exception e) {
            Logger.logError('PipoApp', 'PipoController', 'getEntitiesInvestments', null, null, null, null, e, 'Failed to get entity investment details');
            throw e;
        }
    }


    /**
     * Retrieves tax documents associated with a given userId.
     * This method is exposed to Aura components, and the result is cacheable for performance optimization.
     * The tax document data is fetched from the pipoService.
     * 
     * @param userId The Id of the user for whom the tax documents are being retrieved.
     * @return A list of maps where each map represents a tax document with key-value pairs containing document details.
     * @throws AuraHandledException if an error occurs during the process, with the error message being passed to Aura.
     */
    @AuraEnabled
    public static List<Map<String, Object>> getTaxDocuments(Id userId, String fileName, Boolean base64){
        // try {
            return pipoService.getTaxDocuments(userId, fileName, base64);
        // } catch (Exception e) {
        //     Logger.logError('PipoApp', 'PipoController', 'getTaxDocuments', null, null, null, null, e, 'Failed to get tax documents details for: ' + userId);
        //     throw e;
        // }
    }


    /**
     * @description
     * Retrieves detailed information about a specific investment.
     * 
     * @param investmentId The ID of the investment for which details are retrieved.
     * @return A Map containing investment details (e.g., InvestmentName, Status, Amount).
     * @throws Exception If an error occurs during the process, the error is logged and rethrown.
     */
    @AuraEnabled
    public static Map<String, Object> getInvestmentDetails(Id investmentId){
        // try {
            return pipoService.getInvestmentDetails(investmentId);
        // } catch (Exception e) {
        //     Logger.logError('PipoApp', 'PipoController', 'getInvestmentDetails', null, null, null, null, e, 'Failed to get investment details for: ' + investmentId);
        //     throw new AuraHandledException(e.getMessage());
        // }
    }

    /**
     * @description
     * Retrieves transactions associated with a specific investment ID.
     * 
     * @param investmentId The ID of the investment for which transactions are retrieved.
     * @return A List of Maps containing transaction details (e.g., TransactionDate, Amount, Status).
     * @throws Exception If an error occurs during the process, the error is logged and rethrown.
     */
    @AuraEnabled
    public static List<Map<String, Object>> getInvestmentTransactions(Id investmentId){
        return pipoService.getInvestmentTransactions(investmentId);
    }

    /**
     * @description
     * Requests a refund for a specific investment.
     * 
     * @param investmentId The ID of the investment for which the refund is requested.
     * @param reasonRefund The reason provided for requesting the refund.
     * @throws Exception If an error occurs during the process, the error is logged and rethrown.
     */
    @AuraEnabled
    public static void requestRefund(Id investmentId, String reasonRefund) {
        try {
            pipoService.requestRefund(investmentId, reasonRefund);
        } catch (Exception e) {
            Logger.logError('PipoApp', 'PipoController', 'requestRefund', null, null, null, null, e, 'Failed to get update refund details for: ' + investmentId);
            throw e;
        }
    }

    /**
     * @description
     * Requests a refund for a specific investment.
     * 
     * @param investmentId The ID of the investment for which the refund is requested.
     * @param reasonRefund The reason provided for requesting the refund.
     * @throws Exception If an error occurs during the process, the error is logged and rethrown.
     */
    @AuraEnabled
    public static void tourTaken(Id userId) {
            pipoService.tourTaken(userId);
    }


        /**
     * @description
     * Retrieves Spotlight data for the specified user.
     * Spotlight data typically includes key metrics or values related to the user's portfolio.
     *
     * @param userId The ID of the user for whom Spotlight data is being retrieved.
     * @return A Map containing key-value pairs where the keys are metric names and values are Decimal numbers.
     * @throws Exception If an error occurs during the retrieval process, the error is logged and rethrown.
     */
    @AuraEnabled
    public static Map<String,Decimal> getSpotlightData(Id userId){
        try {
            return pipoService.getSpotlightData(userId);
        } catch (Exception e) {
            Logger.logError('PipoApp', 'PipoController', 'getSpotlightData', null, null, null, null, e, 'Failed to get spotlight details for: ' + userId);
            throw e;
        }
    }

    /**
     * @description
     * Retrieves a list of pending and inactive investments for the specified user.
     * Pending investments are those awaiting completion, and inactive investments are no longer active.
     *
     * @param userId The ID of the user for whom pending and inactive investments are being retrieved.
     * @return A List of Maps, where each Map contains key-value pairs representing investment details.
     * @throws Exception If an error occurs during the retrieval process, the error is logged and rethrown.
     */
    @AuraEnabled
    public static List<Map<String, Object>> getPendingAndInactiveInvestments(Id userId){
        try {
            return pipoService.getPendingAndInactiveInvestments(userId);
        } catch (Exception e) {
            Logger.logError('PipoApp', 'PipoController', 'getPendingAndInactiveInvestments', null, null, null, null, e, 'Failed to get pending and inactive investments for: ' + userId);
            throw e;
        }
    }

}