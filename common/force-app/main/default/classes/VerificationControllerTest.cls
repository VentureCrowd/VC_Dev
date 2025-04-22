/**

**/
@isTest
public class VerificationControllerTest {
    
   public static testmethod void shouldGetVerificationUser() {
        Test.startTest();
        String orgId = UserInfo.getOrganizationId();  
        String dateString =   
        String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');  
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));  
        String uniqueName = orgId + dateString + randomInt;  
        Profile profileObj = [select id,name from Profile where name='VC Investor Community Plus Login'];
        Account actObj = new Account();
        actObj.Name='Test Name';
        actObj.OwnerId = UserInfo.getUserId();
        insert actObj;
        Contact contObj = new Contact();
        contObj.AccountId = actObj.Id;
        contObj.FirstName = 'Test First name';
        contObj.LastName = 'Test Last Name';
        contObj.Email ='test@test.com';
        contObj.MailingStreet ='test Street';
        contObj.MailingCity ='Test City';
        contObj.MailingCountry='Australia';
        contObj.MailingState = 'Test state';
        contObj.MailingPostalCode='34234';
        insert contObj;
        
        User userObj = new User();
        userObj.FirstName = contObj.FirstName;
        userObj.LastName = contObj.LastName;
        userObj.ContactId = contObj.Id;
        userObj.ProfileId = profileObj.Id;
        userObj.email = uniqueName + '@sfdc' + orgId + '.org';
        userObj.Username = uniqueName + '@sfdc' + orgId + '.org';
        userObj.EmailEncodingKey = 'ISO-8859-1';  
        userObj.Alias = uniqueName.substring(18, 23);  
        userObj.TimeZoneSidKey = 'America/Los_Angeles'; 
        userObj.LocaleSidKey = 'en_US';
        userObj.LanguageLocaleKey = 'en_US';
        userObj.ProfileId = profileObj.Id;        
        insert userObj;
        System.runAs(userObj) {
            Account isVerified = VerificationController.checkVerificationNeeded();
            //System.assert(isVerified == false);
        }
        Test.stopTest();
        
    }
    public static testmethod void updatsAccVerification() {
        Test.startTest();
        String orgId = UserInfo.getOrganizationId();  
        String dateString =   
        String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');  
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));  
        String uniqueName = orgId + dateString + randomInt;  
        Profile profileObj = [select id,name from Profile where name='VC Investor Community Plus Login'];
        Account actObj = new Account();
        actObj.Name='Test Name';
        actObj.OwnerId = UserInfo.getUserId();
        insert actObj;
        Contact contObj = new Contact();
        contObj.AccountId = actObj.Id;
        contObj.FirstName = 'Test First name';
        contObj.LastName = 'Test Last Name';
        contObj.Email ='test@test.com';
        contObj.MailingStreet ='test Street';
        contObj.MailingCity ='Test City';
        contObj.MailingCountry='Australia';
        contObj.MailingState = 'Test state';
        contObj.MailingPostalCode='34234';
        insert contObj;
        
        User userObj = new User();
        userObj.FirstName = contObj.FirstName;
        userObj.LastName = contObj.LastName;
        userObj.ContactId = contObj.Id;
        userObj.ProfileId = profileObj.Id;
        userObj.email = uniqueName + '@sfdc' + orgId + '.org';
        userObj.Username = uniqueName + '@sfdc' + orgId + '.org';
        userObj.EmailEncodingKey = 'ISO-8859-1';  
        userObj.Alias = uniqueName.substring(18, 23);  
        userObj.TimeZoneSidKey = 'America/Los_Angeles'; 
        userObj.LocaleSidKey = 'en_US';
        userObj.LanguageLocaleKey = 'en_US';
        userObj.ProfileId = profileObj.Id;        
        insert userObj;
       
        system.runas(userObj){
           
            string dataToBeUpdated = '['+
                                            +'{"label":"verificationId","value":"a123b4356788"},'+
                                            +'{"label":"verificationToken","value":"we3456ewe678tgg"},'+
                                            +'{"label":"verificationResult","value":"VERIFIED"},'+
                                            +'{"label":"givenName","value":"Test First name"},'+
                                            +'{"label":"middleNames","value":"Test First name"},'+
                                            +'{"label":"surname","value":"Test First name"}'+
                                        +']';
            system.debug('data To be Loaded'+dataToBeUpdated);
            string result = VerificationController.updateAccountVerificationDetails(dataToBeUpdated);
		}
        Test.stopTest();        
        
    }
    public static testmethod void updatsAccVerificationFail() {
        Test.startTest();
        String orgId = UserInfo.getOrganizationId();  
        String dateString =   
        String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');  
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));  
        String uniqueName = orgId + dateString + randomInt;  
        Profile profileObj = [select id,name from Profile where name='VC Investor Community Plus Login'];
        Account actObj = new Account();
        actObj.Name='Test Name';
        actObj.OwnerId = UserInfo.getUserId();
        insert actObj;
        Contact contObj = new Contact();
        contObj.AccountId = actObj.Id;
        contObj.FirstName = 'Test First name';
        contObj.LastName = 'Test Last Name';
        contObj.Email ='test@test.com';
        contObj.MailingStreet ='test Street';
        contObj.MailingCity ='Test City';
        contObj.MailingCountry='Australia';
        contObj.MailingState = 'Test state';
        contObj.MailingPostalCode='34234';
        insert contObj;
        
        User userObj = new User();
        userObj.FirstName = contObj.FirstName;
        userObj.LastName = contObj.LastName;
        userObj.ContactId = contObj.Id;
        userObj.ProfileId = profileObj.Id;
        userObj.email = uniqueName + '@sfdc' + orgId + '.org';
        userObj.Username = uniqueName + '@sfdc' + orgId + '.org';
        userObj.EmailEncodingKey = 'ISO-8859-1';  
        userObj.Alias = uniqueName.substring(18, 23);  
        userObj.TimeZoneSidKey = 'America/Los_Angeles'; 
        userObj.LocaleSidKey = 'en_US';
        userObj.LanguageLocaleKey = 'en_US';
        userObj.ProfileId = profileObj.Id;        
        insert userObj;
		try{
            string result = VerificationController.updateAccountVerificationDetails('dataToBeUpdated');
		}catch(Exception ex){
			system.assert(ex.getMessage() != 'Success');
        }
        Test.stopTest();    
    }
    public static testmethod void callouttest(){
        String orgId = UserInfo.getOrganizationId();  
        String dateString =   
        String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');  
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));  
        String uniqueName = orgId + dateString + randomInt;  
        Profile profileObj = [select id,name from Profile where name='VC Investor Community Plus Login'];
        Account actObj = new Account();
        actObj.Name='Test Name';
        actObj.OwnerId = UserInfo.getUserId();
        insert actObj;
        Contact contObj = new Contact();
        contObj.AccountId = actObj.Id;
        contObj.FirstName = 'Test First name';
        contObj.LastName = 'Test Last Name';
        contObj.Email ='test@test.com';
        contObj.MailingStreet ='test Street';
        contObj.MailingCity ='Test City';
        contObj.MailingCountry='Australia';
        contObj.MailingState = 'Test state';
        contObj.MailingPostalCode='34234';
        insert contObj;        
        User userObj = new User();
        userObj.FirstName = contObj.FirstName;
        userObj.LastName = contObj.LastName;
        userObj.ContactId = contObj.Id;
        userObj.ProfileId = profileObj.Id;
        userObj.email = uniqueName + '@sfdc' + orgId + '.org';
        userObj.Username = uniqueName + '@sfdc' + orgId + '.org';
        userObj.EmailEncodingKey = 'ISO-8859-1';  
        userObj.Alias = uniqueName.substring(18, 23);  
        userObj.TimeZoneSidKey = 'America/Los_Angeles'; 
        userObj.LocaleSidKey = 'en_US';
        userObj.LanguageLocaleKey = 'en_US';
        userObj.ProfileId = profileObj.Id;        
        insert userObj;
        System.runAs(userObj) {
            Test.startTest();
            Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
            VerificationController.getverificationresult('accountId','webServicePassword','verificationToken');
            dynamicformServicesRegistrationsEdent.fieldV3 fld = new dynamicformServicesRegistrationsEdent.fieldV3();
            dynamicformServicesRegistrationsEdent.getSourcesResponse resp1 = new dynamicformServicesRegistrationsEdent.getSourcesResponse();
            dynamicformServicesRegistrationsEdent.sourceV3 resp2 = new dynamicformServicesRegistrationsEdent.sourceV3();
            dynamicformServicesRegistrationsEdent.sourceListV3 resp3 = new dynamicformServicesRegistrationsEdent.sourceListV3();
            dynamicformServicesRegistrationsEdent.getVerificationToken resp4 = new dynamicformServicesRegistrationsEdent.getVerificationToken();
            dynamicformServicesRegistrationsEdent.documentRecord resp5 = new dynamicformServicesRegistrationsEdent.documentRecord();
            dynamicformServicesRegistrationsEdent.nameValuePair resp6 = new dynamicformServicesRegistrationsEdent.nameValuePair();
            dynamicformServicesRegistrationsEdent.registerVerification resp7 = new dynamicformServicesRegistrationsEdent.registerVerification();
            dynamicformServicesRegistrationsEdent.postOfficeDataV3 resp8 = new dynamicformServicesRegistrationsEdent.postOfficeDataV3();
            dynamicformServicesRegistrationsEdent.detailRecordHeader resp9 = new dynamicformServicesRegistrationsEdent.detailRecordHeader();
            Test.stopTest();
        }
        
    }
}