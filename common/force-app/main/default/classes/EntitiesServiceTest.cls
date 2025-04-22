@IsTest
public class EntitiesServiceTest {
	@testSetup
    static void setupTestData() {
        // Create an Account with the 'VC Business Account' RecordType
        Id bussAcctRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('VC Business Account').getRecordTypeId();
        Account businessAccount = new Account(
            Name = 'Test Business Account',
            RecordTypeId = bussAcctRT,
            Active__c = true
        );
        insert businessAccount;
        
        

       User owner = [SELECT Id FROM USER WHERE Name = 'The VentureCrowd Team'];
        Id recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('VC Person Account').getRecordTypeId();
        Account testAccount = new Account(
            FirstName = 'TestPersonAccountFirst',
            LastName = 'TestPersonAccountLast',
            PersonEmail = 'test@user.com',
            RecordTypeId = recordTypeId,
            // Name = 'Test Account',
            OwnerId = owner.Id
        );
        insert testAccount;
        
        
        Profile testProfile = [SELECT Id, Name FROM Profile WHERE Name = 'VC Investor Community Plus Login' LIMIT 1];
    
        Contact getContact = [SELECT Id, Name FROM Contact WHERE FirstName = 'TestPersonAccountFirst'];
        // Id contactId = getContact.Id;

        User testUser = new User(
            FirstName = 'TestingUserN2',
            Username = 'testUser_n2@test.com',
            LastName = 'TestAds',
            // ContactId = testContact.Id,
            Email = 'testUser_n2@test.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = testProfile.Id,
            ContactId = getContact.Id
        );
        insert testUser;
        
        

         // Create an AccountContactRelation
        AccountContactRelation acr = new AccountContactRelation(
            AccountId = businessAccount.Id,
            ContactId = getContact.Id
        );
        insert acr;


        // Set the current user context for testing
        System.runAs(testUser) {
            System.debug('Setup completed');
        }
    }

    @IsTest
    static void testGetRelatedBusinessAccounts() {
        // Retrieve a Contact Id from the setup data
        Contact contact = [SELECT Id FROM Contact LIMIT 1];

        // Call the method to test
        EntitiesService service = new EntitiesService();
        List<Map<String,Object>> relatedAccounts = service.getRelatedBusinessAccounts(contact.Id);

        // Verify the results
        System.assertEquals(1, relatedAccounts.size(), 'There should be one related business account');
    }

    @IsTest
    static void testGetContactFromLoggedInUser() {
        // Retrieve the logged-in user (set in setup)
        User loggedInUser = [SELECT Id, ContactId FROM User WHERE Username='testUser_n2@test.com' LIMIT 1];

        // Call the method to test
        System.runAs(loggedInUser){
            EntitiesService service = new EntitiesService();
        	Id contactId = service.getLoggedInUser();
            System.assertEquals(loggedInUser.ContactId, contactId, 'The contact ID should match the logged-in user\'s contact ID');

        }
    }
}