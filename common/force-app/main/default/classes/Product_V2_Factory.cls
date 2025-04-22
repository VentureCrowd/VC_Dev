public class Product_V2_Factory implements IProduct_V2_Factory {
    
    /**
     * Retrieves a list of product records that are marked for publishing on the community site.
     *
     * @return List<Product2> - A list of Product2 records.
     * @throws AuraHandledException if no products are found or if an error occurs during retrieval.
     */
    public List<Product2> getProductOfferInformation() {
        try {
            // Query to retrieve the relevant product records
            List<Product2> productsRecord = [
                SELECT Portal_Display_Name__c, Tile_Heading__c, Deal_Description__c, Tile_Offer_Type__c, Tile_Banner__c, 
                Family, Deal_Page_Link__c, Raise__c FROM Product2 

                WHERE Publish_on_Community_Site__c = True AND IsActive = True AND Private_Deal__c = False AND Banner_Date_Validation__c = True
                ORDER BY CreatedDate DESC 
            ];
    
            // Check if the query returned any records
            if (productsRecord.isEmpty()) {
                // Log a message indicating no records were found
                Logger.logMessage('ProductApp', 'Product_V2_Factory', 'getProductOfferInformation', 'No product records found');
                
                // Throw an exception indicating no products are available
                throw new AuraHandledException('No products found for publication on the community site.');
            } else {
                // Log a success message indicating records were retrieved
                Logger.logMessage('ProductApp', 'Product_V2_Factory', 'getProductOfferInformation', 'Successfully retrieved product records.');
                
                // Return the list of product records
                return productsRecord;
            }
        } catch (Exception e) {
            // Log an error message with details of the exception
            Logger.logError('ProductApp', 'Product_V2_Factory', 'getProductOfferInformation', null, null, null, null, e, 'Failed to retrieve product records.');
            
            // Throw an AuraHandledException with the original exception message for the caller to handle
            throw new AuraHandledException('An error occurred while retrieving product records: ' + e.getMessage());   
        }
    }

    public Product2 getProductInformation(Id productId) {
        try {
            // Query to retrieve the relevant product records
            Product2 productsRecord = [SELECT Name, Stage__c, Sector__c, DisplayUrl,Portal_Display_Name__c, yielding__c, Distribution_Type__c, Family FROM Product2 WHERE Id =: productId LIMIT 1];
            return productsRecord;
        } catch (Exception e) {
            // Log an error message with details of the exception
            Logger.logError('ProductApp', 'Product_V2_Factory', 'getProductOfferInformation', null, null, null, null, e, 'Failed to retrieve product records.' + productId);
            
            // Throw an AuraHandledException with the original exception message for the caller to handle
            throw new AuraHandledException('An error occurred while retrieving product records: ' + e.getMessage());   
        }

    }
    
    public List<Product2> getProductByType(String productTypeName, String productRTName){
        
        String query = 'SELECT Id, Name, Portal_Display_Name__c, ProductCode FROM Product2 WHERE Publish_on_Community_Site__c = True AND IsActive = True AND Fully_Funded__c = FALSE AND Private_Deal__c = False';
        
        if(!String.isEmpty(productTypeName)){

            query += ' AND Type__c = :productTypeName';
        }

        try{
            if(!String.isEmpty(productRTName)){
                String productRT = Schema.SObjectType.Product2.getRecordTypeInfosByName().get(productRTName).getRecordTypeId();
                if(!String.isEmpty(productRT)){
                    query += ' AND RecordTypeId = :productRT';
                }
            }
        }catch(Exception e){
            System.debug('Error retrieiving Record Type');
        }
        

        List<sObject> returnList = Database.query(query);

        return returnList;
    }
    

    public PricebookEntry getProductPriceBook(Id productId) {
        PricebookEntry priceBookRecord = [SELECT UnitPrice, Name FROM PricebookEntry WHERE Product2Id =:productId];
        return priceBookRecord;
    }

}