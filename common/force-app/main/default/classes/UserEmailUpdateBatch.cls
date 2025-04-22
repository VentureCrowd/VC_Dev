/**

**/
global with sharing class UserEmailUpdateBatch implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext BC) { 
        String query = 'SELECT Id,Account.ispersonaccount,Account.PersonEmail,AccountId,Contactid,Contact.Email,Email,Username,ProfileId FROM User '+(Test.isRunningTest()?' LIMIT 3':'');
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<User> listUser) {
        List<Contact> lstContactToUpdate = new List<Contact>();
        List<Account> lstAccountToUpdate = new List<Account>();
        List<User> usrLstToUpdate = new List<User>();
        Map<Id,Profile> profileMap = new Map<Id,Profile>([SELECT Id, Name FROM Profile WHERE Name IN ('VC Customer Community Login','VC Investor Community Plus Login','VC Partner Community User')]);
        //Logic to Filter the Contacts and Accounts to be updated
        if (!listUser.isEmpty()) {
            for (User oUser : listUser) {
                //Update Person Account
                if (oUser.Account.ispersonaccount && oUser.Account.PersonEmail != oUser.Email ) {
                        lstAccountToUpdate.add(new Account(Id = oUser.AccountId,PersonEmail=oUser.Email ));
                }
                //Update Business Account
                else if (!oUser.Account.ispersonaccount && oUser.Contact.Email != oUser.Email ) {
                        lstContactToUpdate.add(new Contact(Id = oUser.ContactId,Email=oUser.Email ));
                }
                if(oUser.Email <> oUser.Username && profileMap.containsKey(oUser.ProfileId)){
                    oUser.Username = oUser.Email;
                    usrLstToUpdate.add(oUser);
                }
            }
        }
        //Update Account Records
        if (!lstAccountToUpdate.isEmpty()) {
            List<Database.SaveResult> listDbSR = Database.update(lstAccountToUpdate, false);
        }
        //Update Contact Records
        if (!lstContactToUpdate.isEmpty()) {
            List<Database.SaveResult> listDbSR = Database.update(lstContactToUpdate, false);
        }
        if (!usrLstToUpdate.isEmpty()) {
            Database.update(usrLstToUpdate, false);
        }
    }
    global void finish(Database.BatchableContext BC) {

    }
}