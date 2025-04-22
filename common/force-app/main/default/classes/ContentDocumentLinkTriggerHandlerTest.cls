@isTest
public class ContentDocumentLinkTriggerHandlerTest {
    @isTest
    static void testAfterInsert() {
        // Create test data
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Opportunity opp = new Opportunity(Name = 'Test Opportunity', AccountId = acc.Id, CloseDate = Date.today(), StageName = 'Prospecting');
        insert opp;

        // Insert Investment__c linked to Opportunity
        Investment__c investment = new Investment__c(Opportunity__c = opp.Id, Account__c =acc.Id );
        insert investment;

        // Insert ContentVersion to implicitly create ContentDocument
        ContentVersion contentVer = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestPath',
            VersionData = Blob.valueOf('Test Data')
        );
        insert contentVer;

        // Retrieve the ContentDocumentId from the inserted ContentVersion
        ContentVersion insertedContentVer = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVer.Id LIMIT 1];

        ContentDocumentLink cdl = new ContentDocumentLink(
            LinkedEntityId = opp.Id,
            ContentDocumentId = insertedContentVer.ContentDocumentId,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );

        Test.startTest();
        insert cdl;
        Test.stopTest();

        // Verify that the ContentDocumentLink was created for the Investment__c record
        List<ContentDocumentLink> contentDocumentLinks = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId = :insertedContentVer.ContentDocumentId];

        // Verify the log message
        Log_Message__c logEntry = [SELECT Id, Application__c, Source__c, Source_Function__c, log_message__c, Type__c FROM Log_Message__c WHERE Source_Function__c = 'afterInsert' LIMIT 1];
        System.assertEquals('RaiseApp', logEntry.Application__c, 'Application should match');
        System.assertEquals('ContentDocumentLinkTriggerHandler', logEntry.Source__c, 'Source should match');
        System.assertEquals('afterInsert', logEntry.Source_Function__c, 'Source function should match');
        System.assertEquals('Info', logEntry.Type__c, 'Type should be Info');
    }
}