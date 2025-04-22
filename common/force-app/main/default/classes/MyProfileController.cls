/**

**/
public without sharing class MyProfileController {

    @AuraEnabled
    public static void updateSObject(sObject sObj){
        try {
            update sObj;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Id saveAttachment(String base64Data) {

        // Decoding base64Data
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        String communityId = null;
        String userId = UserInfo.getUserId();

        // Set photo
        ConnectApi.Photo photo = ConnectApi.UserProfiles.setPhoto(communityId, userId, new ConnectApi.BinaryInput(EncodingUtil.base64Decode(base64Data), 'image/jpg', 'userImage.jpg'));
        return null;

    }

    @AuraEnabled
    public static string getSObjectInstance(id userId){
        try {
            User oUser = [SELECT Id,contactId,AccountId,Account.ispersonaccount FROM User Where Id = :userId];

            if (oUser.Account.ispersonaccount) {
                return String.valueOf(oUser.AccountId.getSobjectType());
            } else if (oUser.contactId != null) {
                return String.valueOf(oUser.contactId.getSobjectType());
            } else {
                return 'Salesforce';
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static Map<string,string> getMailingAdress(Id userId){
        Map<string,string> retMap = new Map<string,string>();
        User usr = [SELECT Id,AccountId FROM User WHERE Id = :userId];
        Account acc = [SELECT Id,PersonMailingCity,PersonMailingCountry,PersonMailingPostalCode,PersonMailingState,PersonMailingStreet FROM Account WHERE Id = :usr.AccountId];
        retMap.put('Street',acc.PersonMailingStreet);
        retMap.put('City',acc.PersonMailingCity);
        retMap.put('Country',acc.PersonMailingCountry);
        retMap.put('State',acc.PersonMailingState);
        retMap.put('PostalCode',acc.PersonMailingPostalCode);
        retMap.put('accId',acc.Id);
        return retMap;
    }
    @AuraEnabled
    public static string updateAccount(Map<string,string> dataMap){
        Account acc = new Account();
        for(string s : dataMap.keyset()){
            acc.put(s,dataMap.get(s));
        }
        update acc;
        return 'success';
    }
    @AuraEnabled
    public static Map<string,string> getBillingAdress(Id accId){
        Map<string,string> retMap = new Map<string,string>();
        Account acc = [SELECT Id,BillingCity,BillingCountry,BillingPostalCode,BillingState,BillingStreet FROM Account WHERE Id = :accId];
        retMap.put('Street',acc.BillingStreet);
        retMap.put('City',acc.BillingCity);
        retMap.put('Country',acc.BillingCountry);
        retMap.put('State',acc.BillingState);
        retMap.put('PostalCode',acc.BillingPostalCode);
        retMap.put('accId',acc.Id);
        return retMap;
    }
}