public  without sharing class KnowledgeController {
     @TestVisible private static KnowledgeService knowledgeService = new KnowledgeService();

    @AuraEnabled
    public static List<Map<String, Object>> getArticleDetailsFromCourse(Id courseId) {
        return knowledgeService.getArticleDetailsFromCourse(courseId);
    }
    
    @AuraEnabled
    public static List<Map<String, Object>> getCoursesFromLearning(Id learningId) {
        return knowledgeService.getCoursesFromLearning(learningId);
      
    }

    @AuraEnabled
    public static Map<String, Object> getArticleContent(Id articleId) {
        return knowledgeService.getArticleContent(articleId);
      
    }

    @AuraEnabled
    public static List<Map<String, Object>> getProgressFromLearning(Id learningId) {
        return knowledgeService.getLearningProgressFromLearning(learningId);
       
    }

    @AuraEnabled
    public static Boolean updateLearningCompletion(Id learningProgId, Boolean completed) {
        return knowledgeService.updateLearningProgressCompletion(learningProgId,completed);
    }

    @AuraEnabled
    public static Map<String,Object> completeLearningCourse(Id learningId, Id raiseId){
        try {
            return knowledgeService.completeLearningProgress(learningId, raiseId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}