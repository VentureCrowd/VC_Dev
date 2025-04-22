@isTest
public class FileSharingProductObjTest {
    @isTest
    static void testShareFileWithInvestments() {
        Test.startTest();
        
        // Create a test account
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        // Create a test product
        Product2 product = new Product2(Name = 'Test Product');
        insert product;
        
        // Create a test opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id,
            Invested_Product_ADMIN_FIELD__c = product.Id
        );
        insert opp;
        
        // Create a test investment linked to the opportunity
        Investment__c investment = new Investment__c(
            Opportunity__c = opp.Id,
            Account__c = acc.id
        );
        
        insert investment;
        
        // Create a test content version and link it to the product
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Monthly_Update',
            PathOnClient = 'Monthly_Update.jpg',
            VersionData = Blob.valueOf('Test Content'),
            Origin = 'H'
        );
        insert contentVersion;
        
        
        // Link the content document to the product
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
            LinkedEntityId = product.Id,
            ContentDocumentId = [SELECT contentdocumentid FROM contentversion WHERE id =: contentVersion.id].contentdocumentid,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert contentDocumentLink;
        
        // Create flow input data
        FileSharingProductObj.FlowInputs flowInput = new FileSharingProductObj.FlowInputs();
        flowInput.uploadedFileId = contentDocumentLink.Id;
        flowInput.productId = product.Id;
        
        List<FileSharingProductObj.FlowInputs> inputs = new List<FileSharingProductObj.FlowInputs>{ flowInput };
        
        // Invoke the invocable method
        FileSharingProductObj.shareFileWithInvestments(inputs);
        
        Test.stopTest();
        
        // Verify the new content document links were created for the investment
        List<ContentDocumentLink> newContentLinks = [
            SELECT Id, LinkedEntityId, ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :investment.Id
        ];
        
        System.assertEquals(1, newContentLinks.size(), 'A content document link should have been created for the investment.');
        // System.assertEquals(contentDocument.ContentDocumentId, newContentLinks[0].ContentDocumentId, 'The content document link should match the original content document ID.');
    }
}