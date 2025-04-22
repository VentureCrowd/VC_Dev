public without sharing class tempProductController {
    @TestVisible private static tempProductService productService = new tempProductService();

    @AuraEnabled
    public static String getProductDetails(String productId){
        try{
            return productService.getProductDetails(productId);
        }catch (Exception e) {
            Logger.logError('ProductApp', 'tempProductController', 'getProductDetails', null, null, null, null, e, 'Failed to get raise details for companyId: ' + productId);
            throw e;
        }
    }
}