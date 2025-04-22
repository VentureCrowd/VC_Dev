public class MediaLinkFactory implements IMediaLinkFactory {
    /**
     * Gets the media links for a specific raise ID.
     * @param raiseId The Id of the Raise record.
     * @return List of Raise_Media_Link__c records.
     */
    public List<Raise_Media_Links__c> getMediaLinksByRaiseId(Id raiseId) {
        try {
            List<Raise_Media_Links__c> mediaLinks = [
                SELECT Id, Name, Media_URL__c, Related_Raise__c
                FROM Raise_Media_Links__c
                WHERE Related_Raise__c = :raiseId
            ];
            Logger.logMessage('RaiseApp', 'MediaLinkFactory', 'getMediaLinksByRaiseId', 'Successfully retrieved media links for raiseId: ' + raiseId);
            return mediaLinks;
        } catch (Exception e) {
            Logger.logError('RaiseApp', 'MediaLinkFactory', 'getMediaLinksByRaiseId', raiseId, null, null, null, e, 'Failed to retrieve media links for raiseId: ' + raiseId);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Creates a new media link for a specific raise ID.
     * @param raiseId The Id of the Raise record.
     * @param name The name of the media link.
     * @param mediaUrl The URL of the media link.
     * @return The newly created Raise_Media_Links__c record.
     */
    public Raise_Media_Links__c createMediaLink(Id raiseId, String name, String mediaUrl) {
        try {
            Raise_Media_Links__c newMediaLink = new Raise_Media_Links__c();
            newMediaLink.Related_Raise__c = raiseId;
            newMediaLink.Name = name;
            newMediaLink.Media_URL__c = mediaUrl;

            insert newMediaLink;

            Logger.logMessage('RaiseApp', 'MediaLinkFactory', 'createMediaLink', 'Successfully created media link for raiseId: ' + raiseId);
            return newMediaLink;
        } catch (Exception e) {
            Logger.logError('RaiseApp', 'MediaLinkFactory', 'createMediaLink', raiseId, null, null, null, e, 'Failed to create media link for raiseId: ' + raiseId);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Deletes a media link by ID.
     * @param mediaLinkId The Id of the media link to be deleted.
     */
    public void deleteMediaLink(Id mediaLinkId) {
        try {
            Raise_Media_Links__c mediaLink = [SELECT Id FROM Raise_Media_Links__c WHERE Id = :mediaLinkId LIMIT 1];
            delete mediaLink;

            Logger.logMessage('RaiseApp', 'MediaLinkFactory', 'deleteMediaLink', 'Successfully deleted media link with id: ' + mediaLinkId);
        } catch (Exception e) {
            Logger.logError('RaiseApp', 'MediaLinkFactory', 'deleteMediaLink', mediaLinkId, null, null, null, e, 'Failed to delete media link with id: ' + mediaLinkId);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Edits an existing media link by ID.
     * @param mediaLinkId The Id of the media link to be edited.
     * @param raiseId The Id of the related Raise record.
     * @param name The new name of the media link.
     * @param mediaUrl The new URL of the media link.
     * @return The updated Raise_Media_Links__c record.
     */
    public Raise_Media_Links__c editMediaLink( Id mediaLinkId, String name, String mediaUrl) {
       try {
            Raise_Media_Links__c existingMediaLink = [SELECT Id, Related_Raise__c, Name, Media_URL__c FROM Raise_Media_Links__c WHERE Id = :mediaLinkId LIMIT 1];
            existingMediaLink.Name = name;
            existingMediaLink.Media_URL__c = mediaUrl;

            update existingMediaLink;

            Logger.logMessage('RaiseApp', 'MediaLinkFactory', 'editMediaLink', 'Successfully edited media link with id: ' + mediaLinkId);
            return existingMediaLink;
        } catch (Exception e) {
            Logger.logError('RaiseApp', 'MediaLinkFactory', 'editMediaLink', mediaLinkId, null, null, null, e, 'Failed to edit media link with id: ' + mediaLinkId);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Gets the details of a specific media link by its ID.
     * @param mediaLinkId The Id of the media link.
     * @return Map containing id, name, and link of the media link.
     */
    public Raise_Media_Links__c getMediaLinkById(Id mediaLinkId) {
        try {
            Raise_Media_Links__c mediaLink = [
                SELECT Id, Name, Media_URL__c
                FROM Raise_Media_Links__c
                WHERE Id = :mediaLinkId
                LIMIT 1
            ];

            Logger.logMessage('RaiseApp', 'MediaLinkFactory', 'getMediaLinkById', 'Successfully retrieved media link details for Id: ' + mediaLinkId);
            return mediaLink;

        } catch (Exception e) {
            Logger.logError('RaiseApp', 'MediaLinkFactory', 'getMediaLinkById', mediaLinkId, null, null, null, e, 'Failed to retrieve media link details for Id: ' + mediaLinkId);
            throw new AuraHandledException(e.getMessage());
        }
    }
}