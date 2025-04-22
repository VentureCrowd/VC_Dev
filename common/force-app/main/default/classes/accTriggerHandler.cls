public without sharing class accTriggerHandler {
    public static void beforeinsert(){
        for(Account a : (List<Account>) Trigger.new){
            // Only set investment flag synchronously.
            a.Has_Made_1_Investment__c = a.Total_Investment__c >= 1;         
        }
    }
 
    public static void beforeupdate(){
        // Minimal synchronous logic here.
        for(Account a : (List<Account>) Trigger.new){
            // If Approval_Status changed to Approved, update owner
            if(a.Approval_Status__c == 'Approved' && Trigger.oldMap.get(a.Id).get('Approval_Status__c') <> a.get('Approval_Status__c')){
                a.OwnerId = a.Approval_Requested_For__c;
            }
            // Set the investment flag
            a.Has_Made_1_Investment__c = a.Total_Investment__c >= 1;
        }
    }
}