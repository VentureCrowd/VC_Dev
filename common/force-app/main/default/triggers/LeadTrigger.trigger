trigger LeadTrigger on Lead (before insert, after insert, after update,before update) 
{
    TriggerOnLead__c CS = TriggerOnLead__c.getOrgDefaults();
    if(CS.Is_Active__c || Test.isRunningTest())
    {
        if(Trigger.isBefore)
        {
            if(Trigger.isInsert)
            {
                //LeadTriggerHandler.leadReEnquiry(Trigger.new);
                LeadTriggerHandler.beforeInsert();
                LeadTriggerHandler.validateLostLead(Trigger.new, null);
            }
            if(Trigger.isUpdate){
                LeadTriggerHandler.beforeUpdate();
                LeadTriggerHandler.validateLostLead(Trigger.new, Trigger.oldMap);
            }
        }
        if(Trigger.isAfter)
        {
            if(Trigger.isInsert)
            {
                LeadTriggerHandler.deleteLead(Trigger.new);
                LeadTriggerHandler.syncMarketingPreferences(Trigger.new, null,Trigger.newMap);
            }
            if(Trigger.isUpdate)
            {
                LeadTriggerHandler.roundRobinOnOpportunity(Trigger.new, trigger.old);
                LeadTriggerHandler.syncMarketingPreferences(Trigger.new, Trigger.oldMap,Trigger.newMap);
            }
        }
    }
    
}