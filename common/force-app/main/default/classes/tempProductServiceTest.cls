@isTest
private class tempProductServiceTest {
    private static tempProductService productService = new tempProductService();
    @testSetup
    static void setup() {
        // Create a test Product2 record
        Product2 newProduct = new Product2(
            name = 'Test Product',
            Target_Amount__c = 3000
        );
        insert newProduct;
    }

    @isTest
    static void testGetProductDetails() {
        Product2 testProduct = [SELECT Id FROM Product2 LIMIT 1];
        Test.startTest();
        String result = productService.getProductDetails(testProduct.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Expected result to be non-null');
    }

    @IsTest
    static void testGetProductDetails_Failure() {
        String fakeAccountId = '001xx000003XXXXAAO';
        Test.startTest();
        AuraHandledException e = null;
        try {
            String result = productService.getProductDetails(fakeAccountId);
        } catch (AuraHandledException ex) {
            e = ex;
        }
        Test.stopTest();
        
        System.assertNotEquals(null, e, 'Exception should be thrown');
    }
}