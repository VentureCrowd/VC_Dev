@isTest
private class CommentServiceTest {

    @TestSetup
    static void setup() {
        // Create a test Business Account and related person account
        Account personAccount = new Account(Name='Related Person');
        insert personAccount;

        Account businessAccount = new Account(Name='Test Business', Related_Person_Account__c=personAccount.Id);
        insert businessAccount;

        // Create test Raises
        Raise__c testRaise = new Raise__c(Name='Existing Raise', Company__c=businessAccount.Id, Account__c=personAccount.Id);
        insert testRaise;

        Raise__c testRaise2 = new Raise__c(Name='Existing Raise2', Company__c=businessAccount.Id, Account__c=personAccount.Id);
        insert testRaise2;

        // Create a test User
        User testUser = [SELECT Id FROM User LIMIT 1];

        // Create a test Comment
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

        // Create Comment using CommentService
        CommentService service = new CommentService();
        Test.startTest();
        Comment__c newComment = service.createCommentRecord('This is another test comment', testRaise.Id, testUser.Id);
        Test.stopTest();

        // Validate the comment creation
        System.assertNotEquals(null, newComment, 'Comment should be created successfully');
        System.assertEquals('This is another test comment', newComment.comments__c, 'Comment text should match');
        System.assertEquals(testUser.Id, newComment.Post_Comments__c, 'User Id should match');
        System.assertEquals(testRaise.Id, newComment.Raise__c, 'Raise Id should match');
        System.assertEquals(Date.today(), newComment.Posted_Date__c, 'Posted date should match');
    }

    @isTest
    static void testGetComments() {
        // Fetch test data
        Raise__c testRaise = [SELECT Id FROM Raise__c WHERE Name = 'Existing Raise' LIMIT 1];

        // Retrieve Comments using CommentService
        CommentService service = new CommentService();
        Test.startTest();
        List<Map<String, Object>> comments = service.getComments(testRaise.Id);
        Test.stopTest();

        // Validate the retrieved comments
        System.assertNotEquals(null, comments, 'Comments should be retrieved successfully');
        System.assertEquals(1, comments.size(), 'There should be one comment retrieved');
        Map<String, Object> retrievedComment = comments[0];
        System.assertEquals('This is a test comment', retrievedComment.get('Comment'), 'Comment text should match');
        System.assertEquals(Date.today(), retrievedComment.get('PublishedDate'), 'Posted date should match');
    }

    @isTest
    static void testRetrieveCommentsException() {
        Raise__c emptyRaise = [SELECT Id FROM Raise__c WHERE Name = 'Existing Raise2' LIMIT 1];
        CommentService service = new CommentService();
        
        Test.startTest();
        try {
            List<Map<String, Object>> comments = service.getComments(emptyRaise.Id);
            System.assert(false, 'An exception should have been thrown');
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage(), 'Expected exception message not received');
        }
        Test.stopTest();
    }
}