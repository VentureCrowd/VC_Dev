@istest(SeeAllData = true)
public with sharing class InvestmentProductControllerTest {
    @istest
    public static void testmethod1(){
        Account acc = new Account();
        acc.name = 'Test Acount';
        insert acc;
        
        Contact con = new Contact();
        con.lastName = 'lastname';
        con.AccountId = acc.Id;
        insert con;
        Id pricebookId = Test.getStandardPricebookId();               

        //Create Product
        Product2 oProduct = new Product2(name='Test');
        oProduct.Offer_Launch_Date__c = System.today().addDays(-4);
        insert oProduct;

        Opportunity oppObj = new Opportunity();
        oppObj.name = 'Test1lname';
        oppObj.stageName = 'Why Appt Set Pending';
        oppObj.Pricebook2Id = pricebookId;
        date dt = System.today();
        dt = dt.addDays(5);
        oppObj.closedate = dt;
        oppObj.Amount = 50000;
        oppObj.AccountId = acc.Id;
        oppObj.CRC_Assigned__c =UserInfo.getUserId();
        oppObj.CM_Assigned__c  =UserInfo.getUserId();
        oppObj.Invested_Product_ADMIN_FIELD__c = oProduct.Id;
        insert oppObj;

        InvestmentProductController.isMembershipPresent(oppObj.Id);
        InvestmentProductController.isMembershipPresent('oppObj');
        InvestmentProductController.getSelectedProductDetails(oProduct.Id);
        InvestmentProductController.getSelectedProductDetails('oProduct');
    }
    @istest
    public static void testmethod2(){
        Account acc = new Account();
        acc.name = 'Test Acount';
        insert acc;
        
        Contact con = new Contact();
        con.lastName = 'lastname';
        con.AccountId = acc.Id;
        insert con;
        Id pricebookId = Test.getStandardPricebookId();               

        //Create Product
        Product2 oProduct = new Product2(name='Test');
        oProduct.Offer_Launch_Date__c = System.today().addDays(-4);
        insert oProduct;

        Opportunity oppObj = new Opportunity();
        oppObj.name = 'Test1lname';
        oppObj.stageName = 'Why Appt Set Pending';
        oppObj.Pricebook2Id = pricebookId;
        date dt = System.today();
        dt = dt.addDays(5);
        oppObj.closedate = dt;
        oppObj.Amount = 50000;
        oppObj.AccountId = acc.Id;
        oppObj.CRC_Assigned__c =UserInfo.getUserId();
        oppObj.CM_Assigned__c  =UserInfo.getUserId();
        oppObj.Invested_Product_ADMIN_FIELD__c = oProduct.Id;
        insert oppObj;
        InvestmentProductController.performActionOnOpportunity('20','20','20.36',oProduct.Id,oppObj.Id,'200','205','20','opportunity comment');
        InvestmentProductController.testclasscovergaebooster();
    }
    @istest
    public static void testmethod3(){
        Account acc = new Account();
        acc.name = 'Test Acount';
        insert acc;
        
        Contact con = new Contact();
        con.lastName = 'lastname';
        con.AccountId = acc.Id;
        insert con;
        Id pricebookId = Test.getStandardPricebookId();               

        //Create Product
        Product2 oProduct = new Product2(name='Test');
        oProduct.Offer_Launch_Date__c = System.today().addDays(-4);
        insert oProduct;


        DynamicLookupController.findRecords('tst','Opportunity','Name');
        DynamicLookupController.findRecords('','Opportunity','Name');
    }
}