public without sharing class ReCaptchaAuraController {    
    @AuraEnabled
    public static String getRegisterSubmit(Map<String,Object> registerComponentInfo){
        return NULL;
    }
    // New registratopn form
    @AuraEnabled
    public static Boolean verifyrecaptchaToken(string token){
        Http http = new Http();
        HttpRequest request = new HttpRequest();   
        request.setEndpoint('https://www.google.com/recaptcha/api/siteverify');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        string body = 'secret=6Lcxu8QaAAAAAOKqVKlcpePIkcx3Yzmbygc-LhR4&response='+token;
        request.setBody(body);
        HttpResponse response = http.send(request);
        Map<string,Object> retobj = (Map<string,Object>) JSON.deserializeUntyped(response.getBody());
        return (boolean) retobj.get('success') && (decimal)retobj.get('score') > 0.5;
    }
    // Create or find person Account
    @AuraEnabled
    public static Map<string,Object> upsertPersonAccount(Map<string,Object> userdatamap){
        Map<string,Object> retMap = new Map<string,Object>();
        try{
            string email = (string) userdatamap.get('email');
            // Id personAccrecordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Ventures Person Account').getRecordTypeId();
            Id personAccrecordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('VC Person Account').getRecordTypeId();
            List<Account> a = [SELECT Id,(SELECT Id FROM Users),(SELECT Id FROM Contacts),(SELECT Id FROM Opportunities WHERE StageName = 'Closed Won') FROM ACCOUNT WHERE PersonEmail = :email AND RecordTypeId = :personAccrecordId];
            Map<string,string> profileMap = new Map<string,string>();
            for(Profile p : [SELECT Id,Name FROM PROFILE WHERE Name IN ('VC Customer Community Login','VC Investor Community Plus Login')]){
                profileMap.put(p.Name,p.Id);
            }
            List<user> adminuserlst;
            String communityNickname = String.valueOf(System.now().getTime()/1000)+(string) userdatamap.get('email');
            if(communityNickname.length() > 40)
            communityNickname = communityNickname.substring(0,35);
            if(a.Isempty()){
                User owner = [SELECT Id FROM USER WHERE Name = 'The VentureCrowd Team'];
                if(owner == NULL ){
                    owner = [SELECT ID,Name FROM User WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE Group.name='CM') AND IsActive = TRUE LIMIT 1];
                }
                Account act = new Account();
                act.FirstName = (string) userdatamap.get('firstName');
                act.LastName = (string) userdatamap.get('lastName');
                act.OwnerId = owner.Id;
                act.RecordTypeId = personAccrecordId;
                act.PersonEmail = (string) userdatamap.get('email');
                act.PersonMobilePhone = (string) userdatamap.get('mobile');
                act.Ts_Cs__pc = true;
                act.Email_Opt_In__pc = (boolean) userdatamap.get('Email_Opt_In__pc');
                act.utm_source__c = (string) userdatamap.get('utm_source__c');               
                act.utm_medium__c = (string) userdatamap.get('utm_medium__c');               
                act.utm_campaign__c = (string) userdatamap.get('utm_campaign__c');               
                act.utm_content__c = (string) userdatamap.get('utm_content__c');               
                act.utm_term__c = (string) userdatamap.get('utm_term__c');
                act.utm_keyword__c = (string) userdatamap.get('utm_keyword__c');               
                insert act;

                User u = new User();
                u.Username = (string) userdatamap.get('email');
                u.Email = (string) userdatamap.get('email');
                u.FirstName =  (string) userdatamap.get('firstName');
                u.LastName = (string) userdatamap.get('lastName');
                u.MobilePhone = (string) userdatamap.get('mobile');
                u.ProfileId =  profileMap.get('VC Customer Community Login');
                u.EmailEncodingKey = 'UTF-8';
                u.CommunityNickname = communityNickname;
                u.Alias = 'ComUser';
                u.TimeZoneSidKey = 'Australia/Brisbane';
                u.LocaleSidKey = 'en_US';
                u.LanguageLocaleKey = 'en_US';
                Id userId = Site.createExternalUser(u, act.Id, (string) userdatamap.get('password'));
                // ApexPages.PageReference lgn = Site.login(u.Email, (string) userdatamap.get('password'),'/s/portal/portfolio');                
                retMap.put('IsValidtransaction',true);
                retMap.put('IsAccountCreated',true);
                retMap.put('accId',act.Id);
                retMap.put('userId',userId);
                // retMap.put('retURL',lgn.getURL());
            }else if(!a.Isempty() && a[0].Users.isempty()){
                Contact c= new Contact();
                c.Id = a[0].Contacts[0].Id;
                c.Email = (string) userdatamap.get('email');
                c.FirstName = (string) userdatamap.get('firstName');
                c.LastName = (string) userdatamap.get('lastName');
                c.Ts_Cs__c = true;
                c.MobilePhone = (string) userdatamap.get('mobile');
                c.Email_Opt_In__c = true;
                // c.Self_Identification__c = investorDetail;
                update c;

                User u = new User();
                u.Username = (string) userdatamap.get('email');
                u.Email = (string) userdatamap.get('email');
                u.FirstName =  (string) userdatamap.get('firstName');
                u.LastName = (string) userdatamap.get('lastName');
                u.MobilePhone = (string) userdatamap.get('mobile');
                u.CommunityNickname = communityNickname;
                u.EmailEncodingKey = 'UTF-8';
                u.Alias = 'ComUser';
                u.TimeZoneSidKey = 'Australia/Brisbane';
                u.LocaleSidKey = 'en_US';
                u.LanguageLocaleKey = 'en_US';
                
                u.ProfileId = profileMap.get('VC Customer Community Login');
                                
                Id userId = Site.createExternalUser(u, a[0].Id, (string) userdatamap.get('password'));
                ApexPages.PageReference lgn = Site.login(u.Email, (string) userdatamap.get('password'),'/s/portal/my-companies');  
                retMap.put('IsValidtransaction',true);              
                retMap.put('IsAccountCreated',false);
                retMap.put('accId',a[0].Id);
                retMap.put('userId',userId);
                // retMap.put('retURL',lgn.getURL());                
            }else{
                retMap.put('IsValidtransaction',false);                 
            }
            return retMap;
        }catch(Exception e){
            logMsgUtility.logMessage(e, 'ReCaptchaAuraController', 'User Registration', 'upsertPersonAccount',userdatamap );
            return NULL;
        }
    }
    // @AuraEnabled
    // public static string updateAccount(Map<string,object> datmap){
    //     try{
    //         Account a = new Account();
    //         for(string s : datmap.keyset()){
    //             a.put(s,datmap.get(s));
    //         }
    //         update a;
    //         return 'success';
    //     }catch(Exception e){
    //         logMsgUtility.logMessage(e, 'ReCaptchaAuraController', 'User Registration', 'updateAccount',datmap );
    //         return 'failure';
    //     }
    // }
    @AuraEnabled
    public static String updateAccount(Map<String, Object> datmap) {
        try {
            Account a = new Account();
            for (String s : datmap.keySet()) {
                a.put(s, datmap.get(s));
            }
            update a;
            return 'success';
        } catch (Exception e) {
            logMsgUtility.logMessage(e, 'ReCaptchaAuraController', 'User Registration', 'updateAccount', datmap);
            return 'failure';
        }
    }

    @AuraEnabled
    public static string communityLogin(string email,string pwd, string landingurl){
        return Site.login(email, pwd,landingurl).getUrl();
    }
    
    //? Get the ACN of 
    @AuraEnabled(cacheable=true)
    public static String getEOICompanyId(String acn) {
        EOI__c eoi = [SELECT Id FROM EOI__c WHERE Account__r.ACN__c = :acn ORDER BY CreatedDate DESC LIMIT 1];
        return eoi.Id;
    }



    @AuraEnabled
public static Map<String, Object> createAccountAndUser(Map<String, Object> userdata) {
    Map<String, Object> retMap = new Map<String, Object>();
    try {
        // Initialize GenericObjectFactory
        GenericObjectFactory factory = new GenericObjectFactory();

        // Prepare field mappings
        Map<String, String> accountFieldMapInitializer = new Map<String, String>{
            'firstName' => 'FirstName',
            'lastName' => 'LastName',
            'email' => 'PersonEmail',
            'mobile' => 'PersonMobilePhone',
            'Ventures_Company_Name__c' => 'Ventures_Company_Name__c',
            'Website' => 'Website',
            'Sector__c' => 'Sector__c',
            'ACN__c' => 'ACN__c',
            'Create_Company_Account__c'=>'Create_Company_Account__c',
            'Email_Opt_In__pc' => 'Email_Opt_In__pc',
            'Ts_Cs__pc' => 'Ts_Cs__pc',
            'utm_source__c' => 'utm_source__c',
            'utm_medium__c' => 'utm_medium__c',
            'utm_campaign__c' => 'utm_campaign__c',
            'utm_content__c' => 'utm_content__c',
            'utm_term__c' => 'utm_term__c',
            'utm_keyword__c' => 'utm_keyword__c',
            'Self_Identification__pc' => 'Self_Identification__pc',
            'OwnerId'=>'OwnerId',
            'BillingStreet' => 'BillingStreet',
            'BillingCity' => 'BillingCity',
            'BillingState' => 'BillingState',
            'BillingPostalCode' => 'BillingPostalCode',
            'BillingCountry' => 'BillingCountry',
            'Bank_Account_Name__c' => 'Bank_Account_Name__c',
            'Bank_Account_Number__c' => 'Bank_Account_Number__c',
            'BSB_Number__c'=> 'BSB_Number__c',
            'RecordTypeId' => 'RecordTypeId',
            'source'=>'PersonLeadSource',
            'webSource' => 'Web_Source__pc'
        };
        BidiMap accountFieldMap = new BidiMap(accountFieldMapInitializer);

        // Determine Record Type
        String selectedValue = (String) userdata.get('Self_Identification__pc');
        String recordTypeName = 'VC Person Account';
        if (selectedValue == 'Founder') {
            recordTypeName = 'Ventures Person Account';
        }
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        userdata.put('RecordTypeId', recordTypeId);

        // Set default values
        userdata.put('Ts_Cs__pc', true);

        // Get Owner
        User owner = [SELECT Id FROM USER WHERE Name = 'The VentureCrowd Team'];
        if(owner == NULL ){
            owner = [SELECT ID,Name FROM User WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE Group.name='CM') AND IsActive = TRUE LIMIT 1];
        }
        userdata.put('OwnerId',owner.Id);

        // Check if Account already exists
        String email = (String) userdata.get('email');
        List<Account> existingAccounts = [
            SELECT Id, PersonEmail
            FROM Account
            WHERE PersonEmail = :email
        ];
        if (!existingAccounts.isEmpty()) {
            retMap.put('IsValidtransaction', false);
            retMap.put('error', 'Account already exists with this email.');
            return retMap;
        }

        // Create Account
        Map<String, Object> accountResult = factory.createRecord('Account', userdata, accountFieldMap);
        if (accountResult.containsKey('Id')) {
            Id accountId = (Id) accountResult.get('Id');

            //setup community nickname
            String communityNickname  =String.valueOf(System.now().getTime() / 1000) + (String) userdata.get('email');
            if(communityNickname.length() > 40)
            communityNickname = communityNickname.substring(0,35);

            // Create User
            User u = new User();
            u.Username = (String) userdata.get('email');
            u.Email = (String) userdata.get('email');
            u.FirstName = (String) userdata.get('firstName');
            u.LastName = (String) userdata.get('lastName');
            u.MobilePhone = (String) userdata.get('mobile');
            u.CommunityNickname = communityNickname;
            u.EmailEncodingKey = 'UTF-8';
            u.Alias = 'ComUser';
            u.TimeZoneSidKey = 'Australia/Brisbane';
            u.LocaleSidKey = 'en_US';
            u.LanguageLocaleKey = 'en_US';

            // Determine Profile
            Map<String, String> profileMap = new Map<String, String>();
            for (Profile p : [SELECT Id, Name FROM Profile WHERE Name IN ('VC Customer Community Login', 'VC Investor Community Plus Login')]) {
                profileMap.put(p.Name, p.Id);
            }
            u.ProfileId = profileMap.get('VC Customer Community Login');

            // Create External User
            Id userId = Site.createExternalUser(u, accountId, (String) userdata.get('password'));

            retMap.put('IsValidtransaction', true);
            retMap.put('IsAccountCreated', true);
            retMap.put('accId', accountId);
            retMap.put('userId', userId);
        } else {
            retMap.put('IsValidtransaction', false);
            retMap.put('error', accountResult.get('error'));
        }
        return retMap;
    } catch (Exception e) {
        logMsgUtility.logMessage(e, 'ReCaptchaAuraController', 'User Registration', 'createAccountAndUser', userdata);
        retMap.put('IsValidtransaction', false);
        retMap.put('error', e.getMessage());
        return retMap;
    }
}
}