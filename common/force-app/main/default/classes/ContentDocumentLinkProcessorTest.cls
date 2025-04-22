@isTest
public class ContentDocumentLinkProcessorTest {
    @isTest
    static void testExecute() {
        // Create test data
        Account account = new Account(Name = 'Test Account');
        insert account;
        
        Opportunity opportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            AccountId = account.Id
        );
        insert opportunity;
        
        Investment__c investment = new Investment__c(Opportunity__c = opportunity.Id, Account__c = account.Id);
        insert investment;

        // Insert a ContentVersion record
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDocument.pdf',
            VersionData = Blob.valueOf('Test content'),
            IsMajorVersion = true
        );
        insert contentVersion;

        // Retrieve the associated ContentDocumentId
        ContentVersion insertedContentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1];

        ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
            LinkedEntityId = opportunity.Id,
            ContentDocumentId = insertedContentVersion.ContentDocumentId,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert contentDocumentLink;

        Set<Id> contentDocumentLinkIds = new Set<Id>{contentDocumentLink.Id};

        // Execute the queueable
        Test.startTest();
        System.enqueueJob(new ContentDocumentLinkProcessor(contentDocumentLinkIds));
        Test.stopTest();

        // Verify that new ContentDocumentLink was created for the Investment__c record
        List<ContentDocumentLink> newLinks = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :investment.Id];
        System.assertEquals(1, newLinks.size());
        System.assertEquals(insertedContentVersion.ContentDocumentId, newLinks[0].ContentDocumentId);
    }

    @isTest
    static void testExecuteWithMultipleRecords() {
        // Create test data
        Account account = new Account(Name = 'Test Account');
        insert account;

        Opportunity opportunity1 = new Opportunity(
            Name = 'Test Opportunity 1',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            AccountId = account.Id
        );
        Opportunity opportunity2 = new Opportunity(
            Name = 'Test Opportunity 2',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            AccountId = account.Id
        );
        insert new List<Opportunity>{ opportunity1, opportunity2 };
        
        Investment__c investment1 = new Investment__c(Opportunity__c = opportunity1.Id, Account__c = account.Id);
        Investment__c investment2 = new Investment__c(Opportunity__c = opportunity2.Id, Account__c = account.Id);
        insert new List<Investment__c>{ investment1, investment2 };

        // Insert a ContentVersion record
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDocument.pdf',
            VersionData = Blob.valueOf('Test content'),
            IsMajorVersion = true
        );
        insert contentVersion;

        // Retrieve the associated ContentDocumentId
        ContentVersion insertedContentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1];

        ContentDocumentLink contentDocumentLink1 = new ContentDocumentLink(
            LinkedEntityId = opportunity1.Id,
            ContentDocumentId = insertedContentVersion.ContentDocumentId,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        ContentDocumentLink contentDocumentLink2 = new ContentDocumentLink(
            LinkedEntityId = opportunity2.Id,
            ContentDocumentId = insertedContentVersion.ContentDocumentId,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert new List<ContentDocumentLink>{ contentDocumentLink1, contentDocumentLink2 };

        Set<Id> contentDocumentLinkIds = new Set<Id>{ contentDocumentLink1.Id, contentDocumentLink2.Id };

        // Execute the queueable
        Test.startTest();
        System.enqueueJob(new ContentDocumentLinkProcessor(contentDocumentLinkIds));
        Test.stopTest();

        // Verify that new ContentDocumentLinks were created for the Investment__c records
        List<ContentDocumentLink> newLinks1 = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :investment1.Id];
        List<ContentDocumentLink> newLinks2 = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :investment2.Id];

        System.assertEquals(1, newLinks1.size());
        System.assertEquals(insertedContentVersion.ContentDocumentId, newLinks1[0].ContentDocumentId);

        System.assertEquals(1, newLinks2.size());
        System.assertEquals(insertedContentVersion.ContentDocumentId, newLinks2[0].ContentDocumentId);
    }
}