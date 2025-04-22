@isTest
private class CompaniesFactoryTest {

    @TestSetup
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
        
        Profile testProfile = [SELECT Id, Name FROM Profile WHERE Name = 'VC Investor Community Plus Login' LIMIT 1];
    
        Contact getContact = [SELECT Id, Name FROM Contact WHERE FirstName = 'TestPersonAccountFirst'];

        // Create a test Business Account and related person account
        Account personAccount = new Account(Name='Related Person');
        insert personAccount;

        // Create a test Business Account and related person account
        Account personAccount2 = new Account(Name='Related Person2');
        insert personAccount2;

        Account businessAccount = new Account(Name='Test Business', Related_Person_Account__c=personAccount.Id);
        insert businessAccount;

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

        // Create a test EOI
        EOI__c eoi = new EOI__c(Name='Test EOI', Account__c=businessAccount.Id, Internal_Owner__c=owner.Id);
        insert eoi;

        // Create a test Raise
        Raise__c testRaise = new Raise__c(Name='Existing Raise', Company__c=businessAccount.Id, Account__c=personAccount.Id, Owner__c=owner.Id);
        insert testRaise;
    }

    @IsTest
    static void testCheckRaiseExists_True() {
        Account testAccount = [SELECT Id FROM Account WHERE Name='Test Business' LIMIT 1];
        CompaniesFactory factory = new CompaniesFactory();

        Test.startTest();
        Boolean exists = factory.checkRaiseExists(testAccount.Id);
        Test.stopTest();

        System.assertEquals(true, exists, 'Raise should exist');
    }

    @IsTest
    static void testCheckRaiseExists_False() {
        CompaniesFactory factory = new CompaniesFactory();

        Test.startTest();
        Boolean exists = factory.checkRaiseExists('001XXXXXXXXXXXXXXX');
        Test.stopTest();

        System.assertEquals(false, exists, 'Raise should not exist for an invalid companyId');
    }

    @IsTest
    static void testCheckEoiExists_True() {
        Account testAccount = [SELECT Id FROM Account WHERE Name='Test Business' LIMIT 1];
        CompaniesFactory factory = new CompaniesFactory();

        Test.startTest();
        Boolean exists = factory.checkEoiExists(testAccount.Id);
        Test.stopTest();

        System.assertEquals(true, exists, 'EOI should exist');
    }

    @IsTest
    static void testCheckEoiExists_False() {
        CompaniesFactory factory = new CompaniesFactory();

        Test.startTest();
        Boolean exists = factory.checkEoiExists('001XXXXXXXXXXXXXXX');
        Test.stopTest();

        System.assertEquals(false, exists, 'EOI should not exist for an invalid companyId');
    }

    @IsTest
    static void testGetEOIDetailsFromCompanyId() {
        Account testAccount = [SELECT Id FROM Account WHERE Name='Test Business' LIMIT 1];
        EOI__c testEOI = [SELECT Id, Name FROM EOI__c WHERE Account__c=:testAccount.Id LIMIT 1];
        CompaniesFactory factory = new CompaniesFactory();

        Test.startTest();
        EOI__c result = factory.getEOIDetailsFromCompanyId(testAccount.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'EOI details should be retrieved by company ID');
        System.assertEquals(testEOI.Id, result.Id, 'EOI Id should match');
    }

    @IsTest
    static void testGetRaiseRecordCompanyId() {
        Account testAccount = [SELECT Id FROM Account WHERE Name='Test Business' LIMIT 1];
        Raise__c testRaise = [SELECT Id FROM Raise__c WHERE Company__c=:testAccount.Id LIMIT 1];
        CompaniesFactory factory = new CompaniesFactory();

        Test.startTest();
        Raise__c result = factory.getRaiseRecordCompanyId(testAccount.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Raise record should be retrieved by company ID');
        System.assertEquals(testRaise.Id, result.Id, 'Raise Id should match');
    }

    @IsTest
    static void testGetCompanyDetails() {
        Account testAccount = [SELECT Id, Name FROM Account WHERE Name='Test Business' LIMIT 1];
        CompaniesFactory factory = new CompaniesFactory();

        Test.startTest();
        Account result = factory.getCompanyDetails(testAccount.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Company details should be retrieved by company ID');
        System.assertEquals(testAccount.Id, result.Id, 'Company Id should match');
    }

    @IsTest
    static void testGetCompanyId() {
        User testUser = [SELECT Id, AccountId FROM User LIMIT 1];
        CompaniesFactory factory = new CompaniesFactory();

        Test.startTest();
        List<Account> companies = factory.getCompanyId(testUser.Id);
        Test.stopTest();

        System.assertNotEquals(null, companies, 'Companies should be retrieved by user ID');
    }
}