@isTest
public with sharing class SecurityControllerTest {

    @TestSetup
    static void setupTestData() {
        Id recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('VC Person Account').getRecordTypeId();

        // Create a test Account
        Account testAccount = new Account(
            FirstName = 'TestPersonAccountFirst',
            LastName = 'Account',
            RecordTypeId = recordTypeId
        );
        insert testAccount;

        Contact getContact = [SELECT Id, Name FROM Contact WHERE FirstName = 'TestPersonAccountFirst' LIMIT 1];

        // Create a test User associated with the Account
        Profile p = [SELECT Id FROM Profile WHERE Name = 'VC Customer Community Login' LIMIT 1];

        User testUser = new User(
            Alias = 'testuser',
            Email = 'testuserTEST@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuserTEST@example.com',
            ContactId = getContact.Id
        );
        insert testUser;

        Account businessAccount = new Account(Name='Test Business', Related_Person_Account__c=testAccount.Id);
        insert businessAccount;
        
        Id ownerId = 'a3XXX000000cXXXAAI';

        List<User> benQuery = [SELECT Id FROM User WHERE Name='Ben Crow' LIMIT 1];
        if(benQuery.size() > 0){
            ownerId = benQuery[0].Id;
        }

        EOI__c testEOI = new EOI__c(Name = 'Test EOI', Account__c = businessAccount.Id, Internal_Owner__c = ownerId, Related_Person_Account__c = testAccount.Id);
        insert testEOI;

        // Create a test Raise__c record associated with the Account
        Raise__c testRaise = new Raise__c(
            Name = 'Test Raise',
            Account__c = testAccount.Id,
            Owner__c = ownerId,
            Company__c = businessAccount.Id,
            EOI__c = testEOI.Id,
            Status__c = 'In Progress',
            Payment_received__c = true,
            Content_approved__c = true,
            Course_unlocked__c = false,
            Learning_completed__c = false,
            Form_Problem_or_Opportunity__c = 'Test Problem',
            Form_Solution__c = 'Test Solution',
            Form_Differentiation__c = 'Test Differentiation',
            Form_Intellectual_Property__c = 'Test Intellectual Property',
            Form_Total_addressable_market__c = 'Test Market',
            Form_Progress__c = 'Test Progress',
            Form_Growth_plan__c = 'Test Growth Plan',
            Form_Valuation__c = 1000000,
            Form_Company_one_liner__c = 'Test Company Overview',
            Form_Offer_close_date__c = Date.today()
        );
        insert testRaise;
    }

    @isTest
    static void testGetLoggedInAccountId() {
        // Get the test User
        User testUser = [SELECT Id, AccountId FROM User WHERE UserName = 'testuserTEST@example.com' LIMIT 1];

        // Run as the test User
        System.runAs(testUser) {
            // Call the method to test
            String accountId = SecurityController.getLoggedInAccountId();

            // Assert that the returned AccountId matches the test User's AccountId
            System.assertEquals(testUser.AccountId, accountId, 'The returned AccountId should match the test User\'s AccountId');
        }
    }

    @isTest
    static void testCheckRaiseAccess_ValidAccess() {
        // Get the test User and Raise__c record
        User testUser = [SELECT Id, AccountId FROM User WHERE UserName = 'testuserTEST@example.com' LIMIT 1];
        Raise__c testRaise = [SELECT Id FROM Raise__c WHERE Name = 'Test Raise' LIMIT 1];

        // Run as the test User
        System.runAs(testUser) {
            // Call the method to test
            Boolean hasAccess = SecurityController.checkRaiseAccess(testRaise.Id);

            // Assert that the user has access to the Raise__c record
            System.assertEquals(true, hasAccess, 'The user should have access to the Raise__c record');
        }
    }

    @isTest
    static void testCheckRaiseAccess_Exception() {
        // Get the test User
        User testUser = [SELECT Id, AccountId FROM User WHERE UserName = 'testuserTEST@example.com' LIMIT 1];

        // Run as the test User
        System.runAs(testUser) {
            try {
                // Call the method with an invalid Raise Id to trigger an exception
                SecurityController.checkRaiseAccess('0058s00000DPo1nXXX');
                System.assert(false, 'Expected an exception to be thrown');
            } catch (AuraHandledException e) {
                // Assert that the exception was thrown as expected
                System.assert(true, 'An AuraHandledException was thrown as expected');
            }
        }
    }

    @isTest
    static void testCheckEOIAccess_ValidAccess() {
        // Get the test User and Raise__c record
        User testUser = [SELECT Id, AccountId FROM User WHERE UserName = 'testuserTEST@example.com' LIMIT 1];
        EOI__c testEOI = [SELECT Id FROM EOI__c WHERE Name = 'Test EOI' LIMIT 1];

        // Run as the test User
        System.runAs(testUser) {
            // Call the method to test
            Boolean hasAccess = SecurityController.checkEoiAccess(testEOI.Id);

            // Assert that the user has access to the Raise__c record
            System.assertEquals(true, hasAccess, 'The user should have access to the EOI record');
        }
    }

    @isTest
    static void testCheckEOIAccess_Exception() {
        // Get the test User
        User testUser = [SELECT Id, AccountId FROM User WHERE UserName = 'testuserTEST@example.com' LIMIT 1];

        // Run as the test User
        System.runAs(testUser) {
            try {
                // Call the method with an invalid Raise Id to trigger an exception
                SecurityController.checkEoiAccess('0058s00000DPo1nXXX');
                System.assert(false, 'Expected an exception to be thrown');
            } catch (AuraHandledException e) {
                // Assert that the exception was thrown as expected
                System.assert(true, 'An AuraHandledException was thrown as expected');
            }
        }
    }
}