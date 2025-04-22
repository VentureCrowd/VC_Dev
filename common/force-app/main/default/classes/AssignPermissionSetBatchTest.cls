@isTest
public class AssignPermissionSetBatchTest {

    @testSetup
    static void setupTestData() {
        // Create a test Permission Set
        PermissionSet ps = new PermissionSet(Name = 'Portal_User_Permission_Set', Label = 'Portal User Permission Set');
        insert ps;

        // Retrieve existing Profiles or use existing ones
        // Note: Profiles are standard objects and cannot be created via Apex. Use existing profiles or use Metadata API for creation.

        // Assuming 'Portal User Profile Name1' and 'Portal User Profile Name2' exist
        Profile portalProfile1 = [SELECT Id FROM Profile WHERE Name = 'Finance' LIMIT 1];
        Profile portalProfile2 = [SELECT Id FROM Profile WHERE Name = 'Funds Manager' LIMIT 1];

        // Create test Users
        User portalUser1 = new User(
            Alias = 'puser1',
            Email = 'puser1@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Portal1',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = portalProfile1.Id,
            TimeZoneSidKey = 'America/New_York',
            UserName = 'alltestpuser1@test.com.au'
        );
        User portalUser2 = new User(
            Alias = 'puser2',
            Email = 'puser2@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Portal2',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = portalProfile2.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'alltestpuser2@test.com.au'
        );


        insert new List<User> { portalUser1, portalUser2 };
    }

    static testMethod void testAssignPermissionSet() {
        // Retrieve the Permission Set
        PermissionSet ps = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Portal_User_Permission_Set' LIMIT 1];

        // Define the Profile Names to filter
        List<String> profilesToFilter = new List<String>{
            'Finance',
            'Funds Manager'
        };

        // Instantiate the batch class
        AssignPermissionSetBatch batch = new AssignPermissionSetBatch(profilesToFilter, ps.Name);

        // Execute the batch within Test.startTest and Test.stopTest to simulate asynchronous behavior
        Test.startTest();
        Database.executeBatch(batch, 200);
        Test.stopTest();

        // Query PermissionSetAssignments to verify assignments
        List<PermissionSetAssignment> psaList = [SELECT Id, AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE PermissionSetId = :ps.Id];

        // Retrieve Users who should have the Permission Set

       // Retrieve Users who should have the Permission Set
       List<User> portalUsers = [SELECT Id FROM User WHERE Profile.Name IN :profilesToFilter AND UserName LIKE 'alltestpuser%@test.com.au'];
        
       // Assert that each portal user has the Permission Set assigned
       for (User u : portalUsers) {
           Boolean hasPSA = false;
           for (PermissionSetAssignment psa : psaList) {
               if (psa.AssigneeId == u.Id && psa.PermissionSetId == ps.Id) {
                   hasPSA = true;
                   break;
               }
           }
           System.assertEquals(true, hasPSA, 'User with ID ' + u.Id + ' should have the Permission Set assigned.');
       }
     
    }
}