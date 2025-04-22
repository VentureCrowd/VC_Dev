@isTest(seeAllData=true)
public class OpportunityProcessorTest {
    
    // Helper method to generate unique Account names.
    private static String uniqueAccountName() {
        return 'Test Account ' + String.valueOf(System.currentTimeMillis());
    }
    
    // Helper method to generate a unique email address.
    private static String uniqueEmail() {
        return 'test' + String.valueOf(System.currentTimeMillis()) + '@example.com';
    }
    
    @isTest
    static void testAfterUpdate() {
        // Set up test data with required fields (CM & CRC)
        Account acc = new Account(Name = uniqueAccountName());
        insert acc;
        
        // Create a unique Contact.
        Contact con = new Contact(
            LastName = 'Test ' + String.valueOf(System.currentTimeMillis()),
            Email = uniqueEmail(),
            AccountId = acc.Id
        );
        insert con;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Product2 product = new Product2(
            Name = 'Test Product',
            IsActive = true,
            Tile_Banner__c = 'https://test.com',
            Status__c = 'Available'
        );
        insert product;
        
        PricebookEntry pricebookEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = product.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pricebookEntry;
        
        Opportunity opp1 = new Opportunity(
            Name = 'Test Opportunity 1',
            StageName = 'Qualification',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id,
            Pricebook2Id = pricebookId,
            CM_Assigned__c = UserInfo.getUserId(),
            CRC_Assigned__c = UserInfo.getUserId()
        );
        Opportunity opp2 = new Opportunity(
            Name = 'Test Opportunity 2',
            StageName = 'Qualification',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id,
            Pricebook2Id = pricebookId,
            CM_Assigned__c = UserInfo.getUserId(),
            CRC_Assigned__c = UserInfo.getUserId()
        );
        insert new List<Opportunity>{ opp1, opp2 };
        
        OpportunityLineItem oli1 = new OpportunityLineItem(
            OpportunityId = opp1.Id,
            Product2Id = product.Id,
            Quantity = 1,
            UnitPrice = 100,
            PricebookEntryId = pricebookEntry.Id
        );
        OpportunityLineItem oli2 = new OpportunityLineItem(
            OpportunityId = opp2.Id,
            Product2Id = product.Id,
            Quantity = 1,
            UnitPrice = 100,
            PricebookEntryId = pricebookEntry.Id
        );
        insert new List<OpportunityLineItem>{ oli1, oli2 };
        
        // Clone opportunities to simulate pre-update state.
        Opportunity oldOpp1 = opp1.clone(false, true, false, false);
        Opportunity oldOpp2 = opp2.clone(false, true, false, false);
        Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>{
            opp1.Id => oldOpp1,
            opp2.Id => oldOpp2
        };
        
        // Update opportunities to simulate an update trigger.
        opp1.StageName = OpportunityProcessor.LINEITEM_STAGENAME_CONTRACT;
        opp2.StageName = OpportunityProcessor.LINEITEM_STAGENAME_CONTRACT;
        opp2.Loss_Reasons__c = OpportunityProcessor.OPPORTUNITY_LOST_REASON_SOLD_TO_OTHER_PARTY;
        update new List<Opportunity>{ opp1, opp2 };
        
        // Re-query opportunities with updated fields.
        opp1 = [SELECT Id, StageName, Approval_Status__c , RecordTypeId FROM Opportunity WHERE Id = :opp1.Id];
        opp2 = [SELECT Id, StageName, Loss_Reasons__c ,Approval_Status__c , RecordTypeId FROM Opportunity WHERE Id = :opp2.Id];
        Map<Id, Opportunity> newMap = new Map<Id, Opportunity>{
            opp1.Id => opp1,
            opp2.Id => opp2
        };
        
        Test.startTest();
        OpportunityProcessor processor = new OpportunityProcessor(
            new List<Opportunity>{ opp1, opp2 }, oldMap, newMap, 'AFTER_UPDATE'
        );
        System.enqueueJob(processor);
        Test.stopTest();
        
        
    }
    
    @isTest
    static void testAfterInsert() {
        Account acc = new Account(Name = uniqueAccountName());
        insert acc;
        
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id,
            CM_Assigned__c = UserInfo.getUserId(),
            CRC_Assigned__c = UserInfo.getUserId()
        );
        insert opp;
        
        Test.startTest();
        OpportunityProcessor processor = new OpportunityProcessor(
            new List<Opportunity>{ opp }, null, null, 'AFTER_INSERT'
        );
        System.enqueueJob(processor);
        Test.stopTest();
    }
    
    @isTest
    static void testBeforeUpdate() {
        Account acc = new Account(Name = uniqueAccountName());
        insert acc;
        
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id,
            CM_Assigned__c = UserInfo.getUserId(),
            CRC_Assigned__c = UserInfo.getUserId()
        );
        insert opp;
        
        Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>{ opp.Id => opp.clone(false, true, false, false) };
        opp.StageName = 'Qualification';
        update opp;
        
        Test.startTest();
        OpportunityProcessor processor = new OpportunityProcessor(
            new List<Opportunity>{ opp }, oldMap, null, 'BEFORE_UPDATE'
        );
        System.enqueueJob(processor);
        Test.stopTest();
        
        Opportunity updatedOpp = [SELECT StageName FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals('Qualification', updatedOpp.StageName);
    }
    
    @isTest
    static void testBeforeInsert() {
        Account acc = new Account(Name = uniqueAccountName());
        insert acc;
        
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id,
            CM_Assigned__c = UserInfo.getUserId(),
            CRC_Assigned__c = UserInfo.getUserId()
        );
        
        Test.startTest();
        OpportunityProcessor processor = new OpportunityProcessor(
            new List<Opportunity>{ opp }, null, null, 'BEFORE_INSERT'
        );
        System.enqueueJob(processor);
        Test.stopTest();
    }
    
    // @isTest
    // static void testShareFiles() {
    //     Account acc = new Account(Name = uniqueAccountName());
    //     insert acc;
        
    //     Opportunity opp = new Opportunity(
    //         Name = 'Test Opportunity',
    //         StageName = 'Prospecting',
    //         CloseDate = Date.today().addDays(30),
    //         AccountId = acc.Id,
    //         CM_Assigned__c = UserInfo.getUserId(),
    //         CRC_Assigned__c = UserInfo.getUserId()
    //     );
    //     insert opp;
        
    //     Investment__c investment = new Investment__c(
    //         Opportunity__c = opp.Id, 
    //         Account__c = acc.Id
    //     );
    //     insert investment;
        
    //     // Create a file (ContentVersion) for the Opportunity.
    //     ContentVersion content = new ContentVersion(
    //         Title = 'Test File',
    //         PathOnClient = 'TestFile.pdf',
    //         VersionData = Blob.valueOf('Test File Content')
    //     );
    //     insert content;
        
    //     ContentDocumentLink contentLink = new ContentDocumentLink(
    //         ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :content.Id].ContentDocumentId,
    //         LinkedEntityId = opp.Id,
    //         ShareType = 'V',
    //         Visibility = 'AllUsers'
    //     );
    //     insert contentLink;
        
    //     // Update Opportunity to trigger file sharing logic.
    //     opp.StageName = 'Closed Won';
    //     update opp;
        
    //     Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>{ opp.Id => opp };
    //     Opportunity updatedOpp = [SELECT Id, StageName, Approval_Status__c FROM Opportunity WHERE Id = :opp.Id];
    //     Map<Id, Opportunity> newMap = new Map<Id, Opportunity>{ opp.Id => updatedOpp };
        
    //     OpportunityProcessor processor = new OpportunityProcessor(
    //         new List<Opportunity>{ opp }, oldMap, newMap, 'AFTER_UPDATE'
    //     );
        
    //     // Prevent recursion by forcing the static flag.
    //     OpportunityProcessor.emailsProcessed = true;
        
    //     Test.startTest();
    //     System.enqueueJob(processor);
    //     Test.stopTest();
        
    //     // Validate that file sharing created a new ContentDocumentLink on the Investment record.
    //     List<ContentDocumentLink> sharedFiles = [
    //         SELECT ContentDocumentId, LinkedEntityId
    //         FROM ContentDocumentLink
    //         WHERE LinkedEntityId = :investment.Id
    //     ];
    //     System.assertEquals(1, sharedFiles.size(), 'File should be shared with the Investment');
    //     System.assertEquals(contentLink.ContentDocumentId, sharedFiles[0].ContentDocumentId, 'Shared file should match the original file');
    // }
    
    @isTest
    static void testUpdateOpportunities() {
        Account acc = new Account(Name = uniqueAccountName());
        insert acc;
        
        Opportunity opp1 = new Opportunity(
            Name = 'Opportunity 1',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id,
            CM_Assigned__c = UserInfo.getUserId(),
            CRC_Assigned__c = UserInfo.getUserId()
        );
        insert opp1;
        
        Opportunity opp2 = new Opportunity(
            Name = 'Opportunity 2',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id,
            CM_Assigned__c = UserInfo.getUserId(),
            CRC_Assigned__c = UserInfo.getUserId()
        );
        insert opp2;
        
        Set<Id> oppIds = new Set<Id>{ opp1.Id, opp2.Id };
        
        Test.startTest();
        try {
            OpportunityProcessor.updateOpportunities(oppIds);
        } catch (Exception e) {
            System.assert(false, 'Exception during test execution: ' + e.getMessage());
        }
        Test.stopTest();
        
        List<Opportunity> updatedOpportunities = [SELECT StageName, Loss_Reasons__c FROM Opportunity WHERE Id IN :oppIds];
        for (Opportunity updatedOpp : updatedOpportunities) {
            System.assertEquals('Closed Lost', updatedOpp.StageName, 'StageName should be Closed Lost');
            System.assertEquals('Product Unavailable', updatedOpp.Loss_Reasons__c, 'Loss Reason should be Product Unavailable');
        }
    }
    
    @isTest
    static void testSendEmails() {
        Id vcRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('VC').getRecordTypeId();
        Account acc = new Account(Name = uniqueAccountName());
        insert acc;
        Contact con = new Contact(
            LastName = 'EmailTest ' + String.valueOf(System.currentTimeMillis()),
            Email = uniqueEmail(),
            AccountId = acc.Id
        );
        insert con;
        Opportunity opp = new Opportunity(
            Name = 'Email Test Opp',
            StageName = 'Application Received',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id,
            RecordTypeId = vcRecordTypeId,
            Related_Product_Code__c = 'NotTSF',
            Primary_Contact__c = con.Id,
            Amount = 1000,
            Donation__c = false,
            CM_Assigned__c = UserInfo.getUserId(),
            CRC_Assigned__c = UserInfo.getUserId()
        );
        insert opp;
        
        // Create a product and opportunity line item so that Invested_opp_prod_admin__c is set.
        Product2 prod = new Product2(
            Name = 'Email Test Product',
            IsActive = true,
            Tile_Banner__c = 'http://example.com/banner.png',
            Status__c = 'Available'
        );
        insert prod;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Product2Id = prod.Id,
            Quantity = 1,
            UnitPrice = 100,
            PricebookEntryId = pbe.Id
        );
        insert oli;
        
        // Update opp to set Invested_opp_prod_admin__c.
        opp.Invested_opp_prod_admin__c = oli.Id;
        update opp;
        
        // Reset the static flag so sendEmails runs.
        OpportunityProcessor.emailsProcessed = false;
        
        OpportunityProcessor processor = new OpportunityProcessor(
            new List<Opportunity>{ opp }, null, null, 'AFTER_UPDATE'
        );
        // Directly call sendEmails() rather than enqueuing.
        processor.sendEmails();
        
        Opportunity updatedOpp = [SELECT Bpay_Email_sent__c, TSF_receipt_email_sent__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(true, updatedOpp.Bpay_Email_sent__c, 'Bpay_Email_sent__c should be true after sending email.');
    }
    
    // @isTest
    // static void testOLICurrentValuesIpdate() {
    //     Account acc = new Account(Name = uniqueAccountName());
    //     insert acc;
    //     Opportunity opp = new Opportunity(
    //         Name = 'OLI Current Values Test',
    //         StageName = 'Closed Won',
    //         CloseDate = Date.today().addDays(30),
    //         AccountId = acc.Id,
    //         CM_Assigned__c = UserInfo.getUserId(),
    //         CRC_Assigned__c = UserInfo.getUserId()
    //     );
    //     insert opp;
        
    //     // Create an opportunity line item.
    //     Product2 prod = new Product2(
    //         Name = 'OLI Current Product',
    //         IsActive = true,
    //         Tile_Banner__c = 'http://example.com/banner.png',
    //         Status__c = 'Available'
    //     );
    //     insert prod;
    //     Id pricebookId = Test.getStandardPricebookId();
    //     PricebookEntry pbe = new PricebookEntry(
    //         Pricebook2Id = pricebookId,
    //         Product2Id = prod.Id,
    //         UnitPrice = 75,
    //         IsActive = true
    //     );
    //     insert pbe;
    //     OpportunityLineItem oli = new OpportunityLineItem(
    //         OpportunityId = opp.Id,
    //         Product2Id = prod.Id,
    //         Quantity = 3,
    //         UnitPrice = 75,
    //         PricebookEntryId = pbe.Id
    //     );
    //     insert oli;
        
    //     Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>{ opp.Id => new Opportunity(Id = opp.Id, StageName = 'Qualification') };
    //     Map<Id, Opportunity> newMap = new Map<Id, Opportunity>{ opp.Id => opp };
    //     OpportunityProcessor processor = new OpportunityProcessor(
    //         new List<Opportunity>{ opp }, oldMap, newMap, 'AFTER_UPDATE'
    //     );
    //     Test.startTest();
    //     System.enqueueJob(processor);
    //     Test.stopTest();
        
    //     OpportunityLineItem updatedOli = [SELECT Original_Invested_Quantity__c, Original_Sales_Price__c FROM OpportunityLineItem WHERE Id = :oli.Id];
    //     System.assertEquals(3, updatedOli.Original_Invested_Quantity__c, 'Original quantity should be 3.');
    //     System.assertEquals(75 * 3, updatedOli.Original_Sales_Price__c, 'Original sales price should be correctly calculated.');
    // }
    
    @isTest
    static void testUpdateChildOLIstatus() {
        Account acc = new Account(Name = uniqueAccountName());
        insert acc;
        Opportunity opp = new Opportunity(
            Name = 'Update Child OLI Status Test',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id,
            Approval_Status__c = 'Rejected', // valid starting value
            CM_Assigned__c = UserInfo.getUserId(),
            CRC_Assigned__c = UserInfo.getUserId()
        );
        insert opp;
        
        // Update Approval_Status__c to trigger child update.
        opp.Approval_Status__c = 'Completed';
        update opp;
        
        // Re-query the opportunity including Approval_Status__c.
        Opportunity queriedOpp = [SELECT Id, Approval_Status__c, StageName, Sub_Stage__c FROM Opportunity WHERE Id = :opp.Id];
        Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>{
            opp.Id => queriedOpp.clone(false, true, false, false)
        };
        Map<Id, Opportunity> newMap = new Map<Id, Opportunity>{ opp.Id => opp };
        
        Product2 prod = new Product2(
            Name = 'OLI Status Product',
            IsActive = true,
            Tile_Banner__c = 'http://example.com/banner.png',
            Status__c = 'Available'
        );
        insert prod;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 50,
            IsActive = true
        );
        insert pbe;
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Product2Id = prod.Id,
            Quantity = 2,
            UnitPrice = 50,
            PricebookEntryId = pbe.Id
        );
        insert oli;
        
        OpportunityProcessor processor = new OpportunityProcessor(
            new List<Opportunity>{ opp }, oldMap, newMap, 'AFTER_UPDATE'
        );
        Test.startTest();
        System.enqueueJob(processor);
        Test.stopTest();
        
        OpportunityLineItem updatedOli = [SELECT Approval_Status__c FROM OpportunityLineItem WHERE Id = :oli.Id];
        System.assertEquals('Completed', updatedOli.Approval_Status__c, 'OLI approval status should be updated to Completed.');
    }
    
    @isTest
    static void testUpdateProductStatusOnOpportunityClosure() {
        Account acc = new Account(Name = uniqueAccountName());
        insert acc;
        Opportunity opp = new Opportunity(
            Name = 'Test Update Product Status',
            StageName = 'Qualification',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id,
            CM_Assigned__c = UserInfo.getUserId(),
            CRC_Assigned__c = UserInfo.getUserId()
        );
        insert opp;
        
        // Re-query opp with required fields.
        opp = [SELECT Id, StageName, Approval_Status__c, RecordTypeId FROM Opportunity WHERE Id = :opp.Id];
        Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>{ opp.Id => opp.clone(false, true, false, false) };
        
        // Update Opportunity to change StageName to Contract.
        opp.StageName = OpportunityProcessor.LINEITEM_STAGENAME_CONTRACT;
        update opp;
        
        // Re-query opp to form newMap.
        opp = [SELECT Id, StageName, Approval_Status__c, RecordTypeId FROM Opportunity WHERE Id = :opp.Id];
        Map<Id, Opportunity> newMap = new Map<Id, Opportunity>{ opp.Id => opp };
        
        OpportunityProcessor processor = new OpportunityProcessor(
            new List<Opportunity>{ opp }, oldMap, newMap, 'AFTER_UPDATE'
        );
        
        // Create an OpportunityLineItem for product status update.
        Product2 prod = new Product2(
            Name = 'Status Update Product',
            IsActive = true,
            Tile_Banner__c = 'http://example.com/banner.png',
            Status__c = 'Available'
        );
        insert prod;
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = prod.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Product2Id = prod.Id,
            Quantity = 1,
            UnitPrice = 100,
            PricebookEntryId = pbe.Id
        );
        insert oli;
        
        Test.startTest();
        // Call updateProductStatusOnOpportunityClosure only once within a single test block.
        processor.updateProductStatusOnOpportunityClosure(newMap, oldMap);
        Test.stopTest();
    }

    @isTest    
    static void testShareFiles() {
        // Create test Account.
        Account acc = new Account(Name = 'Test Account ShareFiles ' + DateTime.now().getTime());
        insert acc;
        
        // Create test Opportunity.
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity ShareFiles',
            StageName = 'Application Received',  // Stage does not affect sharefiles directly.
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id,
            CM_Assigned__c = UserInfo.getUserId(),
            CRC_Assigned__c = UserInfo.getUserId()
        );
        insert opp;
        
        // Create an Investment__c record related to the Opportunity.
        Investment__c inv = new Investment__c(
            Opportunity__c = opp.Id,
            Account__c = acc.Id
        );
        insert inv;
        
        // Create a file by inserting a ContentVersion record.
        ContentVersion cv = new ContentVersion(
            Title = 'Test File ShareFiles',
            PathOnClient = 'TestFile.pdf',
            VersionData = Blob.valueOf('Test File Content')
        );
        insert cv;
        
        // Query the ContentVersion record to get its ContentDocumentId.
        ContentVersion contentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        
        // Query the ContentDocument using the ContentDocumentId from the ContentVersion.
        ContentDocument cd = [SELECT Id, Title FROM ContentDocument 
                              WHERE Id = :contentVersion.ContentDocumentId LIMIT 1];
        
        // Create a ContentDocumentLink that links the file to the Opportunity.
        ContentDocumentLink oppCDL = new ContentDocumentLink(
            ContentDocumentId = cd.Id,
            LinkedEntityId = opp.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert oppCDL;
        
        // At this point, the Opportunity has a file attached.
        // Calling sharefiles should detect the Investment__c record for the Opportunity and
        // create a new ContentDocumentLink record linking the same ContentDocument to the Investment.
        OpportunityProcessor.sharefiles(new List<Id>{ opp.Id });
        
        // Query for any new ContentDocumentLink records for the Investment.
        List<ContentDocumentLink> invCDLs = [SELECT Id, ContentDocumentId, LinkedEntityId 
                                              FROM ContentDocumentLink 
                                              WHERE LinkedEntityId = :inv.Id];
                                              
        System.assert(invCDLs.size() > 0, 'A ContentDocumentLink should have been created for the Investment record.');
        // Verify that the ContentDocumentId matches the one on the Opportunity.
        System.assertEquals(oppCDL.ContentDocumentId, invCDLs[0].ContentDocumentId, 'The shared file should match the original file.');
    }

}