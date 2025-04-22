@isTest
private class Product_V2_Service_Test {

    @testSetup
    static void setup() {

        User owner = [SELECT Id FROM USER WHERE Name = 'The VentureCrowd Team'];
        Id recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('VC Person Account').getRecordTypeId();
        Account testAccount = new Account(
            FirstName = 'TestPersonAccountFirst',
            LastName = 'TestPersonAccountLast',
            PersonEmail = 'test@user.com',
            RecordTypeId = recordTypeId,
            // Name = 'Test Account',
            OwnerId = owner.Id
        );
        insert testAccount;

        // Create a test company account related to the test account
        Account testCompany = new Account(
            Name = 'Test Company Account',
            
            Related_Person_Account__c = testAccount.Id);
        insert testCompany;

        // Create a sample ContentVersion
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'Test Document';
        contentVersion.PathOnClient = 'Test Document.pdf';
        contentVersion.VersionData = Blob.valueOf('Test Content');
        contentVersion.Form_Field__c = 'companyLogoId';
        insert contentVersion;


        // Create a sample ContentVersion
        ContentVersion contentVersion2 = new ContentVersion();
        contentVersion2.Title = 'Test Document';
        contentVersion2.PathOnClient = 'Test Document.pdf';
        contentVersion2.VersionData = Blob.valueOf('Test Content');
        contentVersion2.Form_Field__c = 'heroImageId';
        insert contentVersion2;

        

        
        Profile testProfile = [SELECT Id, Name FROM Profile WHERE Name = 'VC Investor Community Plus Login' LIMIT 1];
    
        Contact getContact = [SELECT Id, Name FROM Contact WHERE FirstName = 'TestPersonAccountFirst'];
        // Id contactId = getContact.Id;

        User testUser = new User(
            FirstName = 'TestingUserN2',
            Username = 'testUser_n2@test.com',
            LastName = 'TestAds',
            // ContactId = testContact.Id,
            Email = 'testUser_n2@test.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = testProfile.Id,
            ContactId = getContact.Id
        );
        insert testUser;


        // Create a test raise
        Raise__c testRaise = new Raise__c(
            Name = 'Test Raise',
            Account__c = testAccount.Id,
            Company__c = testCompany.Id,
            Status__c = 'New',
            Form_Problem_or_Opportunity__c = 'Problem statement',
            Form_Solution__c = 'Solution statement',
            Form_Differentiation__c = 'Differentiation statement',
            Form_Intellectual_Property__c = 'IP statement',
            Form_Total_addressable_market__c = 'Market size statement',
            Form_Progress__c = 'Progress statement',
            Form_Growth_plan__c = 'Growth plan statement',
            Form_Valuation__c = 1000000,
            Form_Company_one_liner__c = 'One liner',
            Form_Offer_close_date__c = Date.today().addDays(30),
            Form_Offer_launch_date__c = Date.today(),
            Owner__c = testUser.Id
        );
        insert testRaise;

        // Link the document to the account
        ContentDocumentLink docLink = new ContentDocumentLink();
        docLink.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId;
        docLink.LinkedEntityId = testRaise.Id;
        docLink.ShareType = 'V';
        docLink.Visibility = 'AllUsers';
        insert docLink;


        ContentDocumentLink docLink2 = new ContentDocumentLink();
        docLink2.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion2.Id].ContentDocumentId;
        docLink2.LinkedEntityId = testRaise.Id;
        docLink2.ShareType = 'V';
        docLink2.Visibility = 'AllUsers';
        insert docLink2;

        // Create a sample ContentDistribution
        ContentDistribution contentDistribution = new ContentDistribution();
        contentDistribution.ContentVersionId = contentVersion.Id;
        contentDistribution.Name = 'Test Distribution';
        insert contentDistribution;

        // Create a sample ContentDistribution
        ContentDistribution contentDistribution2 = new ContentDistribution();
        contentDistribution2.ContentVersionId = contentVersion2.Id;
        contentDistribution2.Name = 'Test Distribution';
        insert contentDistribution2;



        // Create test Product2 records that match the criteria
        Product2 product1 = new Product2(
            Name = 'Test Product 1',
            Portal_Display_Name__c = 'Product Display 1',
            Tile_Heading__c = 'Heading 1',
            Deal_Description__c = 'Deal Description 1',
            Tile_Offer_Type__c = 'Offer Type 1',
            Tile_Banner__c = 'Banner 1',
            Family = 'Test Family',
            Raise__c = testRaise.Id,

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
            Raise__c = testRaise.Id,

            Deal_Page_Link__c = 'http://example.com/product2',
            Publish_on_Community_Site__c = true,
            IsActive = true,
            Offer_Close_Date__c = Date.today().addDays(1)
        );
        insert new List<Product2> { product1, product2 };


    }

    @isTest
    static void testGetProductOfferInformationSuccess() {
        // Instantiate the service class
        Product_V2_Service service = new Product_V2_Service();

        Test.startTest();
        // Call the method to retrieve product information
        String jsonResult = service.getProductOfferInformation();
        Test.stopTest();

        // Deserialize the JSON result to a list of ProductsData
        List<Product_V2_Service.ProductsData> productsDataList = (List<Product_V2_Service.ProductsData>) JSON.deserialize(jsonResult, List<Product_V2_Service.ProductsData>.class);

        // Validate the results
        System.assertNotEquals(null, productsDataList, 'Product data list should not be null');
        System.assertEquals(2, productsDataList.size(), 'There should be two products returned');
    }

    @isTest
    static void testGetProductOfferInformationNoProducts() {
        // Delete all products to simulate the scenario where no products exist
        delete [SELECT Id FROM Product2];

        // Instantiate the service class
        Product_V2_Service service = new Product_V2_Service();

        Test.startTest();
        try {
            // Call the method to retrieve product information
            service.getProductOfferInformation();
            System.assert(false, 'An exception should have been thrown because no products are available');
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage(), 'Expected exception message not received');
        }
        Test.stopTest();
    }


    @isTest
    static void testGetProductInformationSuccess() {
        // Instantiate the service class
        Product2 testProduct = [SELECT Id, Name FROM Product2 WHERE Name = 'Test Product 1' LIMIT 1];
        
        Test.startTest();
        Product_V2_Service service = new Product_V2_Service();
        Product2 result = service.getProductInformation(testProduct.Id);
        Test.stopTest();

        // Validate the results
        System.assertNotEquals(null, result, 'The product record should not be null.');
    }

    @isTest
    static void testGetProductInformationNoProducts() {
        // Delete all products to simulate the scenario where no products exist
        delete [SELECT Id FROM Product2];

        // Instantiate the service class
        Product_V2_Service service = new Product_V2_Service();

        Test.startTest();
        try {
            Id productId = '0x00000000000';
            service.getProductInformation(productId);
            System.assert(false, 'An exception should have been thrown because no products are available');
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage(), 'Expected exception message not received');
        }
        Test.stopTest();
    }
}