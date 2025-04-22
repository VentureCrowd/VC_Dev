@isTest
public class createAccountEntityTest {
    @IsTest
    static void testmethod1(){    
        Id personaccId  = [SELECT Id,recordtype.Name,SobjectType FROM recordtype WHERE Name ='VC Person Account'].Id;
        Id profId  = [SELECT Id,name FROM Profile WHERE Name ='VC Customer Community Login'].Id;
        Account acc = new Account();
        acc.LastName = 'Test Acount';
        acc.RecordTypeId = personaccId;
        acc.PersonEmail = 'test@test.com';
        insert acc;
        contact con = [SELECT ID FROM CONTACT WHERE AccountId = :acc.Id];
        con.EIC_Property__c = true;
        update con;
        String orgId = UserInfo.getOrganizationId();  
        String dateString =   
        String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');  
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));  
        String uniqueName = orgId + dateString + randomInt;  
        User tempUser = new User(  
            FirstName = 'test first',  
            LastName = 'test last',  
            email = uniqueName + '@sfdc' + orgId + '.org',  
            Username = uniqueName + '@sfdc' + orgId + '.org',  
            EmailEncodingKey = 'ISO-8859-1',  
            Alias = uniqueName.substring(18, 23),  
            TimeZoneSidKey = 'America/Los_Angeles',  
            LocaleSidKey = 'en_US',  
            LanguageLocaleKey = 'en_US',  
            ProfileId = profId,
            ContactId  = con.Id
        );    
        insert tempUser;
        Test.startTest();
        System.runAs(tempUser){
            string s = '{"Name":"fhujfv","Bank_Account_Name__c":"sdfsd","Bank_Account_Number__c":"dsfgds","BSB_Number__c":"gfdgfd","Company_ABN_numbers__c":576,"TFN_e__c":"fdghdf","ACN__c":"879","BillingStreet":"vdgv","BillingCity":"gfsdgf","BillingState":"gfdg","BillingPostalCode":"235","BillingCountry":"Taiwan"}';
            map<string,object> strmap = (Map<String, Object>) JSON.deserializeUntyped(s);
            createAccountEntity.createAccount(strmap);
        }
        Test.stopTest();        
    }
}