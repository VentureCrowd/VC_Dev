@isTest
public class FileUploadControllerTest {

    @testSetup
    static void setupTestData() {
        // Create a sample account for linking files
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Account accountNoFiles = new Account(Name = 'No files');
        insert accountNoFiles;
        
        // Create a sample ContentVersion
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'Test Document';
        contentVersion.PathOnClient = 'Test Document.pdf';
        contentVersion.VersionData = Blob.valueOf('Test Content');
        contentVersion.Form_Field__c = 'TestField';
        insert contentVersion;
        
        // Link the document to the account
        ContentDocumentLink docLink = new ContentDocumentLink();
        docLink.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId;
        docLink.LinkedEntityId = testAccount.Id;
        docLink.ShareType = 'V';
        docLink.Visibility = 'AllUsers';
        insert docLink;

        // Create a sample ContentDistribution
        ContentDistribution contentDistribution = new ContentDistribution();
        contentDistribution.ContentVersionId = contentVersion.Id;
        contentDistribution.Name = 'Test Distribution';
        insert contentDistribution;
    }

    @isTest
    static void testUploadFile() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        String base64Content = EncodingUtil.base64Encode(Blob.valueOf('Test Content'));

        Test.startTest();
        Id contentDocId = FileUploadController.uploadFile('Test Document', base64Content, testAccount.Id, 'Test_Field');
        Test.stopTest();

        System.assertNotEquals(null, contentDocId, 'ContentDocumentId should not be null');
    }

    @isTest
    static void testUploadFile_NoLink() {
        String base64Content = EncodingUtil.base64Encode(Blob.valueOf('Test Content'));

        Test.startTest();
        Id contentDocId = FileUploadController.uploadFile('Test Document', base64Content, null, 'Test_Field');
        Test.stopTest();

        System.assertNotEquals(null, contentDocId, 'ContentDocumentId should not be null');
    }

    @isTest
    static void testUploadFile_Exception() {
        try {
            FileUploadController.uploadFile(null, null, null, 'Test_Field');
            System.assert(false, 'Expected exception not thrown');
        } catch (Exception e) {
            System.assert(e instanceof IllegalArgumentException, 'Expected IllegalArgumentException');
        }
    }
   

    @isTest
    static void testDeleteFileById() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Id testDocId = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :testAccount.Id LIMIT 1].ContentDocumentId;

        Test.startTest();
        Boolean result = FileUploadController.deleteFileById(testDocId);
        Test.stopTest();

        System.assert(result, 'Expected true but got false');
        Integer count = [SELECT COUNT() FROM ContentDocument WHERE Id = :testDocId];
        System.assertEquals(0, count, 'ContentDocument should be deleted');
    }
    
    @isTest
    static void testDeleteFileById_Exception() {

        Id testDocId = 'aXXXX000000cXXXXXX';
        Test.startTest();
        Boolean result = FileUploadController.deleteFileById(testDocId);
       
        Test.stopTest();

        

        System.assertEquals(result, false);
    }
    
    

    @isTest
    static void testDeleteFileByName() {
        ContentVersion testDoc = [SELECT Id, Title FROM ContentVersion LIMIT 1];

        Test.startTest();
        Boolean result = FileUploadController.deleteFileByName(testDoc.Title);
        Test.stopTest();

        System.assert(result, 'Expected true but got false');
        Integer count = [SELECT COUNT() FROM ContentDocument WHERE Title = :testDoc.Title];
        System.assertEquals(0, count, 'ContentDocument should be deleted');
    }

    @isTest
    static void testGetFilesByFieldName() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        List<Map<String, Object>> filesList;

        Test.startTest();
        filesList = FileUploadController.getFilesByFieldName('Test_Field', testAccount.Id);
        Test.stopTest();

        System.assertNotEquals(null, filesList, 'Files list should not be null');
    }

    @isTest
    static void testGetFilesByNameWithoutExtension() {
        List<Map<String, Object>> filesList;

        Test.startTest();
        filesList = FileUploadController.getFilesByNameWithoutExtension('Test Document');
        Test.stopTest();

        System.assertNotEquals(null, filesList, 'Files list should not be null');
        System.assert(filesList.size() > 0, 'Files list should not be empty');
    }

    @isTest
    static void testGetPublicImageUrl() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        String url = FileUploadController.getPublicImageUrl(testAccount.Id);
        Test.stopTest();

        System.assertNotEquals(null, url, 'URL should not be null');
        System.assert(url.contains('force.com'), 'URL should be a valid Salesforce URL');
    }

    @isTest
    static void testgetDocumentsUrl() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        List<Map<String, Object>> result = FileUploadController.getDocumentsUrl('TestField', testAccount.Id);
        Test.stopTest();

        // Check that the result is not null or empty
        System.assertNotEquals(null, result, 'Result should not be null');

        // Validate the structure and content of the first map in the result list
        Map<String, Object> firstEntry = result[0];
        System.assert(firstEntry.containsKey('fileName'), 'Result entry should contain fileName');
        System.assert(firstEntry.containsKey('publicDownloadUrl'), 'Result entry should contain publicDownloadUrl');
        System.assertNotEquals(null, firstEntry.get('fileName'), 'fileName should not be null');
        System.assertNotEquals(null, firstEntry.get('publicDownloadUrl'), 'publicDownloadUrl should not be null');
        System.assert(((String)firstEntry.get('publicDownloadUrl')).contains('force.com'), 'URL should be a valid Salesforce URL');
    }

    @isTest
    static void testLinkContentDocument() {
        // Retrieve test data
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        ContentVersion contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];

        // Call the method and get the result
        Test.startTest();
        Id linkId = FileUploadController.linkContentDocument(contentVersion.ContentDocumentId, testAccount.Id);
        Test.stopTest();

        // Verify the ContentDocumentLink was created
        ContentDocumentLink createdLink = [SELECT Id, ContentDocumentId, LinkedEntityId, ShareType, Visibility FROM ContentDocumentLink WHERE Id = :linkId];
        System.assertNotEquals(null, createdLink, 'ContentDocumentLink should be created');
        System.assertEquals(contentVersion.ContentDocumentId, createdLink.ContentDocumentId, 'ContentDocumentId should match');
        System.assertEquals(testAccount.Id, createdLink.LinkedEntityId, 'LinkedEntityId should match');
        System.assertEquals('V', createdLink.ShareType, 'ShareType should be Viewer');
        System.assertEquals('AllUsers', createdLink.Visibility, 'Visibility should be AllUsers');

        // Verify the ContentDistribution was created
        ContentDistribution createdDistribution = [SELECT Id, ContentVersionId, Name, PreferencesAllowViewInBrowser, PreferencesLinkLatestVersion FROM ContentDistribution WHERE ContentVersionId = :contentVersion.Id];
        System.assertNotEquals(null, createdDistribution, 'ContentDistribution should be created');
        System.assertEquals(contentVersion.Id, createdDistribution.ContentVersionId, 'ContentVersionId should match');
        System.assertEquals(true, createdDistribution.PreferencesAllowViewInBrowser, 'PreferencesAllowViewInBrowser should be true');
        System.assertEquals(true, createdDistribution.PreferencesLinkLatestVersion, 'PreferencesLinkLatestVersion should be true');
    }

    @isTest
    static void testGetFilesByFileNameSuccess() {
        // Arrange: Fetch test Account and ensure that the file with "FY" in the title exists
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        // Act: Call the method getFilesByFileName with a valid fileName and account record ID
        List<Map<String, Object>> result = FileUploadController.getFilesByFileName(testAccount.Id, 'Document', false);
        Test.stopTest();

        // Assert: Validate that the result contains the expected file data
        System.assertNotEquals(null, result, 'The result should not be null.');
        System.assertNotEquals(0, result.size(), 'The result should contain at least one file.');
    }

    @isTest
    static void testGetFilesByFileNameEmptyResult() {
        // Arrange: Fetch test Account and call with a non-existing file name
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        // Act: Call the method getFilesByFileName with a non-matching fileName
        List<Map<String, Object>> result = FileUploadController.getFilesByFileName(testAccount.Id, 'NonExistingFile', false);
        Test.stopTest();

        // Assert: Validate that the result is empty as no matching file should be found
        System.assertEquals(0, result.size(), 'The result should be empty for a non-matching file name.');
    }

    @isTest
    static void testGetFilesByRecordSuccess() {
        // Arrange: Fetch the test Account with linked ContentDocument
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        // Act: Call the method getFilesByRecord with a valid account record ID
        List<Map<String, Object>> result = FileUploadController.getFilesByRecord(testAccount.Id);
        Test.stopTest();

        // Assert: Validate that the result contains the expected file data
        System.assertNotEquals(null, result, 'The result should not be null.');
        System.assertNotEquals(0, result.size(), 'The result should contain at least one file.');
        System.assert(result[0].containsKey('FileName'), 'Each entry should contain the FileName key.');
        System.assert(result[0].containsKey('PublicDownloadUrl'), 'Each entry should contain the PublicDownloadUrl key.');
    }

    @isTest
    static void testGetFilesByRecordNoFiles() {
        // Arrange: Create a new Account without linked ContentDocuments
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'No files' LIMIT 1];


        Test.startTest();
        // Act: Call the method getFilesByRecord for an Account with no linked files
        List<Map<String, Object>> result = FileUploadController.getFilesByRecord(testAccount.Id);
        Test.stopTest();

        // Assert: Validate that the result is an empty list
        System.assertNotEquals(null, result, 'The result should not be null.');
        System.assertEquals(0, result.size(), 'The result should be empty as no files are linked.');
    }

}