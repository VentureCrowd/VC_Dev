public class KnowledgeFactory implements IKnowledgeFactory{
    
    
    
    public Knowledge__kav getArticle(Id articleId){
        Knowledge__kav article = [SELECT Id, 
                                  Answer__c, 
                                  Banner_image_URL__c, 
                                  Description__c, 
                                  Objective__c, 
                                  Question__c, 
                                  Title, 
                                  Course_length__c ,
                                  CreatedDate,
                                  LastPublishedDate,
                                  UrlName 
                                  FROM Knowledge__kav
                                 WHERE Id=:articleId];
        return article;
    }
    
    public List<Knowledge__kav> getArticlesFromCourse(Id courseId){
            List<Knowledge__kav> returnList = new  List<Knowledge__kav>();
            
            List<Course_article__c> courseArticleLinks = [SELECT Id, Name, Course__c, Knowledge__c 
                                                          FROM Course_article__c 
                                                          WHERE Course__c=:courseId ORDER BY Name ASC];
            
            for(Course_article__c courseArticleLink : courseArticleLinks){
                Id articleId = courseArticleLink.Knowledge__c;
                Knowledge__kav article = getArticle(articleId);
                System.debug(article);
                returnList.add(article);
            }	
            
            return returnList;
    }
    
    public Course__c getCourseDetails(Id courseId){
         Course__c course = [SELECT Id, 
                             Name,
                             Description__c,
                             Course_type__c
                             FROM Course__c
                             WHERE Id=:courseId];
        return course;
    }
    
    public List<Course__c> getCoursesFromLearning(Id learningId){
            List<Course__c> returnList = new  List<Course__c>();
            // setup return structure
            List<Learning_course__c> learningCourses = [SELECT Id, Course__c, Learning__c, Name
                                                        FROM Learning_course__c
                                                        WHERE Learning__c=:learningId];
            
            for(Learning_course__c learningCourse : learningCourses){
                Id courseId = learningCourse.Course__c;
                
                Course__c course = getCourseDetails(courseId);
                returnList.add(course);
            }
            
            return returnList;
            
    }

    public List<Learning_progress__c> getLearningProgressFromLearning(Id learningId){
        try{
            List<Learning_progress__c> returnList = [SELECT Id, Name,Completed__c,Knowledge__c ,Learning__c 
            FROM Learning_progress__c 
            WHERE Learning__c=:learningId];

            return returnList;
        }catch(Exception e){
            throw e;
        }
    }

    public Learning__c completeLearningCourse(Id learningId){
        try{
            Learning__c learningRecord = [SELECT Id, Completed__c,Completed_date__c FROM Learning__c WHERE Id=:learningId ];
            learningRecord.Completed__c = true;
            learningRecord.Completed_date__c = Date.today();
            update learningRecord;



            return learningRecord;
        }catch(Exception e){
            Logger.logError('RaiseApp', 'KnowledgeFactory', 'completeLearningCourse', null, null, null, null, e, 'Failed to complete learning' + e.getMessage());
            throw e;
        }
    }


    public Raise__c completeLearningRaise(Id raiseId){
        try{
            Raise__c raiseRecord = [SELECT Id, Learning_completed__c FROM Raise__c WHERE Id=:raiseId LIMIT 1];
            raiseRecord.Learning_completed__c = true;

            update raiseRecord;

            return raiseRecord;
        }catch(Exception e){
            Logger.logError('RaiseApp', 'KnowledgeFactory', 'completeLearningRaise', null, null, null, null, e, 'Failed to complete learning' + e.getMessage());
            throw e;
        }
    }

    public Boolean updateLearningProgressCompletion(Id learningProgId, Boolean completed){
        try{
            Learning_progress__c learningProgRecord = [SELECT Id, Completed__c FROM Learning_progress__c 
            WHERE Id=:learningProgId];

            learningProgRecord.Completed__c = completed;

            update learningProgRecord;
            return true;
        }catch(Exception e){
            throw e;
        }
    }

}