trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert) {
    switch on Trigger.OperationType {
        when AFTER_INSERT {
            ContentDocumentLinkTriggerHandler.afterInsert();
        }
    }
    
}