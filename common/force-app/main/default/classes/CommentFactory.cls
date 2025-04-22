/**
 * Comments factory class that is used to create the Comment__c object without exposing the object
 * creation logic to the client.
 */
public class CommentFactory implements ICommentFactory {

    /**
     * Creates a comment record given the Raise ID.
     *
     * @param comment The string of the comment.
     * @param raiseId The ID of the Business Account to associate with the comment.
     * @param userId The ID of the user creating the comment.
     * @return Newly created Comment__c record.
     * @throws AuraHandledException when the raise ID cannot be found or if another error occurs.
     */ 
    public Comment__c createComment(String comment, Id raiseId, Id userId) {
        try {
            Comment__c commentRecord = new Comment__c();
            commentRecord.comments__c = comment;
            commentRecord.Post_Comments__c = userId;
            commentRecord.Raise__c = raiseId;
            commentRecord.Posted_Date__c = Date.today();
            insert commentRecord;

            return commentRecord;
        } catch (Exception e) {
            Logger.logError('CommentApp', 'CommentFactory', 'createComment', raiseId, null, null, null, e, 'Failed to insert new comment for raiseId: ' + raiseId);
            throw new AuraHandledException('Raise cannot be found!');
        }
    }

    /**
     * Retrieves comments associated with a specific raise.
     *
     * @param raiseId The ID of the raise to retrieve comments for.
     * @return A list of Comment__c records.
     * @throws AuraHandledException when no comments are found or if another error occurs.
     */
    public List<Comment__c> retrieveComments(Id raiseId) {
        try {
            List<Comment__c> commentList = [SELECT Id, comments__c, Post_Comments__r.FullPhotoUrl, Commented_By_Name_Investor__c, Posted_Date__c, Response__c, Reponse_Date__c, Answer_comments__r.FullPhotoUrl, Commented_By_Name__c,
                Answer_comments__r.Title FROM Comment__c WHERE Raise__c = :raiseId AND Approved__c = TRUE ORDER BY Posted_Date__c DESC];

            if (commentList.isEmpty()) {
                Logger.logMessage('CommentApp', 'CommentFactory', 'retrieveComments', 'No comments found for raiseId: ' + raiseId);
                throw new AuraHandledException('No comments found for raiseId: ' + raiseId);
            } else {
                Logger.logMessage('CommentApp', 'CommentFactory', 'retrieveComments', 'Successfully retrieved comments for raiseId: ' + raiseId);
                return commentList;
            }
        } catch (Exception e) {
            Logger.logError('CommentApp', 'CommentFactory', 'retrieveComments', raiseId, null, null, null, e, 'Failed to retrieve comments for raiseId: ' + raiseId);
            throw new AuraHandledException(e.getMessage());
        }
    }
}