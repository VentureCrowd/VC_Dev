@isTest
public class CommunityUserDetailControllerTest {
    
    @isTest
    public static void testGetCurrentUser(){
        Test.startTest();
        CommunityUserDetailController.getCurrentUser();
        Test.stopTest();
        System.assert( CommunityUserDetailController.getCurrentUser() != null);
    }
    
    @isTest
    public static void testGetheaders(){
        Site_Nav_Bar__c testSNV = new Site_Nav_Bar__c();
        testSNV.Sub_Header__c = 'VENTURES';
        testSNV.Display_Order__c = 1;
        testSNV.Display_Name__c = 'Test Display Name';
        testSNV.Display_URL__c = 'testClass.comapex';
        testSNV.Valid_From__c = System.now();
        testSNV.Valid_To__c = System.now() + 1;
        
        INSERT testSNV;
        
        Test.startTest();
        CommunityUserDetailController.getheaders();
        Test.stopTest();
        
        Site_Nav_Bar__c assertSNV = [SELECT Id, Sub_Header__c FROM Site_Nav_Bar__c WHERE Sub_Header__c = 'VENTURES'];
        System.assert(assertSNV != NULL);
        
    }
}