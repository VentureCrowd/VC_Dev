@istest
class investmentHelperTest {
    @isTest
    static void testmethod1(){
        Test.startTest();
        Account acc = new Account();
        acc.name = 'Test Acount';
        insert acc;
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
        oppObj.delete_opportunity__c = true;
        oppObj.closedate = dt;
        oppObj.Amount = 50000;
        oppObj.Invested_Product_ADMIN_FIELD__c = oProduct.Id;
        insert oppObj;
        Investment__c inv = new Investment__c();
        inv.Account__c = acc.Id;
        inv.Opportunity__c = oppObj.Id;
        inv.Process_Fund_Disbursement__c  =  TRUE;
        insert inv;
        investmentHelper.getInvestments();
    }
}