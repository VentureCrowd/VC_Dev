/**
 * @description This test class is designed to validate the functionality of the RaiseTeamController class.
 * It covers various scenarios for creating, editing, retrieving, and deleting team member records.
 * Additionally, it tests the handling of exceptions for the respective methods.
 */
@isTest
public class RaiseTeamControllerTest {
      /**
     * @description Sets up test data required for the test methods. Creates a test account, 
     * test company account, test raise, and a test team member.
     */
    @testSetup
    static void setupTestData() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Account testCompany = new Account(Name = 'Test Company Account');
        insert testCompany;

        Raise__c testRaise = new Raise__c(Name = 'Test Raise', Account__c = testAccount.Id, Company__c = testCompany.Id);
        insert testRaise;

        Raise_Team_and_Advisors__c testMember = new Raise_Team_and_Advisors__c(
            Name = 'Test Member',
            Category__c = 'Founder',
            Picture__c = 'https://example.com/image.jpg',
            Description__c = 'Test Description',
            LinkedIn__c = 'https://linkedin.com/in/test',
            Related_Raise__c = testRaise.Id,
            Role__c = 'CEO'
        );
        insert testMember;
    }

    /**
     * @description Tests the getTeamMembersByRaiseId method to retrieve team members for a given raise ID and category.
     */
    @isTest
    static void testGetTeamMemberByRaiseId() {
        Raise__c testRaise = [SELECT Id FROM Raise__c LIMIT 1];

        Test.startTest();
        List<Map<String, String>> result = RaiseTeamController.getTeamMembersByRaiseId(testRaise.Id,'Founder');
        Test.stopTest();

        System.assertNotEquals(null, result);
    }

    /**
     * @description Tests the getTeamMemberById method to retrieve a team member by its ID.
     */
    @isTest
    static void testGetTeamMemberById() {
        Raise_Team_and_Advisors__c testMember = [SELECT Id FROM Raise_Team_and_Advisors__c LIMIT 1];

        Test.startTest();
        Map<String, String> result = RaiseTeamController.getTeamMemberById(testMember.Id);
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals(testMember.Id, result.get('id'));
        System.assertEquals('Test Member', result.get('name'));
    }
    
    /**
     * @description Tests the getTeamMemberById method to handle exception when the team member ID is invalid.
     */
    @isTest
    static void testGetTeamMemberById_Exception() {
        Id testMember = 'aXXXX000000cXXXXXX';
	
        Exception expectedException = null;
        
        Test.startTest();
        try{
            Map<String, String> result = RaiseTeamController.getTeamMemberById(testMember);    
        }catch(Exception e){
            expectedException = e;
        }

        Test.stopTest();

        System.assertNotEquals(null, expectedException);
    }

    /**
     * @description Tests the createTeamMember method to create a new team member.
     */
    @isTest
    static void testCreateTeamMember() {
        Raise__c testRaise = [SELECT Id FROM Raise__c LIMIT 1];

        Test.startTest();
        Map<String, String> newMember = RaiseTeamController.createTeamMember(
            testRaise.Id,
            'New Member',
            'Management Team',
            'https://example.com/newimage.jpg',
            'New Description',
            'https://linkedin.com/in/newmember',
            'COO'
        );
        Test.stopTest();

        System.assertNotEquals(null, newMember.get('id'));
        System.assertEquals('New Member', newMember.get('name'));
    }
    
    /**
     * @description Tests the createTeamMember method to handle exception when the raise ID is invalid.
     */
    @isTest
    static void testCreateTeamMember_Exception() {
        Id testRaise = 'aXXXX000000cXXXXXX';
		
        Exception expectedException = null;	
        
        Test.startTest();
        try{
            Map<String, String> newMember = RaiseTeamController.createTeamMember(
            testRaise,
            'New Member',
            'Management Team',
            'https://example.com/newimage.jpg',
            'New Description',
            'https://linkedin.com/in/newmember',
            'COO'
        );
        }catch(Exception e){
            expectedException = e;
        }
        
        Test.stopTest();

        System.assertNotEquals(null, expectedException);
        
    }

    /**
     * @description Tests the editTeamMember method to edit an existing team member.
     */
    @isTest
    static void testEditTeamMember() {
        Raise_Team_and_Advisors__c testMember = [SELECT Id FROM Raise_Team_and_Advisors__c LIMIT 1];

        Test.startTest();
        Map<String, String> updatedMember = RaiseTeamController.editTeamMember(
            testMember.Id,
            'Updated Member',
            'https://example.com/updatedimage.jpg',
            'Updated Description',
            'https://linkedin.com/in/updatedmember',
            'CTO'
        );
        Test.stopTest();

        System.assertEquals('Updated Member', updatedMember.get('name'));
    }
    

    /**
     * @description Tests the editTeamMember method to handle exception when the team member ID is invalid.
     */
    @isTest
    static void testEditTeamMember_Exception() {
        Id testMember = 'aXXXX000000cXXXXXX';
		
		Exception expectedException = null;		
        
        Test.startTest();
        try{
            Map<String, String> updatedMember = RaiseTeamController.editTeamMember(
            testMember,
            'Updated Member',
            'https://example.com/updatedimage.jpg',
            'Updated Description',
            'https://linkedin.com/in/updatedmember',
            'CTO'
        	);
        }catch(Exception e){
            expectedException =e ;
        }
        
        Test.stopTest();

        System.assertNotEquals(null, expectedException);
    }


    /**
     * @description Tests the deleteTeamMember method to delete an existing team member.
     */
    @isTest
    static void testDeleteTeamMember() {
        Raise_Team_and_Advisors__c testMember = [SELECT Id FROM Raise_Team_and_Advisors__c LIMIT 1];

        Test.startTest();
        Boolean result = RaiseTeamController.deleteTeamMember(testMember.Id);
        Test.stopTest();

        System.assert(result);
    }
    
    /**
     * @description Tests the deleteTeamMember method to handle exception when the team member ID is invalid.
     */
    @isTest
    static void testDeleteTeamMember_Exception() {
        Id testMember = 'aXXXX000000cXXXXXX';
		
        Test.startTest();
        Boolean result = RaiseTeamController.deleteTeamMember(testMember);
        Test.stopTest();
        
        System.assertEquals(false,result);
    }
}