public class LearningFactory implements ILearningFactory {

    public Map<String,Object> createLearning(String companyName, List<String> courseNames){
        Map<String,Object> returnData = new Map<String,Object>();
        // create the learning object
        Learning__c learningRecord = new Learning__c();

        learningRecord.put('Name', companyName + ' Learning');

        insert learningRecord;

        returnData.put('learning', learningRecord);

        // assign the course with the Learning_course__c
        Id learningRecordId = learningRecord.Id;
        String learningRecordName = learningRecord.Name;

        List<Learning_course__c> linkedCourses = createLearningCourses(learningRecordId, learningRecordName, courseNames);

        returnData.put('learningCourses', linkedCourses);

        // using the Learning_courses__c create the  Learning_progress__c objects based on the course_articles__c records
        // this can be a list of learning courses
        for(Learning_course__c learningCourse : linkedCourses){
            Id course = learningCourse.Course__c;

            List<Course_article__c> courseArticles = [SELECT Id, Name, Knowledge__c, Course__c FROM Course_article__c WHERE Course__c=:course ORDER BY Name ASC];

            List<Learning_progress__c> linkedProgress = createLearningProgress(learningRecordId,learningRecordName,courseArticles);

            returnData.put('learningProgress'+course, linkedProgress);

        }
        

        return returnData;
    }

    public List<Learning_course__c> createLearningCourses(Id learningId, String learningName, List<String> courseNames){
        List<Learning_course__c> returnData = new List<Learning_course__c>();
        
        for(String courseName : courseNames){
            Course__c courseToAssign = [SELECT Id, Name FROM Course__c WHERE Name=:courseName];
            System.debug(courseName);
            System.debug(courseToAssign);
            // create new learning course link
            Learning_course__c newLearningCourseLink = new Learning_course__c();

            newLearningCourseLink.put('Name', learningName + ' X ' + courseName);
            newLearningCourseLink.put('Learning__c', learningId);
            newLearningCourseLink.put('Course__c', courseToAssign.Id);

            returnData.add(newLearningCourseLink);
        }

        insert returnData;

        return returnData;
    }


    public List<Learning_progress__c> createLearningProgress(Id learningId, String learningName, List<Course_article__c> courseArticles){
        //for each course article, get the knowledge article ID, and learning Id, then create the learning progress object
        List<Learning_progress__c> returnProgressRecords = new List<Learning_progress__c> ();

        for(Course_article__c courseArticle :courseArticles){
            Learning_progress__c newLearningProgress = new Learning_progress__c();

            String learningProgressName = learningName + ' X ' + courseArticle.Name;
            newLearningProgress.put('Name',learningProgressName);
            newLearningProgress.put('Knowledge__c',courseArticle.Knowledge__c);
            newLearningProgress.put('Learning__c', learningId);

            returnProgressRecords.add(newLearningProgress);
        }

        if(returnProgressRecords.size() > 0){
            insert returnProgressRecords;
        }

        return returnProgressRecords;
    }
}