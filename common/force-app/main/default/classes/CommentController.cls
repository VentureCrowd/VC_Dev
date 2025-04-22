/**
 * Apex controller for the Raise process.
 * The goal is to not have any business logic living in this layer,
 * but merely translate the callers input to match that of the service class
 */

public without sharing class CommentController {
    @TestVisible private static CommentService commentService = new CommentService();

    /**
     * Creates a comment and associates it with a specified raise.
     *
     * @param comment The string of the comment.
     * @param raiseId The ID of the raise.
     * @param userId The ID of the user to link the comment to.
     * @return A Comment__c object representing the created comment record.
     */
    @AuraEnabled
    public static Comment__c createCommentRecord(String comment, Id raiseId, Id userId) {
        try {
            return commentService.createCommentRecord(comment, raiseId, userId);
        } catch (Exception e) {
            Logger.logError('CommentApp', 'CommentController', 'createCommentRecord', null, null, null, null, e, 'Failed to create comment record for raiseId: ' + raiseId);
            throw e;
        }
    }

    /**
     * Retrieves the comment details for the specified raise.
     *
     * @param raiseId The ID of the raise to retrieve the raise details for.
     * @return A List containing all the comments for the company.
     */
    @AuraEnabled() 
    public static List<Map<String, Object>> retrieveCommentsFromRaiseId(Id raiseId) {
        try{
            return commentService.getComments(raiseId);
        }catch (Exception e) {
            Logger.logError('CommentApp', 'CommentController', 'retrieveCommentsFromRaiseId', null, null, null, null, e, 'Failed to create comment record for raiseId: ' + raiseId);
            throw e;
        }
    }
}