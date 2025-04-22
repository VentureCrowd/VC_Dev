public class ContentDocumentLinkTriggerHandler {
    public static void afterInsert() {
        Set<Id> newContentDocumentLinkIds = Trigger.newMap.keySet();

        // Log the IDs being processed
        String resultString = String.join(new List<Id>(newContentDocumentLinkIds), ',');

        // Enqueue the processing of ContentDocumentLinks
        System.enqueueJob(new ContentDocumentLinkProcessor(newContentDocumentLinkIds));
    }
}