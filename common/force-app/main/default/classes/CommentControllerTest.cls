@isTest
private class CommentControllerTest {

    @TestSetup
    static void setup() {
        // Create a test Business Account and related person account
        Account personAccount = new Account(Name='Related Person');
        insert personAccount;

        Account businessAccount = new Account(Name='Test Business', Related_Person_Account__c=personAccount.Id);
        insert businessAccount;

        // Create test Raises
        Raise__c testRaise = new Raise__c(Name='Existing Raise', Company__c=businessAccount.Id, Account__c=personAccount.Id);
        testRaise.Form_Offer_close_date__c = Date.today();
        insert testRaise;

        Raise__c testRaise2 = new Raise__c(Name='Existing Raise2', Company__c=businessAccount.Id, Account__c=personAccount.Id);
        testRaise2.Form_Offer_close_date__c = Date.today();
        insert testRaise2;

        // Create a test Comment
        User testUser = [SELECT Id FROM User LIMIT 1];
        Comment__c testComment = new Comment__c(
            comments__c = 'This is a test comment',
            Post_Comments__c = testUser.Id,
            Raise__c = testRaise.Id,
            Posted_Date__c = Date.today(),
            Approved__c = true
        );
        insert testComment;
    }

    @isTest
    static void testCreateCommentRecord() {
        // Fetch test data
        Raise__c testRaise = [SELECT Id FROM Raise__c WHERE Name = 'Existing Raise' LIMIT 1];
        User testUser = [SELECT Id FROM User LIMIT 1];

        // Create Comment using CommentController
        Test.startTest();
        try {
            Comment__c newComment = CommentController.createCommentRecord('This is another test comment', testRaise.Id, testUser.Id);

            // Validate the comment creation
            System.assertNotEquals(null, newComment, 'Comment should be created successfully');
            System.assertEquals('This is another test comment', newComment.comments__c, 'Comment text should match');
            System.assertEquals(testUser.Id, newComment.Post_Comments__c, 'User Id should match');
            System.assertEquals(testRaise.Id, newComment.Raise__c, 'Raise Id should match');
            System.assertEquals(Date.today(), newComment.Posted_Date__c, 'Posted date should match');
        } catch (Exception e) {
            System.assert(false, 'An exception should not have been thrown: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testRetrieveCommentsFromRaiseId() {
        // Fetch test data
        Raise__c testRaise = [SELECT Id FROM Raise__c WHERE Name = 'Existing Raise' LIMIT 1];

        // Retrieve Comments using CommentController
        Test.startTest();
        try {
            List<Map<String, Object>> comments = CommentController.retrieveCommentsFromRaiseId(testRaise.Id);

            // Validate the retrieved comments
            System.assertNotEquals(null, comments, 'Comments should be retrieved successfully');
            System.assertEquals(1, comments.size(), 'There should be one comment retrieved');
            Map<String, Object> retrievedComment = comments[0];
            System.assertEquals('This is a test comment', retrievedComment.get('Comment'), 'Comment text should match');
            System.assertEquals(Date.today(), retrievedComment.get('PublishedDate'), 'Posted date should match');
        } catch (Exception e) {
            System.assert(false, 'An exception should not have been thrown: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testCreateCommentRecordWithError() {
        Test.startTest();
        try {
            // Create a Comment with null parameters to force an exception
            Comment__c newComm = CommentController.createCommentRecord('This is another test comment', 'null', 'null');
            System.assert(false, 'An exception should have been thrown for null IDs');
        } catch (Exception e) {
            System.assertNotEquals('null', e.getMessage(), 'Expected exception message not received');
        }
        Test.stopTest();
    }

    @isTest
    static void testRetrieveCommentsFromRaiseIdWithError() {
        Test.startTest();
        try {
            // Retrieve comments with a null raiseId to force an exception
            List<Map<String, Object>> comments = CommentController.retrieveCommentsFromRaiseId(null);
            System.assert(false, 'An exception should have been thrown for invalid ID');
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage(), 'Expected exception message not received');
        }
        Test.stopTest();
    }
}