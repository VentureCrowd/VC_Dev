@isTest
public class MyPortfolio_InvestmentsTest {
    @isTest
    public static void testGetInvestments(){
        Test.startTest();
        String investAmnt = MyPortfolio_Investments.getInvestments();
        system.assertEquals(True, investAmnt != null);
        Test.stopTest();
    }
    
    @isTest
    public static void testGetCurrentUser(){
        Test.startTest();
        List<user> curUser = MyPortfolio_Investments.getCurrentUser();
        system.assertEquals(True, curUser != null);
        Test.stopTest();
    }
    
    @isTest
    public static void testGetInvestmentFromInvestmentObject(){
        Account a = new Account();
        a.LastName = 'test';
        a.FirstName = 'test';
        a.PersonEmail = 'tugg@tyugg.com';
        Database.insert(a);
        
        Investment__c invst = new Investment__c();
        invst.Account__c = a.id;
        invst.Investment_Amount__c = Decimal.valueOf('123');
        Database.insert(invst);
        
        Test.startTest();
        MyPortfolio_Investments.getInvestmentFromInvestmentObject();
        Test.stopTest();
    }

}