public with sharing class investmentHelper {
    @AuraEnabled
    public static List<Investment__c> getInvestments(){        
        return [SELECT Id,Name,Investment_Product_Name__c, Investment_Product_Type__c, Investment_Product_Image__c, Stage__c,Investment_Status__c FROM Investment__c WHERE Investment_Status__c =  'Pending'];
    }
}