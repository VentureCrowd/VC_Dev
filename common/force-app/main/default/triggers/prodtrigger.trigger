trigger prodtrigger on Product2 (after insert, after update,before insert, before update) {
    switch on Trigger.OperationType {
        when AFTER_INSERT {
            prodTriggerHandler.handleROIlogs();
        }
        when AFTER_UPDATE {
            prodTriggerHandler.handleROIlogs();
        }
        when BEFORE_UPDATE {
            
        }
        when BEFORE_INSERT {
            
        }
    }
}