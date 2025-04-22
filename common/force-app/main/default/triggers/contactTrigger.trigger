trigger contactTrigger on Contact (after insert) {
    switch on Trigger.OperationType {
        when AFTER_UPDATE {

        }
        when BEFORE_UPDATE {

        }
        when AFTER_INSERT {
            contactTriggerHandler.updatetoPersonAcc(Trigger.new);
        }
    }
}