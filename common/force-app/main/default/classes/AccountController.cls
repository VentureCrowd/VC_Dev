/**
 * Apex controller for the Account Object.
 * The goal is not to have any business logic living in this layer,
 * but merely translate the callers input to match that of the service class.
 */

public with sharing class AccountController {
    @TestVisible private static AccountService accountService = new AccountService();

    /**
     * Method exposed to Aura and LWC components via @AuraEnabled to retrieve account information.
     * 
     * @param accountId The Id of the account to retrieve information for.
     * @return A Map containing account details, such as Name, PreferredName, IdVerified, ContactId, and Email.
     * 
     * This method invokes the AccountService to fetch the account information using the provided accountId.
     * In case of any exceptions, it logs the error and rethrows it for handling by the calling layer.
     */
    @AuraEnabled()
    public static Map<String, Object> getAccountInformation(Id accountId){
        try{
            return accountService.getAccountInformation(accountId);
        }catch (Exception e) {
            Logger.logError('AccountApp', 'AccountController', 'getAccountInformation', null, null, null, null, e, 'Failed to get account details for accountId: ' + accountId);
            throw e;
        }
    }

    @AuraEnabled()
    public static Id getAccountId(Id userId){
        try{
            return accountService.getAccountId(userId);
        }catch (Exception e) {
            Logger.logError('AccountApp', 'AccountController', 'getAccountId', null, null, null, null, e, 'Failed to get account id for userId: ' + userId);
            throw e;
        }
    }
}