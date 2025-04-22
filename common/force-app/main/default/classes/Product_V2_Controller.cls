public without sharing class Product_V2_Controller {

    // This is a test-visible instance of the Product_V2_Service class, 
    // allowing it to be mocked or manipulated in test methods.
    @TestVisible private static Product_V2_Service productService = new Product_V2_Service();

    /**
     * This method is exposed to Aura and LWC components via @AuraEnabled.
     * It retrieves product offer information from the service layer.
     *
     * @return A JSON string containing product offer information.
     * @throws Exception if there is an issue in retrieving the product information.
     */
    @AuraEnabled
    public static String getProductOfferInformation() {
        try {
            // Call the service method to get the product offer information
            return productService.getProductOfferInformation();
        } catch (Exception e) {
            // Log the error with detailed information including the exception
            Logger.logError('ProductApp', 'Product_V2_Controller', 'getProductOfferInformation', null, null, null, null, e, 'Failed to retrieve product offer information');
            throw e;
        }
    }
    
    /**
     * Retrieves detailed information about a specific product identified by its ID.
     * 
     * @param productId The ID of the Product2 record to retrieve.
     * @return A Product2 object containing the requested product's details.
     * @throws AuraHandledException If an error occurs during the query execution.
     */
    @AuraEnabled
    public static Product2 getProductInformation(Id productId) {
        try {
            // Call the service method to get the product offer information
            return productService.getProductInformation(productId);
        } catch (Exception e) {
            // Log the error with detailed information including the exception
            Logger.logError('ProductApp', 'Product_V2_Controller', 'getProductInformation', null, null, null, null, e, 'Failed to retrieve product id' + productId);
            throw e;
        }
    }
    
    /**
     * Retrieves the PricebookEntry associated with a specific product.
     * 
     * @param productId The ID of the Product2 record whose price book entry is to be retrieved.
     * @return A PricebookEntry object containing the price details for the given product.
     * @throws QueryException If the product does not have an associated PricebookEntry or multiple entries are found.
     */
    @AuraEnabled
    public static PricebookEntry getProductPriceBook(Id productId) {
        try {
            // Call the service method to get the product offer information
            return productService.getProductPriceBook(productId);
        } catch (Exception e) {
            // Log the error with detailed information including the exception
            Logger.logError('ProductApp', 'Product_V2_Controller', 'getProductPriceBook', null, null, null, null, e, 'Failed to retrieve product id' + productId);
            throw e;
        }
    }

    /**
     * This method is exposed to Aura and LWC components via @AuraEnabled.
     * It retrieves product offer information from the service layer.
     *
     * @return A JSON string containing product offer information.
     * @throws Exception if there is an issue in retrieving the product information.
     */
    @AuraEnabled
    public static List<Map<String,Object>> getProductByType(String productTypeName, String productRTName){
        // try {
            return productService.getProductByType(productTypeName, productRTName);
        // } catch (Exception e) {
        //     throw new AuraHandledException(e.getMessage());
        // }
    }
}