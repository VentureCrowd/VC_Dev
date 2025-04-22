public without sharing class ProdFileShare_batch implements Database.Batchable<sObject>, Schedulable  {
    public Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator('SELECT ID FROM Product2');
    }
    public void execute(Database.BatchableContext BC, List<Product2> scope){
      List<ContentDocumentLink> cdlst = [SELECT Id,LinkedEntityId,ContentDocumentId,ContentDocument.Title,ContentDocument.CreatedDate FROM ContentDocumentLink WHERE LinkedEntityId = :scope[0].Id 
                                                                                                                                                        AND ContentDocument.CreatedDate = LAST_N_DAYS:360 
                                                                                                                                                        AND (ContentDocument.Title like 'Monthly_Update%' OR 
                                                                                                                                                        ContentDocument.Title like 'Product_Update%' OR 
                                                                                                                                                        ContentDocument.Title like 'General_Update%' OR 
                                                                                                                                                        ContentDocument.Title like 'Corporate_Action%' OR
                                                                                                                                                        ContentDocument.Title like 'Investor_Update%' OR
                                                                                                                                                        ContentDocument.Title like 'Fund_Update%' 
                                                                                                                                                        ) ];
      Product2 prod = [SELECT Id,(SELECT Id FROM Opportunities__r) FROM Product2 WHERE Id = :scope[0].Id];
      Map<Id,Set<Id>> oppVScdmap = new Map<Id,Set<Id>>();
      Map<Id,Set<Id>> invVScdmap = new Map<Id,Set<Id>>();
      ContentDocumentLink cdlink;
      List<ContentDocumentLink> cdlinklst = new List<ContentDocumentLink>();
      Map<Id,opportunity> oppMap = new Map<Id,opportunity>([SELECT Id,Name,(SELECT Id,ContentDocumentId FROM ContentDocumentLinks),(SELECT Id FROM Investments1__r) FROM Opportunity WHERE Invested_Product_ADMIN_FIELD__c = :scope[0].Id]);
      Map<Id,Investment__c> invmap = new Map<Id,Investment__c>([SELECT Id,Name,(SELECT Id,ContentDocumentId FROM ContentDocumentLinks) FROM Investment__c WHERE Opportunity__r.Invested_Product_ADMIN_FIELD__c = :scope[0].Id]);
      for(Investment__c inv : invmap.values()){
        if(!invVScdmap.containsKey(inv.Id))
        invVScdmap.put(inv.Id,new Set<ID>());
        for(ContentDocumentLink cdl : inv.ContentDocumentLinks){
          invVScdmap.get(inv.Id).add(cdl.ContentDocumentId);
        }
      }
      for(Id i : invmap.keyset()){
        for(ContentDocumentLink cdl : cdlst){
          if(!invVScdmap.get(i).contains(cdl.ContentDocumentId)){
             cdlink = new ContentDocumentLink();
              cdlink.ContentDocumentId = cdl.ContentDocumentId;
              cdlink.LinkedEntityId = i;
              cdlink.ShareType = 'V';
              cdlink.Visibility = 'AllUsers';
              cdlinklst.add(cdlink);
          }
        }
      }
      if(!cdlinklst.isEmpty())
      insert cdlinklst;
    }
    public void finish(Database.BatchableContext BC){
    }
    public void execute(SchedulableContext SC) {
      Database.executeBatch(new ProdFileShare_batch(), 1);
    }
}