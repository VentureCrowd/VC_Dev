public with sharing class FileSharingProductObj {
    // Define a class to encapsulate the flow input
    public class FlowInputs {
        @InvocableVariable
        public String uploadedFileId; // Correcting the type to String for the ID
        @InvocableVariable
        public String productId; // Product2 Id
    }

    // Define the invocable method to process the input from the flow
    @InvocableMethod
    public static void shareFileWithInvestments(List<FlowInputs> inputs) {
        for (FlowInputs input : inputs) {
            // Query the ContentDocumentLink using the uploadedFileId which is a String
            ContentDocumentLink cdl = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE Id = :input.uploadedFileId LIMIT 1];

            // Query ContentDocumentLinks for the specified Product2 record
            List<ContentDocumentLink> cdlst = [
                SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title, ContentDocument.CreatedDate 
                FROM ContentDocumentLink 
                WHERE LinkedEntityId = :input.productId
                AND ContentDocument.CreatedDate = LAST_N_DAYS:8 
                AND (
                    ContentDocument.Title LIKE 'Monthly_Update%' OR 
                    ContentDocument.Title LIKE 'Product_Update%' OR 
                    ContentDocument.Title LIKE 'General_Update%' OR 
                    ContentDocument.Title LIKE 'Corporate_Action%' OR 
                    ContentDocument.Title LIKE 'Investor_Update%' OR 
                    ContentDocument.Title LIKE 'Fund_Update%'
                )
            ];
            // Fetch Opportunities and Investments related to the specified Product2 record
            Map<Id, Investment__c> invMap = new Map<Id, Investment__c>([
                SELECT Id, Name, (SELECT Id, ContentDocumentId FROM ContentDocumentLinks) 
                FROM Investment__c 
                WHERE Opportunity__r.Invested_Product_ADMIN_FIELD__c = :input.productId
            ]);

            // Initialize maps to track already linked documents
            Map<Id, Set<Id>> invVScdMap = new Map<Id, Set<Id>>();
            for (Investment__c inv : invMap.values()) {
                invVScdMap.put(inv.Id, new Set<ID>());
                for (ContentDocumentLink invCdl : inv.ContentDocumentLinks) {
                    invVScdMap.get(inv.Id).add(invCdl.ContentDocumentId);
                }
            }

            // Prepare ContentDocumentLinks to insert
            List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
            for (Id invId : invMap.keySet()) {
                for (ContentDocumentLink productCdl : cdlst) {
                    if (!invVScdMap.get(invId).contains(productCdl.ContentDocumentId)) {
                        ContentDocumentLink newCdl = new ContentDocumentLink(
                            ContentDocumentId = productCdl.ContentDocumentId,
                            LinkedEntityId = invId,
                            ShareType = 'V',
                            Visibility = 'AllUsers'
                        );
                        contentDocumentLinks.add(newCdl);
                    }
                }
            }

            // Insert the new content document links
            if (!contentDocumentLinks.isEmpty()) {
                insert contentDocumentLinks;
            }
        }
    }
}