public without sharing class SuggestedInvestmentController {
    
    @AuraEnabled
    public static String getRecentInvestments(){
             List<product2> prodList =[select id,Name,Family,IM_PDS__c,DisplayUrl,Deal_Page_Link__c,Trust_Deed_Link__c,Sector_Personas__c,
  ProductCode,FAQ_s__c,Fully_Funded__c,Return_Type__c,Button_Text__c, Tile_Banner__c, Tile_Heading__c, Tile_Offer_Type__c from  product2 where Publish_on_Community_Site__c = TRUE  AND  IsActive = TRUE AND Private_Deal__c = FALSE AND Fully_Funded__c = FALSE order by Tile_Ordering__c LIMIT 3];
            return JSON.serialize(prodList);
    }
    
}