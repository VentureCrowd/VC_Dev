/**

**/
public without sharing class KeyDocumentController {

    public static final string GUEST_USER = 'Guest';
    public static final string VISIBILITY_ALL_USERS = 'AllUsers';
    public static final string SF_BASE_URL = System.URL.getSalesforceBaseUrl().toExternalForm()+'/sfc/servlet.shepherd/document/download/';
   @AuraEnabled
   public static List<KeyDocumentWrapper> retrieveRelatedFiles(Id ProductId){
       try {
           String userType = UserInfo.getUserType();
           List<KeyDocumentWrapper> lstKeyDocumentWrapper = new List<KeyDocumentWrapper> ();
           Set<Id> setContentDcoumentid = new Set<Id>();
           Map<Id,ContentDistribution> mapContentDocumentidDistribution = new Map<Id,ContentDistribution>();
           contentDocumentLink[] lstContentDocument = [select id,ContentDocumentId, ContentDocument.LatestPublishedVersion.title,visibility from ContentDocumentLink where LinkedEntityId = :ProductId];
           
           if (!lstContentDocument.isEmpty()) {
            //    for (contentDocumentLink oContentDoc : lstContentDocument)  {
            //        setContentDcoumentid.add(oContentDoc.ContentDocumentId);
            //    }

            //    if (!setContentDcoumentid.isEmpty()) {
            //        ContentDistribution[] lstContentDistribution = [Select Id,ContentDocumentId,ContentDownloadUrl,DistributionPublicUrl from ContentDistribution where ContentDocumentId IN :setContentDcoumentid];
            //        if (!lstContentDistribution.isEmpty()) {
            //            for(ContentDistribution oContent : lstContentDistribution  ) {
            //              mapContentDocumentidDistribution.put(oContent.ContentDocumentId,oContent);
            //            }
            //        }
            //    }

               for (contentDocumentLink oContentDoc : lstContentDocument)  {

                //    if (mapContentDocumentidDistribution?.containsKey(oContentDoc.ContentDocumentId)) {
                //        lstKeyDocumentWrapper.add(new KeyDocumentWrapper(true,oContentDoc.ContentDocument.LatestPublishedVersion.title,mapContentDocumentidDistribution?.get(oContentDoc.ContentDocumentId).DistributionPublicUrl));
                //    } else 
                   if (userType != GUEST_USER && oContentDoc.visibility == VISIBILITY_ALL_USERS) {
                       lstKeyDocumentWrapper.add(new KeyDocumentWrapper(true,oContentDoc.ContentDocument.LatestPublishedVersion.title,SF_BASE_URL+oContentDoc.ContentDocumentId));
                   } else if (userType == GUEST_USER && oContentDoc.visibility == VISIBILITY_ALL_USERS){
                        lstKeyDocumentWrapper.add(new KeyDocumentWrapper(false,oContentDoc.ContentDocument.LatestPublishedVersion.title,''));
                   }
               }

           }

           return lstKeyDocumentWrapper;

       } catch (Exception e) {
           throw new AuraHandledException(e.getMessage());
       }
   }

   public class KeyDocumentWrapper {
       @AuraEnabled
       public  Boolean hasAccess{get; set;} 

       @AuraEnabled
       public  String fileName{get; set;}
       
       @AuraEnabled
       public  string  linkUrl{get; set;} 

       public KeyDocumentWrapper(Boolean hasAccess,String fileName, String  linkUrl) {
        this.hasAccess = hasAccess;
        this.fileName = fileName;
        this.linkUrl = linkUrl;
       }
   }
}