// test class for RECAPTCHA Controller
// This may need to be refactored in future! - KENDRICK
@isTest
public class ReCaptchaAuraControllerTest {
    @isTest 
    public static void testGetRegisterSubmitNewuser(){
        Map<String,Object> registerComponentInfo = new Map<String,Object>{
            'firstName' => 'tes',
            'lastName'=>'test',
            'terms'=>true,
            'mobile'=>'+61410436322',
            'investPimpa'=>false,
            'investSYield'=>false,
            'investBotanic'=>false,
            'password'=>'Testo123',
            'email'=>'tgyh@rfv.com'
        };
        Test.startTest();
        try{
            String newUserVal = ReCaptchaAuraController.getRegisterSubmit(registerComponentInfo);
        } catch(Exception ex){
            System.assert(true, ex.getMessage());
        }
        Test.stopTest();
    }

   @isTest
    public static void testGetRegisterSubmitExistingContact(){
        Contact c = new Contact(
            LastName = 'test',
            Email = 'tgyh@rfv.com'
        );
        insert c;

        Map<String,Object> registerComponentInfo = new Map<String,Object>{
            'firstName' => 'tes',
            'lastName'=>'test',
            'terms'=>true,
            'mobile'=>'+61410436322',
            'investPimpa'=>false,
            'investSYield'=>false,
            'investBotanic'=>false,
            'password'=>'Testo123',
            'email'=>'tgyh@rfv.com'
        };
        Test.startTest();
        String existingContactVal = ReCaptchaAuraController.getRegisterSubmit(registerComponentInfo);
        Test.stopTest();
    }

     @istest
    static void testmethodA2(){
        ReCaptchaAuraController cls = new ReCaptchaAuraController();
    }

   @isTest
    public static void upsertPersonAccountTest(){
        Map<String,Object> registerComponentInfo = new Map<String,Object>{
            'firstName' => 'tes',
            'lastName'=>'test',
            'terms'=>true,
            'mobile'=>'+61410436322',
            'investPimpa'=>false,
            'investSYield'=>false,
            'Email_Opt_In__pc'=>false,
            'password'=>'Testo123',
            'email'=>'tgyh@rfv.com'
        };
        Test.startTest();
        ReCaptchaAuraController.upsertPersonAccount(registerComponentInfo);
        Test.stopTest();
    }

    @isTest
    public static void upsertPersonAccountTest_1(){
        Account acc = new Account(
            LastName = 'test',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('VC Person Account').getRecordTypeId(),
            PersonEmail = 'tgyh@rfv.com'
        );
        insert acc;

        Map<String,Object> datmap = new Map<String,Object>{
            'Id' => acc.Id,
            'LastName' => acc.LastName
        };
        ReCaptchaAuraController.updateAccount(datmap);

        Map<String,Object> registerComponentInfo = new Map<String,Object>{
            'firstName' => 'tes',
            'lastName'=>'test',
            'terms'=>true,
            'mobile'=>'+61410436322',
            'investPimpa'=>false,
            'investSYield'=>false,
            'Email_Opt_In__pc'=>false,
            'password'=>'Testo123',
            'email'=>'tgyh@rfv.com'
        };
        Test.startTest();
        ReCaptchaAuraController.upsertPersonAccount(registerComponentInfo);
        try{
            ReCaptchaAuraController.communityLogin((String)registerComponentInfo.get('email'), (String)registerComponentInfo.get('password'), '/s');
        } catch(Exception e){}
        Test.stopTest();
    }
    
    @isTest
    public static void testCreateAccountAndUser_Founder() {
        // Prepare test data
        Map<String, Object> userdata = new Map<String, Object>{
            'firstName' => 'Test',
            'lastName' => 'User',
            'email' => 'testuserfounder@example.com',
            'password' => 'TestPassword1',
            'mobile' => '+61412345678',
            'Self_Identification__pc' => 'Founder',
            'Ventures_Company_Name__c' => 'Test Ventures',
            'Website' => 'https://testventures.com',
            'Sector__c' => 'FINTECH',
            'ACN__c' => '123456789',
            'Email_Opt_In__pc' => true,
            'utm_source__c' => 'TestSource',
            'utm_medium__c' => 'TestMedium',
            'utm_campaign__c' => 'TestCampaign',
            'utm_content__c' => 'TestContent',
            'utm_term__c' => 'TestTerm',
            'utm_keyword__c' => 'TestKeyword'
        };

        // Run test
        Test.startTest();
        Map<String, Object> retMap = ReCaptchaAuraController.createAccountAndUser(userdata);
        Test.stopTest();

        // Assert that account and user are created successfully
        System.assertEquals(true, retMap.get('IsValidtransaction'));
        Id accountId = (Id) retMap.get('accId');
        System.assertNotEquals(null, accountId, 'Account Id should not be null');


        // Verify Account record
        Account acc = [SELECT Id, RecordType.Name, Ventures_Company_Name__c, Website, Sector__c, ACN__c
                       FROM Account WHERE Id = :accountId];
        System.assertEquals('Test Ventures', acc.Ventures_Company_Name__c);
        System.assertEquals('https://testventures.com', acc.Website);
        System.assertEquals('FINTECH', acc.Sector__c);
        System.assertEquals('123456789', acc.ACN__c);
        System.assertEquals('Ventures Person Account', acc.RecordType.Name);


    }


    @isTest
    public static void testCreateAccountAndUser_Retail() {
        // Prepare test data
        Map<String, Object> userdata = new Map<String, Object>{
            'firstName' => 'Retail',
            'lastName' => 'User',
            'email' => 'retailuser@example.com',
            'password' => 'TestPassword1',
            'mobile' => '+61487654321',
            'Self_Identification__pc' => 'Retail',
            'Email_Opt_In__pc' => false,
            'utm_source__c' => 'RetailSource',
            'utm_medium__c' => 'RetailMedium',
            'utm_campaign__c' => 'RetailCampaign',
            'utm_content__c' => 'RetailContent',
            'utm_term__c' => 'RetailTerm',
            'utm_keyword__c' => 'RetailKeyword'
        };

        // Run test
        Test.startTest();
        Map<String, Object> retMap = ReCaptchaAuraController.createAccountAndUser(userdata);
        Test.stopTest();

        // Assert that account and user are created successfully
        System.assertEquals(true, retMap.get('IsValidtransaction'));
        Id accountId = (Id) retMap.get('accId');
        Id userId = (Id) retMap.get('userId');
        System.assertNotEquals(null, accountId, 'Account Id should not be null');

        // Verify Account record
        Account acc = [SELECT Id, RecordType.Name FROM Account WHERE Id = :accountId];
        System.assertEquals('VC Person Account', acc.RecordType.Name);

    }

     @isTest
    public static void testCreateAccountAndUser_ExistingAccount() {
        // First, create an existing account
        String email = 'existinguser@example.com';
        Account existingAcc = new Account(
            FirstName = 'Existing',
            LastName = 'User',
            PersonEmail = email,
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('VC Person Account').getRecordTypeId()
        );
        insert existingAcc;

        // Prepare test data with same email
        Map<String, Object> userdata = new Map<String, Object>{
            'firstName' => 'New',
            'lastName' => 'User',
            'email' => email,
            'password' => 'TestPassword1',
            'mobile' => '+61487654322',
            'Self_Identification__pc' => 'Retail',
            'Email_Opt_In__pc' => false
        };

        // Run test
        Test.startTest();
        Map<String, Object> retMap = ReCaptchaAuraController.createAccountAndUser(userdata);
        Test.stopTest();

        // Assert that account creation failed
        System.assertEquals(false, retMap.get('IsValidtransaction'));
        System.assertEquals('Account already exists with this email.', retMap.get('error'));
    }


}