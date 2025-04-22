public without sharing class contactTriggerHandler {
    public static void updatetoPersonAcc(List<Contact> contacts){
        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();
        Map<String, Account> accountsMap = new Map<String, Account>();
        for(Contact contactObj: contacts) {
            if(!contactObj.IsPersonAccount){
                String name = '';
                if(!String.isBlank(contactObj.FirstName)) {
                    name = name+contactObj.FirstName;
                }
                if(!String.isBlank(contactObj.MiddleName)) {
                    name = name+contactObj.MiddleName;
                }
                if(!String.isBlank(contactObj.LastName)) {
                    name = name+contactObj.LastName;
                }
                if(!String.isBlank(contactObj.Suffix)) {
                    name = name+contactObj.Suffix;
                } 
                Account personAccountObj = new Account();
                personAccountObj.Name = name;
                personAccountObj.recordtypeId = rtMapByName.get('VC Business Account').getRecordTypeId();
                personAccountObj.OwnerId = contactObj.OwnerId;
                accountsMap.put(contactObj.Id,personAccountObj);
            }
        }
        List<Contact> updateContactsLst = new List<Contact>();
        List<Account> updateAccountsLst = new List<Account>();
        if(accountsMap.size() > 0) {
            insert accountsMap.values();
            Set<String> conIds = accountsMap.keyset();
            for(String recId: conIds) {
                Contact con = new Contact();
                con.id = recId;
                Account acc = accountsMap.get(recId);
                con.AccountId = acc.Id;
                updateContactsLst.add(con);
                
                Account newpersonAccountObj = new Account();
                newpersonAccountObj.Id =acc.Id;
                newpersonAccountObj.recordtypeId = rtMapByName.get('VC Person Account').getRecordTypeId();
                updateAccountsLst.add(newpersonAccountObj);
            }
        }
        if(updateContactsLst.size() > 0) {
            update updateContactsLst;
        }
        if(updateAccountsLst.size() > 0) {
            update updateAccountsLst;
        }
    }
}