@isTest(SeeAllData=true)
public class AccountProcessorTest {

    // ----------------------------
    // Trigger-based Tests (Business Accounts)
    // ----------------------------
    
    static testMethod void testTriggerBeforeInsertAndAfterInsert() {
        // Create a BPAY__c record.
        BPAY__c bpayTest = new BPAY__c(Active__c = false);
        insert bpayTest;
        
        // Query a non-Person Account RecordType.
        RecordType rtBusiness = [SELECT Id FROM RecordType 
                                 WHERE SobjectType = 'Account' AND IsPersonType = false LIMIT 1];
        
        // Create a business Account.
        Account acc = new Account(
            Name = 'Test Account Insert',
            RecordTypeId = rtBusiness.Id,
            Account_Created_via_Portal__c = false,
            Investor_Updates_OptIn__c = false,
            PersonHasOptedOutOfEmail = false
        );
        Test.startTest();
            insert acc;
        Test.stopTest();
        
        // Requery the account including required fields.
        acc = [SELECT Id, Has_Made_1_Investment__c, BPAY__c, Total_Investment__c, Account_Created_via_Portal__c 
               FROM Account WHERE Id = :acc.Id];
        System.assertEquals(false, acc.Has_Made_1_Investment__c,
            'Investment flag should be false as Total_Investment__c is 0.');
        System.assertNotEquals(null, acc.BPAY__c,
            'BPAY__c should be assigned by after-insert processing.');
    }
    
    static testMethod void testTriggerBeforeUpdateAndAfterUpdate() {
        BPAY__c bpayTest = new BPAY__c(Active__c = false);
        insert bpayTest;
        
        RecordType rtBusiness = [SELECT Id FROM RecordType 
                                 WHERE SobjectType = 'Account' AND IsPersonType = false LIMIT 1];
        
        Account acc = new Account(
            Name = 'Test Account Update',
            RecordTypeId = rtBusiness.Id,
            Approval_Status__c = 'In Progress',
            Approval_Requested_For__c = UserInfo.getUserId(),
            Account_Created_via_Portal__c = false,
            Active__c = false
        );
        insert acc;
        
        User cmUser = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Application Received',
            AccountId = acc.Id,
            Sent_Verify_ID_Email__c = true,
            Bpay_Email_Sent__c = false,
            ID_Verified__c = false,
            CloseDate = Date.today().addDays(30),
            CM_Assigned__c = cmUser.Id,
            CRC_Assigned__c = cmUser.Id
        );
        insert opp;
        
        // Update the Account.
        acc.Approval_Status__c = 'Approved';
        update acc;
        
        Test.startTest();
            Test.stopTest();
        
        // Requery including OwnerId.
        acc = [SELECT Id, OwnerId, Approval_Requested_For__c, BPAY__c, Total_Investment__c, Account_Created_via_Portal__c 
               FROM Account WHERE Id = :acc.Id];
        opp = [SELECT Id, ID_Verified__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(false, opp.ID_Verified__c,
            'Since ID_Checked__pc did not change, opportunity flag remains false.');
        System.assertEquals(acc.Approval_Requested_For__c, acc.OwnerId,
            'Owner should be updated to Approval_Requested_For__c.');
        System.assertNotEquals(null, acc.BPAY__c,
            'BPAY__c should be assigned in before update processing.');
    }
    
    // ----------------------------
    // Direct Processor Tests (each in its own method)
    // ----------------------------
    
    static testMethod void testDirectProcessorBeforeUpdate() {
        RecordType rtBusiness = [SELECT Id FROM RecordType 
                                 WHERE SobjectType = 'Account' AND IsPersonType = false LIMIT 1];
        Account accForBeforeUpdate = new Account(
            Name = 'Direct Processor Account',
            RecordTypeId = rtBusiness.Id,
            BPAY__c = null,
            Approval_Status__c = 'In Progress',
            Approval_Requested_For__c = UserInfo.getUserId()
        );
        insert accForBeforeUpdate;
        
        Account oldAcc = [SELECT Id, BPAY__c, Approval_Status__c, Approval_Requested_For__c, 
                                 ID_Checked__pc, Total_Investment__c, Account_Created_via_Portal__c
                          FROM Account WHERE Id = :accForBeforeUpdate.Id];
        Account newAcc = oldAcc.clone(true, true);
        newAcc.put('ID_Checked__pc', true);
        newAcc.Approval_Status__c = 'Approved';
        
        Map<Id, Account> oldMap = new Map<Id, Account>{ oldAcc.Id => oldAcc };
        Map<Id, Account> newMap = new Map<Id, Account>{ newAcc.Id => newAcc };
        List<Account> accList = new List<Account>{ newAcc };
        
        BPAY__c bpayForDirect = new BPAY__c(Active__c = false);
        insert bpayForDirect;
        
        AccountProcessor procBeforeUpdate = new AccountProcessor(accList, oldMap, newMap, 'BEFORE_UPDATE');
        Test.startTest();
            procBeforeUpdate.execute(null);
        Test.stopTest();
    }
    
    static testMethod void testDirectProcessorAfterInsert() {
        RecordType rtBusiness = [SELECT Id FROM RecordType 
                                 WHERE SobjectType = 'Account' AND IsPersonType = false LIMIT 1];
        Account accAfterInsert = new Account(
            Name = 'Direct After Insert',
            RecordTypeId = rtBusiness.Id,
            BPAY__c = null,
            Account_Created_via_Portal__c = false
        );
        insert accAfterInsert;
        Account accAfterInsertQueried = [SELECT Id, BPAY__c, Email_Opt_In__pc, PersonHasOptedOutOfEmail, 
                                                Total_Investment__c, Account_Created_via_Portal__c
                                         FROM Account WHERE Id = :accAfterInsert.Id];
        accAfterInsertQueried.put('Email_Opt_In__pc', false);
        accAfterInsertQueried.put('PersonHasOptedOutOfEmail', false);
        
        Map<Id, Account> aiNewMap = new Map<Id, Account>{ accAfterInsertQueried.Id => accAfterInsertQueried };
        List<Account> aiList = new List<Account>{ accAfterInsertQueried };
        
        // In test context, our processor’s email-sending method now falls back to a valid recipient.
        AccountProcessor procAfterInsert = new AccountProcessor(aiList, null, aiNewMap, 'AFTER_INSERT');
        Test.startTest();
            procAfterInsert.execute(null);
        Test.stopTest();
    }
    
    static testMethod void testDirectProcessorAfterInsertCommunity() {
        RecordType rtBusiness = [SELECT Id FROM RecordType 
                                 WHERE SobjectType = 'Account' AND IsPersonType = false LIMIT 1];
        Account accAfterInsertComm = new Account(
            Name = 'Direct After Insert Community',
            RecordTypeId = rtBusiness.Id,
            BPAY__c = null,
            Account_Created_via_Portal__c = true
        );
        insert accAfterInsertComm;
        Account accAfterInsertCommQueried = [SELECT Id, BPAY__c, Email_Opt_In__pc, PersonHasOptedOutOfEmail, 
                                                   Total_Investment__c, Account_Created_via_Portal__c, OwnerId
                                             FROM Account WHERE Id = :accAfterInsertComm.Id];
        accAfterInsertCommQueried.put('Email_Opt_In__pc', false);
        accAfterInsertCommQueried.put('PersonHasOptedOutOfEmail', false);
        
        Map<Id, Account> aiCommMap = new Map<Id, Account>{ accAfterInsertCommQueried.Id => accAfterInsertCommQueried };
        List<Account> aiCommList = new List<Account>{ accAfterInsertCommQueried };
        
        AccountProcessor procAfterInsertComm = new AccountProcessor(aiCommList, null, aiCommMap, 'AFTER_INSERT');
        Test.startTest();
            procAfterInsertComm.execute(null);
        Test.stopTest();
    }
    
    static testMethod void testDirectProcessorAfterUpdate() {
        // For Person Accounts, use a Person Account record type.
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        // Create a test user if needed.
        User testUser = new User(
            Username = 'personacctuser@test.com',
            Alias = 'pacct',
            Email = 'personacctuser@test.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = p.Id,
            LastName = 'User'
        );
        insert testUser;
        
        System.runAs(testUser) {
            RecordType rtPerson = [SELECT Id FROM RecordType 
                                   WHERE SobjectType = 'Account' AND IsPersonType = true LIMIT 1];
            Account accAfterUpdate = new Account(
                RecordTypeId = rtPerson.Id,
                FirstName = 'Direct',
                LastName = 'AfterUpdate',
                BPAY__c = null,
                Account_Created_via_Portal__c = true,
                Active__c = false,
                Approval_Status__c = 'In Progress'
            );
            insert accAfterUpdate;

             // Create an Opportunity linked to this Person Account.
             Opportunity opp = new Opportunity(
                Name = 'Opp for Update',
                StageName = 'Application Received',
                AccountId = accAfterUpdate.Id,
                Sent_Verify_ID_Email__c = true,
                Bpay_Email_Sent__c = false,
                ID_Verified__c = false,
                CloseDate = Date.today().addDays(30),
                CM_Assigned__c = testUser.Id,
                CRC_Assigned__c = testUser.Id
            );
            insert opp;
            
            // Query the Person Account including all required fields.
            Account oldAccUpd = [SELECT Id, OwnerId, BPAY__c, Account_Created_via_Portal__c, Active__c, Approval_Status__c,
                                        Approval_Requested_For__c, ID_Checked__pc, Investor_Updates_OptIn__c, Email_Opt_In__pc, 
                                        PersonHasOptedOutOfEmail, Total_Investment__c, CreatedBy.ContactId, IsPersonAccount
                                 FROM Account WHERE Id = :accAfterUpdate.Id];
            Account newAccUpd = oldAccUpd.clone(true, true);
            newAccUpd.Active__c = true;
            newAccUpd.put('ID_Checked__pc', true);
            newAccUpd.put('Email_Opt_In__pc', true);
            newAccUpd.put('PersonHasOptedOutOfEmail', false);
            newAccUpd.Approval_Requested_For__c = testUser.Id;
            
            Map<Id, Account> oldMapUpd = new Map<Id, Account>{ oldAccUpd.Id => oldAccUpd };
            Map<Id, Account> newMapUpd = new Map<Id, Account>{ newAccUpd.Id => newAccUpd };
            List<Account> updList = new List<Account>{ newAccUpd };
            
            AccountProcessor procAfterUpdate = new AccountProcessor(updList, oldMapUpd, newMapUpd, 'AFTER_UPDATE');
            Test.startTest();
                procAfterUpdate.execute(null);
            Test.stopTest();
            
            // Requery and verify the Opportunity.
            opp = [SELECT Id, ID_Verified__c FROM Opportunity WHERE AccountId = :accAfterUpdate.Id LIMIT 1];
            System.assertEquals(true, opp.ID_Verified__c,
                'Opportunity should have ID_Verified__c updated to true after simulating ID_Checked__pc change.');
        }
    }

   
}