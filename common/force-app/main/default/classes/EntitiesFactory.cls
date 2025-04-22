public inherited sharing class EntitiesFactory implements IEntitiesFactory{
 
    public List<Account> getRelatedBusinessAccounts(Id contactId){
        // get business account RT ID
        Id bussAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('VC Business Account').getRecordTypeId();

        List<Account> accContactRel = [SELECT Id, Name ,BSB_Number__c,Bank_Account_Number__c
        FROM Account 
        WHERE Id In (SELECT AccountId FROM AccountContactRelation WHERE ContactId=:contactId) 
        AND RecordTypeId=:bussAccountRecType
        AND Active__c=True];

        return accContactRel;
    }

    public Id getContactFromLoggedInUser(){
        Id loggedInUser = UserInfo.getUserId();

       // Query the User object to get the ContactId
        User currentUser = [
            SELECT ContactId 
            FROM User 
            WHERE Id = :loggedInUser
            LIMIT 1
        ];
        
        // Return the ContactId
        return currentUser.ContactId;
    }
}