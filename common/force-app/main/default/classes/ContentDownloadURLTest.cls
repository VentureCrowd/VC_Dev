@IsTest(SeeAllData=true)
public class ContentDownloadURLTest {
    
    /*
 	 * Test method for the getSalesforceFilesDownloadUrlsTest utility method.
     * 
 	 * Test class for the ContentDownloadURL class to validate the getSalesforceFilesDownloadUrls method.
     */
    @isTest
    static void getSalesforceFilesDownloadUrlsTest() {
        Test.startTest();
		// Prepare test data using a test data factory method
        TestDataFactory.dataForContentDownloadURL();
        
        // Query the EOI record created by the test data factory
       	List<EOI__c> lstOfEOI = [Select Id from EOI__c where Name= 'Test Eoi record' ];

        // Create a ContentVersion record
        ContentVersion version = new ContentVersion(
            Title = 'Test Document',
            VersionData = Blob.valueOf('Test file content'),
			PathOnClient = 'test-document.txt' 
        );
        insert version;
        
        // Query the ContentVersion record for getting an Id, Title & ContentDocumentId
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                            FROM ContentVersion WHERE Id = :version.Id LIMIT 1];
        
        // Create a ContentVersion associated with the ContentDocument
        ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = lstOfEOI[0].id;
            contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
            contentlink.ShareType = 'V';
            insert contentlink;
        Test.stopTest();
        
        
        
        
        
        // Call the method being tested
        List<ContentDownloadURL.FileDownloadUrl> result = ContentDownloadURL.getSalesforceFilesDownloadUrls(lstOfEOI[0].Id);

        // Assertions for Positive Test scenario
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(1, result.size(), 'There should be one FileDownloadUrl in the result');

        //Verifies data inside fileDownloadUrl.title & fileDownloadUrl.contentDownloadURL
        ContentDownloadURL.FileDownloadUrl fileDownloadUrl = result[0];
        System.assertEquals('Test Document', fileDownloadUrl.title, 'Title should match');
        System.assertNotEquals(null, fileDownloadUrl.contentDownloadURL, 'ContentDownloadURL should not be null');
        
        // Assertions for Catch Block Test scenario
        List<ContentDownloadURL.FileDownloadUrl> resultForCatchBlock = ContentDownloadURL.getSalesforceFilesDownloadUrls(lstOfEOI[0].Id);
        System.assertEquals(0, resultForCatchBlock.size(), 'ContentDownloadURL should be throw an error');
        
        // Assertions for Negative Test scenario
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Ventures Company Account').getRecordTypeId();
        List<ContentDownloadURL.FileDownloadUrl> resultForNegativeTesting = ContentDownloadURL.getSalesforceFilesDownloadUrls(devRecordTypeId);
        System.assertEquals(0, resultForNegativeTesting.size(), 'ContentDownloadURL should be zero');
    }
}