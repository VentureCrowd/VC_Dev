public class KnowledgeService {
    private KnowledgeFactory factory = new KnowledgeFactory();
    
    public List<Map<String,Object>> getArticleDetailsFromCourse(Id courseId){
        try{
            // setup return structure
            List<Map<String,Object>> returnList = new  List<Map<String,Object>>();
            
            // get articles from factory
            List<Knowledge__kav> articles = factory.getArticlesFromCourse(courseId);
            
            //loop thru return result and create the article structure
            for(Knowledge__kav article : articles){
                Map<String,Object> articleReturn = new Map<String,Object>();
                
                articleReturn.put('id', article.Id);
                articleReturn.put('title', article.Title);
                articleReturn.put('description', article.Description__c);
                articleReturn.put('estimatedCompletionTime' , article.Course_length__c);
                articleReturn.put('urlName', article.UrlName);
                returnList.add(articleReturn);
            }
            
            return returnList;
        }catch(Exception e){
            throw e;
        }
    }
    
    public Map<String,Object> getArticleContent(Id articleId){
        try{
            // setup return structure
           	Map<String,Object> articleReturn = new Map<String,Object>();
            // get articles from factory
            Knowledge__kav article = factory.getArticle(articleId);
                        
            articleReturn.put('id', article.Id);
            articleReturn.put('title', article.Title);
            articleReturn.put('description', article.Description__c);
            articleReturn.put('objective', article.Objective__c);
            articleReturn.put('createdDate', article.CreatedDate);
            articleReturn.put('lastPublishedDate', article.LastPublishedDate);
            articleReturn.put('question', article.Question__c);
            articleReturn.put('answer', article.Answer__c);
           	articleReturn.put('estimatedCompletionTime' , article.Course_length__c);
            return articleReturn;
        }catch(Exception e){
            throw e;
        }
    }
    
    public List<Map<String,Object>> getCoursesFromLearning(Id learningId){
        try{
             // setup return structure
            List<Map<String,Object>> returnList = new  List<Map<String,Object>>();
            
            // get courses from learningId
            List<Course__c> courses = factory.getCoursesFromLearning(learningId);
        	
             for(Course__c course : courses){
                Map<String,Object> courseReturn = new Map<String,Object>();
                
                courseReturn.put('id', course.Id);
                courseReturn.put('title', course.Name);
                courseReturn.put('description', course.Description__c);
                
                
                returnList.add(courseReturn);
            }
            
            return returnList;
			            
        }catch(Exception e){
            throw e;
        }
    }

    public List<Map<String,Object>> getLearningProgressFromLearning(Id learningId){
        try{
             // setup return structure
            List<Map<String,Object>> returnList = new  List<Map<String,Object>>();
            
            // get courses from learningId
            List<Learning_progress__c> learningProgressItems = factory.getLearningProgressFromLearning(learningId);
        	
             for(Learning_progress__c learningProgress : learningProgressItems){

                Map<String,Object> learningProgressReturn = new Map<String,Object>();
                
                learningProgressReturn.put('id', learningProgress.Id);
                learningProgressReturn.put('name', learningProgress.Name);
                learningProgressReturn.put('completed', learningProgress.Completed__c);
                learningProgressReturn.put('articleId', learningProgress.Knowledge__c);
                learningProgressReturn.put('learningId', learningProgress.Learning__c);
                
                
                returnList.add(learningProgressReturn);
            }
            
            return returnList;
			            
        }catch(Exception e){
            throw e;
        }
    }


    public Boolean updateLearningProgressCompletion(Id learningProgId, Boolean completed){
        try{
            factory.updateLearningProgressCompletion(learningProgId,completed);
            return true;
        }catch(Exception e){
            throw e;
        }
    }

    public Map<String,Object> completeLearningProgress(Id learningId, Id raiseId){
        try{
            Learning__c learningRecord =  factory.completeLearningCourse(learningId);
            Raise__c raiseRecord = factory.completeLearningRaise(raiseId);

            Map<String,Object> retData = new Map<String,Object>();
            retData.put('raiseId', raiseRecord.Id);
            retData.put('raiseLearningStatus',raiseRecord.Learning_completed__c);
            retData.put('learningId' , learningRecord.Id);
            retData.put('completed' ,learningRecord.Completed__c);
            retData.put('completedDate',learningRecord.Completed_date__c);

            return retData;
        }catch(Exception e){
            throw e;
        }
    }
}