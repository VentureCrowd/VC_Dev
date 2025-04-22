global without sharing  class NewsCategoryController {
     public List<News_List_Page__c> newsList{get;set;}
     public String currentcategory {get;set;}
   	 public String catgoreyimagurl{get;set;}
    
    public NewsCategoryController(){
        String category=ApexPages.currentPage().getParameters().get('category');
        System.debug('category='+category);
        this.currentcategory=category;
        this.newsList=[SELECT Id, News_Label__c,CategoryBanner_Img_Url__c, Tagged_category__c, Date__c, News_Category__c, News_Descriptions__c, Likes_Number__c, Newsbg_Url__c,  src_url__c, Navigation_url__c FROM News_List_Page__c where News_Category__c=:category ORDER BY Date__c DESC LIMIT 199];
        if(this.newsList.size()>0){
          this.catgoreyimagurl= this.newsList[0].CategoryBanner_Img_Url__c;
        }
    }
}