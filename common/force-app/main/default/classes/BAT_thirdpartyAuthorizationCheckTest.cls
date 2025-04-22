@istest
public with sharing class BAT_thirdpartyAuthorizationCheckTest {
    @istest
    static void testmethod1(){
        Id personaccId  = [SELECT Id,recordtype.Name,SobjectType FROM recordtype WHERE Name ='VC Person Account'].Id;
        Id platinumpartner  = [SELECT Id,recordtype.Name,SobjectType FROM recordtype WHERE Name ='Platinum Partner'].Id;
        Account acc = new Account();
        acc.LastName = 'Test Acount';
        acc.RecordTypeId = personaccId;
        acc.Third_Party_Authorised__c = TRUE;
        insert acc;
        contact con = [SELECT ID FROM CONTACT WHERE AccountId = :acc.Id];
        con.EIC_Property__c = true;
        update con;
        Id apprecordtypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByName().get('Third party Authority').getRecordTypeId();
        Application__c a = new Application__c();
        a.RecordTypeId = apprecordtypeId;
        a.Account__c = acc.Id;
        a.TPA_End_date__c = system.Today().adddays(-1);
        insert a;
        Database.executeBatch(new BAT_thirdpartyAuthorizationCheck());
        System.schedule('test', '0 00 05 ? * 2', new BAT_thirdpartyAuthorizationCheck());
    }
}