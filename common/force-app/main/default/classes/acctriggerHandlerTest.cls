/**
Test method for accTriggerHandler
 */
@istest
class acctriggerHandlerTest {
    @IsTest
    static void methodName(){        
        createCaseCntrl.getUserDEtails();
        Account acc = new Account();
        acc.name = 'Test Acount';
        insert acc;
        acc.Bank_Account_Number__c = 'test';
        acc.BSB_Number__c = 'test';
        acc.Bank_Account_Name__c = 'test';
        update acc;
    }
}