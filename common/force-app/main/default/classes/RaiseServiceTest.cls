@IsTest
private class RaiseServiceTest {
    private static RaiseService raiseService = new RaiseService();
    private static Id testAccountId;
    private static Id testCompanyId;
    private static Id testRaiseId;
    
    @testSetup
    static void setupTestData() {
        Id ownerId = 'a3XXX000000cXXXAAI';
        List<User> benQuery = [SELECT Id FROM User WHERE Name='Ben Crow' LIMIT 1];
        if(benQuery.size() > 0){
            ownerId = benQuery[0].Id;
        }

        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        testAccountId = testAccount.Id;
        
        Account testCompany = new Account(Name = 'Test Company Account',Related_Person_Account__c=testAccount.Id);
        insert testCompany;
        testCompanyId = testCompany.Id;

        EOI__c testEOI = new EOI__c(
            Name='Test EOI For Raise', 
            Account__c=testCompany.Id,
            Internal_Owner__c = ownerId);
        insert testEOI;

        Raise__c testRaise = new Raise__c(
            Name = 'Test Raise',
            Account__c = testAccountId,
            Company__c = testCompanyId,
            EOI__c = testEOI.Id,
            Owner__c = ownerId,
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
            Form_Offer_close_date__c = Date.today()
        );
        insert testRaise;
        testRaiseId = testRaise.Id;
    }

    @isTest
    static void testGetRaisePageDetailsRaiseId() {
        Raise__c testRaise = [SELECT Id FROM Raise__c LIMIT 1];
        Test.startTest();
        String result = raiseService.getRaisePageDetailsRaiseId(testRaise.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Expected result to be non-null');

        
    }

    @IsTest
    static void testCreateRaiseRecord_Success() {
        Account testCompany = [SELECT Id FROM Account WHERE Name='Test Company Account' LIMIT 1];
        
        Test.startTest();
        Raise__c result = raiseService.createRaiseRecord(testCompany.Id, 'Retail');
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Raise record should be created');
        System.assertEquals(testCompany.Id, result.Company__c, 'Company ID should match');
    }

    @IsTest
    static void testCreateRaiseRecord_Failure() {
        String fakeAccountId = '001xx000003XXXXAAO';
        Test.startTest();
        AuraHandledException e = null;
        try {
            Raise__c result = raiseService.createRaiseRecord(fakeAccountId, 'Retail');
        } catch (AuraHandledException ex) {
            e = ex;
        }
        Test.stopTest();
        
        System.assertNotEquals(null, e, 'Exception should be thrown');
    }

    @IsTest
    static void testRaiseExists_True() {
        Account testCompany = [SELECT Id FROM Account WHERE Name='Test Company Account' LIMIT 1];
        Test.startTest();
        Boolean exists = raiseService.raiseExists(testCompany.Id);
        Test.stopTest();
        
        System.assertEquals(true, exists, 'Raise should exist for the company');
    }

    @IsTest
    static void testRaiseExists_False() {
        String fakeAccountId = '001xx000003XXXXAAO';
        Test.startTest();
        Boolean exists = raiseService.raiseExists(fakeAccountId);
        Test.stopTest();
        
        System.assertEquals(false, exists, 'No raise should exist for the new company');
    }

    @IsTest
    static void testGetRaiseDetails_ExistingId() {
        Raise__c testRaise = [SELECT Id FROM Raise__c LIMIT 1];
        Test.startTest();
        String details = raiseService.getRaiseDetails(testRaise.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, details, 'Details should not be null');
        System.assert(details.contains('Test Raise'), 'Details should contain raise name');
    }

    @IsTest
    static void testGetRaiseDetails_NonExistingId_ThrowsException() {
        String nonExistingId = 'a0Dxx000000XXXX';
        
        Test.startTest();
        AuraHandledException expectedException = null;
        try {
            String details = raiseService.getRaiseDetails(nonExistingId);
        } catch (AuraHandledException e) {
            expectedException = e;
        }
        Test.stopTest();
        
        System.assertNotEquals(null, expectedException, 'An AuraHandledException should be thrown for non-existing ID');
    }

    @IsTest
    static void testGetRaiseDetailsFromCompanyId_ExistingCompany() {
        Account testCompany = [SELECT Id FROM Account WHERE Name='Test Company Account' LIMIT 1];
        Test.startTest();
        String details = raiseService.getRaiseDetailsFromCompanyId(testCompany.Id);
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
            String details = raiseService.getRaiseDetailsFromCompanyId(nonExistingCompanyId);
        } catch (AuraHandledException e) {
            expectedException = e;
        }
        Test.stopTest();
        
        System.assertNotEquals(null, expectedException, 'An AuraHandledException should be thrown for non-existing ID');
    }

    @isTest
    static void testgetSummaryStatistics() {
        Raise__c testRaise = [SELECT Id FROM Raise__c LIMIT 1];
        EOI__c testEOI = [SELECT Id FROM EOI__c LIMIT 1];

        Test.startTest();
        Map<String,Object> result = raiseService.getSummaryStatistics(testRaise.Id, testEOI.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Raise record should not be null');
    }

    @isTest
    static void testGetRaiseRecordType() {
        // Query for the test Raise record created in the test setup.
        Raise__c raiseTest = [SELECT Id, RecordType.DeveloperName FROM Raise__c LIMIT 1];
        
        
        // Call the method in a test context.
        Test.startTest();
        String result = raiseService.getRaiseRecordType(raiseTest.Id);
        Test.stopTest();
        
        // Assert that the returned Raise__c record is not null.
        System.assertNotEquals(null, result, 'Expected a non-null Raise__c record.');
        
        // Assert that the returned record's Id matches the one queried from test setup.
        System.assertEquals('Primary_Raise', result, 'RecordType DeveloperName did not match.');
    }
}