public without sharing class MediaLinkService {
    private MediaLinkFactory factory = new MediaLinkFactory();

    /**
     * Gets the media links for a specific raise ID and returns them in the specified format.
     * @param raiseId The Id of the Raise record.
     * @return List of media link maps with id, name, and link.
     */
    public List<Map<String, String>> getMediaLinksByRaiseId(Id raiseId) {
        List<Map<String, String>> formattedMediaLinks = new List<Map<String, String>>();
        try {
            List<Raise_Media_Links__c> mediaLinks = factory.getMediaLinksByRaiseId(raiseId);
            for (Raise_Media_Links__c mediaLink : mediaLinks) {
                Map<String, String> mediaLinkMap = new Map<String, String>();
                mediaLinkMap.put('id', mediaLink.Id);
                mediaLinkMap.put('name', mediaLink.Name);
                mediaLinkMap.put('link', mediaLink.Media_URL__c);
                formattedMediaLinks.add(mediaLinkMap);
            }
            Logger.logMessage('RaiseApp', 'MediaLinkService', 'getMediaLinksByRaiseId', 'Successfully formatted media links for raiseId: ' + raiseId);
        } catch (Exception e) {
            Logger.logError('RaiseApp', 'MediaLinkService', 'getMediaLinksByRaiseId', raiseId, null, null, null, e, 'Failed to retrieve and format media links for raiseId: ' + raiseId);
            throw new AuraHandledException(e.getMessage());
        }
        return formattedMediaLinks;
    }

    /**
     * Edits an existing media link by ID.
     * @param mediaLinkId The Id of the media link to be edited.
     * @param raiseId The Id of the related Raise record.
     * @param name The new name of the media link.
     * @param mediaUrl The new URL of the media link.
     * @return Map containing id, name, and link of the edited media link.
     */
    public Map<String, String> editMediaLink(Id mediaLinkId, String name, String mediaUrl) {
        try {
            Raise_Media_Links__c updatedMediaLink = factory.editMediaLink(mediaLinkId, name, mediaUrl);
            Map<String, String> mediaLinkMap = new Map<String, String>();
            mediaLinkMap.put('id', updatedMediaLink.Id);
            mediaLinkMap.put('name', updatedMediaLink.Name);
            mediaLinkMap.put('link', updatedMediaLink.Media_URL__c);

            Logger.logMessage('RaiseApp', 'MediaLinkService', 'editMediaLink', 'Successfully edited media link with id: ' + mediaLinkId);
            return mediaLinkMap;
        } catch (Exception e) {
            Logger.logError('RaiseApp', 'MediaLinkService', 'editMediaLink', mediaLinkId, null, null, null, e, 'Failed to edit media link with id: ' + mediaLinkId);
            throw new AuraHandledException(e.getMessage());
        }
    }

     /**
     * Creates a new media link for a specific raise ID.
     * @param raiseId The Id of the Raise record.
     * @param name The name of the media link.
     * @param mediaUrl The URL of the media link.
     * @return Map containing id, name, and link of the newly created media link.
     */
    public Map<String, String> createMediaLink(Id raiseId, String name, String mediaUrl) {
        try {
            Raise_Media_Links__c newMediaLink = factory.createMediaLink(raiseId, name, mediaUrl);
            Map<String, String> mediaLinkMap = new Map<String, String>();
            mediaLinkMap.put('id', newMediaLink.Id);
            mediaLinkMap.put('name', newMediaLink.Name);
            mediaLinkMap.put('link', newMediaLink.Media_URL__c);

            Logger.logMessage('RaiseApp', 'MediaLinkService', 'createMediaLink', 'Successfully created media link for raiseId: ' + raiseId);
            return mediaLinkMap;
        } catch (Exception e) {
            Logger.logError('RaiseApp', 'MediaLinkService', 'createMediaLink', raiseId, null, null, null, e, 'Failed to create media link for raiseId: ' + raiseId);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Deletes a media link by ID.
     * @param mediaLinkId The Id of the media link to be deleted.
     */
    public void deleteMediaLink(Id mediaLinkId) {
        try {
            factory.deleteMediaLink(mediaLinkId);
            Logger.logMessage('RaiseApp', 'MediaLinkService', 'deleteMediaLink', 'Successfully deleted media link with id: ' + mediaLinkId);
        } catch (Exception e) {
            Logger.logError('RaiseApp', 'MediaLinkService', 'deleteMediaLink', mediaLinkId, null, null, null, e, 'Failed to delete media link with id: ' + mediaLinkId);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Gets the details of a specific media link by its ID.
     * @param mediaLinkId The Id of the media link.
     * @return Map containing id, name, and link of the media link.
     */
    public Map<String, String> getMediaLinkById(Id mediaLinkId) {
       Map<String, String> formattedMediaLink = new Map<String, String>();
        try {
            Raise_Media_Links__c mediaLink = factory.getMediaLinkById(mediaLinkId);
          
            formattedMediaLink.put('id', mediaLink.Id);
            formattedMediaLink.put('name', mediaLink.Name);
            formattedMediaLink.put('link', mediaLink.Media_URL__c);

            Logger.logMessage('RaiseApp', 'MediaLinkService', 'getMediaLinkById', 'Successfully formatted media links for mediaLinkId: ' + mediaLinkId);
        } catch (Exception e) {
            Logger.logError('RaiseApp', 'MediaLinkService', 'getMediaLinkById', mediaLinkId, null, null, null, e, 'Failed to retrieve and format media links for mediaLinkId: ' + mediaLinkId);
            throw new AuraHandledException(e.getMessage());
        }
        return formattedMediaLink;
    }
}