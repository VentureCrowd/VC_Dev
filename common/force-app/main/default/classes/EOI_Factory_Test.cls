@IsTest
public class EOI_Factory_Test {

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
        FirstName = 'TestingUserN2111',
        Username = 'testUser_n211@test.com',
        LastName = 'TestA22ds',
        // ContactId = testContact.Id,
        Email = 'testUser_n211@test.com',
        Alias = 'tuser',
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

        // Create a test Raise (unrelated to this test but provided in the setup)
        Raise__c testRaise = new Raise__c(
            Name = 'Existing Raise',
            Company__c = businessAccount.Id,
            Account__c = personAccount.Id,
            Owner__c = owner.Id
        );
        insert testRaise;
    }

    @isTest
    static void testGetEoiOfferInformation_Success() {
        // Instantiate the factory class
        EOI_Factory factory = new EOI_Factory();

        Test.startTest();
        // Call the method to retrieve EOI information
        List<EOI__c> eoiRecords = factory.getEoiOfferInformation();
        Test.stopTest();

        // Validate the results
        System.assertNotEquals(null, eoiRecords, 'EOI records list should not be null');
        System.assertEquals(2, eoiRecords.size(), 'There should be one EOI record returned');
        System.assertEquals('Exciting EOI Title', eoiRecords[0].EOI_Title__c, 'The EOI title should match the expected value');
    }


    @isTest
    static void testGetSXSWEoiOfferInformation_Success() {
        // Instantiate the factory class
        EOI_Factory factory = new EOI_Factory();

        Test.startTest();
        // Call the method to retrieve EOI information
        List<EOI__c> eoiRecords = factory.getEoiSXSWFinalist('');
        Test.stopTest();

        // Validate the results
        System.assertNotEquals(null, eoiRecords, 'EOI records list should not be null');
        System.assertEquals(2, eoiRecords.size(), 'There should be one EOI record returned');
        System.assertEquals('Exciting EOI Title', eoiRecords[0].EOI_Title__c, 'The EOI title should match the expected value');
    }

    @isTest
    static void testGetSXSWEoiOfferInformation_SuccessSearch() {
        // Instantiate the factory class
        EOI_Factory factory = new EOI_Factory();

        Test.startTest();
        // Call the method to retrieve EOI information
        List<EOI__c> eoiRecords = factory.getEoiSXSWFinalist('Test');
        Test.stopTest();

        // Validate the results
        System.assertNotEquals(null, eoiRecords, 'EOI records list should not be null');
        System.assertEquals(1, eoiRecords.size(), 'There should be one EOI record returned');
        System.assertEquals('Exciting EOI Title', eoiRecords[0].EOI_Title__c, 'The EOI title should match the expected value');
    }

    @isTest
    static void testGetSXSWEoiOfferInformation_NoEOIs() {
        // Delete all EOIs to simulate the scenario where no records exist
        delete [SELECT Id FROM EOI__c];

        // Instantiate the factory class
        EOI_Factory factory = new EOI_Factory();

        Test.startTest();
        try {
            // Call the method to retrieve EOI information
            factory.getEoiSXSWFinalist('');
            System.assert(false, 'An exception should have been thrown because no EOIs are available');
        } catch (DmlException e) {
            // Validate that the exception is thrown with the correct message
            System.assert(true);

        }
        Test.stopTest();
    }


    @isTest
    static void testGetEoiOfferInformation_NoEOIs() {
        // Delete all EOIs to simulate the scenario where no records exist
        delete [SELECT Id FROM EOI__c];

        // Instantiate the factory class
        EOI_Factory factory = new EOI_Factory();

        Test.startTest();
        try {
            // Call the method to retrieve EOI information
            factory.getEoiOfferInformation();
            System.assert(false, 'An exception should have been thrown because no EOIs are available');
        } catch (DmlException e) {
            // Validate that the exception is thrown with the correct message
            System.assert(true);
        }
        Test.stopTest();
    }
}