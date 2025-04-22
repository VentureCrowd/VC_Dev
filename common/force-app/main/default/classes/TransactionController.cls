/**
 * @description
 * Controller class to handle transaction-related operations in the Transaction App.
 * This class provides methods to retrieve transaction records and integrates with the TransactionsService for data processing.
 * 
 * The class includes robust error handling and uses @AuraEnabled methods for integration with Aura and Lightning components.
 * 
 * @author
 * Cesar Vaca
 *
 * @date
 * 18-11-2024
 */

public with sharing class TransactionController {

    // Service class to manage transaction-related logic
    @TestVisible private static TransactionsService transactionService = new TransactionsService();

    /**
     * @description
     * Retrieves a list of Interest Transactions associated with a given Investment record.
     * 
     * This method is accessible from Lightning components using @AuraEnabled
     *
     * @param investmentId The Id of the Investment record for which transactions are being retrieved.
     * @return A list of Transaction__c records representing interest transactions for the given investment.
     */

    @AuraEnabled
    public static List<Transaction__c> getInterestTransactions (Id investmentId){
        return transactionService.getInterestTransactions(investmentId);
    }
}