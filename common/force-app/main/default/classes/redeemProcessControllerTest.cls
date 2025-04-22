@isTest
public class redeemProcessControllerTest {
        public static testMethod void testredeemProcess() {
        Account accobj = Test_DataFactory.prepareAccount();
        Contact conobj = Test_DataFactory.prepareContact(accobj.Id);
        product2 prodObj = Test_DataFactory.prepareProduct();
        PricebookEntry pricebk  = Test_DataFactory.preparePricebook(prodObj.Id);
        Opportunity oppObj = Test_DataFactory.prepareOpportunity(true,accobj.Id,prodobj.Id);
        OpportunityLineItem lineObj = Test_DataFactory.prepareProductLineItem(oppObj.Id,pricebk.Id,prodObj.Id);
        oppObj.Invested_Opp_Prod_ADMIN__c = lineObj.Id;
        update oppObj;
        redeemProcessController.transactionLogs(oppObj.Id,lineObj.Id,1000.00,100.00,system.today());
    }
}