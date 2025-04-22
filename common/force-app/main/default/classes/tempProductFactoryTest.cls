@isTest
private class tempProductFactoryTest {

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
    static void testCreateRaise_Success() {
        Product2 testAccount = [SELECT Id, Target_Amount__c FROM Product2 WHERE name='Test Product' LIMIT 1];
        tempProductFactory factory = new tempProductFactory();

        Test.startTest();
        Product2 newProduct = factory.getProductDetails(testAccount.Id);
        Test.stopTest();

        System.assertNotEquals(null, newProduct, 'Product record should be not null');
        System.assertEquals(3000, newProduct.Target_Amount__c, 'Target ammount should be 3000');
    }
    @IsTest
    static void testCreateRaise_Failure() {
        String fakeCompanyId = '001XXXXXXXXXXXXXXX';
        tempProductFactory factory = new tempProductFactory();

        Test.startTest();
        try {
            Product2 newProduct = factory.getProductDetails(fakeCompanyId);
            System.assert(false, 'An exception should have been thrown for invalid ID');
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage(), 'Expected exception message not received');
        }
        Test.stopTest();
    }
}