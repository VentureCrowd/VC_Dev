@isTest
private class Product_V2_Factory_Test {

    @testSetup
    static void setup() {
        // Create test Product2 records that match the criteria
        Product2 product1 = new Product2(
            Name = 'Test Product 1',
            Portal_Display_Name__c = 'Product Display 1',
            Tile_Heading__c = 'Heading 1',
            Deal_Description__c = 'Deal Description 1',
            Tile_Offer_Type__c = 'Offer Type 1',
            Tile_Banner__c = 'Banner 1',
            Family = 'Test Family',
            Deal_Page_Link__c = 'http://example.com/product1',
            Publish_on_Community_Site__c = true,
            IsActive = true,
            Offer_Close_Date__c = Date.today().addDays(1)
        );
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
            Offer_Close_Date__c = Date.today().addDays(1)
        );
        insert new List<Product2> { product1, product2 };
    }

    @isTest
    static void testGetProductOfferInformationSuccess() {
        // Instantiate the factory class
        Product_V2_Factory factory = new Product_V2_Factory();

        Test.startTest();
        // Call the method to retrieve product information
        List<Product2> products = factory.getProductOfferInformation();
        Test.stopTest();

        // Validate the results
        System.assertNotEquals(null, products, 'Product list should not be null');
        System.assertEquals(2, products.size(), 'There should be two products returned');
        System.assertEquals('Product Display 1', products[0].Portal_Display_Name__c, 'First product display name should match');
        System.assertEquals('Product Display 2', products[1].Portal_Display_Name__c, 'Second product display name should match');
    }

    @isTest
    static void testGetProductOfferInformationNoProducts() {
        // Delete all products to simulate the scenario where no products exist
        delete [SELECT Id FROM Product2];

        // Instantiate the factory class
        Product_V2_Factory factory = new Product_V2_Factory();

        Test.startTest();
        try {
            // Call the method to retrieve product information
            
            factory.getProductOfferInformation();
            System.assert(false, 'An exception should have been thrown because no products are available');
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage(), 'Expected exception message not received');
        }
        Test.stopTest();
    }


    @isTest
    static void testGetProductInformationSucess() {
        // Instantiate the factory class
        Product2 testProduct = [SELECT Id FROM Product2 WHERE Name = 'Test Product 1' LIMIT 1];
        Product_V2_Factory factory = new Product_V2_Factory();

        Test.startTest();
        // Call the method to retrieve product information
        Product2 products = factory.getProductInformation(testProduct.Id);
        Test.stopTest();

        // Validate the results
        System.assertNotEquals(null, products, 'Product list should not be null');
    }

    @isTest
    static void testGetProductInformationNoProducts() {
        // Delete all products to simulate the scenario where no products exist
        delete [SELECT Id FROM Product2];

        // Instantiate the factory class
        Product_V2_Factory factory = new Product_V2_Factory();

        Test.startTest();
        try {
            // Call the method to retrieve product information
            Id productId = '0x00000000000';
            factory.getProductInformation(productId);
            System.assert(false, 'An exception should have been thrown because no products are available');
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage(), 'Expected exception message not received');
        }
        Test.stopTest();
    }
}