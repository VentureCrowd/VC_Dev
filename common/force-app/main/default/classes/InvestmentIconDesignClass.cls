public without sharing  class  InvestmentIconDesignClass {
  @auraEnabled
    public static String retrivePdtCategory(String recordId){
        Id productId = [select Id,Opportunity_Product__r.Product2Id from Investment__c where Id=:recordId].Opportunity_Product__r.Product2Id;  
        String sector = [select Id,Name,Sector__c from Product2 where Id =: productId ].Sector__c;
         return sector;
     }
   
}