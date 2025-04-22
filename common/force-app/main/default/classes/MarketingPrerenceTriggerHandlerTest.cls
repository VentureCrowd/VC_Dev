@isTest
public class MarketingPrerenceTriggerHandlerTest {
    @isTest
    static void testmethod1(){
        Account acc = new Account();
        acc.lastname = 'Test1lname';
        acc.Phone = '6786789876';
        acc.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('VC Person Account').getRecordTypeId();
        insert acc;

        MarketingPrerenceTriggerHandler.performSyncFromMarketingPreference = true;
        Marketing_Preference__c mp = [SELECT Id FROM Marketing_Preference__c];
        mp.Investor_Updates_OptIn__c = false;
        update mp;
        MarketingPrerenceTriggerHandler.performSyncFromMarketingPreference = true;
        mp.Investor_Updates_OptIn__c = true;
        update mp;
    }
}