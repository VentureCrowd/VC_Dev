@isTest
private class AccountControllerTest {
    
    @testSetup
    static void setupTestData() {
        // Create test data for Account and User
        User owner = [SELECT Id FROM USER WHERE Name = 'The VentureCrowd Team' LIMIT 1];
        
        Id recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('VC Person Account').getRecordTypeId();
        
        Account testAccount = new Account(
            FirstName = 'TestPersonAccountFirst',
            LastName = 'TestPersonAccountLast', 
            PersonEmail = 'test@user.com',
            RecordTypeId = recordTypeId,
            Preferred_Name__pc = 'PreferredTestName',
            ID_Checked__pc = true,
            OwnerId = owner.Id
        );
        insert testAccount;

        Profile testProfile = [SELECT Id, Name FROM Profile WHERE Name = 'VC Investor Community Plus Login' LIMIT 1];
        Contact contact = [SELECT Id, Name FROM Contact WHERE FirstName = 'TestPersonAccountFirst' LIMIT 1];
        
        User testUser = new User(
            FirstName = 'TestingUserN2',
            Username = 'testUser_n2@test.com',
            LastName = 'TestAds',
            Email = 'testUser_n2@test.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = testProfile.Id,
            ContactId = contact.Id
        );
        insert testUser;

    }
    
    @isTest
    static void testGetAccountInformation_Success() {
        // Arrange: Fetch the test account created in the testSetup
        Id testAccountId = [SELECT Id FROM Account WHERE FirstName = 'TestPersonAccountFirst' LIMIT 1].Id;
        
        Test.startTest();
        // Act: Call the method on AccountController
        Map<String, Object> result = AccountController.getAccountInformation(testAccountId);
        Test.stopTest();
        
        // Assert: Verify that the result contains the expected values
        System.assertNotEquals(null, result, 'The result map should not be null.');
        System.assertEquals('TestPersonAccountFirst', result.get('Name'), 'Name should match the first name.');
        System.assertEquals('PreferredTestName', result.get('PreferredName'), 'PreferredName should match.');
        System.assertEquals(true, result.get('IdVerified'), 'ID_Checked__pc should be true.');
    }
    
    @isTest
    static void testGetAccountInformationException() {
        Test.startTest();
        try {
            // Act: Call the method with an invalid account ID to trigger an exception
            AccountController.getAccountInformation('001000000000001');
            System.assert(false, 'An exception should have been thrown for invalid ID');
        } catch (Exception e) {
            // Assert: Verify that an exception is thrown
            System.assertNotEquals(null, e.getMessage(), 'Expected exception message not received');
        }
        Test.stopTest();
    }


    @isTest
    static void testGetAccountId() {
        // Arrange: Fetch the test account created in the testSetup
        Id testAccountId = [SELECT Id FROM User WHERE FirstName = 'TestingUserN2' LIMIT 1].Id;
        
        Test.startTest();
        // Act: Call the method on AccountController
        Id result = AccountController.getAccountId(testAccountId);
        Test.stopTest();
        
        // Assert: Verify that the result contains the expected values
        System.assertNotEquals(null, result, 'The result map should not be null.');

    }
}