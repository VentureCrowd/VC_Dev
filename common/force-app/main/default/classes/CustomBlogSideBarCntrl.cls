public without sharing class CustomBlogSideBarCntrl {

    @AuraEnabled(cacheable=true)
    public static List<News_List_Page__c> fetchMonthlyArchives(String strMonth, String strYear){
        List<News_List_Page__c> lstArchivesPages = new List<News_List_Page__c>();
        if(String.isNotBlank(strMonth) && String.isNotBlank(strYear)) {
            Date monthStartDate = Date.newInstance(Integer.valueOf(strYear), Integer.valueOf(strMonth), 1);
            Date monthEndDate = monthStartDate.addMonths(+1);

            Map<String, Object> mapResult = new Map<String, Object>();
            lstArchivesPages = [SELECT Id, Date__c, News_Label__c, Navigation_url__c, News_Category__c, News_Descriptions__c, Newsbg_Url__c
                                                        FROM News_List_Page__c
                                                        WHERE Date__c >= :monthStartDate
                                                        AND Date__c < :monthEndDate
                                                        Order By Date__c ASC];
                                                        // WHERE Archive__c = true AND Publish_On_Community_Site__c = true
        }
        System.debug('===lstArchivesPages===>'+ JSON.serialize(lstArchivesPages));
        return lstArchivesPages;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> fetchNewsList(){
        Map<String, Object> mapResult = new Map<String, Object>();
        List<News_List_Page__c> lstNewsListPages = [SELECT Id, Date__c, News_Label__c, Navigation_url__c, News_Category__c, News_Descriptions__c
                                                    FROM News_List_Page__c
                                                    WHERE Publish_On_Community_Site__c = true
                                                    Order By Date__c DESC
                                                    LIMIT 6];
        mapResult.put('lstNewsListPages', lstNewsListPages);

        List<News_List_Page__c> lstArchivesPages = [SELECT Id, Date__c, News_Label__c, Navigation_url__c, News_Category__c
                                                    FROM News_List_Page__c
                                                    Order By Date__c DESC];
                                                    // WHERE Archive__c = true AND Publish_On_Community_Site__c = true
        Map<String, String> mapKeyToMonth = new Map<String, String>();
        for(News_List_Page__c nlPage : lstArchivesPages) {
            Date myDate = nlPage.Date__c;
            DateTime myDateTime = datetime.newInstance(myDate.year(), myDate.month(), myDate.day());
            mapKeyToMonth.put(myDateTime.format('MMMM'), myDateTime.format('MMMM YYYY'));
        }
        mapResult.put('mapArchiveMonthly', mapKeyToMonth);
        return mapResult;
    }

    /**
     * Method used in Next Post Blog Component
     */
    @AuraEnabled
    public static Map<String, Object> fetchBlogDetails(Integer currentBlogSeqNum){
        Map<String, Object> mapResult = new Map<String, Object>();
        Map<Integer, News_List_Page__c> mapNewListOage = new Map<Integer, News_List_Page__c>();
        List<News_List_Page__c> lstBlogs = [SELECT Id, date__c , Name,Navigation_url__c, News_Label__c, Blog_Sequesnce__c, 
                                            Publish_On_Community_Site__c, Archive__c, Page_Name__c, CategoryBanner_Img_Url__c,
                                            News_Category__c, News_Descriptions__c
                                            FROM News_List_Page__c
                                            Order BY Blog_Sequesnce__c ASC];
        News_List_Page__c nextBlog = new News_List_Page__c();
        if(lstBlogs.size() == currentBlogSeqNum) {
            nextBlog = lstBlogs[0];
        }
        else {
            nextBlog = lstBlogs[currentBlogSeqNum];
        }
        mapResult.put('nextBlog', nextBlog);
        return mapResult;
    }
}