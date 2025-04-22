/**
 * @description
 * Factory class responsible for retrieving `Transaction__c` records associated with a given investment ID.
 * This class implements the `ITransactionsFactory` interface to adhere to the Transaction App's 
 * defined contract for transaction data retrieval.
 * 
 * The retrieved records include details such as Account, Created Date, Transaction Type, 
 * Amount, Status, Name, and Line Item Descriptions.
 * 
 * @date
 * 18-11-2024
 */

public inherited sharing class TransactionsFactory implements ITransactionsFactory  {

    /**
     * @description
     * Retrieves a list of `Transaction__c` records for a given investment ID. 
     * The records are filtered to include only those with a `Transaction_Type__c` of "Bill," 
     * and are ordered by the `CreatedDate` in descending order.
     * 
     * @param investmentId The ID of the Investment record for which transactions are being retrieved.
     * @return A list of `Transaction__c` records matching the specified criteria, or an empty list if none are found.
     */
    public List<Transaction__c> getInterestTransactions (Id investmentId) {
        // Fetch Transactions
        List<Transaction__c> transactionRecord = [SELECT Account__c, CreatedDate, Transaction_Type__c, Transaction_Amount__c, Status__c, Name, XI_Line_Items_Description__c
        FROM Transaction__c WHERE Investment__c = :investmentId AND Transaction_Type__c = 'Bill' AND (Status__c = 'Paid' OR Status__c = 'Draft') ORDER BY CreatedDate DESC];
        return transactionRecord;
    }
}