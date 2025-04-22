@isTest
public class SuggestedInvestmentControllerTest {
    @isTest
    public static void testGetRecentInvestments(){
        product2 prod = new product2();
        prod.Name = 'Test Prod';
        prod.IM_PDS__c = 'https://test.salesforce.com';
        prod.DisplayUrl = 'https://www.venturecrowd.com.au';
        prod.Deal_Page_Link__c = 'https://www.venturecrowd.com.au';
        prod.Trust_Deed_Link__c = 'https://www.venturecrowd.com.au';
        prod.Sector_Personas__c = 'Just Launchers';
        prod.ProductCode = 'AURT';
        prod.FAQ_s__c = 'Test FAQ';
        prod.Fully_Funded__c = true;
        prod.Return_Type__c = 'Per Annum';
        prod.Tile_Banner__c = 'https://www.venturecrowd.com.au';
        prod.Tile_Heading__c = 'Test heading';
        prod.Tile_Offer_Type__c = 'Investment';
        prod.Button_Text__c = 'View Offer';
        prod.IsActive = true;
        prod.Private_Deal__c = false;
        prod.Publish_on_Community_Site__c = TRUE;
        prod.Offer_Launch_Date__c = system.now();
        prod.Offer_Close_Date__c = system.now();
        database.insert(prod,false);
        //Database.SaveResult prodINs = 
        //System.assertEquals(True, prodINs.isSuccess());
            Test.startTest();
            	String suggestedInvetsment = SuggestedInvestmentController.getRecentInvestments();
        		system.assertEquals(suggestedInvetsment != null,true);
            Test.stopTest();
    }

}