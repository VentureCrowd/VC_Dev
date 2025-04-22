/**

**/
@isTest
public class UserEmailUpdateSchedulerTest {
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
    static void validateContactEmailUpdate(){
        
        String updatedEmail = 'Updated@test.com';
        //Update the exising Business user Email
        User oUser = [SELECT Id,Email FROM USER WHERE Account.isPersonAccount = false LIMIT 1];
        oUser.Email = updatedEmail;
        update oUser;

        Test.startTest();
        // Schedule the test job
        UserEmailUpdateScheduler sch = new UserEmailUpdateScheduler();
        String jobId = System.schedule('scheduledTestJob', sch.CRON_EXP, sch);
        Test.stopTest();
    }

    @IsTest
    static void validateAccountEmailUpdate(){
        
        String updatedEmail = 'Updated@test.com';
        //Update the exising Business user Email
        User oUser = [SELECT Id,Email FROM USER WHERE Account.isPersonAccount = true LIMIT 1];
        oUser.Email = updatedEmail;
        update oUser;

        Test.startTest();
        // Schedule the test job
        UserEmailUpdateScheduler sch = new UserEmailUpdateScheduler();
        String jobId = System.schedule('scheduledTestJob', sch.CRON_EXP, sch);
        Test.stopTest();
    }
}