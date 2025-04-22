/**

**/
public without sharing class commentsClass {
    @Auraenabled
     public static string createComment(Comment__c comObj,String productId)
     {
         if(productId != '' && productId != null) {
             comObj.Product__c = productId;
         }         
         upsert comObj;
         return comObj.Id;        
     }
 @auraenabled
     public static list<Comment__c> retriveComments(String productId){
         return [select id,Name,comments__c,Response__c,Approved__c,Commented_By_Name__c,Commented_By_Name_Investor__c,
         Post_Comments__r.Name,Post_Comments__r.UserRole.Name,Post_Comments__r.FullPhotoUrl,
         Answer_comments__r.Name,Answer_comments__r.UserRole.Name,Answer_comments__r.Title,Answer_comments__r.FullPhotoUrl,
         CreatedDate,Posted_Date__c,Reponse_Date__c FROM Comment__c where Approved__c=True AND Product__c=:productId Order By  createdDate DESC LIMIT 3];
     }
    
     @Auraenabled
     public static list<Comment__c> retriveNextThreeComments(Integer nextLimit,String productId){
         return [select id,Name,comments__c,Response__c,Approved__c,Commented_By_Name__c,Commented_By_Name_Investor__c,
         Post_Comments__r.Name,Post_Comments__r.UserRole.Name,Post_Comments__r.FullPhotoUrl,
         Answer_comments__r.Name,Answer_comments__r.UserRole.Name,Answer_comments__r.Title,Answer_comments__r.FullPhotoUrl,
         CreatedDate,Posted_Date__c,Reponse_Date__c FROM Comment__c where Approved__c=True AND Product__c=:productId Order By createdDate DESC LIMIT : nextLimit];
     }

 }