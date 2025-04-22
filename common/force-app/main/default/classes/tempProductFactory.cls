public class tempProductFactory {
    public Product2 getProductDetails(Id productId) {
        try {
            Product2 productRecord = [SELECT Id, Offer_Launch_Date__c, Temp_Total_Opp_Amount__c, Target_Amount__c,
            Offer_Close_Date__c, Portal_Display_Name__c, Stage__c, Minimum_Investment__c,Deal_Description__c
            FROM Product2
            WHERE Id = :productId];
    
            if (productRecord != null) {
                Logger.logMessage('ProductApp', 'tempProductFactory', 'getProductDetails', 'Successfully retrieved full product record for productId: ' + productId);
                return productRecord;
            } else {
                Logger.logMessage('ProductApp', 'tempProductFactory', 'getProductDetails', 'No raise record found for productId: ' + productId);
                throw new AuraHandledException('No product record found for product: ' + productId);
            }
        } catch (Exception e) {
            Logger.logError('ProductApp', 'tempProductFactory', 'getProductDetails', productId, null, null, null, e, 'Failed to get full raise record for raiseId: ' + productId);
            throw new AuraHandledException(e.getMessage());   
        }
    }
}