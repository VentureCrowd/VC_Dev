@isTest
public  class prodTriggerHandlerTest {
    @isTest
    static void testmethod1(){
        Product2 oProduct = new Product2(name='Test');
        oProduct.Offer_Launch_Date__c = System.today().addDays(-4);
        insert oProduct;
        oProduct.Fixed_Returns__c = 12 ;
        update oProduct;
        oProduct.Fixed_Returns__c = 14 ;
        update oProduct; 
    }
}