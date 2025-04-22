@istest
public class ProdFileShare_batchTest {
    @istest
    static void testMethod1() {
        Test.startTest();
        Account acc = new Account();
        acc.name = 'Test Acount';
        insert acc;
        Id pricebookId = Test.getStandardPricebookId();               

        //Create Product
        Product2 oProduct = new Product2(name='Test');
        oProduct.Offer_Launch_Date__c = System.today().addDays(-4);
        insert oProduct;
        Id opprectypeId = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('VC').getRecordTypeId();
        Opportunity oppObj = new Opportunity();
        oppObj.name = 'Test1lname';
        oppObj.stageName = 'Application Received';
        oppObj.CRC_Assigned__c = UserInfo.getuserId();
        oppObj.CM_Assigned__c =  UserInfo.getuserId();
        date dt = System.today();
        dt = dt.addDays(5);
        oppObj.closedate = dt;
        oppObj.Amount = 50000;
        oppObj.recordtypeId = opprectypeId;
        oppObj.Related_Product_Code__c = 'opprectypeId';
        oppObj.AccountId = acc.Id;
        oppObj.Invested_Product_ADMIN_FIELD__c = oProduct.Id;
        insert oppObj;
        
        // Investment__c inv = new Investment__c();
        // inv.Account__c = acc.Id;
        // inv.Opportunity__c = oppObj.Id;
        // insert inv;
        ContentVersion content=new ContentVersion(); 
        content.Title='Monthly_Update'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        insert content;
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=oProduct.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'V';
        contentlink.Visibility = 'AllUsers';        
        insert contentlink;
        system.schedule('Test Territory Check', '0 0 23 * * ?', new ProdFileShare_batch());
        Test.stopTest();  
        
       
        
    }
}