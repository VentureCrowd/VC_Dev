public without sharing class oppUtilityclass {
    @AuraEnabled
    public static Map<string,object> getdata(Id recordId){
        Map<string,object> retobj = new Map<string,object>();
        Opportunity opp = [SELECT ID,Contribution_Fee__c,Contribution_Fee_Original__c,Approval_Status__c,(SELECT Id,Contribution_Fee__c,Contribution_Fee_Original__c,Approval_Status__c FROM OpportunityLineItems) FROM Opportunity WHERE Id =:recordId];
        retobj.put('oppApproval_Status__c',opp.Approval_Status__c);
        retobj.put('Contribution_Fee__c',opp.OpportunityLineItems[0].Contribution_Fee__c);
        retobj.put('Contribution_Fee_Original__c',opp.OpportunityLineItems[0].Contribution_Fee_Original__c);
        retobj.put('oliId',opp.OpportunityLineItems[0].Id);
        return retobj;
    }
    @AuraEnabled
    public static void proceedwaiverequest(Id oppId, string comment,Decimal Contribution_Fee, Id oliId){
        try {
            Opportunity opp = new Opportunity();
            opp.Id = oppId;
            opp.Contribution_Fee__c = Contribution_Fee;
            opp.Approval_Status__c = 'Approval Required';
            update opp;
            OpportunityLineItem lineItem = new OpportunityLineItem();
            lineItem.Id = oliId;
            lineItem.Approval_Status__c = 'In Progress';
            lineItem.Contribution_Fee__c = Contribution_Fee;
            update lineItem;
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments(comment);
            req1.setObjectId(oppId);
            helper hlp =new helper();
            Id userId = hlp.getUserId() == NULL ?  Userinfo.getuserID() : hlp.getUserId();
            req1.setNextApproverIds(new Id[] {userId});
            Approval.ProcessResult result = Approval.process(req1);            
        }catch (Exception e) {
            throw new customException(e.getMessage());
        }
    }
    public class customException extends Exception {}
    public without sharing class helper{
        public string getUserId(){
            return [SELECT Id FROM USER WHERE USERNAME ='jason@venturecrowd.com.au']?.Id;
        }
    }
}