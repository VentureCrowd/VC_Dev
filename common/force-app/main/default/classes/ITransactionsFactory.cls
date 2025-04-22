public interface ITransactionsFactory {
    List<Transaction__c> getInterestTransactions (Id investmentId);
}