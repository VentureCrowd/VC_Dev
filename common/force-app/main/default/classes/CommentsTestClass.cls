@isTest 
private class CommentsTestClass { 
    @isTest
     static void testCommentCreation() {
        
         Product2 prdt = new Product2();
        prdt.Name = 'Test Prod';
        prdt.Offer_Launch_Date__c = system.now();
        prdt.Offer_Close_Date__c = system.now();
        insert prdt;
        Comment__c commentObj = Test_DataFactory.prepareComment(false, prdt.Id); 
        Test.startTest();
        commentsClass.createComment(commentObj, prdt.Id);
        commentObj.Approved__c = true;
         update commentObj;
         commentsClass.retriveComments(prdt.Id);
         commentsClass.retriveNextThreeComments(1, prdt.Id);
        Test.stopTest();       
    } 
}