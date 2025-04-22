@isTest
public class NewsCategoryControllerTest {

    @isTest
    public static void newsBlogTestMethod(){
        News_List_Page__c nlp = new News_List_Page__c();
        nlp.News_Label__c = 'News Label1';
        nlp.Tagged_category__c = 'Tagged Catg1';
        nlp.Date__c = system.today();
        nlp.News_Category__c = 'News Catg1';
        nlp.News_Descriptions__c = 'test desc';
        nlp.Likes_Number__c = 2;
        nlp.Newsbg_Url__c = 'https://www.venturecrowd.com.au';
        nlp.src_url__c = 'https://www.venturecrowd.com.au';
        nlp.Navigation_url__c = 'https://www.venturecrowd.com.au'; 
        Database.SaveResult newsINs = database.insert(nlp,false);
        System.assertEquals(True, newsINs.isSuccess());   
		PageReference pageRef=Page.VC_CF_News_category;
       	Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('category','News Catg1');
        NewsCategoryController nc = new NewsCategoryController();
    }
}