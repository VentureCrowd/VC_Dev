@isTest
public class OpportunityLineItemTriggerHandlerTest {
    @isTest
    static void testmethod1(){
        Account acc = new Account();
        acc.name = 'Test Acount';
        insert acc;
        Contact con = new Contact();
        con.lastName = 'lastname';
        con.AccountId = acc.Id;
        insert con;
        Id pricebookId = Test.getStandardPricebookId();        
        List<Opportunity> oppList = new List<Opportunity>();
        Id vcpprecordTypeId =Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('VCPP').getRecordTypeId();

        //Opporutnity 1
        Opportunity oppObj = new Opportunity();
        oppObj.name = 'Test1lname';
        oppObj.stageName = 'Why Appt Set Pending';
        oppObj.Pricebook2Id = pricebookId;
        date dt = System.today();
        dt = dt.addDays(5);
        oppObj.delete_opportunity__c = true;
        oppObj.closedate = dt;
        oppObj.Amount = 50000;
        oppObj.AccountId = acc.Id;
        oppObj.recordTypeId=vcpprecordTypeId;
        oppList.add(oppObj);
        //Opporutnity 2
        Opportunity oppObj2 = new Opportunity();
        oppObj2.name = 'Test2lname';
        oppObj2.stageName = 'Why Appt Set Pending';
        oppObj2.Pricebook2Id = pricebookId;
        date dt1 = System.today();
        dt1 = dt1.addDays(5);
        oppObj2.delete_opportunity__c = true;
        oppObj2.closedate = dt;
        oppObj2.Amount = 50000;
        oppObj2.AccountId = acc.Id;
        oppObj2.recordTypeId=vcpprecordTypeId;
        oppList.add(oppObj2);
        insert oppList;            
        //Create Product
        Product2 oProduct = new Product2(name='Test');
        oProduct.Offer_Launch_Date__c = System.today().addDays(-4);
        insert oProduct;
        //Price Book entry creation
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = oProduct.Id,
            UnitPrice = 12000, IsActive = true);
        insert customPrice;        
       //Create Opportunity Line item 1
       OpportunityLineItem oppLineItem = new OpportunityLineItem();
       oppLineItem.Product2Id = oProduct.Id;
       oppLineItem.OpportunityId = oppList[0].Id;
       oppLineItem.Quantity = 1;
       oppLineItem.UnitPrice = 10;
       oppLineItem.PricebookEntryId = customPrice.Id;
       insert oppLineItem;
    }
}