public interface ICommentFactory {
    Comment__c createComment(String comment, Id raiseId, Id userId);
    List<Comment__c> retrieveComments(Id raiseId);
}