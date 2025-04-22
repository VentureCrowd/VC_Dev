@isTest
private class tempProductControllerTest {

    @testSetup
    static void setup() {
        // Create a test Product2 record
        Product2 newProduct = new Product2(
            name = 'Test Product',
            Target_Amount__c = 3000
        );
        insert newProduct;
    }

    @IsTest
    static void testGetProductDetails() {
        Product2 testProduct = [SELECT Id FROM Product2 LIMIT 1];
        Test.startTest();
        String details = tempProductController.getProductDetails(testProduct.Id);
        Test.stopTest();

        System.assertNotEquals(null, details, 'Details should not be null');
    }
    
    // Test the retrieval of raise details with an invalid raise ID to simulate an error
    @IsTest
    static void testGetProductDetailsWithError() {
        Test.startTest();
        try {
            String details = tempProductController.getProductDetails('0000000000');
            System.assert(false, 'An exception should have p thrown for invalid ID');
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage(), 'Expected exception message not received');
        }
        Test.stopTest();
    }
}