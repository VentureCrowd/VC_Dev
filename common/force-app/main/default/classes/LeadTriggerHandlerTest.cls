@isTest
public class LeadTriggerHandlerTest 
{
    static testMethod void deleteLeadTestMethod3() 
    {
        List<lead> leadList = new List<lead>();
        Lead leadObj = new Lead();
        leadObj.lastname = 'Test1lname';
        leadObj.email = 'testemail1@yopmail.com';
        leadObj.MobilePhone = '6786789876';
        leadObj.Status = 'New';
        leadObj.Products_Interested_In__c = 'Investing';
        leadObj.LeadSource = 'Partner';
        leadObj.Loss_Reason__c = 'No Trust';
        leadObj.Is_Duplicate__c = True;

        leadList.add(leadObj);
		insert leadList;        

        update leadlist;
        Test.startTest();
        LeadTriggerHandler.deleteLead(leadList);
        LeadTriggerHandler.deleteLead2(leadList);
        LeadTriggerHandler.deleteLead3(leadList);
        LeadTriggerHandler.roundRobinOnOpportunity(leadList, leadList);
        
        Test.stopTest();
    }
    static testMethod void leadReEnquiryTestMethod1() 
    {
        Account acc = new Account();
        acc.lastname = 'Test1lname';
        acc.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('VC Person Account').getRecordTypeId();

        acc.Phone = '6786789876';
        //insert acc;
        
        Contact con = new Contact();
        con.LastName  = 'Test1lname';
        con.MobilePhone = '6786789876';
        con.email = 'testemail1@yopmail.com1';
        insert con;

        List<lead> leadList = new List<lead>();
        Lead leadObj = new Lead();
        leadObj.lastname = 'Test1lname';
        leadObj.email = 'testemail1@yopmail.com';
        leadObj.MobilePhone = '6786789876';
        leadObj.Status = 'New';
        leadObj.Products_Interested_In__c = 'Investing';
        leadObj.LeadSource = 'Partner';
        leadObj.Loss_Reason__c = 'No Trust';

        leadList.add(leadObj);
		insert leadList;        

        Test.startTest();
        // LeadTriggerHandler.leadReEnquiry(leadList);
        //LeadTriggerHandler.roundRobinOnOpportunity(newleadList, oldleadList);
        Test.stopTest();
    }
    static testMethod void leadReEnquiryTestMethod2() 
    {
        Account acc = new Account();
        acc.lastname = 'Test1lname';
        acc.Phone = '6786789876';
        acc.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('VC Person Account').getRecordTypeId();
//        insert acc;
        
        Contact con = new Contact();
        con.LastName  = 'Test1lname';
        con.MobilePhone = '6786789876';
        con.email = 'testemail1@yopmail.com1';
        insert con;

        List<lead> leadList = new List<lead>();
        Lead leadObj = new Lead();
        leadObj.lastname = 'Test1lname';
        leadObj.email = 'testemail1@yopmail.com';
        leadObj.MobilePhone = '6786789876';
        leadObj.Status = 'New';
        leadObj.Products_Interested_In__c = 'Investing';
        leadObj.LeadSource = 'Partner';
        leadObj.Loss_Reason__c = 'No Trust';

        leadList.add(leadObj);
		insert leadList;        

        Test.startTest();
        // LeadTriggerHandler.leadReEnquiry(leadList);
        Test.stopTest();
    }
    static testMethod void beforetrigger(){
        Id VCPPRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('VCPP').getRecordTypeId();
        Lead leadObj = new Lead();
        leadObj.lastname = 'Test1lnameufgufguhjfgj';
        leadObj.email = 'testemail1@yohgughugyhupmail.com';
        leadObj.MobilePhone = '6786789876';
        leadObj.Status = 'New';
        leadObj.Products_Interested_In__c = 'Investing';
        leadObj.LeadSource = 'Partner';
        leadObj.Loss_Reason__c = 'No Trust';
        leadObj.RecordTypeId = VCPPRecordTypeId;
        insert leadObj;
    }
    
}