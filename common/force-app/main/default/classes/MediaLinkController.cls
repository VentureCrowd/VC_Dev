public without sharing class MediaLinkController {
    @TestVisible private static MediaLinkService mediaLinkService = new MediaLinkService();

    /**
     * Gets the media links for a specific raise ID.
     * @param raiseId The Id of the Raise record.
     * @return List of media link maps with id, name, and link.
     */
    @AuraEnabled
    public static List<Map<String, String>> getMediaLinksByRaiseId(Id raiseId) {
        try {
            return mediaLinkService.getMediaLinksByRaiseId(raiseId);
        } catch (Exception e) {
            Logger.logError('RaiseApp', 'MediaLinkController', 'getMediaLinksByRaiseId', raiseId, null, null, null, e, 'Failed to retrieve media links for raiseId: ' + raiseId);
            throw e;
        }
    }


    /**
     * Creates a new media link for a specific raise ID.
     * @param raiseId The Id of the Raise record.
     * @param name The name of the media link.
     * @param mediaUrl The URL of the media link.
     * @return Map containing id, name, and link of the newly created media link.
     */
    @AuraEnabled
    public static Map<String, String> createMediaLink(Id raiseId, String name, String mediaUrl) {
        try {
            return mediaLinkService.createMediaLink(raiseId, name, mediaUrl);
        } catch (Exception e) {
            Logger.logError('RaiseApp', 'MediaLinkController', 'createMediaLink', raiseId, null, null, null, e, 'Failed to create media link for raiseId: ' + raiseId);
            throw e;
        }
    }

    /**
     * Deletes a media link by ID.
     * @param mediaLinkId The Id of the media link to be deleted.
     * @return Boolean indicating success or failure.
     */
    @AuraEnabled
    public static Boolean deleteMediaLink(Id mediaLinkId) {
        try {
            mediaLinkService.deleteMediaLink(mediaLinkId);
            return true;
        } catch (Exception e) {
            Logger.logError('RaiseApp', 'MediaLinkController', 'deleteMediaLink', mediaLinkId, null, null, null, e, 'Failed to delete media link with id: ' + mediaLinkId);
            return false;
        }
    }

    /**
     * Edits a media link by ID.
     * @param raiseId The Id of the Raise record.
     * @param mediaLinkId The Id of the media link to be edited.
     * @param name The new name of the media link.
     * @param mediaUrl The new URL of the media link.
     * @return Map containing id, name, and link of the edited media link.
     */
    @AuraEnabled
    public static Map<String, String> editMediaLink( Id mediaLinkId, String name, String mediaUrl) {
        try {
            return mediaLinkService.editMediaLink( mediaLinkId, name, mediaUrl);
        } catch (Exception e) {
            Logger.logError('RaiseApp', 'MediaLinkController', 'editMediaLink', mediaLinkId, null, null, null, e, 'Failed to edit media link with id: ' + mediaLinkId);
            throw e;
        }
    }


    @AuraEnabled
    public static Map<String, String> getMediaLinkById(Id mediaLinkId) {
        try {
            return mediaLinkService.getMediaLinkById(mediaLinkId);
        } catch (Exception e) {
            Logger.logError('RaiseApp', 'MediaLinkController', 'getMediaLinkById', mediaLinkId, null, null, null, e, 'Failed to retrieve media link details for Id: ' + mediaLinkId);
            throw new AuraHandledException(e.getMessage());
        }
    }
}