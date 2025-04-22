public without sharing class EntitiesController {
    @TestVisible private static EntitiesService service = new EntitiesService();

    @AuraEnabled
    public static List<Map<String, Object>> getRelatedBusinessAccounts(Id contactId) {
        return service.getRelatedBusinessAccounts(contactId);
    }


    @AuraEnabled
    public static Id getContactId() {
        return service.getLoggedInUser();
    }
}