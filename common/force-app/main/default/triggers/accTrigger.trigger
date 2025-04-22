trigger accTrigger on Account (before insert, before update, after insert, after update) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            accTriggerHandler.beforeinsert();
        } else if(Trigger.isUpdate){
            // Execute lightweight before update logic synchronously.
            accTriggerHandler.beforeupdate();
            // Enqueue heavy before update logic asynchronously.
            AccountProcessor processor = new AccountProcessor(Trigger.new, Trigger.oldMap, Trigger.newMap, 'BEFORE_UPDATE');
            if (!System.isFuture() && !System.isQueueable()) {
                System.enqueueJob(processor);
            }
        }
    }
    if(Trigger.isAfter){
        AccountProcessor processor = new AccountProcessor(Trigger.new, Trigger.oldMap, Trigger.newMap, Trigger.operationType.name());
        if (!System.isFuture() && !System.isQueueable()) {
            System.enqueueJob(processor);
        }
    }
}