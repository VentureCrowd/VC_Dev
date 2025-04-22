@IsTest
public class MyEOIControllerTest {
    
    @TestSetup 
    static void setup() {
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
        
        
        List<EOI__c> lstOfEOIForInsert = new List<EOI__c>();
        EOI__c eoiObj = new EOI__c();
        	eoiObj.Name = 'Test updateEoi Method';
        	eoiObj.Account__c = saveResults1[0].getId();
        	eoiObj.EOI_Status__c = 'Not Published';
          eoiObj.Internal_Owner__c = owner.Id;
        	eoiObj.Related_Person_Account__c = saveResults1[0].getId();
          eoiObj.One_liner_about_business__c = 'Innovative business idea';
          eoiObj.EOI_Title__c = 'Exciting EOI Title';
        lstOfEOIForInsert.add(eoiObj);
        
        Database.SaveResult[] saveResults2 ;
        System.runAs(owner){
           saveResults2 = Database.insert(lstOfEOIForInsert,false);
        }
        Test.stopTest();
    }

    /**
      * Test method for the updateEoi Aura-enabled method in the MyEOIController.
      * 
      * This test case covers the scenario of updating an EOI record status using the
      * MyEOIController's updateEoi method.
      */
    @IsTest
    static void updateEoiTest(){
        // Query the EOI record created by the TestSetup
        List<EOI__c> lstOfEOI = [Select Id from EOI__c where Name = :'Test updateEoi Method'];
        
        // Prepare data for updating the EOI record status
        Map<string,object> datamap = new Map<string,object>();
        	datamap.put('Id',lstOfEOI[0].Id);
        	datamap.put('EOI_Status__c','Submitted to be Published');
        Id eoiId = lstOfEOI[0].Id;
        
        // Perform the updateEoi method and assert the result
        System.assertEquals('Success',MyEOIController.updateEoi(datamap,eoiId));
        
        // Attempt to update the EOI with an empty Id
        datamap.put('Id','');
        
        // Retrieve the Record Type Id for VC Business Account
        Id recordIdByName = Schema.SObjectType.Account.getRecordTypeInfosByName().get('VC Business Account').getRecordTypeId();
        String result = MyEOIController.updateEoi(datamap,recordIdByName);
        
        // Perform the updateEoi method with an empty Id and assert that it does not return 'Success'
        System.assertNotEquals('Success',result); 
    }
    
    /**
      * Test method for the getEoiDetails Aura-enabled method in the MyEOIController.
      * 
      * This test case covers the scenario of retrieving EOI details using the
      * MyEOIController's getEoiDetails method.
      */
    @IsTest
    static void getEoiDetailsTest() {
      		// Query the EOI record created by the TestSetup
            List<EOI__c> lstOfEOI = [Select Id from EOI__c where Name = :'Test updateEoi Method'];
            Id eoiId = lstOfEOI[0].Id;
          
          	// Assert that the returned SObjectType matches the expected SObjectType
            System.assertEquals(Schema.EOI__c.getSObjectType(),(MyEOIController.getEoiDetails(eoiId)).getSObjectType());
            
          	// Attempt to retrieve EOI details with an invalid Id and assert that it does not return 'Success'
            String objectName = 'Account';
            String recordTypeLabel = 'VC Business Account';
          	String excpectedRecordId = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByName().get(recordTypeLabel).getRecordTypeId();
            try{
                MyEOIController.getEoiDetails(excpectedRecordId);
            }catch(Exception e){
                System.assertNotEquals('Success',e.getMessage());
            }
        }
    
     /**
      * Test method for the addUpdateTeamMember Aura-enabled method in the MyEOIController.
      * 
      * This test case covers the scenario of adding or updating a team member in the
      * MyEOIController's addUpdateTeamMember method.
      */

    @IsTest
    static void addUpdateTeamMemberTest() {
		// Query the EOI record created by the TestSetup
        List<EOI__c> lstOfEOI = [Select Id from EOI__c where Name = :'Test updateEoi Method'];
        Id eoiId = lstOfEOI[0].Id;  
        
        // Prepare data for adding or updating a team member with valid information
        Map<string,object> datamap = new Map<string,object>();
        		datamap.put('Name','John Steven');
        		datamap.put('Category__c','Founder');
        		datamap.put('Member_Role__c','Founder & CEO');
        		datamap.put('Team_Member_Description__c','john is an Accredited Practicing Dietitian');
        		datamap.put('Team_member_Linkedin__c','https://www.linkedin.com/');
        		datamap.put('Team_Related_EOI__c',eoiId);
        
        // Perform the addUpdateTeamMember method and assert the result
        System.assertEquals('Success',MyEOIController.addUpdateTeamMember(datamap));
        
        // Attempt to add or update a team member with an invalid EOI Id and assert that it does not return 'Success'
        Id recordIdByName = Schema.SObjectType.Account.getRecordTypeInfosByName().get('VC Business Account').getRecordTypeId();
        datamap.put('Team_Related_EOI__c',recordIdByName);
        System.assertNotEquals('Success',MyEOIController.addUpdateTeamMember(datamap));
    }
    
   /**
	 * Test method for the getTeamMembers Aura-enabled method in the MyEOIController.
 	* 
 	* This test case covers the scenario of retrieving team members based on a category
 	* and EOI Id using the MyEOIController's getTeamMembers method.
 	*/
    @IsTest
    static void getTeamMembersTest(){
        // Query the test user 
        User owner = [SELECT Id FROM USER WHERE Name = 'The VentureCrowd Team'];
        
        // Query the EOI record created by the TestSetup
        List<EOI__c> lstOfEOI = [Select Id from EOI__c where Name = :'Test updateEoi Method'];
        Id eoiId = lstOfEOI[0].Id;     
        
        // Prepare data for creating a team member related to the EOI record
		List<EOI_team_and_advisors__c> lstOfEoiTeamAndAdviser = new List<EOI_team_and_advisors__c>();
        	EOI_team_and_advisors__c eoiTeamAndAdviser = new EOI_team_and_advisors__c();
    			eoiTeamAndAdviser.put('Name','John Steven');
        		eoiTeamAndAdviser.put('Category__c','Founder');
        		eoiTeamAndAdviser.put('Member_Role__c','Founder & CEO');
        		eoiTeamAndAdviser.put('Team_Member_Description__c','john is an Accredited Practicing Dietitian');
        		eoiTeamAndAdviser.put('Team_member_Linkedin__c','https://www.linkedin.com/');
        		eoiTeamAndAdviser.put('Team_Related_EOI__c',eoiId);
        lstOfEoiTeamAndAdviser.add(eoiTeamAndAdviser);
        
        // Insert the team member data
        Test.startTest();
        System.runAs(owner){
         Database.SaveResult[] saveResults3 = Database.insert(lstOfEoiTeamAndAdviser,false);
        }
        Test.stopTest();
        
        // Prepare data for testing the getTeamMembers method
        String category = 'Founder';
        Id teamRelatedEOI = lstOfEOI[0].Id;
        
        // Assert that the getTeamMembers method returns the expected number of team members
        System.assertEquals(1,(MyEOIController.getTeamMembers(category,teamRelatedEOI)).size());
        
        // Assert that the getTeamMembers method returns null for an empty category
        System.assertEquals(null,MyEOIController.getTeamMembers('',teamRelatedEOI));
    }

    /**
 	  * Test method for the addUpdateLeadInvestor Aura-enabled method in the MyEOIController.
 	  * 
	  * This test case covers the scenario of adding or updating a lead investor related to an EOI
 	  * using the MyEOIController's addUpdateLeadInvestor method.
 	  */
    @IsTest
    static void addUpdateLeadInvestorTest(){
        // Query the EOI record created by the Test
        List<EOI__c> lstOfEOI = [Select Id from EOI__c where Name = :'Test updateEoi Method'];
        Id eoiId = lstOfEOI[0].Id; 
        
        // Prepare data for adding or updating a lead investor related to the EOI record
		Map<string,Object> datamap = new Map<string,Object>();
    			datamap.put('Name','John Steven');
        		datamap.put('Lead_Investor_Bio__c','Former PWC Director (Private Clients and Mergers & Acquisitions)');
        		datamap.put('Related_EOI__c',eoiId);
        
        // Perform the addUpdateLeadInvestor method and assert the result
        System.assertEquals('Success',MyEOIController.addUpdateLeadInvestor(datamap));
        
        // Attempt to add or update a lead investor with an invalid EOI Id
        Id recordIdByName = Schema.SObjectType.Account.getRecordTypeInfosByName().get('VC Business Account').getRecordTypeId();
        datamap.put('Related_EOI__c',recordIdByName);
        
        // Assert that the addUpdateLeadInvestor method does not succeed with an invalid EOI Id
        System.assertNotEquals('Success',MyEOIController.addUpdateLeadInvestor(datamap));
    }
    

    /**
      * Test method for the getLeadInvestor Aura-enabled method in the MyEOIController.
      * 
      * This test case covers the scenario of retrieving lead investors related to an EOI
      * using the MyEOIController's getLeadInvestor method.
      */
    @IsTest
    static void getLeadInvestorTest(){
        // Retrieve the user context for data isolation
        User owner = [SELECT Id FROM USER WHERE Name = 'The VentureCrowd Team'];
        
        // Query the EOI record created by the TestSetup
        List<EOI__c> lstOfEOI = [Select Id from EOI__c where Name = :'Test updateEoi Method'];
        Id eoiId = lstOfEOI[0].Id; 
        
        // Prepare data for inserting a lead investor related to the EOI record
		List<EOI_Lead_Investor__c> lstOfLeadInvestor = new List<EOI_Lead_Investor__c>();
        	EOI_Lead_Investor__c leadInvestor = new EOI_Lead_Investor__c();
    			leadInvestor.put('Name','John Steven');
        		leadInvestor.put('Lead_Investor_Bio__c','Former PWC Director (Private Clients and Mergers & Acquisitions)');
        		leadInvestor.put('Related_EOI__c',eoiId);
        lstOfLeadInvestor.add(leadInvestor);
        
        // Insert the lead investor record
        Test.startTest();
        System.runAs(owner){
           Database.insert(lstOfLeadInvestor,false);
        }
        Test.stopTest();
        
        // Perform the getLeadInvestor method and assert that the result is an not empty list
        System.assertEquals(1,(MyEOIController.getLeadInvestor(eoiId)).size());
        
        // Attempt to retrieve lead investors with an invalid EOI Id
        Id recordIdByName = Schema.SObjectType.Account.getRecordTypeInfosByName().get('VC Business Account').getRecordTypeId();
        
        // Assert that the getLeadInvestor method returns null with an invalid EOI Id
        System.assertEquals(null,MyEOIController.getLeadInvestor(recordIdByName)); 
    }
    
    /**
      * Test method for the addUpdateMediaLinks Aura-enabled method in the MyEOIController.
      * 
      * This test case covers the scenario of adding or updating media links related to an EOI
      * using the MyEOIController's addUpdateMediaLinks method.
      */
    @IsTest
    static void addUpdateMediaLinksTest(){
        // Query the EOI record created by the TestSetup
        List<EOI__c> lstOfEOI = [Select Id from EOI__c where Name = :'Test updateEoi Method'];
        Id eoiId = lstOfEOI[0].Id;
        
        // Prepare data for adding or updating a media link related to the EOI record
		Map<string,Object> datamap = new Map<string,Object>();
    		datamap.put('Name','A long media link');
        	datamap.put('Media_URL__c','https://www.afr.com');
        	datamap.put('EOI__c',eoiId);
        
        // Perform the addUpdateMediaLinks method and assert the result
        System.assertEquals('Success',MyEOIController.addUpdateMediaLinks(datamap));
        
        // Attempt to retrieve lead investors with an invalid EOI Id	
        Id recordIdByName = Schema.SObjectType.Account.getRecordTypeInfosByName().get('VC Business Account').getRecordTypeId();
        
        // Attempt to add or update media links with an invalid EOI Id
        datamap.put('EOI__c',recordIdByName);
        
        // Assert that the addUpdateMediaLinks method does not succeed with an invalid EOI Id
        System.assertNotEquals('Success',MyEOIController.addUpdateMediaLinks(datamap));
    }
    
    /**
      * Test method for the getMediaLinks Aura-enabled method in the MyEOIController.
      * 
      * This test case covers the scenario of retrieving media links related to an EOI
      * using the MyEOIController's getMediaLinks method.
      */
    @IsTest
    static void getMediaLinksTest(){
        // Retrieve the user context for data isolation
        User owner = [SELECT Id FROM USER WHERE Name = 'The VentureCrowd Team'];
        
        // Query the EOI record created by the TestSetup
        List<EOI__c> lstOfEOI = [Select Id from EOI__c where Name = :'Test updateEoi Method'];
        Id eoiId = lstOfEOI[0].Id;
        
        // Prepare data for inserting a media link related to the EOI record
		List<EOI_Media_Links__c> lstOfMediaLinks = new List<EOI_Media_Links__c>();
        	EOI_Media_Links__c mediaLink= new EOI_Media_Links__c();
        		mediaLink.put('Name','A long media link');
        		mediaLink.put('Media_URL__c','https://www.afr.com');
        		mediaLink.put('EOI__c',eoiId);
        lstOfMediaLinks.add(mediaLink);
        
        // Insert the media link records
        Test.startTest();
        System.runAs(owner){
          Database.SaveResult[] saveResults3 = Database.insert(lstOfMediaLinks,false);
        }
        Test.stopTest();
        
        // Perform the getMediaLinks method and assert that the result is not an empty list
        System.assertEquals(1,(MyEOIController.getMediaLinks(eoiId)).size());
        
        // Attempt to retrieve media links with an invalid EOI Id and assert that the result is null
        Id recordIdByName = Schema.SObjectType.Account.getRecordTypeInfosByName().get('VC Business Account').getRecordTypeId();
        System.assertEquals(null,MyEOIController.getMediaLinks(recordIdByName));
    }
    
    /**
 	  * Test method for the getInterestesLeads Aura-enabled method in the MyEOIController.
 	  * 
 	  * This test case covers the scenario of retrieving interested leads related to an EOI
 	  * using the MyEOIController's getInterestesLeads method.
 	  */
    @IsTest
    static void getInterestesLeadsTest(){
        // Retrieve the user context for data isolation
        User owner = [SELECT Id FROM USER WHERE Name = 'The VentureCrowd Team'];
        
        // Query the EOI record created by the TestSetup
        List<EOI__c> lstOfEOI = [Select Id from EOI__c where Name = :'Test updateEoi Method'];
        Id eoiId = lstOfEOI[0].Id; 
        
        // Prepare data for inserting an interested lead related to the EOI record
        List<Lead> lstOfLeads = new List<Lead>();
        	Lead ldObj = new Lead();
        		ldObj.LastName = 'Test Lead';
        		ldObj.Related_EOI__c = eoiId;
        		ldObj.Status = 'New';
        	lstOfLeads.add(ldObj);
        // Insert the lead record
        Test.startTest();
        System.runAs(owner){
          Database.SaveResult[] saveResults3 = Database.insert(lstOfLeads,false);
        }
        Test.stopTest();
        
        // Perform the getInterestesLeads method and assert that the result is not an empty list
        System.assertEquals(1,(MyEOIController.getInterestesLeads(eoiId)).size()); 
    }
}