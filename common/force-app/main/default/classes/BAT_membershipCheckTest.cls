@istest
class BAT_membershipCheckTest {
    @istest
    static void testmethod1(){
        Id personaccId  = [SELECT Id,recordtype.Name,SobjectType FROM recordtype WHERE Name ='VC Person Account'].Id;
        Id platinumpartner  = [SELECT Id,recordtype.Name,SobjectType FROM recordtype WHERE Name ='Platinum Partner'].Id;
        Account acc = new Account();
        acc.LastName = 'Test Acount';
        acc.RecordTypeId = personaccId;
        insert acc;
        contact con = [SELECT ID FROM CONTACT WHERE AccountId = :acc.Id];
        con.EIC_Property__c = true;
        update con;
        Membership__c m = new Membership__c();
        m.Account__c = acc.Id;
        m.RecordTypeId = platinumpartner;
        m.Type__c = 'Platinum Partner';
        m.End_Date__c = system.Today().addDays(-1);
        m.Start_Date__c = system.Today().addDays(-2);
        m.Eligible_from__c = system.Today().addDays(-2);
        insert m;
        system.debug([SELECT Id,Account__c,Account__r.EIC_Property__pc, Account__r.Wholesale__pc, Account__r.EIC_Startup__pc FROM Membership__c]);
        Database.executeBatch(new BAT_membershipCheck());
        System.schedule('test', '0 00 05 ? * 2', new BAT_membershipCheck());
    }
}