public without sharing class createAccountEntity {
    @AuraEnabled
    public static string createAccount(Map<string,object> datamap){
        try{
            Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('VC Business Account').getRecordTypeId();
            User currentuser = [SELECT Id,ContactId,Contact.Account.OwnerId FROM User WHERE Id =:Userinfo.getuserId()];
            User owner = [SELECT Id FROM USER WHERE Name = 'The VentureCrowd Team'];
            if(owner == NULL ){
                owner = [SELECT ID,Name FROM User WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE Group.name='CM') AND IsActive = TRUE LIMIT 1];
            }
            Account a = new Account();
            a.RecordTypeId = devRecordTypeId;
            for(string s : datamap.keyset()){
                system.debug(s);
                a.put(s,datamap.get(s));
            }
            a.Account_Created_via_Portal__c = true;
            a.ownerId = owner.Id;
            // a.ownerId = currentuser.Contact.Account.OwnerId;
            insert a;            
            if(currentuser.ContactId <> NULL){
                AccountContactRelation acr = new AccountContactRelation();
                acr.AccountId = a.Id;
                acr.ContactId = currentuser.ContactId;
                insert acr;
            }
            return 'Sucess';
        }catch(exception e){
            logMsgUtility.logMessage(e,'createAccountEntity','createAccount','AccountEntity',datamap);
            return e.getMessage();
        }
    }
}