@isTest
private class CompaniesServiceTest {

    private static CompaniesService companiesService = new CompaniesService();

    @testSetup
    static void setupTestData() {
        // Create test data for Account, Company, Raise, EOI, and User

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
            Owner__c= owner.Id,
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
            Form_Offer_launch_date__c = Date.today()
        );
        insert testRaise;
    
        // Create a test EOI
        EOI__c testEOI = new EOI__c(
            Name = 'Testing EOI',
            Related_Person_Account__c = testAccount.Id,
            Internal_Owner__c = owner.Id,
            Account__c = testCompany.Id,
            EOI_Status__c = 'Closed',
            EOI_Published_Date__c = DateTime.now(),
            URL_Files_Img__c = '[{"title":"logo","contentDownloadURL":"https://example.com/logo.png"}]'
        );
        insert testEOI;
    }

    @IsTest
    static void testRaiseExists_True() {
        Account testCompany = [SELECT Id FROM Account WHERE Name='Test Company Account' LIMIT 1];

        Test.startTest();
        Boolean exists = companiesService.raiseExists(testCompany.Id);
        Test.stopTest();

        System.assertEquals(true, exists, 'Raise should exist for the given company ID');
    }

    @IsTest
    static void testRaiseExists_False() {

        Test.startTest();
        Boolean exists = companiesService.raiseExists('001XXXXXXXXXXXXXXX');
        Test.stopTest();

        System.assertEquals(false, exists, 'Raise should not exist for an invalid company ID');
    }


    @IsTest
    static void testEoiExists_True() {
        Account testCompany = [SELECT Id FROM Account WHERE Name='Test Company Account' LIMIT 1];
        Test.startTest();
        Boolean exists = companiesService.eoiExists(testCompany.Id);
        Test.stopTest();

        System.assertEquals(true, exists, 'EOI should exist for the given company ID');
    }

    @IsTest
    static void testEoiExists_False() {

        Test.startTest();
        Boolean exists = companiesService.eoiExists('001XXXXXXXXXXXXXXX');
        Test.stopTest();

        System.assertEquals(false, exists, 'EOI should not exist for an invalid company ID');
    }


    @IsTest
    static void testGetRaiseDetailsFromCompanyId_ExistingCompany() {
        Account testCompany = [SELECT Id FROM Account WHERE Name='Test Company Account' LIMIT 1];
        Test.startTest();
        String details = companiesService.getRaiseDetailsFromCompanyId(testCompany.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, details, 'Details should not be null');
        System.assert(details.contains('Test Raise'), 'Details should contain raise name');
    }

    @IsTest
    static void testGetRaiseDetailsFromCompanyId_NonExistingCompany() {
        String nonExistingCompanyId = '001xx000003XXXXAAO';
        
        Test.startTest();
        AuraHandledException expectedException = null;
        try {
            String details = companiesService.getRaiseDetailsFromCompanyId(nonExistingCompanyId);
        } catch (AuraHandledException e) {
            expectedException = e;
        }
        Test.stopTest();
        
        System.assertNotEquals(null, expectedException, 'An AuraHandledException should be thrown for non-existing ID');
    }

    @IsTest
    static void testGetEoiDetailsFromCompanyId_ExistingCompany() {
        Account testCompany = [SELECT Id FROM Account WHERE Name='Test Company Account' LIMIT 1];
        Test.startTest();
        String details = companiesService.getEoiDetailsFromCompanyId(testCompany.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, details, 'Details should not be null');
        System.assert(details.contains('Testing EOI'), 'Details should contain EOI name');
    }

    @IsTest
    static void testGetEoiDetailsFromCompanyId_NonExistingCompany() {
        String nonExistingCompanyId = '001xx000003XXXXAAO';
        
        Test.startTest();
        AuraHandledException expectedException = null;
        try {
            String details = companiesService.getEoiDetailsFromCompanyId(nonExistingCompanyId);
        } catch (AuraHandledException e) {
            expectedException = e;
        }
        Test.stopTest();
        
        System.assertNotEquals(null, expectedException, 'An AuraHandledException should be thrown for non-existing ID');
    }

    @IsTest
    static void testGetCompaniesCardDetails() {
        // User testUser = [SELECT AccountId, ContactId, Id FROM User WHERE Email='testUser_n2@test.com' LIMIT 1];

        // System.debug('Test User: ' + getContact.Id + 'This is the contact' + getContact.Name);

        
        User testUser = [SELECT AccountId, Id, ContactId, Name FROM User WHERE Email = 'testUser_n2@test.com'];
        System.debug(testUser);

        Contact userContact = [SELECT AccountId , Id, Name FROM Contact WHERE FirstName = 'TestPersonAccountFirst'];
        System.debug('This is the contact Details' + userContact);
        // Account testAccount = [SELECT AccountId, Id, Name FROM Contact WHERE UserId=:testUser.Id];
        // System.debug('Test User: ' + testAccount.Id);


        EOI__c testEOI = [SELECT Account__c, Id, Name FROM EOI__c];
        System.debug('Test EOI' + testEOI);

        Raise__c testRaise = [SELECT Account__c, Id, Name FROM Raise__c];
        System.debug('Test Raise' + testRaise);

        Test.startTest();
        List<Map<String, Object>> companiesCardDetails = companiesService.getCompaniesCardDetails(testUser.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, companiesCardDetails, 'Companies card details should be retrieved for the given user ID');
        System.assertNotEquals(0, companiesCardDetails.size(), 'Companies card details list should not be empty');
        Map<String, Object> firstCompanyCardDetails = companiesCardDetails[0];
        System.assertEquals('Test Company Account', firstCompanyCardDetails.get('companyName'), 'Company name should match');
        System.assertEquals(true, firstCompanyCardDetails.get('eoiExist'), 'EOI should exist');
        System.assertEquals(true, firstCompanyCardDetails.get('raiseExist'), 'Raise should exist');
    }

    @IsTest
    static void testGetCompaniesCardDetails_Exception() {
        CompaniesService service = new CompaniesService();

        Test.startTest();
        try {
            service.getCompaniesCardDetails(null);
        } catch (AuraHandledException e) {
            System.assert(true, 'Exception should have been thrown for null user ID');
        }
        Test.stopTest();
    }

}