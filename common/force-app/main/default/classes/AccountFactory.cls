public inherited sharing class AccountFactory{
    public Id getAccountId(Id userId) {

        /**
         * Retrieves the AccountId associated with a given UserId.
         * 
         * @param userId The Id of the user whose AccountId is being retrieved.
         * @return The AccountId if found, otherwise returns null.
         * 
         * This method queries the User object to fetch the AccountId associated with the user.
         * Logs a success or failure message depending on the result of the query.
         */
        List<User> accountId  = [SELECT AccountId FROM User WHERE Id =:userId LIMIT 1];

        if(!accountId.isEmpty()) {
            Logger.logMessage('AccountApp', 'AccountFactory', 'getAccountId', 'Successfully retrieved full raise record for accountId: ' + userId);
            return accountId[0].AccountId;
        } else {
            return null;
        }
    }

    /**
     * Retrieves the Account information for a given AccountId.
     * 
     * @param accountId The Id of the account to retrieve information for.
     * @return The Account object if found.
     * @throws AuraHandledException if no Account record is found.
     * 
     * This method queries the Account object to fetch details like PersonEmail, 
     * Preferred Name, FirstName, ID Checked status, and PersonContactId. Logs a 
     * success or failure message depending on the result of the query.
     */
    public Account getUserAccountInfo(Id accountId) {
        List<Account> accountInformation  = [SELECT PersonEmail, Preferred_Name__pc, FirstName, ID_Checked__pc, PersonContactId,Investor_Banner_Interaction__c FROM Account WHERE Id=:accountId];
        if(accountInformation.isEmpty()) {
            // Logger.logMessage('AccountApp', 'AccountFactory', 'getUserAccountInfo', 'Successfully retrieved account record for accountId: ' + accountId);
            throw new DmlException('No investment record found for account: ' + accountId);
        } else {
            // Logger.logMessage('AccountApp', 'AccountFactory', 'getUserAccountInfo', 'No account record found for accountId: ' + accountId);
            return accountInformation[0];
        }
    }
}