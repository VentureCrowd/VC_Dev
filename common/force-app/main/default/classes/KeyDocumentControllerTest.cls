/**

**/
@isTest
public with sharing class KeyDocumentControllerTest {
    @IsTest
    static void retrieveFiles(){

        Account acct = new Account(Name='TEST_ACCT');
        insert acct;
        
        ContentVersion contentVersion = new ContentVersion(
          Title = 'Penguins',
          PathOnClient = 'Penguins.jpg',
          VersionData = Blob.valueOf('Test Content'),
          IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
        ];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = acct.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        cdl.visibility = KeyDocumentController.VISIBILITY_ALL_USERS;
        insert cdl;
        
        Test.startTest();
        List<KeyDocumentController.KeyDocumentWrapper> lstKeyDocumentWrapper =  KeyDocumentController.retrieveRelatedFiles(acct.id);
        Test.stopTest();

        System.assert(!lstKeyDocumentWrapper.isEmpty());
        
    }
}