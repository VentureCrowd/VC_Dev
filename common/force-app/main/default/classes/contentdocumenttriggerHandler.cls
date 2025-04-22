public with sharing class contentdocumenttriggerHandler {
    public static void oppfileshare(){
        List<id> oppidlst = new List<Id>();
        for (ContentDocumentLink cdl : (List<ContentDocumentLink>)trigger.new ) {
            string parentId = cdl.LinkedEntityId;
            if(parentId.left(3) =='006'){
                oppidlst.add(cdl.LinkedEntityId);
            }
        }
        String oppstage = 'Closed Won';
        if(!oppidlst.isEmpty()){    
            Map<Id,Opportunity> oppmap = new Map<Id,Opportunity>([SELECT Id FROM Opportunity WHERE StageName = :oppstage AND iD in :oppidlst]);
            OpportunityProcessor.sharefiles(new List<Id>(oppmap.keyset()));
        }
    }
}