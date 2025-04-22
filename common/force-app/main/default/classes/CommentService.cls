/**
 * This is the service layer class associated with the Raise process. 
 * All of the business logic relevant to Raise will remain in this class.
 */
public without sharing class CommentService {

    /**
     * Method to create a comment record using the Raise ID of a Business Account.
     *
     * @param comment The string of the comment.
     * @param raiseId The ID of the Business Account to associate with the comment.
     * @param userId The ID of the user creating the comment.
     * @return Newly created Comment__c record.
     * @throws AuraHandledException when the raise ID cannot be found or if another error occurs.
     */ 
    public Comment__c createCommentRecord(String comment, Id raiseId, Id userId) {
        try {
            CommentFactory factory = new CommentFactory();
            Comment__c recordCreated = factory.createComment(comment, raiseId, userId);
            if (recordCreated == null) {
                throw new AuraHandledException('Raise cannot be found!');
            }
            Logger.logMessage('CommentApp', 'CommentService', 'createCommentRecord', 'Successfully created comment record for raiseId: ' + raiseId);
            return recordCreated;
        } catch (Exception e) {
            Logger.logError('CommentApp', 'CommentService', 'createCommentRecord', raiseId, null, null, null, e, 'Failed to create comment record for raiseId: ' + raiseId);
            throw e;
        }
    }

    /**
     * Method to retrieve comments associated with a specific raise.
     *
     * @param raiseId The ID of the raise to retrieve comments for.
     * @return A list of maps containing comment details.
     * @throws AuraHandledException when an error occurs during retrieval.
     */
    public List<Map<String, Object>> getComments(Id raiseId) {
        try {
            List<Map<String, Object>> returnList = new List<Map<String, Object>>();
            CommentFactory factory = new CommentFactory();
            List<Comment__c> comments = factory.retrieveComments(raiseId);

            if (comments != null) {
                for (Comment__c comment : comments) {
                    Map<String, Object> commentReturn = new Map<String, Object>();

                    // Correctly reference the properties of the comment
                    commentReturn.put('Id', comment.Id);
                    commentReturn.put('Comment', comment.comments__c); // Assuming 'comments__c' is the field name for the comment text
                    commentReturn.put('InvestorProfileURL', comment.Post_Comments__r.FullPhotoUrl);
                    commentReturn.put('InvestorName', comment.Commented_By_Name_Investor__c);
                    commentReturn.put('PublishedDate', comment.Posted_Date__c);

                    // VC Team Response
                    commentReturn.put('ResponseDate', comment.Reponse_Date__c); // Fixed typo: Reponse_Date__c to Response_Date__c
                    commentReturn.put('VcTeamProfileUrl', comment.Answer_comments__r.FullPhotoUrl);
                    commentReturn.put('VcTeamRole', comment.Answer_comments__r.Title);
                    commentReturn.put('VcTeamName', comment.Commented_By_Name__c);
                    commentReturn.put('VcTeamResponse', comment.Response__c);

                    returnList.add(commentReturn);
                }
            }
            return returnList;
        } catch (Exception e) {
            Logger.logError('CommentApp', 'CommentService', 'getComments', raiseId, null, null, null, e, 'Failed to retrieve comments for raiseId: ' + raiseId);
            throw new AuraHandledException('Error retrieving comments for raiseId: ' + raiseId);
        }
    }
}