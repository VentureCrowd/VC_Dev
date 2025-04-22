public interface IMediaLinkFactory {
    List<Raise_Media_Links__c> getMediaLinksByRaiseId(Id raiseId);
    Raise_Media_Links__c createMediaLink(Id raiseId, String name, String mediaUrl);
    void deleteMediaLink(Id mediaLinkId);
    Raise_Media_Links__c editMediaLink( Id raiseId, String name, String mediaUrl);
    Raise_Media_Links__c getMediaLinkById(Id mediaLinkId);
}