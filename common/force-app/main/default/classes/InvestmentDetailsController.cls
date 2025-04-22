/**

**/
public without sharing class InvestmentDetailsController {

    public static final string OPPORTUNITY_STAGENAME_APPLICATION_RECEIVED = 'Application Received';
    public static final string OPPORTUNITY_STAGENAME_RECEIPT_ISSUED = 'Receipt Issued';
    public static final string OPPORTUNITY_STAGENAME_CLOSED_WON= 'Closed Won';
    @AuraEnabled(cacheable=true)
    public static string retrieveRaisedAmount(Id productId){
        String raisedAmount = '0';
        try {
            OpportunityLineItem[] lstOpportunity = [SELECT Id,Opportunity.Amount FROM OpportunityLineItem WHERE Product2Id = :productId AND 
                        (Opportunity.StageName = : OPPORTUNITY_STAGENAME_APPLICATION_RECEIVED OR Opportunity.StageName = : OPPORTUNITY_STAGENAME_RECEIPT_ISSUED
                        OR Opportunity.StageName = : OPPORTUNITY_STAGENAME_CLOSED_WON)];

            Lead_Investor__c[] lstInvestor = [SELECT Id,Amount__c FROM Lead_Investor__c WHERE Product__c = :productId];

            if (!lstOpportunity.isEmpty()) {
                Decimal counter = 0;
                for (OpportunityLineItem opp : lstOpportunity) {
                    if (opp.Opportunity.Amount != null) {
                        counter += opp.Opportunity.Amount;
                    }
                }

                if (!lstInvestor.isEmpty()) {
                    for (Lead_Investor__c oLead : lstInvestor) {
                        if (oLead.Amount__c != null) {
                            counter += oLead.Amount__c;
                        }
                    }
                }
                raisedAmount = String.valueOf(counter);
            }            
            return  raisedAmount;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}