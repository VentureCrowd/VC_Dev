public interface IKnowledgeFactory {
    Knowledge__kav getArticle(Id articleId);
    List<Knowledge__kav> getArticlesFromCourse(Id courseId);
    Boolean updateLearningProgressCompletion(Id learningProgId, Boolean completed);
}