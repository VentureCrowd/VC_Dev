@isTest
public class CommentFactoryTest {
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
    static void testCreateComment() {
        // Retrieve test data
        Raise__c testRaise = [SELECT Id FROM Raise__c WHERE Name = 'Existing Raise' LIMIT 1];
        User testUser = [SELECT Id FROM User LIMIT 1];
        
        // Create a new Comment using the CommentFactory
        CommentFactory factory = new CommentFactory();
        Test.startTest();
        Comment__c newComment = factory.createComment('New test comment', testRaise.Id, testUser.Id);
        Test.stopTest();
        
        // Verify the new Comment was created successfully
        System.assertNotEquals(null, newComment, 'The new comment should not be null');
        System.assertEquals('New test comment', newComment.comments__c, 'The comment text should match');
        System.assertEquals(testUser.Id, newComment.Post_Comments__c, 'The user Id should match');
        System.assertEquals(testRaise.Id, newComment.Raise__c, 'The raise Id should match');
    }
    
    @isTest
    static void testCreateCommentException() {
        // Retrieve test data
        User testUser = [SELECT Id FROM User LIMIT 1];
        
        // Attempt to create a new Comment with an invalid Raise Id
        CommentFactory factory = new CommentFactory();
        
        Test.startTest();
        try {
            Comment__c newComment = factory.createComment('New test comment', 'invalidRaiseId', testUser.Id);
            System.assert(false, 'An exception should have been thrown');
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage(), 'Expected exception message not received');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testRetrieveComments() {
        // Retrieve test data
        Raise__c testRaise = [SELECT Id FROM Raise__c WHERE Name = 'Existing Raise' LIMIT 1];
        
        // Retrieve Comments using the CommentFactory
        CommentFactory factory = new CommentFactory();
        Test.startTest();
        List<Comment__c> comments = factory.retrieveComments(testRaise.Id);
        Test.stopTest();
        
        // Verify the Comments were retrieved successfully
        System.assertNotEquals(null, comments, 'The comments list should not be null');
        System.assertEquals(1, comments.size(), 'There should be one comment');
        System.assertEquals('This is a test comment', comments[0].comments__c, 'The comment text should match');
    }
    
    @isTest
    static void testRetrieveCommentsException() {
        Raise__c emptyRaise = [SELECT Id FROM Raise__c WHERE Name = 'Existing Raise2' LIMIT 1];
        CommentFactory factory = new CommentFactory();
        
        Test.startTest();
        try {
            List<Comment__c> comments = factory.retrieveComments(emptyRaise.Id);
            System.assert(false, 'An exception should have been thrown');
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage(), 'Expected exception message not received');
        }
        Test.stopTest();
    }
}