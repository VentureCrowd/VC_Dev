@IsTest
public class TestDataFactory {

    public static void testData() {
	User owner = [SELECT Id FROM USER WHERE Name = 'The VentureCrowd Team'];
        
        Id recordIdByName = Schema.SObjectType.Account.getRecordTypeInfosByName().get('VC Business Account').getRecordTypeId();
        List<Account> lstOfAccountForInsert1 = new List<Account>();
        	Account accObj = new Account();
        		accObj.Name = 'Test Venture Person Account';
        		accObj.RecordTypeId = recordIdByName;
        		accObj.OwnerId = owner.Id;
        	lstOfAccountForInsert1.add(accObj);
        Database.SaveResult[] saveResults1 ;
        Test.startTest();
        System.runAs(owner){
           saveResults1 = Database.insert(lstOfAccountForInsert1,false);
        }
        List<EOI__c> lstOfEOIForInsert = new List<EOI__c>();
        EOI__c eoiObj = new EOI__c();
        	eoiObj.Name = 'Test updateEoi Method';
        	eoiObj.Account__c =  saveResults1[0].getId();
        	eoiObj.EOI_Status__c = 'Not Published';
        	eoiObj.Related_Person_Account__c = saveResults1[0].getId();
        lstOfEOIForInsert.add(eoiObj);
        
        Database.SaveResult[] saveResults2 ;
        System.runAs(owner){
           saveResults2 = Database.insert(lstOfEOIForInsert,false);
        }
        
        
        List<EOI_team_and_advisors__c> lstOfEoiTeamAndAdviser = new List<EOI_team_and_advisors__c>();
        	EOI_team_and_advisors__c eoiTeamAndAdviser = new EOI_team_and_advisors__c();
    			eoiTeamAndAdviser.put('Name','John Steven');
        		eoiTeamAndAdviser.put('Category__c','Founder');
        		eoiTeamAndAdviser.put('Member_Role__c','Founder & CEO');
        		eoiTeamAndAdviser.put('Team_Member_Description__c','john is an Accredited Practicing Dietitian');
        		eoiTeamAndAdviser.put('Team_member_Linkedin__c','https://www.linkedin.com/');
        		eoiTeamAndAdviser.put('Team_Related_EOI__c',saveResults2[0].getId());
        lstOfEoiTeamAndAdviser.add(eoiTeamAndAdviser);
        Database.SaveResult[] saveResults3 ;
       
        System.runAs(owner){
           saveResults3 = Database.insert(lstOfEoiTeamAndAdviser,false);
        }
        Test.stopTest();
    }
    
    public static void dataForContentDownloadURL(){
        User owner = [SELECT Id FROM USER WHERE Name = 'The VentureCrowd Team'];
        
        Id recordIdByName = Schema.SObjectType.Account.getRecordTypeInfosByName().get('VC Business Account').getRecordTypeId();
        List<Account> lstOfAccountForInsert1 = new List<Account>();
        	Account accObj = new Account();
        		accObj.Name = 'Test Venture Person Account';
        		accObj.RecordTypeId = recordIdByName;
        		accObj.OwnerId = owner.Id;
        	lstOfAccountForInsert1.add(accObj);
        Database.SaveResult[] saveResults1 ;
        System.runAs(owner){
           saveResults1 = Database.insert(lstOfAccountForInsert1,false);
        }
        
        
        List<EOI__c> lstOfEOIForInsert = new List<EOI__c>();
        EOI__c eoiObj = new EOI__c();
        	eoiObj.Name = 'Test Eoi record';
        	eoiObj.Account__c = saveResults1[0].getId();
        	eoiObj.EOI_Status__c = 'Not Published';
        	eoiObj.Related_Person_Account__c = saveResults1[0].getId();
        lstOfEOIForInsert.add(eoiObj);
        
        Database.SaveResult[] saveResults2 ;
        System.runAs(owner){
           saveResults2 = Database.insert(lstOfEOIForInsert,false);
        }
    }
}