trigger MarketingPrerenceTrigger on Marketing_Preference__c (after insert, after update) {
    switch on Trigger.OperationType {
        when AFTER_UPDATE {
            MarketingPrerenceTriggerHandler.afterupdate();
        }       
        when AFTER_INSERT {
            MarketingPrerenceTriggerHandler.afterinsert();
        }        
    }
}