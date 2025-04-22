@IsTest
private class RaiseFactoryTest {

    @TestSetup
    static void setup() {
        Id ownerId = 'a3XXX000000cXXXAAI';
        List<User> benQuery = [SELECT Id FROM User WHERE Name='Ben Crow' LIMIT 1];
        if(benQuery.size() > 0){
            ownerId = benQuery[0].Id;
        }
        
        // Create a test Business Account and related person account
        Account personAccount = new Account(Name='Related Person');
        insert personAccount;

        Account businessAccount = new Account(Name='Test Business', Related_Person_Account__c=personAccount.Id);
        insert businessAccount;

        // Create a test EOI
        EOI__c eoi = new EOI__c(Name='Test EOI', Account__c=businessAccount.Id, Internal_Owner__c = ownerId);
        insert eoi;

        // Create a test Raise
        Raise__c testRaise = new Raise__c(Name='Existing Raise', Company__c=businessAccount.Id, Account__c=personAccount.Id, Owner__c = ownerId);
        testRaise.Form_Offer_close_date__c = Date.today();
        insert testRaise;
    }

    @IsTest
    static void testCreateRaise_Success() {
        Account testAccount = [SELECT Id FROM Account WHERE Name='Test Business' LIMIT 1];
        RaiseFactory factory = new RaiseFactory();

        Test.startTest();
        Raise__c newRaise = factory.createRaise(testAccount.Id, 'Retail');
        Test.stopTest();

        System.assertNotEquals(null, newRaise, 'Raise record should be created');
        System.assertEquals('In Progress', newRaise.Status__c, 'Status should be set to In Progress');
        System.assertEquals(true, newRaise.Preraise_completed__c, 'Preraise_completed should be true');
    }

   @IsTest
    static void testCreateRaise_Failure() {
        String fakeCompanyId = '001XXXXXXXXXXXXXXX';
        RaiseFactory factory = new RaiseFactory();

        Test.startTest();
        try {
            Raise__c newRaise = factory.createRaise(fakeCompanyId,'Retail');
            System.assert(false, 'An exception should have been thrown for invalid ID');
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage(), 'Expected exception message not received');
        }
        Test.stopTest();
    }

    @IsTest
    static void testCheckRaiseExists_True() {
        Account testAccount = [SELECT Id FROM Account WHERE Name='Test Business' LIMIT 1];
        RaiseFactory factory = new RaiseFactory();

        Test.startTest();
        Boolean exists = factory.checkRaiseExists(testAccount.Id);
        Test.stopTest();

        System.assertEquals(true, exists, 'Raise should exist');
    }

    @IsTest
    static void testCheckRaiseExists_False() {
        RaiseFactory factory = new RaiseFactory();

        Test.startTest();
        Boolean exists = factory.checkRaiseExists('001XXXXXXXXXXXXXXX');
        Test.stopTest();

        System.assertEquals(false, exists, 'Raise should not exist');
    }

    @IsTest
    static void testGetRaiseRecord_Success() {
        Raise__c testRaise = [SELECT Id FROM Raise__c WHERE Name='Existing Raise' LIMIT 1];
        RaiseFactory factory = new RaiseFactory();

        Test.startTest();
        Raise__c result = factory.getRaiseRecord(testRaise.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Raise record should be retrieved');
        System.assertEquals(testRaise.Id, result.Id, 'Raise Id should match');
    }
    
    @IsTest
    static void testGetRaiseRecord_Failure() {
        String fakeRaiseId = 'a0SXXXXXXXXXXXXXXX';
        RaiseFactory factory = new RaiseFactory();

        Test.startTest();
        Raise__c result = factory.getRaiseRecord(fakeRaiseId);
        Test.stopTest();

        System.assertEquals(null, result, 'Raise record should not be retrieved');
    }

    @IsTest
    static void testGetRaiseRecordCompanyId() {
        Account testAccount = [SELECT Id FROM Account WHERE Name='Test Business' LIMIT 1];
        Raise__c testRaise = [SELECT Id FROM Raise__c WHERE Company__c=:testAccount.Id LIMIT 1];
        RaiseFactory factory = new RaiseFactory();

        Test.startTest();
        Raise__c result = factory.getRaiseRecordCompanyId(testAccount.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Raise record should be retrieved by company ID');
        System.assertEquals(testRaise.Id, result.Id, 'Raise Id should match');
    }
    
    @IsTest
    static void testGetRaiseRecordCompanyId_Failure() {
        String fakeCompanyId = '001XXXXXXXXXXXXXXX';
        RaiseFactory factory = new RaiseFactory();

        Test.startTest();
        try {
            Raise__c result = factory.getRaiseRecordCompanyId(fakeCompanyId);
            System.assert(false, 'An exception should have been thrown for invalid ID');
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage(), 'Expected exception message not received');
        }
        Test.stopTest();
    }

    @isTest
    static void testConvertFieldValue() {
        RaiseFactory factory = new RaiseFactory();

        Test.startTest();
        
        // Test BOOLEAN conversion
        Object booleanValue = factory.convertFieldValue(Schema.DisplayType.BOOLEAN, 'true');
        System.assertEquals(true, booleanValue, 'BOOLEAN conversion failed');
        
        // Test DATE conversion
        Object dateValue = factory.convertFieldValue(Schema.DisplayType.DATE, '2023-05-21');
        System.assertEquals(Date.newInstance(2023, 5, 21), dateValue, 'DATE conversion failed');
        
        // Test DATETIME
        Object datetimeResult = factory.convertFieldValue(Schema.DisplayType.DATETIME, '2023-05-21 12:34:56');
        System.assertEquals(Datetime.newInstanceGmt(2023, 5, 21, 12, 34, 56), datetimeResult, 'Expected 2023-05-21 12:34:56 for datetime conversion');

        // Test INTEGER conversion
        Object integerValue = factory.convertFieldValue(Schema.DisplayType.INTEGER, '123');
        System.assertEquals(123, integerValue, 'INTEGER conversion failed');
        
        // Test DOUBLE conversion
        Object doubleValue = factory.convertFieldValue(Schema.DisplayType.DOUBLE, '123.45');
        System.assertEquals(123.45, doubleValue, 'DOUBLE conversion failed');
        
        // Test CURRENCY conversion
        Object currencyValue = factory.convertFieldValue(Schema.DisplayType.CURRENCY, '123.45');
        System.assertEquals(123.45, currencyValue, 'CURRENCY conversion failed');
        
        // Test PERCENT conversion
        Object percentValue = factory.convertFieldValue(Schema.DisplayType.PERCENT, '50.5');
        System.assertEquals(50.5, percentValue, 'PERCENT conversion failed');
        
        // Test STRING conversion
        Object stringValue = factory.convertFieldValue(Schema.DisplayType.STRING, 'Test String');
        System.assertEquals('Test String', stringValue, 'STRING conversion failed');
        
        // Test TEXTAREA conversion
        Object textAreaValue = factory.convertFieldValue(Schema.DisplayType.TEXTAREA, 'Test Text Area');
        System.assertEquals('Test Text Area', textAreaValue, 'TEXTAREA conversion failed');
        
        // Test URL conversion
        Object urlValue = factory.convertFieldValue(Schema.DisplayType.URL, 'https://www.example.com');
        System.assertEquals('https://www.example.com', urlValue, 'URL conversion failed');
        
        // Test EMAIL conversion
        Object emailValue = factory.convertFieldValue(Schema.DisplayType.EMAIL, 'test@example.com');
        System.assertEquals('test@example.com', emailValue, 'EMAIL conversion failed');
        
        // Test PHONE conversion
        Object phoneValue = factory.convertFieldValue(Schema.DisplayType.PHONE, '123-456-7890');
        System.assertEquals('123-456-7890', phoneValue, 'PHONE conversion failed');
        
        // Test ID conversion
        Object idValue = factory.convertFieldValue(Schema.DisplayType.ID, '0011t00001Dfr4FAAR');
        System.assertEquals('0011t00001Dfr4FAAR', idValue, 'ID conversion failed');
        
        // Test REFERENCE conversion
        Object referenceValue = factory.convertFieldValue(Schema.DisplayType.REFERENCE, '0011t00001Dfr4FAAR');
        System.assertEquals('0011t00001Dfr4FAAR', referenceValue, 'REFERENCE conversion failed');
        
        // Test null value
        Object nullValue = factory.convertFieldValue(Schema.DisplayType.STRING, null);
        System.assertEquals(null, nullValue, 'Null value conversion failed');
        
        // Test default case
        Object defaultValue = factory.convertFieldValue(Schema.DisplayType.MULTIPICKLIST, 'Default Value');
        System.assertEquals('Default Value', defaultValue, 'Default case conversion failed');
        
        Test.stopTest();
    }

    @isTest
    static void testGetFullRaiseRecord() {
        Raise__c testRaise = [SELECT Id FROM Raise__c LIMIT 1];

        Test.startTest();
        RaiseFactory factory = new RaiseFactory();
        Raise__c result = factory.getFullRaiseRecord(testRaise.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Raise record should not be null');
        System.assertEquals(testRaise.Id, result.Id, 'Raise record Id should match the test Raise Id');
    }

    @isTest
    static void testgetSummaryStatistics() {
        Raise__c testRaise = [SELECT Id FROM Raise__c LIMIT 1];
        EOI__c testEOI = [SELECT Id FROM EOI__c LIMIT 1];

        Test.startTest();
        RaiseFactory factory = new RaiseFactory();
        Map<String,Object> result = factory.getSummaryStatistics(testRaise.Id, testEOI.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Raise record should not be null');
    }
    static void testUpdateRaiseStatusSuccess() {
        // Retrieve the test Raise record
        Raise__c testRaise = [SELECT Id, Status__c FROM Raise__c LIMIT 1];
        RaiseFactory factory = new RaiseFactory();
        // Update the status of the test Raise record
        String newStatus = 'Live';
        Test.startTest();
        Raise__c updatedRaise = factory.updateRaiseStatus(testRaise.Id, newStatus);
        Test.stopTest();
        
        // Verify the status was updated correctly
        System.assertEquals(newStatus, updatedRaise.Status__c, 'The status should be updated.');
    }

    @isTest
    static void testGetRaiseRecordType() {
        // Query for the test Raise record created in the test setup.
        Raise__c raiseTest = [SELECT Id, RecordType.DeveloperName FROM Raise__c LIMIT 1];
        
        // Instantiate the class containing the method under test.
        // Replace 'RaiseHelper' with the actual name of the class if different.
        RaiseFactory factory = new RaiseFactory();
        
        // Call the method in a test context.
        Test.startTest();
        Raise__c result = factory.getRaiseRecordType(raiseTest.Id);
        Test.stopTest();
        
        // Assert that the returned Raise__c record is not null.
        System.assertNotEquals(null, result, 'Expected a non-null Raise__c record.');
        
        // Assert that the returned record's Id matches the one queried from test setup.
        System.assertEquals(raiseTest.Id, result.Id, 'The returned Raise__c record should match the queried record.');
        System.assertEquals('Primary_Raise', result.RecordType.DeveloperName, 'RecordType DeveloperName did not match.');
    }
}