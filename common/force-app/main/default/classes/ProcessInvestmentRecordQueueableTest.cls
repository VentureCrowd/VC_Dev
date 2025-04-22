/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ProcessInvestmentRecordQueueableTest {

     @isTest
    static void testProcessInvestmentRecordQueueable_Insert() {
        User owner = [SELECT Id FROM USER WHERE Name = 'The VentureCrowd Team'];

        Id recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('VC Person Account').getRecordTypeId();

        // Create test Account
        Account testAccount = new Account(FirstName = 'TestPersonAccountFirst',
            LastName = 'TestPersonAccountLast',
            PersonEmail = 'test@user.com',
            RecordTypeId = recordTypeId,
            // Name = 'Test Account',
            OwnerId = owner.Id);
        insert testAccount;

        // Create test Product2
        Product2 testProduct = new Product2(
            Name = 'Test Product',
            Tile_Banner__c = 'http://example.com/product'
        );
        
        Profile testProfile = [SELECT Id, Name FROM Profile WHERE Name = 'VC Investor Community Plus Login' LIMIT 1];
    
        Contact getContact = [SELECT Id, Name FROM Contact WHERE FirstName = 'TestPersonAccountFirst'];

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
        
        insert testProduct;
        // Create test Opportunity associated with Account and Product
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = testAccount.Id,
            StageName = 'Expression of Interest',
            CloseDate = Date.today(),
            Invested_Product_ADMIN_FIELD__c = testProduct.Id,
            Unit_Certificate_Amount__c = 1000.00,
            OwnerId = UserInfo.getUserId(),
            CRC_Assigned__c = testUser.id
        );
        insert testOpportunity;

        // Prepare newOppMap
        Map<Id, Opportunity> newOppMap = new Map<Id, Opportunity>{ testOpportunity.Id => testOpportunity };

        // For insert, oldOppMap is null
        Map<Id, Opportunity> oldOppMap = null;
        Boolean isInsert = true;

        // Instantiate the Queueable class
        ProcessInvestmentRecordQueueable queueable = new ProcessInvestmentRecordQueueable(oldOppMap, newOppMap, isInsert);

        // Execute the Queueable class
        Test.startTest();
        System.enqueueJob(queueable);
        Test.stopTest();

        // Verify that the Investment__c record was created
        //List<Investment__c> investments = [
        //   SELECT Id, Opportunity__c, Investment_Product_Name__c, Investment_Product_Type__c
        //    FROM Investment__c
        //    WHERE Opportunity__c = :testOpportunity.Id
        //];
        //System.assertEquals(1, investments.size(), 'Investment__c record should have been created.');
        //Investment__c inv = investments[0];
        //System.assertEquals(testOpportunity.Id, inv.Opportunity__c, 'Opportunity__c should match the Opportunity Id.');
        //System.assertEquals(testProduct.Name, inv.Investment_Product_Name__c, 'Investment_Product_Name__c should match the Product Name.');
        //System.assertEquals(testProduct.Investment_Product_Type__c, inv.Investment_Product_Type__c, 'Investment_Product_Type__c should match.');
    }

    @isTest
    static void testProcessInvestmentRecordQueueable_Update() {
        User owner = [SELECT Id FROM USER WHERE Name = 'The VentureCrowd Team'];

        Id recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('VC Person Account').getRecordTypeId();

        // Create test Account
        Account testAccount = new Account(FirstName = 'TestPersonAccountFirst',
            LastName = 'TestPersonAccountLast',
            PersonEmail = 'test@user.com',
            RecordTypeId = recordTypeId,
            // Name = 'Test Account',
            OwnerId = owner.Id);
        insert testAccount;

        // Create test Product2
        Product2 testProduct = new Product2(
            Name = 'Test Product',
            Tile_Banner__c = 'http://example.com/product'
        );
        insert testProduct;
        
        Profile testProfile = [SELECT Id, Name FROM Profile WHERE Name = 'VC Investor Community Plus Login' LIMIT 1];
    
        Contact getContact = [SELECT Id, Name FROM Contact WHERE FirstName = 'TestPersonAccountFirst'];

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

        // Create test Opportunity
        Opportunity testOpportunity = new Opportunity(
           Name = 'Test Opportunity',
            AccountId = testAccount.Id,
            StageName = 'Expression of Interest',
            CloseDate = Date.today(),
            Invested_Product_ADMIN_FIELD__c = testProduct.Id,
            Unit_Certificate_Amount__c = 1000.00,
            OwnerId = UserInfo.getUserId(),
            CRC_Assigned__c = testUser.id
        );
        insert testOpportunity;

        // Clone the old Opportunity for oldMap
        Opportunity oppOld = testOpportunity.clone(false, true, true, true);
        Map<Id, Opportunity> oldOppMap = new Map<Id, Opportunity>{ testOpportunity.Id => oppOld };

        // Update the Opportunity to new stage
        testOpportunity.StageName = 'EOI';
        update testOpportunity;

        // Get the updated Opportunity
        Opportunity oppNew = [
            SELECT Id, StageName, Number_Of_Units__c, Invested_Product_ADMIN_FIELD__c
            FROM Opportunity
            WHERE Id = :testOpportunity.Id
        ];
        Map<Id, Opportunity> newOppMap = new Map<Id, Opportunity>{ oppNew.Id => oppNew };
        Boolean isInsert = false;

        // Instantiate the Queueable class
        ProcessInvestmentRecordQueueable queueable = new ProcessInvestmentRecordQueueable(oldOppMap, newOppMap, isInsert);

        // Execute the Queueable class
        Test.startTest();
        System.enqueueJob(queueable);
        Test.stopTest();

        // Verify that the Investment__c record was created or updated
        //List<Investment__c> investments = [
        //    SELECT Id, Opportunity__c, Purchased_Shares__c
        //    FROM Investment__c
        //    WHERE Opportunity__c = :testOpportunity.Id
        //];
        //System.assertEquals(1, investments.size(), 'Investment__c record should have been created or updated.');
        //Investment__c inv = investments[0];
        //System.assertEquals(testOpportunity.Id, inv.Opportunity__c, 'Opportunity__c should match the Opportunity Id.');
        //System.assertEquals(oppNew.Number_Of_Units__c, inv.Purchased_Shares__c, 'Purchased_Shares__c should match Opportunity Number_Of_Units__c.');
    }
}