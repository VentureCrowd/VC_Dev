@isTest
public class KnowledgeControllerTest {
    @testSetup
    static void setup() {
      // Create test data for Knowledge__kav, Course__c, Course_article__c, Learning_course__c, and Learning_progress__c objects
        
        // Knowledge articles
        Knowledge__kav article1 = new Knowledge__kav(Title = 'Article 1', Description__c = 'Description 1', Course_length__c = 30, UrlName = 'article-1');
        insert article1;
        Knowledge__kav article2 = new Knowledge__kav(Title = 'Article 2', Description__c = 'Description 2', Course_length__c = 45, UrlName = 'article-2');
        insert article2;
        
        // Course
        Course__c course = new Course__c(Name = 'Course 1', Description__c = 'Course Description', Course_type__c = 'Any');
        insert course;
        
        // Course articles
        Course_article__c courseArticle1 = new Course_article__c(Course__c = course.Id, Knowledge__c = article1.Id);
        insert courseArticle1;
        Course_article__c courseArticle2 = new Course_article__c(Course__c = course.Id, Knowledge__c = article2.Id);
        insert courseArticle2;
        
        // Learning
        Learning__c learning = new Learning__c(Name = 'Learning 1');
        insert learning;
        
        // Learning courses
        Learning_course__c learningCourse1 = new Learning_course__c(Learning__c = learning.Id, Course__c = course.Id);
        insert learningCourse1;
        
        // Learning progress
        Learning_progress__c learningProgress = new Learning_progress__c(Learning__c = learning.Id, Knowledge__c = article1.Id, Completed__c = false);
        insert learningProgress;
        
        
        // Create and insert a test account
         Account personAccount = new Account(Name='Related Person');
         insert personAccount;
 
         Account businessAccount = new Account(Name='Test Business', Related_Person_Account__c=personAccount.Id);
         insert businessAccount;
 
         // Optional: Create and insert related records if needed (like EOI)
         EOI__c testEOI = new EOI__c(Name = 'Test EOI', Account__c = businessAccount.Id);
         insert testEOI;

         Lead testLead = new Lead(
            FirstName ='Test',
            LastName='Lead',
            Email='mail@mail.com',
            Related_EOI__c=testEOI.Id
         );
         insert testLead;

         
         
         Id ownerId = 'a3XXX000000cXXXAAI';
 
         List<User> benQuery = [SELECT Id FROM User WHERE Name='Ben Crow' LIMIT 1];
         if(benQuery.size() > 0){
             ownerId = benQuery[0].Id;
         }
        
         // Creating a Raise__c record to test existing raise functionality
         Raise__c testRaise = new Raise__c(
             Name = 'Test Raise',
             Account__c = personAccount.Id,
             Owner__c = ownerId,
             Company__c = businessAccount.Id,
             Learning__c = learning.Id,
             EOI__c = testEOI.Id,
             Status__c = 'In Progress',
             Payment_received__c = true,
             Content_approved__c = true,
             Course_unlocked__c = false,
             Learning_completed__c = false,
             Form_Problem_or_Opportunity__c = 'Test Problem',
             Form_Solution__c = 'Test Solution',
             Form_Differentiation__c = 'Test Differentiation',
             Form_Intellectual_Property__c = 'Test Intellectual Property',
             Form_Total_addressable_market__c = 'Test Market',
             Form_Progress__c = 'Test Progress',
             Form_Growth_plan__c = 'Test Growth Plan',
             Form_Valuation__c = 1000000,
             Form_Company_one_liner__c = 'Test Company Overview',
             Form_Offer_close_date__c = Date.today()
         );
         insert testRaise;
    }
    
    @isTest
    static void testGetArticleDetailsFromCourse() {
        Course__c course = [SELECT Id FROM Course__c LIMIT 1];
        
        Test.startTest();
        List<Map<String, Object>> result = KnowledgeController.getArticleDetailsFromCourse(course.Id);
        Test.stopTest();
        
        System.assertEquals(2, result.size());
    }
    
    @isTest
    static void testGetCoursesFromLearning() {
        Learning__c learning = [SELECT Id FROM Learning__c LIMIT 1];
        
        Test.startTest();
        List<Map<String, Object>> result = KnowledgeController.getCoursesFromLearning(learning.Id);
        Test.stopTest();
        
        System.assertEquals(1, result.size());
    }
    
    @isTest
    static void testGetProgressFromLearning() {
        Learning__c learning = [SELECT Id FROM Learning__c LIMIT 1];
        
        Test.startTest();
        List<Map<String, Object>> result = KnowledgeController.getProgressFromLearning(learning.Id);
        Test.stopTest();
        
        System.assertEquals(1, result.size());
    }
    
    @isTest
    static void testUpdateLearningCompletion() {
        Learning_progress__c learningProgress = [SELECT Id FROM Learning_progress__c LIMIT 1];
        
        Test.startTest();
        Boolean result = KnowledgeController.updateLearningCompletion(learningProgress.Id, true);
        Test.stopTest();
        
        System.assertEquals(true, result);
        
        Learning_progress__c updatedProgress = [SELECT Completed__c FROM Learning_progress__c WHERE Id = :learningProgress.Id];
        System.assertEquals(true, updatedProgress.Completed__c);
    }
    
     @isTest
    static void testCompleteLearningCourse() {
        Learning__c learningRecord = [SELECT Id FROM Learning__c LIMIT 1];
        Raise__c raiseRecord = [SELECT Id FROM Raise__c LIMIT 1];
        
        Test.startTest();
        Map<String,Object>  result = KnowledgeController.completeLearningCourse(learningRecord.Id, raiseRecord.Id);
        Test.stopTest();
        
        System.assertNotEquals(null,result);
    }
    
    @isTest
    static void testGetArticleContent() {
        Knowledge__kav article = [SELECT Id FROM Knowledge__kav LIMIT 1];
        
        Map<String, Object> result = KnowledgeController.getArticleContent(article.Id);
        System.assertEquals(article.Id, result.get('id'));
    }
}