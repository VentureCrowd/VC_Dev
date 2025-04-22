@isTest
public with sharing class CustomBlogSideBarCntrl_Test {

    @TestSetup
    static void makeData(){
        List<News_List_Page__c> lstNewsListPages = new List<News_List_Page__c>();
        for(Integer i= 1; i< 10; i++ ) {
            lstNewsListPages.add(new News_List_Page__c(
                                        Date__c = Date.today().addMonths(i),
                                        News_Label__c = 'Test Label ' + i,
                                        Blog_Sequesnce__c = i,
                                        Navigation_url__c = 'https://cm-vc-internal.cs74.force.com/InvestorLogin/s/vc-cf-ecofriendlyinvestment',
                                        Archive__c = false,
                                        Publish_On_Community_Site__c = true));
        }
        for(Integer i= 10; i< 20; i++ ) {
            lstNewsListPages.add(new News_List_Page__c(
                                        Date__c = Date.today().addMonths(i),
                                        News_Label__c = 'Test Label ' + i,
                                        Blog_Sequesnce__c = i,
                                        Navigation_url__c = 'https://cm-vc-internal.cs74.force.com/InvestorLogin/s/vc-cf-ecofriendlyinvestment',
                                        Archive__c = true,
                                        Publish_On_Community_Site__c = true));
        }
        insert lstNewsListPages;
    }
    
    @isTest
    static void test_fetchNewsList() {
        Map<String, Object> mapNewsListResult = CustomBlogSideBarCntrl.fetchNewsList();
        System.assertEquals(true, mapNewsListResult.size() > 0);

        Map<String, Object> netBlogResult = CustomBlogSideBarCntrl.fetchBlogDetails(2);
        System.assertEquals(true, netBlogResult.size() > 0);
        
        Date todaysDate =Date.today();
        List<News_List_Page__c> lstMonthlyArchive = CustomBlogSideBarCntrl.fetchMonthlyArchives(todaysDate.month() + '' , todaysDate.year() + '');
    }
}