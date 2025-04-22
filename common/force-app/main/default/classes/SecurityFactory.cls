public without sharing class SecurityFactory {
    
    public Id getRaiseAccountId(String raiseId){
        Raise__c raiseRecord = [SELECT Id, Account__c FROM Raise__c WHERE Id = :raiseId LIMIT 1];

        if(raiseRecord.Account__c != null){
            return raiseRecord.Account__c;}
        else{
            return null;
        }
    }

    public Id getEoiAccountId(String eoiId){
        EOI__c eoiRecord = [SELECT Id, Related_Person_Account__c FROM EOI__c WHERE Id = :eoiId LIMIT 1];

        if(eoiRecord.Related_Person_Account__c != null){
            return eoiRecord.Related_Person_Account__c;}
        else{
            return null;
        }
    }
}