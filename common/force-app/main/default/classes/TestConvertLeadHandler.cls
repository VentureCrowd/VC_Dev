@isTest
public class TestConvertLeadHandler {
    Static testMethod void convertLeadTest()
    {	
        Account acct = new Account();
        acct.lastname = 'Testlname';
        acct.Phone = '123456789';
        acct.PersonEmail = 'Test@test.com';
        acct.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('VC Person Account').getRecordTypeId();
        insert acct;
        
        Lead leadObj = new Lead();
        leadObj.lastname = 'Testlname';
        leadObj.email = 'Test@test.com';
        leadObj.MobilePhone = '123456789';
        leadObj.Status = 'New';
        leadObj.LeadSource = 'VC Website Organic';
        leadObj.Web_Source__c ='ZEGA-CSF';
		insert leadObj;    
        
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity oppObj = new Opportunity();
        oppObj.name = 'Test1lname';
        oppObj.AccountId = acct.Id;
        oppObj.stageName = 'Application Received';
        oppObj.Web_Source__c = 'ZEGA-CSF';
        oppObj.LeadSource = 'VC Website Organic';
        oppObj.Email_ID__c = 'test@value.com';
        date dt = System.today();
        dt = dt.addDays(5);
		oppObj.CloseDate = dt;        
        oppList.add(oppObj);
        insert oppList; 
        
        test.startTest();
        ConvertLeadHandler.convertLead(oppList);
        test.stopTest();

    }
}