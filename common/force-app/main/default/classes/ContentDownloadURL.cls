public without sharing class ContentDownloadURL {
    //? Wrap to hold the title and content DownloadURL
    public class FileDownloadUrl {
        @AuraEnabled
        public String title;
        @AuraEnabled
        public String contentDownloadURL;
        
        public FileDownloadUrl(String title, String contentDownloadURL) {
            this.title = title;
            this.contentDownloadURL = contentDownloadURL;
        }
    }
    
    @AuraEnabled
    public static List<FileDownloadUrl> getSalesforceFilesDownloadUrls(Id recordId) {
    // public static List<FileDownloadUrl> getSalesforceFilesDownloadUrls(String recordId, String customObject, String customField ) {
        List<FileDownloadUrl> fileDownloadUrls = new List<FileDownloadUrl>();
        try {
            Map<Id, String> documentIdToTitle = new Map<Id, String>();
            List<ContentDocumentLink> documentLinks = [
                SELECT ContentDocumentId, ContentDocument.Title
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :recordId
            ];
            for (ContentDocumentLink link : documentLinks) {
                documentIdToTitle.put(link.ContentDocumentId, link.ContentDocument.Title);
            }

            if (documentIdToTitle.isEmpty()) {
                return fileDownloadUrls;
            }

            List<ContentVersion> contentVersions = [
                SELECT Id, ContentDocumentId
                FROM ContentVersion
                WHERE ContentDocumentId IN :documentIdToTitle.keySet()
                AND IsLatest = true
            ];

            List<ContentDistribution> distributionsToInsert = new List<ContentDistribution>();
            for (ContentVersion version : contentVersions) {
                ContentDistribution distribution = new ContentDistribution();
                distribution.ContentVersionId = version.Id;
                distribution.Name = 'External Link ' + documentIdToTitle.get(version.ContentDocumentId);
                distribution.PreferencesNotifyOnVisit = false;
                distribution.PreferencesAllowViewInBrowser = true;
                distribution.PreferencesAllowOriginalDownload = true;
                distribution.PreferencesPasswordRequired = false;
                distributionsToInsert.add(distribution);
            }
            insert distributionsToInsert;


            Map<Id, String> versionIdToTitle = new Map<Id, String>();
            for (ContentVersion version : contentVersions) {
                versionIdToTitle.put(version.Id, documentIdToTitle.get(version.ContentDocumentId));
            }

            List<ContentDistribution> fetchedDistributions = [
                SELECT Id, ContentDownloadUrl, ContentVersionId
                FROM ContentDistribution
                WHERE Id IN :distributionsToInsert
            ];

            for (ContentDistribution dist : fetchedDistributions) {
                String title = versionIdToTitle.get(dist.ContentVersionId);
                fileDownloadUrls.add(new FileDownloadUrl(title, dist.ContentDownloadUrl));
            }

            // Serialize the fileDownloadUrls list into a JSON string
            String jsonFileDownloadUrls = JSON.serialize(fileDownloadUrls);
            
            // Update the custom object record with the JSON string
            EOI__c eoiRecord = [SELECT Id, URL_Files_Img__c FROM EOI__c WHERE Id = :recordId LIMIT 1];
            eoiRecord.URL_Files_Img__c = jsonFileDownloadUrls;
            update eoiRecord;

            } catch (Exception e) {
                System.debug('Error retrieving file download URLs: ' + e.getMessage());
            }
    // EOI__c eoiRecord = [SELECT Id, Banner_URL__c, Logo_URL__c FROM EOI__c WHERE Id = :recordId LIMIT 1];
    // eoiRecord.Banner_URL__c = fileDownloadUrls[0].contentDownloadURL;
    // eoiRecord.Logo_URL__c = fileDownloadUrls[1].contentDownloadURL;
    // update eoiRecord;
    return fileDownloadUrls;
    }
}