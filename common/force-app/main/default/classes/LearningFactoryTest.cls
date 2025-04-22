@isTest
public class LearningFactoryTest {
    @isTest
    static void testCreateLearning() {
        // Create test data
        List<Knowledge__kav> knowledgeArticles = new List<Knowledge__kav>{
            new Knowledge__kav(Title = 'Knowledge Article 1',UrlName='ka-1'),
            new Knowledge__kav(Title = 'Knowledge Article 2',UrlName='ka-2')
        };
        insert knowledgeArticles;
        
        List<Course__c> courses = new List<Course__c>{
            new Course__c(Name = 'Course 1'),
            new Course__c(Name = 'Course 2')
        };
        insert courses;

        List<Course_article__c> courseArticles = new List<Course_article__c>{
            new Course_article__c(Name = 'Article 1', Knowledge__c = knowledgeArticles[0].Id, Course__c = courses[0].Id),
            new Course_article__c(Name = 'Article 2', Knowledge__c = knowledgeArticles[1].Id, Course__c = courses[1].Id)
        };
        insert courseArticles;

        // Instantiate the LearningFactory
        LearningFactory factory = new LearningFactory();

        // Call the createLearning method
        Test.startTest();
        Map<String, Object> result = factory.createLearning('Test Company', new List<String>{'Course 1', 'Course 2'});
        Test.stopTest();

        // Verify the learning record
        Learning__c learning = (Learning__c) result.get('learning');
        System.assertNotEquals(null, learning.Id, 'Learning record should be created');
        System.assertEquals('Test Company Learning', learning.Name, 'Learning record name should be correctly set');

        // Verify the learning courses
        List<Learning_course__c> learningCourses = (List<Learning_course__c>) result.get('learningCourses');
        System.assertEquals(2, learningCourses.size(), 'There should be two learning courses created');
        System.assertEquals(courses[0].Id, learningCourses[0].Course__c, 'Learning course should be linked to the correct course');
        System.assertEquals(courses[1].Id, learningCourses[1].Course__c, 'Learning course should be linked to the correct course');

        // Verify the learning progress
        List<Learning_progress__c> learningProgress1 = (List<Learning_progress__c>) result.get('learningProgress' + courses[0].Id);
        List<Learning_progress__c> learningProgress2 = (List<Learning_progress__c>) result.get('learningProgress' + courses[1].Id);
        System.assertEquals(1, learningProgress1.size(), 'There should be one learning progress created for Course 1');
        System.assertEquals(1, learningProgress2.size(), 'There should be one learning progress created for Course 2');
        System.assertEquals(knowledgeArticles[0].Id, learningProgress1[0].Knowledge__c, 'Learning progress should be linked to the correct knowledge article');
        System.assertEquals(knowledgeArticles[1].Id, learningProgress2[0].Knowledge__c, 'Learning progress should be linked to the correct knowledge article');
    }

    @isTest
    static void testCreateLearningCourses() {
        // Create test data
        Learning__c learning = new Learning__c(Name = 'Test Learning');
        insert learning;

        List<Course__c> courses = new List<Course__c>{
            new Course__c(Name = 'Course 1'),
            new Course__c(Name = 'Course 2')
        };
        insert courses;

        // Instantiate the LearningFactory
        LearningFactory factory = new LearningFactory();

        // Call the createLearningCourses method
        Test.startTest();
        List<Learning_course__c> result = factory.createLearningCourses(learning.Id, learning.Name, new List<String>{'Course 1', 'Course 2'});
        Test.stopTest();

        // Verify the learning courses
        System.assertEquals(2, result.size(), 'There should be two learning courses created');
        System.assertEquals(courses[0].Id, result[0].Course__c, 'Learning course should be linked to the correct course');
        System.assertEquals(courses[1].Id, result[1].Course__c, 'Learning course should be linked to the correct course');
    }

    @isTest
    static void testCreateLearningProgress() {
        // Create test data
        Learning__c learning = new Learning__c(Name = 'Test Learning');
        insert learning;

        List<Knowledge__kav> knowledgeArticles = new List<Knowledge__kav>{
            new Knowledge__kav(Title = 'Knowledge Article 1',UrlName='ka-1'),
            new Knowledge__kav(Title = 'Knowledge Article 2',UrlName='ka-2')
        };
        insert knowledgeArticles;

        List<Course__c> courses = new List<Course__c>{
            new Course__c(Name = 'Course 1'),
            new Course__c(Name = 'Course 2')
        };
        insert courses;

        List<Course_article__c> courseArticles = new List<Course_article__c>{
            new Course_article__c(Name = 'Article 1', Knowledge__c = knowledgeArticles[0].Id, Course__c=courses[0].Id),
            new Course_article__c(Name = 'Article 2', Knowledge__c = knowledgeArticles[1].Id, Course__c=courses[1].Id)
        };
        insert courseArticles;

        // Instantiate the LearningFactory
        LearningFactory factory = new LearningFactory();

        // Call the createLearningProgress method
        Test.startTest();
        List<Learning_progress__c> result = factory.createLearningProgress(learning.Id, learning.Name, courseArticles);
        Test.stopTest();

        // Verify the learning progress records
        System.assertEquals(2, result.size(), 'There should be two learning progress records created');
        System.assertEquals(knowledgeArticles[0].Id, result[0].Knowledge__c, 'Learning progress should be linked to the correct knowledge article');
        System.assertEquals(knowledgeArticles[1].Id, result[1].Knowledge__c, 'Learning progress should be linked to the correct knowledge article');
    }
}