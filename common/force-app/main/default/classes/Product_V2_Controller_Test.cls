@isTest
private class Product_V2_Controller_Test {

    @testSetup
    static void setup() {
        // Create test Product2 records
        Product2 product1 = new Product2(
            Name = 'Test Product 1',
            Portal_Display_Name__c = 'Product Display 1',
            Tile_Heading__c = 'Heading 1',
            Deal_Description__c = 'Deal Description 1',
            Tile_Offer_Type__c = 'Offer Type 1',
            Tile_Banner__c = 'http://example.com/product1',
            Family = 'Test Family',
            Deal_Page_Link__c = 'http://example.com/product1',
            DisplayUrl = 'http://example.com/product1',
            Publish_on_Community_Site__c = true,
            IsActive = true,
            Offer_Close_Date__c = Date.today().addDays(1),
            Type__c='Property Product'
        );
        insert product1;
        
        Product2 product2 = new Product2(
            Name = 'Test Product 2',
            Portal_Display_Name__c = 'Product Display 2',
            Tile_Heading__c = 'Heading 2',
            Deal_Description__c = 'Deal Description 2',
            Tile_Offer_Type__c = 'Offer Type 2',
            Tile_Banner__c = 'Banner 2',
            Family = 'Test Family',
            Deal_Page_Link__c = 'http://example.com/product2',
            Publish_on_Community_Site__c = true,
            IsActive = true,
            Offer_Close_Date__c = Date.today().addDays(1),
            Type__c='Property Product'
        );
        insert product2;

        PricebookEntry priceBook = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = product1.Id,
            UnitPrice = 500,
            IsActive = true
        );
        insert priceBook;
        
    }
    @isTest
    static void testgetProductByType() {

        // Call the controller method to get product offer information
        Test.startTest();
        List<Map<String,Object>> ret = Product_V2_Controller.getProductByType('Property Product','VC');
        System.assertNotEquals(null,ret, 'Product list should not be null');
        Test.stopTest();
    }

    @isTest
    static void testGetProductOfferInformationSuccess() {
        Test.startTest();
        String jsonResult = Product_V2_Controller.getProductOfferInformation();
        Test.stopTest();

        List<Product_V2_Service.ProductsData> productsDataList = (List<Product_V2_Service.ProductsData>) JSON.deserialize(jsonResult, List<Product_V2_Service.ProductsData>.class);

        System.assertNotEquals(null, productsDataList, 'Product data list should not be null');
        System.assertEquals(2, productsDataList.size(), 'There should be two product returned');
    }

    @isTest
    static void testGetProductOfferInformationNoProducts() {
        delete [SELECT Id FROM Product2];

        Test.startTest();
         // Delete all products to simulate the scenario where no products exist
        delete [SELECT Id FROM Product2];
        try {
            Product_V2_Controller.getProductOfferInformation();
            System.assert(false, 'An exception should have been thrown because no products are available');
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage(), 'Expected exception message not received');
        }
        Test.stopTest();
    }

    @isTest
    static void testGetProductInformationSuccess() {
        Product2 product = [SELECT Id FROM Product2 WHERE Name ='Test Product 1' LIMIT 1];

        Test.startTest();
        Product2 result = Product_V2_Controller.getProductInformation(product.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Product should not be null');
        System.assertEquals(product.Id, result.Id, 'Returned product ID should match the queried product ID');
    }

    @isTest
    static void testGetProductInformationInvalidId() {
        Test.startTest();
        try {
            Product_V2_Controller.getProductInformation(null);
            System.assert(false, 'An exception should have been thrown for null product ID');
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage(), 'Expected exception message not received');
        }
        Test.stopTest();
    }

    @isTest
    static void testGetProductPriceBookSuccess() {
        Product2 product = [SELECT Id FROM Product2 WHERE Name ='Test Product 1' LIMIT 1];

        Test.startTest();
        PricebookEntry result = Product_V2_Controller.getProductPriceBook(product.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'PricebookEntry should not be null');
    }

    @isTest
    static void testGetProductPriceBookNoPriceBookEntry() {
        Test.startTest();
        try {
            Product_V2_Controller.getProductPriceBook('005000000000001');
            System.assert(false, 'An exception should have been thrown because no PricebookEntry exists for the product');
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage(), 'Expected exception message not received');
        }
        Test.stopTest();
    }
}