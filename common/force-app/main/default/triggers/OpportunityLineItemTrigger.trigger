trigger OpportunityLineItemTrigger on OpportunityLineItem (before insert) {
    switch on Trigger.OperationType {
        when BEFORE_INSERT {
            OpportunityLineItemTriggerHandler.beforeInsert(Trigger.new);
        }
    }

}