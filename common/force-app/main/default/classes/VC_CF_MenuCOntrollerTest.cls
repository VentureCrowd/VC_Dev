@isTest
public class VC_CF_MenuCOntrollerTest {
	@isTest
    public static void testnavigate(){
        VC_CF_MenuCOntroller ctrl=new VC_CF_MenuCOntroller();
        PageReference pageRef = Page.VC_CF_Home;
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('navigateurl',System.Label.Investor_Community_URL+'/vc-cf-home/vc-cf-invest');
        PageReference newpage=  ctrl.navigateToPage();
        System.assertEquals(System.Label.Investor_Community_URL+'/vc-cf-home/vc-cf-invest', newpage.getUrl());        
    }
    @isTest
    public static void navbarTest(){
        Site_Nav_Bar__c s = new Site_Nav_Bar__c();
        s.Display_Name__c = 'test';
        s.Display_URL__c = 'test';
        s.Sub_Header__c = 'INVEST';
        s.Valid_From__c = system.now().adddays(-1);
        s.Display_Order__c = 1;
        insert s;
        system.debug([SELECT Id, Sub_Header__c,  Display_Order__c, Display_Name__c, Display_URL__c, Active__c FROM Site_Nav_Bar__c WHERE Active__c = TRUE ORDER BY Sub_Header__c,Display_Order__c ASC]);
        VC_CF_MenuCOntroller ctrl=new VC_CF_MenuCOntroller();
    }
}