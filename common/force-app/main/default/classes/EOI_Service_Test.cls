@isTest
private class EOI_Service_Test {
    // test class for EOI service
    @TestSetup
    static void setup() {
        User owner = [SELECT Id FROM USER WHERE Name = 'The VentureCrowd Team'];
        Id recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('VC Person Account').getRecordTypeId();

        // Create a test Business Account and related Person Account
        Account personAccount = new Account(
            FirstName = 'TestPersonAccountFirst',
            LastName = 'TestPersonAccountLast',
            PersonEmail = 'test@user.com',
            RecordTypeId = recordTypeId,
            // Name = 'Test Account',
            OwnerId = owner.Id
        );
        insert personAccount;

        Account businessAccount = new Account(Name = 'Test Business', Related_Person_Account__c = personAccount.Id);
        insert businessAccount;

        Profile testProfile = [SELECT Id, Name FROM Profile WHERE Name = 'VC Investor Community Plus Login' LIMIT 1];
    
        Contact getContact = [SELECT Id, Name FROM Contact WHERE FirstName = 'TestPersonAccountFirst'];

        User testUser = new User(
        FirstName = 'TestingUserN3',
        Username = 'testUser_n3@test.com',
        LastName = 'TestAd11s',
        // ContactId = testContact.Id,
        Email = 'testUser_n3@test.com',
        Alias = 't3user',
        TimeZoneSidKey = 'America/Los_Angeles',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        ProfileId = testProfile.Id,
        ContactId = getContact.Id
        );
        insert testUser;

         // Create a test EOI
        EOI__c eoi = new EOI__c(
            Name = 'Test EOI',
            Account__c = businessAccount.Id,
            EOI_Status__c = 'Published',
            Publish_on_Community_Site__c = true,
            URL_Files_Img__c = 'http://example.com/image.png',
            Published_EOI_URL__c = 'http://example.com/eoi',
            One_liner_about_business__c = 'Innovative business idea',
            SXSW_Finalist__c = true,
            EOI_Title__c = 'Exciting EOI Title',
            Internal_Owner__c=owner.Id
        );
        insert eoi;

        EOI__c eoi2 = new EOI__c(
            Name = 'EOI new',
            Account__c = businessAccount.Id,
            EOI_Status__c = 'Published',
            Publish_on_Community_Site__c = true,
            URL_Files_Img__c = 'http://example.com/image.png',
            Published_EOI_URL__c = 'http://example.com/eoi',
            One_liner_about_business__c = 'Innovative business idea',
            SXSW_Finalist__c = true,
            EOI_Title__c = 'Exciting EOI Title',
            Internal_Owner__c=owner.Id
        );
        insert eoi2;
    }

    @isTest
    static void testGetEoiOfferInformation_Success() {
        // Instantiate the service class
        EOI_Service service = new EOI_Service();

        Test.startTest();
        // Call the method to retrieve and process EOI information
        String jsonResult = service.getEoiOfferInformation();
        Test.stopTest();

        // Deserialize the JSON result to a list of EOI_Service.EoiOfferData
        List<EOI_Service.EoiOfferData> eoiDataList = (List<EOI_Service.EoiOfferData>) JSON.deserialize(jsonResult, List<EOI_Service.EoiOfferData>.class);

        // Validate the results
        System.assertNotEquals(null, eoiDataList, 'EOI data list should not be null');
        System.assertEquals(2, eoiDataList.size(), 'There should be one EOI record returned');
        System.assertEquals('Exciting EOI Title', eoiDataList[0].tileHeading, 'The EOI title should match the expected value');
        System.assertEquals('http://example.com/eoi', eoiDataList[0].dealPageLink, 'The EOI deal page link should match the expected value');
    }

    @isTest
    static void testGetSXSWEoiOfferInformation_Success() {
        // Instantiate the service class
        EOI_Service service = new EOI_Service();

        Test.startTest();
        // Call the method to retrieve and process EOI information
        String jsonResult = service.getSXSWEoiOfferInformation('');
        Test.stopTest();

        // Deserialize the JSON result to a list of EOI_Service.EoiOfferData
        List<EOI_Service.EoiOfferData> eoiDataList = (List<EOI_Service.EoiOfferData>) JSON.deserialize(jsonResult, List<EOI_Service.EoiOfferData>.class);

        // Validate the results
        System.assertNotEquals(null, eoiDataList, 'EOI data list should not be null');
        System.assertEquals(2, eoiDataList.size(), 'There should be one EOI record returned');
        System.assertEquals('Exciting EOI Title', eoiDataList[0].tileHeading, 'The EOI title should match the expected value');
        System.assertEquals('http://example.com/eoi', eoiDataList[0].dealPageLink, 'The EOI deal page link should match the expected value');
    }

    @isTest
    static void testGetSXSWEoiOfferInformation_SuccessSearch() {
        // Instantiate the service class
        EOI_Service service = new EOI_Service();

        Test.startTest();
        // Call the method to retrieve and process EOI information
        String jsonResult = service.getSXSWEoiOfferInformation('Test');
        Test.stopTest();

        // Deserialize the JSON result to a list of EOI_Service.EoiOfferData
        List<EOI_Service.EoiOfferData> eoiDataList = (List<EOI_Service.EoiOfferData>) JSON.deserialize(jsonResult, List<EOI_Service.EoiOfferData>.class);

        // Validate the results
        System.assertNotEquals(null, eoiDataList, 'EOI data list should not be null');
        System.assertEquals(1, eoiDataList.size(), 'There should be one EOI record returned');
        System.assertEquals('Exciting EOI Title', eoiDataList[0].tileHeading, 'The EOI title should match the expected value');
        System.assertEquals('http://example.com/eoi', eoiDataList[0].dealPageLink, 'The EOI deal page link should match the expected value');
    }


    @isTest
    static void testGetEoiOfferInformation_NoEOIs() {
        // Delete all EOIs to simulate the scenario where no records exist
        delete [SELECT Id FROM EOI__c];

        // Instantiate the service class
        EOI_Service service = new EOI_Service();

        Test.startTest();
        try {
            // Call the method to retrieve and process EOI information
            service.getEoiOfferInformation();
            System.assert(false, 'An exception should have been thrown because no EOIs are available');
        } catch (Exception e) {
            // Validate that the exception is thrown with the correct message
            System.assertNotEquals(null, e.getMessage(), 'Expected exception message not received');
        }
        Test.stopTest();
    }

    @isTest
    static void testGetSXSWEoiOfferInformation_NoEOIs() {
        // Delete all EOIs to simulate the scenario where no records exist
        delete [SELECT Id FROM EOI__c];

        // Instantiate the service class
        EOI_Service service = new EOI_Service();

        Test.startTest();
        try {
            // Call the method to retrieve and process EOI information
            service.getSXSWEoiOfferInformation('');
            System.assert(false, 'An exception should have been thrown because no EOIs are available');
        } catch (Exception e) {
            // Validate that the exception is thrown with the correct message
            System.assertNotEquals(null, e.getMessage(), 'Expected exception message not received');
        }
        Test.stopTest();
    }
}