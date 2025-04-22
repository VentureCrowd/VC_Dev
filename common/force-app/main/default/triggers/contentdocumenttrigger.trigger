trigger contentdocumenttrigger on ContentDocumentLink (after insert) {
    contentdocumenttriggerHandler.oppfileshare();
}