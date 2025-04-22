@isTest
private class CompaniesControllerTest {

    // Helper method to set up the necessary test data
    @testSetup
    static void setupTestData() {

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
            
        
        Account personAccount = new Account(Name='Related Person');
        insert personAccount;

        Account businessAccount = new Account(Name='Test Business', Related_Person_Account__c=personAccount.Id);
        insert businessAccount;

        

        Contact testContact = new Contact(
            AccountId = businessAccount.Id,
            FirstName = 'Test First name',
            LastName = 'Test Last Name',
            Email ='test@test.com',
            MailingStreet ='test Street',
            MailingCity ='Test City',
            MailingCountry='Australia',
            MailingState ='Test state',
            MailingPostalCode='34234'
        );
        insert testContact;

        Profile testProfile = [SELECT Id, Name FROM Profile WHERE Name = 'VC Investor Community Plus Login' LIMIT 1];

        User testUser = new User(
            FirstName = 'TestingUserN2',
            Username = 'testUser_n2@test.com',
            LastName = 'TestAds',
            ContactId = testContact.Id,
            Email = 'testUser_n2@test.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = testProfile.Id
        );
        insert testUser;



        // Optional: Create and insert related records if needed (like EOI)
        EOI__c testEOI = new EOI__c(Name = 'Test EOI', Account__c = businessAccount.Id, Internal_Owner__c=owner.Id);
        insert testEOI;

        // Creating a Raise__c record to test existing raise functionality
        Raise__c testRaise = new Raise__c(
            Name = 'Test Raise',
            Account__c = personAccount.Id,
            Company__c = businessAccount.Id,
            Status__c = 'In Progress',
            EOI__c = testEOI.Id,
            Owner__c = testUser.Id
        );
        insert testRaise;

    }


    // Test to check if the raise exists for an account
    @IsTest
    static void testRaiseExists() {
        Account testAccount = [SELECT Id FROM Account WHERE Name='Test Business' LIMIT 1];
        Test.startTest();
        Boolean exists = CompaniesController.raiseExists(testAccount.Id);
        Test.stopTest();
         // Assert to confirm that the raise exists
        System.assert(exists, 'Raise should exist for the test account');
    }
    

    // Test to check if the raise exists for an invalid account ID to simulate an error
    @IsTest
    static void testRaiseDoesntExist() {
        Test.startTest();
        Boolean exists = CompaniesController.raiseExists('invalidId');
        Test.stopTest();
        
        System.assertEquals(false,exists, 'An exception should have been thrown for invalid ID');
    }

    // Test to check if the raise exists for an account
    @IsTest
    static void testEoiExists() {
        Account testAccount = [SELECT Id FROM Account WHERE Name='Test Business' LIMIT 1];
        Test.startTest();
        Boolean exists = CompaniesController.eoiExists(testAccount.Id);
        Test.stopTest();
            // Assert to confirm that the raise exists
        System.assert(exists, 'Raise should exist for the test account');
    }
    

    // Test to check if the raise exists for an invalid account ID to simulate an error
    @IsTest
    static void testEoiDoesntExist() {
        Test.startTest();
        Boolean exists = CompaniesController.eoiExists('invalidId');
        Test.stopTest();
        
        System.assertEquals(false,exists, 'An exception should have been thrown for invalid ID');
    }

    @IsTest
    static void testGetRaiseDetailsFromCompanyId() {
        Account testAccount = [SELECT Id FROM Account WHERE Name='Test Business' LIMIT 1];
        Test.startTest();
        String details = CompaniesController.getRaiseDetailsFromCompanyId(testAccount.Id);
        Test.stopTest();

        // Assert to ensure that details are returned
        System.assertNotEquals(null, details, 'Details should not be null');
        System.assert(details.contains('Test Raise'), 'Details should contain the raise name');
    }

    // Test the retrieval of raise details with an invalid company ID to simulate an error
    @IsTest
    static void testGetRaiseDetailsFromCompanyIdWithError() {
        Test.startTest();
        try {
            String details = CompaniesController.getRaiseDetailsFromCompanyId('invalidId');
            System.assert(false, 'An exception should have been thrown for invalid ID');
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage(), 'Expected exception message not received');
        }
        Test.stopTest();
    }

    @IsTest
    static void testGetEoiDetailsFromCompanyId() {
        Account testAccount = [SELECT Id FROM Account WHERE Name='Test Business' LIMIT 1];
        // 
        Test.startTest();
        String details = CompaniesController.getEoiDetailsFromCompanyId(testAccount.Id);
        Test.stopTest();

        // Assert to ensure that details are returned
        System.assertNotEquals(null, details, 'Details should not be null');
        System.assert(details.contains('Test EOI'), 'Details should contain the raise name');
    }

    // Test the retrieval of raise details with an invalid company ID to simulate an error
    @IsTest
    static void testGetEoiDetailsFromCompanyIdWithError() {
        Test.startTest();
        try {
            String details = CompaniesController.getEoiDetailsFromCompanyId('invalidId');
            System.assert(false, 'An exception should have been thrown for invalid ID');
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage(), 'Expected exception message not received');
        }
        Test.stopTest();
    }

    @IsTest
    static void testGetCompaniesCardDetails() {
        User testUser = [SELECT Id FROM User WHERE FirstName='TestingUserN2' LIMIT 1];
        Test.startTest();
        List<Map<String,Object>> details = CompaniesController.getCompaniesCardDetails(testUser.Id);
        Test.stopTest();
        // Assert to ensure that details are returned
        System.assertNotEquals(null, details, 'Details should not be null');
    }
    
    @IsTest
    static void testGetCompaniesCardDetailsWithError() {
        Test.startTest();
        try {
            List<Map<String,Object>> details = CompaniesController.getCompaniesCardDetails('invalidId');
            System.assert(false, 'An exception should have been thrown for invalid ID');
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage(), 'Expected exception message not received');
        }
        Test.stopTest();
    }
    
}