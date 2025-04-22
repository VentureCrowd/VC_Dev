@isTest
public class interestDividendDisbursementCntrlTest {
    @TestSetup
    static void makeData(){
        Account acc = new Account();
        acc.name = 'Test Acount';
        acc.Active__c = true;
        insert acc;
        Contact con = new Contact();
        con.lastName = 'lastname';
        con.AccountId = acc.Id;
        insert con;
        Id pricebookId = Test.getStandardPricebookId();        
        List<Opportunity> oppList = new List<Opportunity>();
        //Opporutnity 1
        Opportunity oppObj = new Opportunity();
        oppObj.name = 'Test1lname';
        oppObj.stageName = 'Why Appt Set Pending';
        oppObj.Pricebook2Id = pricebookId;
        date dt = System.today();
        dt = dt.addDays(5);
        oppObj.closedate = dt;
        oppObj.Amount = 50000;
        oppObj.AccountId = acc.Id;
        oppList.add(oppObj);
        //Opporutnity 2
        Opportunity oppObj2 = new Opportunity();
        oppObj2.name = 'Test2lname';
        oppObj2.stageName = 'Why Appt Set Pending';
        oppObj2.Pricebook2Id = pricebookId;
        date dt1 = System.today();
        dt1 = dt1.addDays(5);
        oppObj2.closedate = dt;
        oppObj2.Amount = 50000;
        oppObj2.AccountId = acc.Id;
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
       oppLineItem.TotalPrice = 10;
       oppLineItem.PricebookEntryId = customPrice.Id;
       insert oppLineItem;

       //Create Opportunity Line item 2
       OpportunityLineItem oppLineItem2 = new OpportunityLineItem();
       oppLineItem2.Product2Id = oProduct.Id;
       oppLineItem2.OpportunityId = oppList[1].Id;
       oppLineItem2.Quantity = 1;
       oppLineItem2.TotalPrice = 10;
       oppLineItem2.PricebookEntryId = customPrice.Id;
       insert oppLineItem2;

       //Update Opportunity 1 for test
        oppList[0].Funds_received_in_Bank__c = true;
        oppList[0].StageName ='Closed Won';
        oppList[0].Unit_Certificate_Amount__c = 200000;
        oppList[0].Unit_Cert_Issued__c  = System.today();
        oppList[0].Initial_Term_Expiry__c  = 2;
        oppList[0].Invested_Opp_Prod_ADMIN__c = oppLineItem.Id;
        oppList[0].Invested_Product_ADMIN_FIELD__c = oProduct.Id;
        
        Test.startTest();
        update oppList;
        Test.stopTest();
    }
    @isTest
    static void testmethod1(){
        interestDividendDisbursementCntrl.availableProdOptns();
        Product2 prd = [SELECT Id FROM Product2 LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity  Order by CreatedDate LIMIT 1];
        interestDividendDisbursementCntrl.getProdsetails(prd.Id);
        interestDividendDisbursementCntrl.updatePriceBookEntry(prd.Id,200);
        interestDividendDisbursementCntrl.updatePriceBookEntry(prd.Id,300);
        interestDividendDisbursementCntrl.getProddetails(prd.Id);
        interestDividendDisbursementCntrl.dateformatter('2012-02-02');
        string jsonstr = '[{"Name":"Ezzat Danial Nesseim-VentureCrowd Trust No. 0645 (Wych)","oppId":"'+opp.Id+'","startdate":"20-4-2022","enddate":"13-12-2022","dayscnt":0,"totalint":0,"children":[],"icnname":"utility:close"}]';
        interestDividendDisbursementCntrl.createFunddisuirsment(prd.Id,'13-12-2022',jsonstr);
    }
}