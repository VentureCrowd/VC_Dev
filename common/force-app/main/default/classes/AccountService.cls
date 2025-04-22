public without sharing class AccountService {
    /**
     * Method to retrieve an account record using the Account ID.
     * 
     * @param accountId The Id of the Account to retrieve information for.
     * @return A Map containing relevant account information such as Name, PreferredName, 
     *         ID verification status, ContactId, and Email.
     * 
     * This method uses the AccountFactory class to retrieve account information based on 
     * the provided accountId. If the account is found, it populates the details into a 
     * Map and returns it. Logs a success message upon successful retrieval.
     */
    public Map<String, Object> getAccountInformation(Id accountId) {
            // Initialize AccountFactory to handle account-related operations
            AccountFactory factory = new AccountFactory();
            // Retrieve the account information (as an Account object) using the provided accountId
            Account accountRecord = factory.getUserAccountInfo(accountId);
            // Initialize a map to store and return the account details
            Map<String, Object> returnMap = new Map<String, Object>();
    
            // If the accountRecord is not null, populate the returnMap with relevant account details
            if(accountRecord != null){
                returnMap.put('InvestorBannerInteraction', accountRecord.Investor_Banner_Interaction__c);            
                // Add the first name of the account holder to the map
                returnMap.put('Name', accountRecord.FirstName);    
                // Add the preferred name of the account holder to the map, if available
                returnMap.put('PreferredName', accountRecord.Preferred_Name__pc);
                // Add the ID verification status of the account to the map
                returnMap.put('IdVerified', accountRecord.ID_Checked__pc);
                // Add the contact Id
                returnMap.put('ContactId', accountRecord.PersonContactId);
                // Add the email
                returnMap.put('Email', accountRecord.PersonEmail);
            }
    
            // Log a success message indicating the account information retrieval was successful
            // Logger.logMessage('PipoApp', 'AccountService', 'getAccountInformation', 'Successfully retrieved account details for accountId: ' + accountId);
    
            // Return the map containing the account information
            return returnMap;
    }

    /**
     * Method to retrieve the AccountId associated with a given UserId.
     * 
     * @param userId The Id of the User whose AccountId is to be retrieved.
     * @return The AccountId if found, otherwise null.
     * 
     * This method uses the AccountFactory class to retrieve the AccountId linked to the 
     * provided userId. Logs a success message upon successful retrieval.
     */
    public Id getAccountId(Id userId) {
            // Initialize AccountFactory to handle account-related operations
            AccountFactory factory = new AccountFactory();
            // Retrieve the account ID associated with the provided userId
            Id accountId = factory.getAccountId(userId);
            // Return the retrieved accountId
            return accountId;
    }
    
}