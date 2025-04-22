@isTest
public with sharing class ProductControllerTest {
    @TestSetup
    public static void creatData(){
         List<News_List_Page__c> nlps = new List<News_List_Page__c>();
        for(Integer i=0;i<10;i++){
		 News_List_Page__c nlp = new News_List_Page__c();
        
        nlp.News_Label__c = 'News Label Test '+i+1;
        nlp.Tagged_category__c = 'Tagged Catg1';
        nlp.Date__c = system.today();
        nlp.News_Category__c = 'News Catg1';
        nlp.News_Descriptions__c = 'test desc';
        nlp.Likes_Number__c = 0;
        nlp.Newsbg_Url__c = 'https://www.venturecrowd.com.au';
        nlp.src_url__c = 'https://www.venturecrowd.com.au';
        nlp.Navigation_url__c = 'https://www.venturecrowd.com.au'; 
        nlp.CategoryBanner_Img_Url__c = 'https://www.venturecrowd.com.au';
            
            nlps.add(nlp);
        }
        
        insert nlps;
        createtestproduct();
        createnewsBlogs();
       
    }
    @isTest
    public static void productTestMethod(){
        product2 prod = new product2();
        prod.Name = 'Test Prod';
        prod.IM_PDS__c = 'https://test.salesforce.com';
        prod.DisplayUrl = 'https://www.venturecrowd.com.au';
        prod.Deal_Page_Link__c = 'https://www.venturecrowd.com.au';
        prod.Trust_Deed_Link__c = 'https://www.venturecrowd.com.au';
        prod.Sector_Personas__c = 'Just Launchers';
        prod.ProductCode = 'AURT';
        prod.FAQ_s__c = 'Test FAQ';
        prod.Fully_Funded__c = true;
        prod.Return_Type__c = 'Per Annum';
        prod.Tile_Banner__c = 'https://www.venturecrowd.com.au';
        prod.Tile_Heading__c = 'Test heading';
        prod.Tile_Offer_Type__c = 'Investment';
        prod.Button_Text__c = 'View Offer';
        prod.IsActive = true;
        prod.Private_Deal__c = false;
        prod.Publish_on_Community_Site__c = TRUE;
        prod.Offer_Launch_Date__c = system.now();
        prod.Offer_Close_Date__c = system.now();
        
        Database.SaveResult prodINs = database.insert(prod,false);
        System.assertEquals(True, prodINs.isSuccess());

        ProductController pc = new ProductController();
        ProductController.getInvestProds();
        ProductController.getRelProds(new List<Id> {prod.Id});
    }

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

        ProductController pc = new ProductController();
    }
    @isTest
    public static void testnewslike(){
        List<News_List_Page__c> pages=[Select Id from News_List_Page__c where News_Label__c like 'News Label Test %'];
       ProductController pc = new ProductController();
        pc.currentblogrecId=pages[0].Id;
        pc.likeblog();
        News_List_Page__c currpage=[Select Id,Likes_Number__c from News_List_Page__c where Id=:pages[0].Id Limit 1];
        System.assertEquals(1, currpage.Likes_Number__c);
        
    }
    
   @isTest
    public static void testimaginfo(){
        List<Image_Info__c> infoList=new List<Image_Info__c>();
        Image_Info__c img1=new Image_Info__c(Image_Unique_Name__c='Test1',Image_Public_URL__C='https://google.com/myimage1');
         Image_Info__c img2=new Image_Info__c(Image_Unique_Name__c='Test2',Image_Public_URL__C='https://google.com/myimage2');
        infoList.add(img1);
         infoList.add(img2);
        insert  infoList;
        ProductController infoctrl=new ProductController();
       System.assert(infoctrl.imageNameURLMap.containsKey('Test1'));
    }
    
    @isTest
    public static void getProducttest(){
        ProductController.getProducts(false, 'Property Product');
        ProductController.getProducts(true, null);
    }
     @isTest
    public static void getNewsBlogtest(){
       List<News_List_Page__c> newsblogs= ProductController.getNewsBlogs();
		System.assert(newsblogs.size()>0);
    }
    
   @isTest
    public static void getNBForNewsConByCat(){
        News_List_Page__c nlp = new News_List_Page__c(Date__c=System.today(), News_Label__c='Test');
        nlp.News_Category__c = 'Test';
        
        insert nlp;
       List<News_List_Page__c> lstPC =  ProductController.getNewsBlogsForNewsContainerByCategory(10, 0, 'Test');
       ProductController.getNewsBlogsForNewsContainer( 2, 2);
       ProductController.getNewsBlogsByCategory('Test');
        System.assertEquals(1, lstPC.size());
        
    }
    public static void createtestproduct(){
         List<product2> productlist=new  List<product2>();
        for(Integer i=0;i<10;i++){
            product2 prod = new product2();
        prod.Name = 'Test Prod '+i+1;
        prod.IM_PDS__c = 'https://test.salesforce.com';
        prod.DisplayUrl = 'https://www.venturecrowd.com.au';
        prod.Deal_Page_Link__c = 'https://www.venturecrowd.com.au';
        prod.Trust_Deed_Link__c = 'https://www.venturecrowd.com.au';
        prod.Sector_Personas__c = 'Just Launchers';
        prod.ProductCode = 'AURT';
        prod.FAQ_s__c = 'Test FAQ';
        prod.Fully_Funded__c = true;
        prod.Return_Type__c = 'Per Annum';
        prod.Tile_Banner__c = 'https://www.venturecrowd.com.au';
        prod.Tile_Heading__c = 'Test heading';
        prod.Tile_Offer_Type__c = 'Investment';
        prod.Button_Text__c = 'View Offer';
        prod.IsActive = true;
        prod.Private_Deal__c = false;
        prod.Publish_on_Community_Site__c = TRUE;
        prod.Offer_Launch_Date__c = system.now();
        prod.Offer_Close_Date__c = system.now();
            productlist.add(prod);
        }
        
        insert productlist;
        ProductController.isRetailProd(productlist[0].Id);
    }
    public static void createnewsBlogs(){
        List<News_List_Page__c> newslist=new List<News_List_Page__c>();
        for(Integer i=0;i<10;i++){
            
             News_List_Page__c nlp = new News_List_Page__c();
        nlp.News_Label__c = 'News Label '+i+1;
        nlp.Tagged_category__c = 'Tagged Catg1';
        nlp.Date__c = system.today();
        nlp.News_Category__c = 'News Catg1';
        nlp.News_Descriptions__c = 'test desc';
        nlp.Likes_Number__c = 2;
        nlp.Newsbg_Url__c = 'https://www.venturecrowd.com.au';
        nlp.src_url__c = 'https://www.venturecrowd.com.au';
        nlp.Navigation_url__c = 'https://www.venturecrowd.com.au'; 
        newslist.add(nlp);
        }
        insert newslist;
    }
    @IsTest
    static void getInvestProds_Test(){    
        ProductController.investmentsRecords(' WHERE Stage__c = \'Closed Won\' AND Is_Person_Account__c = TRUE AND Process_Fund_Disbursement__c = FALSE','Current Investments - Personal');
        ProductController.investmentsRecords(' WHERE Stage__c = \'Closed Won\' AND Is_Person_Account__c = FALSE AND Process_Fund_Disbursement__c = FALSE ','Current Investments - Entities');
        ProductController.investmentsRecords('  WHERE (Stage__c = \'Application Received\'  OR Stage__c = \'Receipt Issued\' )AND Process_Fund_Disbursement__c = FALSE','Pending Investments');
        ProductController.investmentsRecords(' WHERE Stage__c = \'Closed Won\' AND Process_Fund_Disbursement__c = TRUE ','Previous Investments');
        InvestControllerTest.testCreateOpportunityMethod();
        Investment__c inv = [SELECT Id,Current_Value__c,Account__r.BPAY_CRN__c,Account__r.BPAY_Biller_Code__c,Investment_Product_Image_FORMULA__c,Opportunity_Product__r.Current_Investment_Value__c,Opportunity_Product__r.TotalPrice,Opportunity_Product__r.ListPrice,Opportunity_Product__r.Investment_Contribution_Fee__c,Opportunity_Product__r.Product2.Portal_Display_Name__c,Opportunity_Product__r.Product2.Portal_Short_Description__c,Opportunity_Product__r.Product2.Type__c,Opportunity_Product__r.Product2.Sector__c,Opportunity_Product__r.Product2.stage__c,Investment_Product_Type__c,Investment_Date__c,Investment_Amount__c,Investment_Opp_ID__c,Funds_Received__c,Purchased_Shares__c, Account__r.Name FROM Investment__c];
        new ProductController.invRecordWrapper(inv,'Current Investments - Personal');
        //new ProductController.invRecordWrapper(inv,'Pending Investments');
    }
    @IsTest
    static void getFiles_Test(){
        InvestControllerTest.testCreateOpportunityMethod();
        Investment__c invest = [SELECT Id FROM Investment__c LIMIT 1];
        //Create files
        ContentVersion testFile = new ContentVersion (
        Title = 'FY23 Tax Statement Amended',
		PathOnClient = 'FY23 Tax Statement Amended.txt',
        VersionData = Blob.valueOf('Test'),
        IsMajorVersion = true
          
        );
        insert testFile;
        testFile = [SELECT  ContentDocumentId FROM  ContentVersion WHERE Id = :testFile.Id];
        ContentDocumentLink testLink = new ContentDocumentLink(
        ContentDocumentId = testFile.ContentDocumentId,
        LinkedEntityId = invest.Id,
        ShareType = 'V'
        
        );
        insert testLink;
        ProductController.fetchFiles(invest.Id);

    }
}