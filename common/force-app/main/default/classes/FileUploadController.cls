public without sharing class FileUploadController {
    @AuraEnabled
    public static Id uploadFile(String fileName, String base64FileContents, Id recordId, String fieldName) {
        
        
        // Validate input parameters
        if (String.isEmpty(fileName) || String.isEmpty(base64FileContents)) {
            throw new IllegalArgumentException('File name and contents cannot be empty.');
        }

        if (fieldName == null) {
            throw new IllegalArgumentException('File must be attached to a field name, cannot be null.');
        }

        // check if file recordId is provided
        Boolean linkFile = true;
        if(recordId == null){
            linkFile = false;
        }

        try {
            // Decode the base64 encoded file content
            Blob fileContentsBlob = EncodingUtil.base64Decode(base64FileContents);

            // Create a new ContentVersion record to store the file
            ContentVersion newFile = new ContentVersion();
            newFile.Title = fileName;
            newFile.PathOnClient = fileName; // PathOnClient must include the file extension
            newFile.VersionData = fileContentsBlob;
            newFile.Origin = 'H'; // 'H' denotes files uploaded via API
            newFile.Form_field__c = fieldName; // Set the custom field Form_field__c

            // Insert the new ContentVersion
            insert newFile;



            // Query for the ContentDocumentId related to the inserted ContentVersion
            Id newContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :newFile.Id].ContentDocumentId;

            // Link the new ContentDocument to the specified record
            if(linkFile){
                linkContentDocument(newContentDocumentId, recordId);
                Logger.logMessage('FileUploadApp', 'FileUploadController', 'uploadFile', 'Successfully uploaded file with name: ' + fileName + ' to recordId: ' + recordId);
            }else{
                Logger.logMessage('FileUploadApp', 'FileUploadController', 'uploadFile', 'Successfully uploaded file with name: ' + fileName);
            }
            
            return newContentDocumentId;
        } catch (Exception e) {
            Logger.logError('FileUploadApp', 'FileUploadController', 'uploadFile', recordId, null, null, null, e, 'Failed to upload file with name: ' + fileName + ' to recordId: ' + recordId);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Links the ContentDocument to the specified record.
     * @param contentDocumentId The ID of the ContentDocument.
     * @param recordId The ID of the record to link to.
     */
    @AuraEnabled
    public static Id linkContentDocument(Id contentDocumentId, Id recordId) {

        // Check if the ContentDocumentLink already exists
        List<ContentDocumentLink> existingLinks = [
            SELECT Id 
            FROM ContentDocumentLink 
            WHERE ContentDocumentId = :contentDocumentId 
            AND LinkedEntityId = :recordId
        ];

        ContentDocumentLink link;
        if (existingLinks.isEmpty()) {
            // Link the new ContentDocument to the specified record
            link = new ContentDocumentLink();
            link.ContentDocumentId = contentDocumentId;
            link.LinkedEntityId = recordId; // This is the ID of the record to link to
            link.ShareType = 'V'; // V for Viewer permissions, can also use 'C' for Collaborator or 'I' for Inferred
            link.Visibility = 'AllUsers'; // Controls visibility; use 'AllUsers' or 'InternalUsers'
            // Insert the ContentDocumentLink
            insert link;
        } else {
            link = existingLinks[0];
        }

        // Retrieve the latest ContentVersionId for the given ContentDocumentId
        ContentVersion contentVersion = [
            SELECT Id
            FROM ContentVersion
            WHERE ContentDocumentId = :contentDocumentId
            ORDER BY VersionNumber DESC
            LIMIT 1
        ];

        // Check if a ContentDistribution already exists for this ContentVersion
        List<ContentDistribution> existingDistributions = [
            SELECT Id 
            FROM ContentDistribution 
            WHERE ContentVersionId = :contentVersion.Id
        ];

        if (existingDistributions.isEmpty()) {
            // Otherwise, create a new ContentDistribution for this ContentVersion
            ContentDistribution distribution = new ContentDistribution();
            distribution.Name = 'Public Distribution for ' + link.ContentDocumentId;
            distribution.ContentVersionId = contentVersion.Id;
            distribution.PreferencesAllowViewInBrowser = true;
            distribution.PreferencesLinkLatestVersion = true;
            distribution.PreferencesNotifyOnVisit = false;
            distribution.PreferencesPasswordRequired = false;
            distribution.PreferencesAllowOriginalDownload = true;
            insert distribution;
        }

        Logger.logMessage('FileUploadApp', 'FileUploadController', 'linkContentDocument', 'Successfully linked ContentDocumentId: ' + contentDocumentId + ' to recordId: ' + recordId);
        return link.Id;
    }

    /**
     * Deletes a file by its ID.
     * @param fileId The ID of the file to be deleted.
     * @return Boolean indicating success or failure.
     */
    @AuraEnabled
    public static Boolean deleteFileById(String fileId) {
        try {
            ContentDocument file = [SELECT Id FROM ContentDocument WHERE Id = :fileId LIMIT 1];
            delete file;
            Logger.logMessage('FileUploadApp', 'FileUploadController', 'deleteFileById', 'Successfully deleted file with Id: ' + fileId);
            return true;
        } catch (Exception e) {
            Logger.logError('FileUploadApp', 'FileUploadController', 'deleteFileById', fileId, null, null, null, e, 'Failed to delete file by Id: ' + fileId);
            return false;
        }
    }

    /**
     * Deletes a file by its name.
     * @param fileName The name of the file to be deleted.
     * @return Boolean indicating success or failure.
     */
    @AuraEnabled
    public static Boolean deleteFileByName(String fileName) {
        try {
            List<ContentDocument> files = [SELECT Id FROM ContentDocument WHERE Title = :fileName];
            if (!files.isEmpty()) {
                delete files;
                Logger.logMessage('FileUploadApp', 'FileUploadController', 'deleteFileByName', 'Successfully deleted file with name: ' + fileName);
                return true;
            } else {
                Logger.logMessage('FileUploadApp', 'FileUploadController', 'deleteFileByName', 'No file found with name: ' + fileName);
                return false;
            }
        } catch (Exception e) {
            Logger.logError('FileUploadApp', 'FileUploadController', 'deleteFileByName', fileName, null, null, null, e, 'Failed to delete file by name: ' + fileName);
            return false;
        }
    }
    /**
     * Gets all files by a specific field name.
     * @param fieldName The field name to filter files by.
     * @param recordId The record ID to filter files by.
     * @return List of file information maps.
     */
    @AuraEnabled
    public static List<Map<String, Object>> getFilesByFieldName(String fieldName, Id recordId) {
        List<Map<String, Object>> filesList = new List<Map<String, Object>>();
        try {
            if (String.isEmpty(fieldName) || recordId == null) {
                throw new IllegalArgumentException('Field name and record ID cannot be empty.');
            }

            // First, get the ContentDocumentIds linked to the recordId
            List<ContentDocumentLink> documentLinks = [
                SELECT ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :recordId
            ];
            
            if (!documentLinks.isEmpty()) {
                Set<Id> contentDocumentIds = new Set<Id>();
                for (ContentDocumentLink link : documentLinks) {
                    contentDocumentIds.add(link.ContentDocumentId);
                }

                // Then, query the ContentVersions using the ContentDocumentIds and field name
                List<ContentVersion> contentVersions = [
                    SELECT Id, Title, ContentDocumentId, Form_field__c
                    FROM ContentVersion
                    WHERE Form_field__c = :fieldName
                    AND ContentDocumentId IN :contentDocumentIds
                ];

                for (ContentVersion cv : contentVersions) {
                    Map<String, Object> fileMap = new Map<String, Object>();
                    fileMap.put('index', filesList.size());
                    fileMap.put('fileName', cv.Title);
                    fileMap.put('internalName', cv.Form_field__c);
                    fileMap.put('fileId', cv.ContentDocumentId);
                    filesList.add(fileMap);
                }
            }

            Logger.logMessage('FileUploadApp', 'FileUploadController', 'getFilesByFieldName', 'Successfully retrieved files for fieldName: ' + fieldName + ' and recordId: ' + recordId);
        } catch (IllegalArgumentException e) {
            Logger.logError('FileUploadApp', 'FileUploadController', 'getFilesByFieldName', fieldName, recordId, null, null, e, 'Invalid input parameters.');
            throw new AuraHandledException('Invalid input parameters: ' + e.getMessage());
        } catch (Exception e) {
            Logger.logError('FileUploadApp', 'FileUploadController', 'getFilesByFieldName', fieldName, recordId, null, null, e, 'Failed to retrieve files for fieldName: ' + fieldName + ' and recordId: ' + recordId);
            throw new AuraHandledException('An unexpected error occurred: ' + e.getMessage());
        }
        return filesList;
    }

    /**
     * Gets all files by a name without the extension.
     * @param fileNameWithoutExtension The name of the file without the extension.
     * @return List of file information maps.
     */
    @AuraEnabled
    public static List<Map<String, Object>> getFilesByNameWithoutExtension(String fileNameWithoutExtension) {
        List<Map<String, Object>> filesList = new List<Map<String, Object>>();
        try {
            List<ContentDocument> contentDocuments = [
                SELECT Id, Title, LatestPublishedVersionId
                FROM ContentDocument
                WHERE Title LIKE :fileNameWithoutExtension + '%'
            ];
            Integer counter = 0;
            for (ContentDocument cd : contentDocuments) {
                ContentVersion cv = [
                    SELECT Id, Title, ContentDocumentId, Form_field__c
                    FROM ContentVersion
                    WHERE Id = :cd.LatestPublishedVersionId
                    LIMIT 1
                ];
                Map<String, Object> fileMap = new Map<String, Object>();
                fileMap.put('index', counter);
                fileMap.put('fileName', cv.Title);
                fileMap.put('internalName', cv.Form_field__c);
                fileMap.put('fileId', cv.ContentDocumentId);
                filesList.add(fileMap);
                counter ++;
            }
            Logger.logMessage('FileUploadApp', 'FileUploadController', 'getFilesByNameWithoutExtension', 'Successfully retrieved files with name: ' + fileNameWithoutExtension);
        } catch (Exception e) {
            Logger.logError('FileUploadApp', 'FileUploadController', 'getFilesByNameWithoutExtension', fileNameWithoutExtension, null, null, null, e, 'Failed to retrieve files with name: ' + fileNameWithoutExtension);
        }
        return filesList;
    }
    @AuraEnabled
    public static String getPublicImageUrl(Id recordId) {
        try {
            // Retrieve the ContentDocumentId linked to the recordId
            ContentDocumentLink documentLink = [
                SELECT ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :recordId
                LIMIT 1
            ];

            // Retrieve the latest ContentVersionId for the given ContentDocumentId
            ContentVersion contentVersion = [
                SELECT Id
                FROM ContentVersion
                WHERE ContentDocumentId = :documentLink.ContentDocumentId
                ORDER BY VersionNumber DESC
                LIMIT 1
            ];
            
            // Check if there is an existing ContentDistribution for this ContentVersion
            ContentDistribution distributions = [
                SELECT ContentDownloadUrl
                FROM ContentDistribution
                WHERE ContentVersionId = :contentVersion.Id
                LIMIT 1
            ];
            
            // // If an existing distribution is found, return the public URL
            // if (!distributions.isEmpty()) {
            //     return distributions[0].ContentDownloadUrl;
            // }

            

            // Retrieve and return the new public URL
            // ContentDistribution distributionQuery = [
            //     SELECT ContentDownloadUrl
            //     FROM ContentDistribution
            //     WHERE Id = :distribution.Id
            //     LIMIT 1
            // ];

            Logger.logMessage('FileUploadApp', 'FileUploadController', 'getPublicImageUrl', 'Successfully retrieved public image URL for recordId: ' + distributions.ContentDownloadUrl);
            return distributions.ContentDownloadUrl;
        } catch (Exception e) {
            Logger.logError('FileUploadApp', 'FileUploadController', 'getPublicImageUrl', recordId, null, null, null, e, 'Failed to retrieve public image URL for recordId: ' + recordId);
            throw new AuraHandledException('An unexpected error occurred: ' + e.getMessage());
        }
    }

        /**
     * Gets all files for specified fieldname and record id
     * @param fieldName The field name to filter files by.
     * @param recordId The record ID to filter files by.     
     * @return List with filename and their contentDownloadUrl
     */
    @AuraEnabled
    public static List<Map<String, Object>> getDocumentsUrl(String fieldName, Id recordId) {
        List<Map<String, Object>> filesList = new List<Map<String, Object>>();
        try {
            if (recordId == null) {
                throw new IllegalArgumentException('Record ID cannot be empty.');
            }
    
            // Retrieve the ContentDocumentId linked to the recordId
            List<ContentDocumentLink> documentLinks = [
                SELECT ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :recordId
            ];
    
            if (!documentLinks.isEmpty()) {
                Set<Id> contentDocumentIds = new Set<Id>();
                for (ContentDocumentLink link : documentLinks) {
                    contentDocumentIds.add(link.ContentDocumentId);
                }
            
    
                // Then, query the ContentVersions using the ContentDocumentIds
                List<ContentVersion> contentVersions = [
                    SELECT Id, Title
                    FROM ContentVersion
                    WHERE ContentDocumentId IN :contentDocumentIds AND Form_field__c = :fieldName
                    ORDER BY VersionNumber DESC
                ];
        
                // Create a map to hold the ContentVersionIds and Titles
                Map<Id, String> contentVersionMap = new Map<Id, String>();
                for (ContentVersion version : contentVersions) {
                    contentVersionMap.put(version.Id, version.Title);
                }
        
                // Check if there is an existing ContentDistribution for these ContentVersions
                List<ContentDistribution> distributions = [
                    SELECT ContentVersionId, ContentDownloadUrl
                    FROM ContentDistribution
                    WHERE ContentVersionId IN :contentVersionMap.keySet()
                ];
        
                // Create a map to hold the existing distribution URLs
                Map<Id, String> distributionUrls = new Map<Id, String>();
                for (ContentDistribution dist : distributions) {
                    distributionUrls.put(dist.ContentVersionId, dist.ContentDownloadUrl);
                }
    
                // Populate the filesList with filenames and URLs
                for (Id contentVersionId : contentVersionMap.keySet()) {
                    Map<String, Object> documentsMap = new Map<String, Object>();
                    documentsMap.put('fileName', contentVersionMap.get(contentVersionId));
                    documentsMap.put('publicDownloadUrl', distributionUrls.get(contentVersionId));
                    filesList.add(documentsMap);
                }
            }

            Logger.logMessage('FileUploadApp', 'FileUploadController', 'getDocumentsUrl', 'Successfully retrieved public document URLs for recordId: ' + recordId);
            return filesList;
        } catch (Exception e) {
            Logger.logError('FileUploadApp', 'FileUploadController', 'getDocumentsUrl', recordId, null, null, null, e, 'Failed to retrieve public document URLs for recordId: ' + recordId);
            throw new AuraHandledException('An unexpected error occurred: ' + e.getMessage());
        }
    } 

    /**
     * Gets all files for specified fileName and record id
     * @param fieldName The field name to filter files by.
     * @param recordId The record ID to filter files by.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
     * @param encodeBase64 Select this if you want to encode the file to base64     
     * @return List with filename and their contentDownloadUrl
     */
    @AuraEnabled
    public static List<Map<String, Object>> getFilesByFileName(Id recordId, String fileName, Boolean encodeBase64) {
    List<Map<String, Object>> filesList = new List<Map<String, Object>>();
    
    try {
        if (recordId == null) {
            throw new IllegalArgumentException('Record ID cannot be empty.');
        }

        // Retrieve the ContentDocumentIds linked to the recordId
        List<ContentDocumentLink> documentLinks = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :recordId
        ];  

        if (!documentLinks.isEmpty()) {
            Set<Id> contentDocumentIds = new Set<Id>();
            for (ContentDocumentLink link : documentLinks) {
                contentDocumentIds.add(link.ContentDocumentId);
            }
        
            // Get the specific file name
            String searchFileName = '%' + fileName + '%';

            // Query the ContentVersions using the ContentDocumentIds and the specified file type
            List<ContentVersion> contentVersions = [
                SELECT Id, Title, ContentDocumentId, VersionData
                FROM ContentVersion
                WHERE ContentDocumentId IN :contentDocumentIds AND Title LIKE :searchFileName
                ORDER BY VersionNumber DESC
            ];

            // Loop through each ContentVersion and retrieve the base64-encoded data
            for (ContentVersion contentVersion : contentVersions) {
                Map<String, Object> fileData = new Map<String, Object>();
                // fileData.put('ContentDocumentId', contentVersion.ContentDocumentId);
                if (encodeBase64) {
                    fileData.put('Base64Data', EncodingUtil.base64Encode(contentVersion.VersionData));
                }
                fileData.put('FileName', contentVersion.Title);
                filesList.add(fileData);
            }
        }

        // Return the list of base64-encoded files
        // Logger.logMessage('FileUploadApp', 'FileUploadController', 'getDocumentsBase64ByType', 'Successfully retrieved base64 files for recordId: ' + recordId);
        return filesList;
        } catch (Exception e) {
            Logger.logError('FileUploadApp', 'FileUploadController', 'getDocumentsBase64ByType', recordId, null, null, null, e, 'Failed to retrieve base64 files for recordId: ' + recordId);
            throw new AuraHandledException('An unexpected error occurred: ' + e.getMessage());
        }
    }

    /**
     * Gets all files for specified record id
     * @param fieldName The field name to filter files by.
     * @param recordId The record ID to filter files by.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
     * @return List with filename and their contentDownloadUrl
     */
    @AuraEnabled
    public static List<Map<String, Object>> getFilesByRecord(Id recordId) {
        List<Map<String, Object>> filesList = new List<Map<String, Object>>();
        try {
            if (recordId == null) {
                throw new IllegalArgumentException('Record ID cannot be empty.');
            }
    
            // Retrieve the ContentDocumentIds linked to the recordId
            List<ContentDocumentLink> documentLinks = [
                SELECT ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :recordId
            ];  
    
            if (!documentLinks.isEmpty()) {
                Set<Id> contentDocumentIds = new Set<Id>();
                for (ContentDocumentLink link : documentLinks) {
                    contentDocumentIds.add(link.ContentDocumentId);
                }
    
                // Query the ContentVersions using the ContentDocumentIds
                List<ContentVersion> contentVersions = [
                    SELECT Id, Title, ContentDocumentId, CreatedDate
                    FROM ContentVersion
                    WHERE ContentDocumentId IN :contentDocumentIds
                    ORDER BY CreatedDate DESC
                ];
    
                // Loop through each ContentVersion and retrieve or create the public download url
                for (ContentVersion contentVersion : contentVersions) {
                    Map<String, Object> fileData = new Map<String, Object>();
                    
                    // Check if a ContentDistribution already exists for this ContentVersion
                    List<ContentDistribution> existingDistributions = [
                        SELECT Id, ContentDownloadUrl 
                        FROM ContentDistribution 
                        WHERE ContentVersionId = :contentVersion.Id
                        LIMIT 1
                    ];
                    
                    ContentDistribution distribution;
                    if (existingDistributions.isEmpty()) {
                        // Create a new ContentDistribution if it doesn't exist
                        distribution = new ContentDistribution();
                        distribution.Name = 'Public Distribution for ' + contentVersion.ContentDocumentId;
                        distribution.ContentVersionId = contentVersion.Id;
                        distribution.PreferencesAllowViewInBrowser = true;
                        distribution.PreferencesLinkLatestVersion = true;
                        distribution.PreferencesNotifyOnVisit = false;
                        distribution.PreferencesPasswordRequired = false;
                        distribution.PreferencesAllowOriginalDownload = true;
                        insert distribution;

                        // Re-query the record to get the updated ContentDownloadUrl 
                        distribution = [SELECT Id, ContentDownloadUrl FROM ContentDistribution WHERE Id = :distribution.Id LIMIT 1];
                    } else {
                        distribution = existingDistributions[0];
                    }
    
                    // Return the data
                    fileData.put('Date', contentVersion.CreatedDate.format('dd/MM/yyyy'));
                    fileData.put('FileName', contentVersion.Title);
                    fileData.put('PublicDownloadUrl', distribution.ContentDownloadUrl);
                    filesList.add(fileData);
                }
            }
            return filesList;
        } catch (Exception e) {
            // Log and throw error
            Logger.logError('FileUploadApp', 'FileUploadController', 'getFilesByRecord', recordId, null, null, null, e, 'Failed to retrieve base64 files for recordId: ' + recordId);
            throw new AuraHandledException('An unexpected error occurred: ' + e.getMessage());
        }
    }
}