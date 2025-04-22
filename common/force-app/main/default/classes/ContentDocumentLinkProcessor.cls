public class ContentDocumentLinkProcessor implements Queueable, Database.AllowsCallouts {
    private Set<Id> contentDocumentLinkIds;

    public ContentDocumentLinkProcessor(Set<Id> contentDocumentLinkIds) {
        System.debug(contentDocumentLinkIds);
        this.contentDocumentLinkIds = contentDocumentLinkIds;
    }

    public void execute(QueueableContext context) {

        if(!this.contentDocumentLinkIds.isEmpty()){

            Set<Id> contentDocIds = this.contentDocumentLinkIds;

            List<ContentDocumentLink> newContentDocumentLinks = [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink WHERE Id IN :contentDocIds];
            System.debug(newContentDocumentLinks);
            Set<Id> opportunityIds = new Set<Id>();
            for (ContentDocumentLink cdl : newContentDocumentLinks) {
                if (cdl.LinkedEntityId != null && String.valueOf(cdl.LinkedEntityId).startsWith('006') && !cdl.ContentDocument.Title.containsIgnoreCase('INTERNAL-')) {
                    opportunityIds.add(cdl.LinkedEntityId);
                }
            }
    
            if (opportunityIds.isEmpty()) {
                return;
            }
            
            System.debug(opportunityIds);
            Map<Id, Investment__c> opportunityIdToInvestmentMap = new Map<Id, Investment__c>();

            for (Investment__c inv : [SELECT Id, Opportunity__c FROM Investment__c WHERE Opportunity__c IN :opportunityIds]) {
                opportunityIdToInvestmentMap.put(inv.Opportunity__c, inv);
            }

            System.debug(opportunityIdToInvestmentMap);
            List<ContentDocumentLink> newInvestmentLinks = new List<ContentDocumentLink>();
            for (ContentDocumentLink cdl : newContentDocumentLinks) {
                if (cdl.LinkedEntityId != null && String.valueOf(cdl.LinkedEntityId).startsWith('006') && opportunityIdToInvestmentMap.containsKey(cdl.LinkedEntityId) && !cdl.ContentDocument.Title.containsIgnoreCase('INTERNAL-')) {
                    ContentDocumentLink newCdl = new ContentDocumentLink();
                    newCdl.ContentDocumentId = cdl.ContentDocumentId;
                    newCdl.LinkedEntityId = opportunityIdToInvestmentMap.get(cdl.LinkedEntityId).Id;
                    newCdl.ShareType = 'V';
                    newCdl.Visibility = 'AllUsers';
                    newInvestmentLinks.add(newCdl);
                }
            }
            
            System.debug(newInvestmentLinks);
            if (!newInvestmentLinks.isEmpty()) {
                Database.insert(newInvestmentLinks, false);
            }
        }
       
    }
}