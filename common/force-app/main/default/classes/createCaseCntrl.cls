public without sharing class createCaseCntrl {
    @AuraEnabled
    public static object getUserDEtails(){
        if(Userinfo.getUserType() <> 'Guest'){
            Map<string,string> userdetails = new Map<string,string>();
            User u = [SELECT Id,Name,FirstName,LastName,ContactId,Contact.AccountId,Email,Contact.MobilePhone FROM USER WHERE Id =:Userinfo.getUserId()];
            userdetails.put('FirstName',u.FirstName);
            userdetails.put('LastName',u.LastName);
            userdetails.put('email',u.Email);
            userdetails.put('ContactId',u.ContactId);
            userdetails.put('AccountId',u.Contact.AccountId);
            userdetails.put('mobilePhone',u.Contact.MobilePhone);
            return userdetails;
        }else{
            return NULL;
        }
    }
    @AuraEnabled
    public static string createCase(Map<string,string> casedetails){
        Account personaacc;
        Case cs = new Case();
        if(Userinfo.getUserType() == 'Guest'){
            personaacc = fetchAcc(casedetails.get('Email'),casedetails);
            cs.AccountId = personaacc.Id;
        }else{
            cs.AccountId = casedetails.get('AccountId');
            cs.ContactId = casedetails.get('ContactId');
        }
        cs.SuppliedEmail = casedetails.get('Email');
        cs.SuppliedPhone = casedetails.get('Phone');
        cs.SuppliedName = casedetails.get('FirstName')+' '+casedetails.get('LastName');
        cs.Subject = casedetails.get('Subject');
        cs.Description = casedetails.get('Description');
        cs.RecordTypeId = casedetails.get('recordtypeId');
        cs.OwnerId = casedetails.get('assigneQueueId');
        insert cs;
        return cs.Id;
    }
    public static account fetchAcc(string email,Map<string,string> casedetails){
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('VC Person Account').getRecordTypeId();
        system.debug(recordTypeId+email);
        List<Account> acclst = [SELECT Id,Name FROM Account WHERE RecordTypeId =:recordTypeId AND PersonEmail = :email LIMIT 1];
        system.debug(acclst);
        if(acclst <> NULL && acclst.size() >0){
            return acclst[0];
        }
        else{
            Account acc = new Account();
            acc.FirstName = casedetails.get('FirstName');
            acc.LastName = casedetails.get('LastName');
            acc.PersonEmail = email;
            acc.RecordTypeId = recordTypeId;
            insert acc;
            return acc;
        }

    }
}