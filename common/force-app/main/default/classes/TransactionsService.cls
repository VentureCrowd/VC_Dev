/**
 * @description
 * Service class for managing transaction-related operations in the Transaction App.
 * This class provides methods for retrieving and processing transaction records, 
 * including filtering transactions based on specific criteria.
 *
 * It integrates with the TransactionsFactory for data retrieval and ensures robust 
 * processing logic to meet application requirements.
 * 
 * @author
 * Cesar Vaca
 *
 * @date
 * 18-11-2024
 */
public inherited sharing class TransactionsService {

    /**
     * @description
     * Retrieves and filters a list of `Transaction__c` records based on a specific investment ID. 
     * Filters are applied to identify transactions that are interest- or redemption-related, 
     * and modifications are made to transaction descriptions under specific conditions.
     *
     * @param investmentId The ID of the Investment record for which transactions are being retrieved.
     * @return A list of filtered `Transaction__c` records that match the specified criteria.
     */
    public List<Transaction__c> getInterestTransactions (Id investmentId) {
        // Create an instance of InvestmentFactory to retrieve investments
        TransactionsFactory factory = new TransactionsFactory();
        // Retrieve investment records associated with the accountId
        List<Transaction__c> transactionRecord = factory.getInterestTransactions(investmentId);
        
        // Empty list to store the filtered transactions
        List<Transaction__c> filteredTransactions = new List<Transaction__c>();
        // This regex pattern it was used for all the int conventions keep it for future use
        // String regexPattern = '\\b(?:[iI]nt_\\w*|Int|int|[Rr]ed_\\w*|Interest|interest|[Cc]omp [Ii]nt)\\b';
        
        // Regex pattern to match all the Interest or Redemptions transactions
        String regexPattern = '\\b(?:Int_IP|Int_CAP|Int_COM|Red_PT|Red_FULL)\\b';
        
        Pattern myPattern = Pattern.compile(regexPattern);
        // Iterate over the transaction to find the interest transactions
        for (Transaction__c transactionsXero : transactionRecord) {
            Matcher myMatcher = myPattern.matcher(transactionsXero.XI_Line_Items_Description__c);
            if (myMatcher.find()) {
                // Replace the line item description with the regex
                transactionsXero.XI_Line_Items_Description__c = myMatcher.group();
                filteredTransactions.add(transactionsXero);
                // Modify descriptions for draft transactions with specific criteria
                if (transactionsXero.Status__c == 'Draft' && transactionsXero.XI_Line_Items_Description__c == 'Int_IP') {
                    transactionsXero.XI_Line_Items_Description__c = 'Int_ACC';
                    // Track all the comp int - Old naming convention 
                } else if (transactionsXero.XI_Line_Items_Description__c.equalsIgnoreCase('Comp Int')) {                     
                    transactionsXero.XI_Line_Items_Description__c = 'Int_COM';
                }
                
            }
        }
        return filteredTransactions;
    }
    
}