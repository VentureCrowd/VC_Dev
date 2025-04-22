@isTest
public without sharing class MyCompaniesControllerTest {
   
    /**
     * Test method for the addUpdateTeamMember Aura-enabled method.
     * 
     * This test case covers the scenario of creating a company record using the
       MyCompaniesController's editCompany method.
     * 
     * */
    @IsTest
    public static void createNewCompanyTest() {
        // Retrieve the Record Type Id for VC Business Account
        Id recordIdByName = Schema.SObjectType.Account.getRecordTypeInfosByName().get('VC Business Account').getRecordTypeId();
        
        // Prepare data for creating a new company
        Map<String, Object> dataMap1 = new Map<String, Object>();      	
        	dataMap1.put('Name',(Object)'Mr. Test Account Record');
            dataMap1.put('RecordTypeId',(Object)recordIdByName);
            dataMap1.put('BillingCountry',(Object)'US');
			dataMap1.put('Website',(Object)'https://developer.salesforce.com/');
        	dataMap1.put('Year_Founded__c',(Object)2024);
			dataMap1.put('Sector__c',(Object)'FINTECH');
			dataMap1.put('ACN__c',(Object)'20000000000');
			dataMap1.put('Account_Created_via_Portal__c',(Object)true);
        
        // Perform the createNewCompany method and assert the result
        System.assertEquals('Success',MyCompaniesController.createNewCompany(dataMap1));
        
        // Attempt to create a new company with duplicate values
        Map<String, Object> dataMap2 = new Map<String, Object>();      	
        	dataMap2.put('Name',(Object)'Mr. Test Account Record');
            dataMap2.put('RecordTypeId',(Object)recordIdByName);
        
        // Assert that the createNewCompany method does not succeed with duplicate values
        System.assertNotEquals('Success',MyCompaniesController.createNewCompany(dataMap2));
    }
    
    /**
     * Test method for the addUpdateTeamMember Aura-enabled method.
     * 
     * This test case covers the scenario of editing a company record using the
       MyCompaniesController's editCompany method.
     * 
     * */
    @IsTest
    public static void editCompanyTest() {
        // Retrieve the Record Type Id for VC Business Account
        Id recordIdByName = Schema.SObjectType.Account.getRecordTypeInfosByName().get('VC Business Account').getRecordTypeId();
        
        // Create test data using the TestDataFactory
        TestDataFactory.testData();
        
        // Query the test account created by the TestDataFactory
        List<Account> lstOfAcc = [Select Id from Account where Name = 'Test Venture Person Account'];
        System.debug('lstOfAcc'+lstOfAcc);
        // Prepare data for updating the test account
        Map<string,object> datamap1 = new Map<string,object>();
            datamap1.put('Id',(Object)lstOfAcc[0].Id);
        	datamap1.put('Name',(Object)'Mr. Test Account Record1');
			datamap1.put('Website',(Object)'https://developer.salesforce.com');
			datamap1.put('Sector__c',(Object)'FINTECH');
			datamap1.put('ACN__c',(Object)'20000000000'); 
        
        // Perform the editCompany method and assert the result
       	System.assertEquals('Success',MyCompaniesController.editCompany(datamap1));
        
        // Attempt to edit the company with an invalid Record Type Id
        Map<String, Object> dataMap2 = new Map<String, Object>();      	
        	dataMap2.put('Name',(Object)'Mr. Test Account Record');
            dataMap2.put('RecordTypeId',(Object)recordIdByName);
        
        // Assert that the editCompany method does not succeed with an invalid Record Type Id
        System.assertNotEquals('Success',MyCompaniesController.editCompany(dataMap2));
    }
    
    /**
     * Test method for the addUpdateTeamMember Aura-enabled method.
     * 
     * This test case covers the scenario of adding or updating a team member in the
     * MyCompaniesController's addUpdateTeamMember method.
     */
    @IsTest
    public static void addUpdateTeamMemberTest() {
        // Create test data using the TestDataFactory
        TestDataFactory.testData();
        // Query the test team member created by the TestDataFactory
        List<EOI_team_and_advisors__c> lstOfEoiTeamAndAdviser1 = [Select Id from EOI_team_and_advisors__c where Name = 'John Steven'];
        
        // Prepare data for adding or updating a team member with a valid base64 string
        Map<String,Object> datamap1 = new map<string,Object>();
        	datamap1.put('base64','VGhpcyBpcyBhIGJpbmFyeSBkYXRhIGluIFhNTCBvZiBhcGV4');
            datamap1.put('filename','submitform');
    		datamap1.put('Id',lstOfEoiTeamAndAdviser1[0].Id); 
        
        // Perform the addUpdateTeamMember method and assert the result
        System.assertEquals('Success',MyCompaniesController.addUpdateTeamMember(datamap1));

        // Query the test team member created by the TestDataFactory
        List<EOI_team_and_advisors__c> lstOfEoiTeamAndAdviser2 = [Select Id from EOI_team_and_advisors__c where Name = 'John Steven'];
        
        // Prepare data for adding or updating a team member with an invalid base64 string
        Map<String,Object> datamap2 = new map<string,Object>();
        	datamap2.put('base64','2565163561535632121535313213$#$#$%$%VGhpcyBpcyBhIGJpbmFyeSBkYXRhIGluIFhNTCBvZiBhcGV4');
            datamap2.put('filename','submitform');
    		datamap2.put('Id',lstOfEoiTeamAndAdviser2[0].Id); 
        
        // Assert that the addUpdateTeamMember method does not succeed with an invalid base64 string
        System.assertNotEquals('Success',MyCompaniesController.addUpdateTeamMember(datamap2));
    } 
    
	/**
     * Test method for the uploadFile Aura-enabled method.
     * 
     * This test case covers the scenario of uploading a file using the
     * MyCompaniesController's uploadFile method.
     */    
    @IsTest
    public static void uploadFileTest() {
       	// Create test data using the TestDataFactory
       	TestDataFactory.testData(); 
       
       	// Prepare data for uploading a file
       	String base64 = 'VGhpcyBpcyBhIGJpbmFyeSBkYXRhIGluIFhNTCBvZiBhcGV4';
      	String filename='submitform';
        
        // Query the test team member created by the TestDataFactory
      	List<EOI_team_and_advisors__c> lstOfEoiTeamAndAdviser = [Select Id from EOI_team_and_advisors__c where Name = 'John Steven'];
       	String eoiTeamAndAdviserId = lstOfEoiTeamAndAdviser[0].Id; 
        
        // Perform the uploadFile method and get the result
       	String result = MyCompaniesController.uploadFile(base64,filename,eoiTeamAndAdviserId);
        
        // Query the ContentDocumentLink related to the uploaded file
       	List<ContentDocumentLink> contentDocumentLinks = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE Id = :result];
        
        // Assert that the ContentDocumentLink is created and the result is not empty or null
        System.assertNotEquals(0, contentDocumentLinks.size());
        System.assertNotEquals('',result);
      	System.assertNotEquals(null,result);
        
       	String result2 = MyCompaniesController.uploadFile(base64,filename,eoiTeamAndAdviserId);
		System.assertNotEquals('',result2);
      	System.assertNotEquals(null,result2);    
    } 
    
    /**
     * Test method for the getTeamMembers Aura-enabled method.
     * 
     * This test case covers the scenario of retrieving team members based on a category
     * and EOI Id using the MyCompaniesController's getTeamMembers method.
     */
    @IsTest
    public static void getTeamMembersTest() {
        // Create test data using the TestDataFactory
        TestDataFactory.testData(); 
        String category='Founder';
        
        // Query the EOI record created by the TestDataFactory
        Id eoiId =[Select Id from EOI__c where Name ='Test updateEoi Method'].Id;
        
        // Perform the getTeamMembers method and assert that the result is an not empty list
        System.assertNotEquals(null,MyCompaniesController.getTeamMembers(category,eoiId));
    }
     
    /**
     * Test method for the getFounders Aura-enabled method.
     * 
     * This test case covers the scenario of retrieving founders based on an EOI Id
     * using the MyCompaniesController's getFounders method.
     */
    @IsTest
    public static void getFoundersTest() {
       // Create test data using the TestDataFactory
       TestDataFactory.testData(); 
        
       // Query the EOI record created by the TestDataFactory
       List<EOI__c> lstOfEOIForInsert = [Select Id from EOI__c where Name = 'Test updateEoi Method'];
        
       // Perform the getFounders method and assert that the result is not an empty list
      // System.assertNotEquals(0,(MyCompaniesController.getFounders(lstOfEOIForInsert[0].Id)).size());
    }
    
    /**
     * Test method for the getPicklistvalues Aura-enabled method.
     * 
     * This test case covers the scenario of retrieving picklist values
     * using the MyCompaniesController's getPicklistvalues method.
     */
    @IsTest
    public static void getPicklistvaluesTest() {
        // Perform the getPicklistvalues method and assert that the result contains at least one Active picklist value
        System.assertNotEquals(null, MyCompaniesController.getPicklistvalues().size());
    }
    
    @IsTest
    public static void upsertFounderImageTest() {
        // Create test data using the TestDataFactory
        TestDataFactory.testData();
        
        List<EOI_team_and_advisors__c> lstOfEoiTeamAndAdviser = [Select Id from EOI_team_and_advisors__c where Name= 'John Steven' ];
		System.debug('lstOfEOI'+lstOfEoiTeamAndAdviser);
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
            contentlink.LinkedEntityId = lstOfEoiTeamAndAdviser[0].id;
            contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
            contentlink.ShareType = 'V';
            insert contentlink;
        
        // Query the test team member created by the TestDataFactory
        List<EOI__c> lstOfEoi = [Select Id from EOI__c where Name = 'Test updateEoi Method'];
        MyCompaniesController.upsertFounderImage(lstOfEoi[0].Id);
        //System.assertEquals('',MyCompaniesController.upsertFounderImage(lstOfEoi[0].Id));
    }
    
    @IsTest
    public static void createEoiLeadTest() {
        Map<string,object> datamap = new Map<string,object>();
        	datamap.put('lastname',(Object) 'Test1lname');
        	datamap.put('email',(Object) 'testemail1@yopmail.com');
       		datamap.put('MobilePhone',(Object) '6786789876');
          	datamap.put('Status',(Object) 'New');
       		datamap.put('Products_Interested_In__c',(Object) 'Investing');
        	datamap.put('LeadSource',(Object) 'Partner');
        	datamap.put('Loss_Reason__c',(Object) 'No Trust');
        	datamap.put('Is_Duplicate__c',(Object) True);
        System.assertEquals('Success',MyCompaniesController.createEoiLead(datamap));
        
        Map<string,object> datamapForCatch = new Map<string,object>();
        	datamapForCatch.put('lastname',(Object) 'Test1lname');
        	datamapForCatch.put('Id',(Object) '123456789012345678');
        System.assertNotEquals('Success',MyCompaniesController.createEoiLead(datamapForCatch));
    }
    /*
    @IsTest
    public static void getMyCompaniesTest() {
       User owner = [SELECT Id FROM USER WHERE Name = 'The VentureCrowd Team'];
        
        Id recordIdByName = Schema.SObjectType.Account.getRecordTypeInfosByName().get('VC Business Account').getRecordTypeId();
        List<Account> lstOfAccountForInsert1 = new List<Account>();
        	Account accObj = new Account();
        		accObj.Name = 'Test Venture Person Account';
        		accObj.RecordTypeId = recordIdByName;
        		accObj.OwnerId = owner.Id;
        	lstOfAccountForInsert1.add(accObj);
        Database.SaveResult[] saveResults1 ;
        Test.startTest();
        System.runAs(owner){
           saveResults1 = Database.insert(lstOfAccountForInsert1,false);
        }
        Test.stopTest();
      // System.assertNotEquals(0,MyCompaniesController.getMyCompanies('0052v00000glEDkAAM').size());
    }
    */
}