public interface IInvestmentFactory {
    List<Investment__c> getInvestments (List<Id> accountId, Integer limitSize, Integer offsetValue);
    List<Investment__c> getInvestmentsIds (Id accountId);
    List<Investment__c> getInvestmentDetails (Id investmentId);
    List<Investment__c> getInvestmentSpotlightData (Id accountId);
    List<Investment__c> getPendingAndClosedInvestments (List<Id> accountId);
    Boolean showCSFBanner (Id accountId);
}