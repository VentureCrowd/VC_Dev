@IsTest
private class RaiseControllerTest {

    // Helper method to set up the necessary test data
    @TestSetup
    static void setupTestData() {
        // Create and insert a test account
        Account personAccount = new Account(Name='Related Person');
        insert personAccount;

        Account businessAccount = new Account(Name='Test Business', Related_Person_Account__c=personAccount.Id);
        insert businessAccount;
        
        Id ownerId = 'a3XXX000000cXXXAAI';

        List<User> benQuery = [SELECT Id FROM User WHERE Name='Ben Crow' LIMIT 1];
        if(benQuery.size() > 0){
            ownerId = benQuery[0].Id;
        }

        EOI__c testEOI = new EOI__c(Name = 'Test EOI', Account__c = businessAccount.Id, Internal_Owner__c = ownerId);
        insert testEOI;

        // Creating a Raise__c record to test existing raise functionality
        Raise__c testRaise = new Raise__c(
            Name = 'Test Raise',
            Account__c = personAccount.Id,
            Owner__c = ownerId,
            Company__c = businessAccount.Id,
            EOI__c = testEOI.Id,
            Status__c = 'In Progress',
            Payment_received__c = true,
            Content_approved__c = true,
            Course_unlocked__c = false,
            Learning_completed__c = false,
            Form_Problem_or_Opportunity__c = 'Test Problem',
            Form_Solution__c = 'Test Solution',
            Form_Differentiation__c = 'Test Differentiation',
            Form_Intellectual_Property__c = 'Test Intellectual Property',
            Form_Total_addressable_market__c = 'Test Market',
            Form_Progress__c = 'Test Progress',
            Form_Growth_plan__c = 'Test Growth Plan',
            Form_Valuation__c = 1000000,
            Form_Company_one_liner__c = 'Test Company Overview',
            Form_Offer_close_date__c = Date.today()
        );
        insert testRaise;
    }

    // Test the creation of a Raise__c record
    @IsTest
    static void testCreateRaiseRecord() {
        Account testAccount = [SELECT Id FROM Account WHERE Name='Test Business' LIMIT 1];
        Test.startTest();
        Raise__c result = RaiseController.createRaiseRecord(testAccount.Id, 'Retail');
        Test.stopTest();

        // Asserts to verify the correct record creation
        System.assertNotEquals(null, result, 'The raise record should not be null');
        System.assertEquals('In Progress', result.Status__c, 'Status should be "In Progress"');
        System.assertEquals(true, result.Preraise_completed__c, 'Preraise should be completed');
    }
    
    // Test the creation of a Raise__c record with an invalid account ID to simulate an error
    @IsTest
    static void testCreateRaiseRecordWithError() {
        Test.startTest();
        try {
            Raise__c result = RaiseController.createRaiseRecord('invalidId','Retail');
            System.assert(false, 'An exception should have been thrown for invalid ID');
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage(), 'Exception message not received');
        }
        Test.stopTest();
    }

    // Test to check if the raise exists for an account
    @IsTest
    static void testRaiseExists() {
        Account testAccount = [SELECT Id FROM Account WHERE Name='Test Business' LIMIT 1];
        Test.startTest();
        Boolean exists = RaiseController.raiseExists(testAccount.Id);
        Test.stopTest();

        // Assert to confirm that the raise exists
        System.assert(exists, 'Raise should exist for the test account');
    }
    
    // Test to check if the raise exists for an invalid account ID to simulate an error
    @IsTest
    static void testRaiseDoesntExist() {
        Test.startTest();
        Boolean exists = RaiseController.raiseExists('invalidId');
        Test.stopTest();
        
        System.assertEquals(false,exists, 'An exception should have been thrown for invalid ID');

    }

    // Test the retrieval of raise details by Raise ID
    @IsTest
    static void testGetRaiseDetails() {
        Raise__c testRaise = [SELECT Id FROM Raise__c LIMIT 1];
        Test.startTest();
        String details = RaiseController.getRaiseDetails(testRaise.Id);
        Test.stopTest();

        // Assert to ensure that some details are returned
        System.assertNotEquals(null, details, 'Details should not be null');
        System.assert(details.contains('Test Raise'), 'Details should contain the raise name');
    }
    
    // Test the retrieval of raise details with an invalid raise ID to simulate an error
    @IsTest
    static void testGetRaiseDetailsWithError() {
        Test.startTest();
        try {
            String details = RaiseController.getRaiseDetails('invalidId');
            System.assert(false, 'An exception should have been thrown for invalid ID');
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage(), 'Expected exception message not received');
        }
        Test.stopTest();
    }

    // Test the retrieval of raise details by Company ID
    @IsTest
    static void testGetRaiseDetailsFromCompanyId() {
        Account testAccount = [SELECT Id FROM Account WHERE Name='Test Business' LIMIT 1];
        Test.startTest();
        String details = RaiseController.getRaiseDetailsFromCompanyId(testAccount.Id);
        Test.stopTest();

        // Assert to ensure that details are returned
        System.assertNotEquals(null, details, 'Details should not be null');
        System.assert(details.contains('Test Raise'), 'Details should contain the raise name');
    }
    
    // Test the retrieval of raise details with an invalid company ID to simulate an error
    @IsTest
    static void testGetRaiseDetailsFromCompanyIdWithError() {
        Test.startTest();
        try {
            String details = RaiseController.getRaiseDetailsFromCompanyId('invalidId');
            System.assert(false, 'An exception should have been thrown for invalid ID');
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage(), 'Expected exception message not received');
        }
        Test.stopTest();
    }

    @IsTest
    static void testGetgetRaiseDetailsForm() {
        Raise__c testRaise = [SELECT Id FROM Raise__c LIMIT 1];

        Test.startTest();
        Map<String,Object>  details = RaiseController.getRaiseDetailsForm(testRaise.Id);
        Test.stopTest();

        // Assert to ensure that details are returned
        System.assertNotEquals(null, details, 'Details should not be null');
    }

    @IsTest
    static void testGetgetRaiseDetailsFormError() {
        Id testRaiseId = 'a3XXX000000cXXXAAI';

        Exception expectedException = null;
        Test.startTest();
        
        try{
            Map<String,Object>  details = RaiseController.getRaiseDetailsForm(testRaiseId);
        }catch(Exception e){
            expectedException = e;
        }
        
        Test.stopTest();

        // Assert to ensure that details are returned
        System.assertNotEquals(null, expectedException, 'expectedException should not be null');
    }

    @IsTest
    static void testGetupdateRaiseDetails() {
        Raise__c testRaise = [SELECT Id FROM Raise__c LIMIT 1];

        Map<String,Object> fieldsToUpdate = new Map<String,Object>();

        fieldsToUpdate.put('companyFullName', 'NewName CompanyName');

        Test.startTest();
        Map<String,Object>  details = RaiseController.updateRaiseDetails(testRaise.Id, fieldsToUpdate);
        Test.stopTest();

        // Assert to ensure that details are returned
        System.assertNotEquals(null, details, 'Details should not be null');
    }

    @IsTest
    static void testGetupdateRaiseDetailsError() {
        Id testRaiseId = 'a3XXX000000cXXXAAI';

        Map<String,Object> fieldsToUpdate = new Map<String,Object>();

        fieldsToUpdate.put('companyFullName', 'NewName CompanyName');
        Exception expectedException = null;
        Test.startTest();

        try{
            Map<String,Object>  details = RaiseController.updateRaiseDetails(testRaiseId, fieldsToUpdate);
        }catch(Exception e){
            expectedException = e;
        }
        Test.stopTest();

        // Assert to ensure that details are returned
        System.assertNotEquals(null, expectedException, 'expectedException should not be null');
    }

    @IsTest
    static void testGetPicklistValues() {
        String objectName = 'Raise__c';
        String fieldName = 'Form_Stage__c';

        Test.startTest();

        List<Map<String, String>>  details = RaiseController.getPicklistValues(objectName, fieldName);

        Test.stopTest();

        // Assert to ensure that details are returned
        System.assertNotEquals(null, details, 'Should not be null');
    }

    @IsTest
    static void testGetPicklistValuesError() {
        String objectName = 'Raise__c';
        String fieldName = 'nonExistentField';

        Exception expectedException = null;
        Test.startTest();
        try{
            List<Map<String, String>>  details = RaiseController.getPicklistValues(objectName, fieldName);
        }catch(Exception e){
            expectedException = e;
        }

        Test.stopTest();

        // Assert to ensure that details are returned
        System.assertNotEquals(null, expectedException, 'Should not be null');
    }

    @isTest
    static void testUserLoggedIn() {
        Test.startTest();
        Boolean isLoggedIn = RaiseController.userLoggedIn();
        Test.stopTest();

        // Perform assertions
        System.assertEquals(true, isLoggedIn, 'User should be logged in');
    }

    @isTest
    static void testUpdateRaiseStatus() {
        Raise__c testRaise = [SELECT Id, Status__c FROM Raise__c LIMIT 1];

        Test.startTest();
        Raise__c updatedRaise = RaiseController.updateRaiseStatus(testRaise.Id, 'Waiting for payment');
        Test.stopTest();

        // Perform assertions
        System.assertNotEquals(null, updatedRaise, 'Updated Raise should not be null');
        System.assertEquals('Waiting for payment', updatedRaise.Status__c, 'Raise status should be updated to Waiting for payment');
    }

    @isTest
    static void testGetRaisePageDetailsRaiseId() {
        // Retrieve the test raise record
        Raise__c testRaise = [SELECT Id FROM Raise__c LIMIT 1];

        // Mock the raiseService.getRaisePageDetailsRaiseId method
        Test.startTest();
        String raiseDetails = RaiseController.getRaisePageDetailsRaiseId(testRaise.Id);
        Test.stopTest();

        // Perform assertions
        System.assertNotEquals(null, raiseDetails, 'Raise details should not be null');
        // Add more assertions based on the expected format and content of raiseDetails
    }

    @IsTest
    static void testGetRaisePageDetailsRaiseIdWithError() {
        Test.startTest();
        try {
            String raiseDetails = RaiseController.getRaisePageDetailsRaiseId('invalidId');
            System.assert(false, 'An exception should have been thrown for invalid ID');
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage(), 'Expected exception message not received');
        }
        Test.stopTest();
    }


    public static void testGetRaiseStatuses() {
		Raise__c testRaise = [SELECT Id FROM Raise__c LIMIT 1];
        
        Test.startTest();
        Map<String, Object> result = RaiseController.getRaiseStatuses(testRaise.Id);
        Test.stopTest();

        System.assertEquals('Test Raise', result.get('name'));
        System.assertEquals(true, result.get('paymentReceived'));
        System.assertEquals(true, result.get('contentApproved'));
        System.assertEquals(false, result.get('courseUnlocked'));
        System.assertEquals(false, result.get('learningCompleted'));
    }

    @isTest
    public static void testUnlockRaiseCourse() {
        // Setup test data
        List<Knowledge__kav> knowledgeArticles = new List<Knowledge__kav>{
            new Knowledge__kav(Title = 'Knowledge Article 1', UrlName = 'ka-1'),
            new Knowledge__kav(Title = 'Knowledge Article 2', UrlName = 'ka-2')
        };
        insert knowledgeArticles;
        
        List<Course__c> courses = new List<Course__c>{
            new Course__c(Name = 'Capital Raising 101 Course'),
            new Course__c(Name = 'Course 2')
        };
        insert courses;

        List<Course_article__c> courseArticles = new List<Course_article__c>{
            new Course_article__c(Name = 'Article 1', Knowledge__c = knowledgeArticles[0].Id, Course__c = courses[0].Id),
            new Course_article__c(Name = 'Article 2', Knowledge__c = knowledgeArticles[1].Id, Course__c = courses[1].Id)
        };
        insert courseArticles;

        Raise__c testRaise = [SELECT Id FROM Raise__c LIMIT 1];


        Test.startTest();
        Map<String, Object> result = RaiseController.unlockRaiseCourse(testRaise.Id);
        Test.stopTest();

        System.assertEquals(testRaise.Id, result.get('id'));
        System.assertEquals(true, result.get('courseUnlocked'));
        System.assertEquals(true, result.get('paymentReceived'));
    }

    @isTest
    public static void testCreateLearningForRaise() {
        // Setup test data
        List<Knowledge__kav> knowledgeArticles = new List<Knowledge__kav>{
            new Knowledge__kav(Title = 'Knowledge Article 3', UrlName = 'ka-3'),
            new Knowledge__kav(Title = 'Knowledge Article 4', UrlName = 'ka-4')
        };
        insert knowledgeArticles;
        
        List<Course__c> courses = new List<Course__c>{
            new Course__c(Name = 'Capital Raising 101 Course')
        };
        insert courses;

        List<Course_article__c> courseArticles = new List<Course_article__c>{
            new Course_article__c(Name = 'Article 3', Knowledge__c = knowledgeArticles[0].Id, Course__c = courses[0].Id),
            new Course_article__c(Name = 'Article 4', Knowledge__c = knowledgeArticles[1].Id, Course__c = courses[0].Id)
        };
        insert courseArticles;

		Raise__c testRaise = [SELECT Id FROM Raise__c LIMIT 1];

        Test.startTest();
        Map<String, Object> result = RaiseController.createLearningForRaise(testRaise.Id);
        Test.stopTest();

        System.assertNotEquals(null, result.get('learningData'));
        System.assertNotEquals(null, result.get('raiseData'));
    }

    @isTest
    static void testgetSummaryStatistics() {
        Raise__c testRaise = [SELECT Id FROM Raise__c LIMIT 1];
        EOI__c testEOI = [SELECT Id FROM EOI__c LIMIT 1];

        Test.startTest();
        Map<String,Object> result = RaiseController.getSummaryStatistics(testRaise.Id, testEOI.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Raise record should not be null');
    }

    @isTest
    static void testGetRaiseRecordType() {
        // Query for the test Raise record created in the test setup.
        Raise__c raiseTest = [SELECT Id, RecordType.DeveloperName FROM Raise__c LIMIT 1];
        
        
        // Call the method in a test context.
        Test.startTest();
        String result = RaiseController.getRaiseRecordType(raiseTest.Id);
        Test.stopTest();
        
        // Assert that the returned Raise__c record is not null.
        System.assertNotEquals(null, result, 'Expected a non-null Raise__c record.');
        
        // Assert that the returned record's Id matches the one queried from test setup.
        System.assertEquals('Primary_Raise', result, 'RecordType DeveloperName did not match.');
    }
}