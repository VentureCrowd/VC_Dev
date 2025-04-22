@istest
public class QUE_oppEmailTest {
    @istest
    static void testMethod1(){
        BPAY__c bpay = new BPAY__c();
        bpay.Active__c = false;
        bpay.Biller_Code__c = '201913';
        bpay.CRN__c = '201913';
        insert bpay;
        Account acc = new Account();
        acc.name = 'Test Acount';
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('VC Business Account').getRecordTypeId();
        insert acc;        
        Contact con = new Contact();
        con.lastName = 'lastname';
        con.email = 'test@test.com';
        con.AccountId = acc.Id;
        insert con;        
        Id opprectypeId = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('VC').getRecordTypeId();
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity oppObj = new Opportunity();
        oppObj.name = 'Test1lname';
        oppObj.stageName = 'Application Received';
        oppObj.CRC_Assigned__c = UserInfo.getuserId();
        oppObj.CM_Assigned__c =  UserInfo.getuserId();
        date dt = System.today();
        dt = dt.addDays(5);
        oppObj.delete_opportunity__c = true;
        oppObj.closedate = dt;
        oppObj.Amount = 50000;
        oppObj.recordtypeId = opprectypeId;
        oppObj.Related_Product_Code__c = 'opprectypeId';
        oppObj.AccountId = acc.Id;
            
        Product2 oProduct = new Product2(name='Test');
        oProduct.Offer_Launch_Date__c = System.today().addDays(-4);
        insert oProduct;
        oppObj.Invested_Product_ADMIN_FIELD__c = oProduct.Id;
        oppList.add(oppObj); 
        insert oppList;
        Id pricebookId = Test.getStandardPricebookId();
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
        oppLineItem.TotalPrice = 10;
        oppLineItem.PricebookEntryId = customPrice.Id;
        insert oppLineItem;  
        oppList[0].Invested_opp_prod_admin__c = oppLineItem.Id;
        oppList[0].Primary_Contact__c = con.Id;
        update oppList;  
        try{   
            test.starttest();
            System.enqueueJob(new QUE_oppEmail(oppList));  
            test.stoptest(); 
        }catch(exception e){}   
    }
}