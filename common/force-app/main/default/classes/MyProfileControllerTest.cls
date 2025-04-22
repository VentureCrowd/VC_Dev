/**

**/
@isTest (seealldata = false)
public with sharing class MyProfileControllerTest {

    @testSetup
    static void setupData () {

        List<Account> lstAccount = new List<Account>();
        List<User> lstUser = new List<User>();

        Account oAccount = new Account(name ='Grazitti') ;
        lstAccount.add(oAccount);

        String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('VC Person Account').getRecordTypeId();
        Account personAccount = new Account(RecordTypeId = recordTypeId, FirstName = 'TestPersonAccountFirst', LastName = 'TestPersonAccountLast', PersonEmail = 'test@user.com');
        lstAccount.add(personAccount);

        insert lstAccount;
       
        Contact oContact = new Contact(LastName ='testCon',AccountId = lstAccount[0].Id);
        insert oContact;  

        Id userProfileId = [select id from profile where name='VC Investor Community Plus Login'].id;

        User businesUser = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = userProfileId, country='United States',IsActive =true,
                ContactId = oContact.Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        lstUser.add(businesUser);

        Account acc = [Select PersonContactId From Account Where Id = :lstAccount[1].Id];

        User personUser = new User(FirstName = 'TestFirstName',
                                    LastName = 'TestLastName',
                                    Email = 'test@user.com',
                                    Username = 'test@user.com',
                                    Alias = 'TestPA', 
                                    TimeZoneSidKey = 'GMT', 
                                    LocaleSidKey = 'en_US', 
                                    EmailEncodingKey = 'UTF-8', 
                                    ProfileId = userProfileId, 
                                    LanguageLocaleKey = 'en_US',
                                    ContactId = acc.PersonContactId);
        lstUser.add(personUser);
        insert lstUser;
    }


    @IsTest
    static void updateSObject_Test(){
        User oUser = new User(Id=UserInfo.getUserId());
        Test.startTest();
        System.runAs(new User(Id=UserInfo.getUserId())){
            MyProfileController.updateSObject(oUser);
        }
        Test.stopTest();
    }
    
    @IsTest
    static void updateSObject_NegativeTest(){
        User oUser = new User(Id=UserInfo.getUserId());
        Boolean isException = false;
        Test.startTest();
        System.runAs(new User(Id=UserInfo.getUserId())){
            
            try {
                oUser.FirstName = '';
                oUser.LastName = '';
                MyProfileController.updateSObject(oUser);
            } catch (Exception expObj) {
                isException = true;
            }
            
        }
        Test.stopTest();
        System.assert(isException);
    }
    @IsTest
    static void getSObjectInstance_Test(){
    	user oUser = new User(Id=UserInfo.getUserId()) ;
        User nUser = [SELECT Id,contactId,AccountId,Account.ispersonaccount FROM User Where Id = :oUser.Id];
        Test.startTest();
        MyProfileController.getSObjectInstance(nUser.Id);
        Test.stopTest();
    }
    
    @IsTest
    static void getSObjectInstanceContact_Test(){
    	user oUser = new User(Id=UserInfo.getUserId()) ;
        // User nUser = [SELECT Id,contactId,AccountId,Account.ispersonaccount FROM User Where Account.ispersonaccount = false AND contactId != null limit 1];
        Test.startTest();
        //MyProfileController.getSObjectInstance(nUser.Id);
        Test.stopTest();
    }
    
    @IsTest
    static void getSObjectInstanceAccount_Test(){
    	user oUser = new User(Id=UserInfo.getUserId()) ;
        User nUser = [SELECT Id,contactId,AccountId,Account.ispersonaccount FROM User Where Account.ispersonaccount = true limit 1];
        Test.startTest();
        MyProfileController.getSObjectInstance(nUser.Id);
        Test.stopTest();
    }

    @IsTest
    static void testmethod1(){
        try{
        MyProfileController.saveAttachment(EncodingUtil.urlencode('hello boss', 'UTF-8'));
        }catch(exception e){}
        User nUser = [SELECT Id,contactId,AccountId,Account.ispersonaccount FROM User Where Account.ispersonaccount = true limit 1];
        MyProfileController.getMailingAdress(nUser.Id);
        Id AccountId = [SELECT Id FROM ACCOUNT LIMIT 1].Id;
        Map<string,string> dataMap = new Map<string,string>{'Id' => AccountId};
        MyProfileController.updateAccount(dataMap);
        MyProfileController.getBillingAdress(nUser.AccountId);

    }
}