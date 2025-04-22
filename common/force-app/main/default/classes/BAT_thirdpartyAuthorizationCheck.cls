public without sharing class BAT_thirdpartyAuthorizationCheck implements Database.Batchable<Sobject>,Schedulable{
    public Database.QueryLocator start(Database.BatchableContext BC){
        Id apprecordtypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByName().get('Third party Authority').getRecordTypeId();
        string query = 'SELECT Id,Contact__r.AccountId FROM Application__c WHERE TPA_End_date__c < Today AND Contact__r.Account.Third_Party_Authorised__c = TRUE AND recordtypeId =:apprecordtypeId';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Application__c> scope){
        Map<Id,Account> accMap = new Map<Id,Account>();
        for(Application__c m : scope){
            Account acc = new Account();
            acc.Id = m.Contact__r.AccountId;
            acc.Third_Party_Authorised__c = false;
            accMap.put(acc.Id,acc);
        }
        update accMap.values();
    }
    public void finish(Database.BatchableContext BC){

    }
    public void execute(SchedulableContext sc){
        Database.executeBatch(this);
    }
}