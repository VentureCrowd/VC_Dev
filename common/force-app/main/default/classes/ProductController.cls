global without sharing  class ProductController{
  public List<product2> prodList{get; set;}
  public List<product2> prodListHome{get; set;}
  public List<product2> prodListProperty{get; set;}
  public List<product2> successfulDealList{get; set;}
  public List<News_List_Page__c> newsBlogList{get; set;}
  Map<Id,News_List_Page__c> newsMap;
  public String baseUrl{get; set;}
  public Id currentblogrecId{get; set;}
  public Boolean showall{get;set;}
  public Boolean showacategory{get;set;}
   public Map<String,String> imageNameURLMap{get;set;}
  
   //public List<News_List_Page__c> currentnewsList{get;set;}
  // public String currentcategory {get;set;}
  //public List<prodWrapper> productWrapLst{get; set;}
  
  global ProductController(){ 
      
     // For adding Image in the VF page 
       imageNameURLMap=new  Map<String,String>();
      for(Image_Info__c img:[Select Image_Unique_Name__c,Image_Public_URL__C from Image_Info__c]){
        this.imageNameURLMap.put(img.Image_Unique_Name__c,img.Image_Public_URL__C);  
      }
      
      
      this.showall=true;
      this.showacategory=false;
      // Method to check of environement is Production ORG or not
      baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
      
      //################## Property Page Product #######################

      prodListProperty = [select id,Name,Family,DisplayUrl,Deal_Page_Link__c,Trust_Deed_Link__c,Sector_Personas__c,
                 ProductCode,FAQ_s__c,Fully_Funded__c,Return_Type__c,Deal_Description__c, Tile_Banner__c, Tile_Heading__c, Tile_Offer_Type__c, Button_Text__c 
                 from  product2 where Publish_on_Community_Site__c = TRUE  AND  IsActive = TRUE AND Private_Deal__c = FALSE AND Fully_Funded__c = FALSE AND Type__c in ('Property Product') order by Tile_Ordering__c LIMIT 199];
      
      // ########## Product list Home #############
      prodListHome =[select id,Name,Family,DisplayUrl,Deal_Page_Link__c,Trust_Deed_Link__c,Sector_Personas__c,
                     ProductCode,FAQ_s__c,Fully_Funded__c,Return_Type__c,Deal_Description__c,  Tile_Banner__c, Tile_Heading__c, Tile_Offer_Type__c, Button_Text__c 
                     from  product2 where Publish_on_Community_Site__c = TRUE  AND  IsActive = TRUE AND Private_Deal__c = FALSE AND Fully_Funded__c = FALSE order by Tile_Ordering__c LIMIT 3];
      
      
      
      // ########## Product list query #############
      prodList =[select id,Name,Family,DisplayUrl,Deal_Page_Link__c,Trust_Deed_Link__c,Sector_Personas__c,
                 ProductCode,FAQ_s__c,Fully_Funded__c,Return_Type__c,Deal_Description__c, Tile_Banner__c, Tile_Heading__c, Tile_Offer_Type__c, Button_Text__c 
                 from  product2 where Publish_on_Community_Site__c = TRUE  AND  IsActive = TRUE AND Private_Deal__c = FALSE AND Fully_Funded__c = FALSE order by Tile_Ordering__c LIMIT 199];
      
      
      // ########## Successful Deal list query #############
      successfulDealList =[select id,Name,Family,DisplayUrl,Deal_Page_Link__c,Trust_Deed_Link__c,Sector_Personas__c,Deal_Description__c,
                           ProductCode,FAQ_s__c,Fully_Funded__c,Return_Type__c, Tile_Banner__c, Tile_Heading__c, Tile_Offer_Type__c, Button_Text__c from  product2 where IsActive = TRUE AND Fully_Funded__c = TRUE AND Private_Deal__c = FALSE order by Tile_Ordering__c LIMIT 199];
      
      
      // ########## News blog tile information query #############
      
      newsBlogList = [SELECT Id, News_Label__c, Tagged_category__c, Date__c, News_Category__c, News_Descriptions__c, Likes_Number__c, Newsbg_Url__c,  src_url__c, Navigation_url__c FROM News_List_Page__c ORDER BY Date__c DESC LIMIT 199];
      newsMap=new Map<Id,News_List_Page__c>(newsBlogList);
      // for(News_List_Page__c nlp:newsBlogList){
      //     prodWrapper pw = new prodWrapper();
      
      //     Date d = nlp.Date__c;
      //     String dt = DateTime.newInstance(d.year(),d.month(),d.day()).format('MMMM d YYYY');
      
      
      //     pw.nlabel = nlp.News_Label__c;
      //     pw.ndate = dt;
      //     pw.ncateg = nlp.News_Category__c;
      //     pw.ndes = nlp.News_Descriptions__c;
      //     pw.lnum = nlp.Likes_Number__c;
      //     pw.nimgUrl = nlp.Newsbg_Url__c;
      //     productWrapLst.add(pw);
      //   }
  }
  public void likeblog(){
      System.debug('liking news Id='+this.currentblogrecId);
      System.debug('liking news ='+newsMap.get(this.currentblogrecId));
      News_List_Page__c currentNews=newsMap.get(this.currentblogrecId);
      currentNews.Likes_Number__c=currentNews.Likes_Number__c!=null?currentNews.Likes_Number__c+1:1;
      update currentNews;
      newsBlogList = [SELECT Id, News_Label__c,CategoryBanner_Img_Url__c, Tagged_category__c, Date__c, News_Category__c, News_Descriptions__c, Likes_Number__c, Newsbg_Url__c,  src_url__c, Navigation_url__c FROM News_List_Page__c ORDER BY Id LIMIT 199];
      newsMap=new Map<Id,News_List_Page__c>(newsBlogList);
      system.debug('after update newsBlogList='+newsBlogList);
      
     // return null;
  }
  
/*  public void categorychange(){
      
      String category=this.currentcategory;
      system.debug(' categorychange category=>>'+category);
      this.showall=false;
      this.showacategory=true;
      this.currentnewsList=[SELECT Id, News_Label__c,CategoryBanner_Img_Url__c, Tagged_category__c, Date__c, News_Category__c, News_Descriptions__c, Likes_Number__c, Newsbg_Url__c,  src_url__c, Navigation_url__c FROM News_List_Page__c where News_Category__c=:category ORDER BY Date__c DESC LIMIT 199];

  }*/
  
  // public class prodWrapper{
  //   public string nlabel{get;set;}
  //   public string ndate{get;set;}
  //   public string ncateg{get;set;}
  //   public string ndes{get;set;}
  //   public decimal lnum{get;set;}
  //   public String nimgUrl{get;set;}
  // }
  @AuraEnabled(Cacheable=true)
  public static List<Product2> getProducts(Boolean isSucessfull, String productType){
    if(productType=='' || productType==null){
    
    if(isSucessfull){
                 return [select id,Name,Family,DisplayUrl,Deal_Page_Link__c,Trust_Deed_Link__c,Sector_Personas__c,Tile_Ordering__c,
                           ProductCode,FAQ_s__c,Fully_Funded__c,Return_Type__c,Deal_Description__c, Tile_Banner__c, Tile_Heading__c, Tile_Offer_Type__c, Button_Text__c from  product2 where IsActive = TRUE AND Fully_Funded__c = TRUE AND Private_Deal__c = FALSE order by Tile_Ordering__c LIMIT 199];
      
      
      }
       return  [select id,Name,Family,DisplayUrl,Deal_Page_Link__c,Trust_Deed_Link__c,Sector_Personas__c,Tile_Ordering__c,
                 ProductCode,FAQ_s__c,Fully_Funded__c,Return_Type__c,Deal_Description__c, Tile_Banner__c, Tile_Heading__c, Tile_Offer_Type__c, Button_Text__c 
                 from  product2 where Publish_on_Community_Site__c = TRUE  AND IsActive = TRUE AND Private_Deal__c = FALSE AND Fully_Funded__c = FALSE order by Tile_Ordering__c LIMIT 199];
      
  } else {
    List<string> prodlst = productType.split(',');
    if(isSucessfull){
      return [select id,Name,Family,DisplayUrl,Deal_Page_Link__c,Trust_Deed_Link__c,Sector_Personas__c,Tile_Ordering__c,
                ProductCode,FAQ_s__c,Fully_Funded__c,Return_Type__c,Deal_Description__c, Tile_Banner__c, Tile_Heading__c, Tile_Offer_Type__c, Button_Text__c from  product2 where IsActive = TRUE AND Fully_Funded__c = TRUE AND Private_Deal__c = FALSE AND Type__c in :prodlst order by Tile_Ordering__c LIMIT 199];
}
return  [select id,Name,Family,DisplayUrl,Deal_Page_Link__c,Trust_Deed_Link__c,Sector_Personas__c,Tile_Ordering__c,
      ProductCode,FAQ_s__c,Fully_Funded__c,Return_Type__c,Deal_Description__c, Tile_Banner__c, Tile_Heading__c, Tile_Offer_Type__c, Button_Text__c 
      from  product2 where Publish_on_Community_Site__c = TRUE  AND IsActive = TRUE AND Private_Deal__c = FALSE AND Fully_Funded__c = FALSE AND Type__c in :prodlst order by Tile_Ordering__c LIMIT 199];


  }
}
  
   @AuraEnabled(Cacheable=true)
  public static List<News_List_Page__c> getNewsBlogs(){
     return  [SELECT Id, News_Label__c,CategoryBanner_Img_Url__c, Tagged_category__c, Date__c, News_Category__c, News_Descriptions__c, Likes_Number__c, Newsbg_Url__c,  src_url__c, Navigation_url__c FROM News_List_Page__c ORDER BY Id LIMIT 199];   
  }

  @AuraEnabled(Cacheable=true)
  public static List<News_List_Page__c> getNewsBlogsForNewsContainer(Integer limitSize, Integer offset){
    return  [SELECT Id, News_Label__c,CategoryBanner_Img_Url__c, Tagged_category__c, Date__c, 
                    News_Category__c, News_Descriptions__c, Likes_Number__c, Newsbg_Url__c,  
                    src_url__c, Navigation_url__c 
            FROM News_List_Page__c 
            ORDER BY Id 
            LIMIT :limitSize
            OFFSET :offset];   
  }

  
  @AuraEnabled(Cacheable=true)
  public static List<News_List_Page__c> getNewsBlogsByCategory(String category){
     return  [SELECT Id, News_Label__c,CategoryBanner_Img_Url__c, Tagged_category__c, Date__c, News_Category__c, News_Descriptions__c, Likes_Number__c, Newsbg_Url__c,  src_url__c, Navigation_url__c FROM News_List_Page__c Where Tagged_category__c=:category ORDER BY Id LIMIT 199];   
  }

  @AuraEnabled(Cacheable=true)
  public static List<News_List_Page__c> getNewsBlogsForNewsContainerByCategory(Integer limitSize, Integer offset, String categoryName){
    return  [SELECT Id, News_Label__c,CategoryBanner_Img_Url__c, Tagged_category__c, Date__c, 
                    News_Category__c, News_Descriptions__c, Likes_Number__c, Newsbg_Url__c,  
                    src_url__c, Navigation_url__c 
            FROM News_List_Page__c 
            WHERE News_Category__c = :categoryName 
            ORDER BY Id 
            LIMIT :limitSize
            OFFSET :offset];   
  }
  
  @AuraEnabled(Cacheable=true)
  public static List<List<Product2>> getInvestProds(){
    List<List<Product2>> retlst = new List<List<Product2>>();
    retlst.add([SELECT id,Name,Family,DisplayUrl,Deal_Page_Link__c,Trust_Deed_Link__c,Sector_Personas__c,ProductCode,FAQ_s__c,Fully_Funded__c,Return_Type__c,Deal_Description__c, Tile_Banner__c, Tile_Heading__c, Tile_Offer_Type__c, Button_Text__c FROM product2 WHERE Publish_on_Community_Site__c = TRUE  AND  IsActive = TRUE AND Private_Deal__c = FALSE AND Fully_Funded__c = FALSE order by Tile_Ordering__c  LIMIT 50000]);
    retlst.add([SELECT id,Name,Family,DisplayUrl,Deal_Page_Link__c,Trust_Deed_Link__c,Sector_Personas__c,ProductCode,FAQ_s__c,Fully_Funded__c,Return_Type__c,Deal_Description__c, Tile_Banner__c, Tile_Heading__c, Tile_Offer_Type__c, Button_Text__c FROM product2 WHERE IsActive = TRUE AND Fully_Funded__c = TRUE AND Private_Deal__c = FALSE order by Tile_Ordering__c  LIMIT 50000]);
    return retlst;
  }
  @AuraEnabled(Cacheable=true)
  public static List<Product2> getRelProds(List<Id> prodIdlst){
    List<Product2> myList = [SELECT id,Name,Family,DisplayUrl,Deal_Page_Link__c,Trust_Deed_Link__c,Sector_Personas__c,ProductCode,FAQ_s__c,Fully_Funded__c,Return_Type__c,Deal_Description__c, Tile_Banner__c, Tile_Heading__c, Tile_Offer_Type__c, Button_Text__c FROM product2 WHERE Id IN :prodIdlst  LIMIT 50000];
    return myList;
  }
@AuraEnabled
  public static List<invRecordWrapper> investmentsRecords(string filter,string investmentTile){   
    List<Id> accidlst = new List<Id>();
    User usr = [SELECT Id,contact.AccountId,contactId  FROM USER WHERE ID =:UserInfo.getuserId()];
    Id loggedinaccId = usr.contact.AccountId;

    if(investmentTile <> 'Current Investments - Entities'){
      accidlst.add(loggedinaccId);
    }
    if(investmentTile <> 'Current Investments - Personal'){
      List<AccountContactRelation> acrlst = [SELECT Id, Account.Name,AccountId FROM AccountContactRelation WHERE ContactId = :usr.contactId];
      for(AccountContactRelation acr:acrlst){
        accidlst.add(acr.AccountId);
      }
    }
    string query = 'SELECT Id,Current_Value__c,Purchased_Shares__c,Account__r.Name,Opportunity_Product__r.ListPrice,Opportunity_Product__r.Current_Investment_Value__c,Account__r.BPAY_CRN__c,Account__r.BPAY_Biller_Code__c,Investment_Product_Image_FORMULA__c,Opportunity_Product__r.TotalPrice,Opportunity_Product__r.Investment_Contribution_Fee__c,Opportunity_Product__r.Product2.Portal_Display_Name__c,Opportunity_Product__r.Product2.Portal_Short_Description__c,Opportunity_Product__r.Product2.Type__c,Opportunity_Product__r.Product2.Sector__c,Opportunity_Product__r.Product2.stage__c,Investment_Product_Type__c,Investment_Date__c,Investment_Amount__c,Investment_Opp_ID__c,Funds_Received__c FROM Investment__c';  
    filter += ' AND Account__c = :accidlst';
    filter +=  ' AND Opportunity__r.StageName <> \'Closed Lost\'';

    String finalQuery = query + filter;

    List<Investment__c> invlst = Database.Query(query+filter);
    List<invRecordWrapper> wraplst = new List<invRecordWrapper>();
    try{
      for(Investment__c inv : invlst){
          wraplst.add(new invRecordWrapper(inv,investmentTile));
      }
      return wraplst;
    }catch(Exception e){
      Logger.logMessage('Product','ProductController','Err', 'Id ' + String.valueof(loggedinaccId) + 'Query ' + finalQuery + 'accIdLst ' + JSON.serialize(accidlst) + 'invlst ' + JSON.serialize(invlst) + 'err ' + e.getStackTraceString());
      throw e;
    }
    
  }
  public class invRecordWrapper{
      @AuraEnabled public string prodimgformula;
      @AuraEnabled public string prodDisplayName;
      @AuraEnabled public string portalshortdescription;
      @AuraEnabled public List<fields> fieldDataSet;
      @AuraEnabled public string invId;
      @AuraEnabled public string redirectType;
      @AuraEnabled public boolean showviewmore;
      public invRecordWrapper(Investment__c inv,string investmentTile){
        fieldDataSet = new List<fields>();
        prodimgformula = inv.Investment_Product_Image_FORMULA__c;
        prodDisplayName = inv.Opportunity_Product__r.Product2.Portal_Display_Name__c;
        if(investmentTile == 'Pending Investments'){
          Decimal inamout = inv.Opportunity_Product__r.TotalPrice+inv.Opportunity_Product__r.Investment_Contribution_Fee__c;
          fieldDataSet.add(new fields('Investment Amount','$'+inamout?.format()));
          if(inv.Funds_Received__c){
            fieldDataSet.add(new fields('Status', 'Funds Received'));   
            portalshortdescription = 'Thanks! We have received your payment, and your investment will be confirmed once the certificate of ownership is issued.';         
          }else{
            fieldDataSet.add(new fields('Status','Funds Pending'));
            fieldDataSet.add(new fields('BPAY Biller Code',inv.Account__r.BPAY_Biller_Code__c)); 
            fieldDataSet.add(new fields('BPAY CRN',inv.Account__r.BPAY_CRN__c)); 
            portalshortdescription = 'Please complete the transfer of funds with the below BPAY details. It may take two business days for this payment to be reflected in this investor portal.';
          }   
          invId = inv.Id;         
          showviewmore = true;
          redirectType = 'filesRelatedlist';
        }else if(investmentTile == 'Current Investments - Personal' || investmentTile == 'Current Investments - Entities'){
          fieldDataSet.add(new fields('Current Holding Value','$'+inv.Opportunity_Product__r.Current_Investment_Value__c.format(),'This reflects the number of Securities Held multiplied by the Current Security Price. For more information about how we price your holding, please revert to our Pricing policies on our website')); 
          portalshortdescription = inv.Opportunity_Product__r.Product2.Portal_Short_Description__c;
          fieldDataSet.add(new fields('Purchase Price','$'+inv.Investment_Amount__c?.format())); 
          fieldDataSet.add(new fields('Current Security Price',inv.Current_Value__c,'If you own units in a trust, the Current Security Price reflects the unit\'s current value. If you own direct shares in a company, the "Current Security Price" reflects the share\'s current value. For more information about how we price, please revert to our Pricing policies on our website '));   
          fieldDataSet.add(new fields('Securities Held',inv.Purchased_Shares__c?.format(),'If you own units in a trust, the number of Securities Held reflects the number of units you hold. If you own direct shares in a company, the number of Securities Held reflects the number of shares you hold. Please refer to your Holding Certificate, which states your ownership.')); 
          if(investmentTile == 'Current Investments - Personal'){
            fieldDataSet.add(new fields('Investor',inv.Account__r.Name,true,UserInfo.getUserId()));
          }else{
            fieldDataSet.add(new fields('Investor',inv.Account__r.Name,true,inv.Account__c));
          }          
          fieldDataSet.add(new fields('Investment ID',inv.Investment_Opp_ID__c));
          if(inv.Opportunity_Product__r.Product2.Sector__c <> NULL)
            fieldDataSet.add(new fields('Sector',inv.Opportunity_Product__r.Product2.Sector__c));           
          if(inv.Opportunity_Product__r.Product2.stage__c <> NULL)
            fieldDataSet.add(new fields('Stage',inv.Opportunity_Product__r.Product2.stage__c)); 
          showviewmore = true;    
          redirectType = 'detail';    
          invId = inv.Id;     
        }else{
          portalshortdescription = inv.Opportunity_Product__r.Product2.Portal_Short_Description__c;
          fieldDataSet.add(new fields('Investment Amount','$'+inv.Investment_Amount__c?.format()));
          if(inv.Opportunity_Product__r.Product2.Sector__c <> NULL)
            fieldDataSet.add(new fields('Sector',inv.Opportunity_Product__r.Product2.Sector__c));
          if(inv.Opportunity_Product__r.Product2.stage__c <> NULL)
            fieldDataSet.add(new fields('Stage',inv.Opportunity_Product__r.Product2.stage__c));            
          fieldDataSet.add(new fields('Investment ID',inv.Investment_Opp_ID__c));   
          showviewmore = true;    
          redirectType = 'detail';    
          invId = inv.Id;     
        }
      }
  }
  public class fields{
      @AuraEnabled public string label;
      @AuraEnabled public string value;
      @AuraEnabled public boolean isHyperLink = false;
      @AuraEnabled public string hyperlinknavigation;
      @AuraEnabled public string helpText;
      public fields(string label,string value){
          this.label = label;
          this.value = value;
      }
      public fields(string label,string value, boolean isHyperLink, string hyperlinknavigation){
          this.label = label;
          this.value = value;
          this.isHyperLink = isHyperLink;
          this.hyperlinknavigation = hyperlinknavigation;
      }
      public fields(string label,string value, string helpText){
        this.label = label;
        this.value = value;
        this.isHyperLink = isHyperLink;
        this.hyperlinknavigation = hyperlinknavigation;
        this.helpText = helpText;
    }
  }
  @AuraEnabled
  public static Product2 isRetailProd(Id prodId){
    return [SELECT Id,Type__c,Footer_Text__c,AFSL_Licence__c FROM Product2 WHERE Id = :prodId];
  }
  @AuraEnabled
  public static Map<String,List<FileDetails>> fetchFiles(Id recordId){
    List<String> investmentDocuments = new List<String>{'Investment Contract',
    'Unit Certificate',
    'Receipt',
    'Receipt of transfer',
    'Share Certificate',
    'Con Note',
    'Loan Agreement',
    'SAFE Note',
    'Interest Certificate',
    'Promissory Note',
    'PDS Part 1',
    'PDS Part 2',
    'Information Memorandum',
    'Target Market Determination',
    'CSF Offer Document',
    'Trust Deed',
    'Off Market Transfer',
    'Buy Back Agreement',
    'Investment Variation',
    'Redemption Request form',
    'Limited Partnership',
    'Agreement to Reinvest Distributions',
    'Application for Product',
    'Terms of Issue',
    'Investment_Contract',
    'Unit_Certificate',
    'Receipt_of_transfer',
    'Share_Certificate',
    'Con_Note',
    'Loan_Agreement',
    'SAFE_Note',
    'Interest_Certificate',
    'Promissory_Note',
    'Fund_Document',
    'Prospectus',
    'Information_Memorandum',
    'Target_Market_Determination',
    'CSF_Offer_Document',
    'Trust_Deed',
    'Off_Market_Transfer',
    'Buy_Back_Agreement',
    'Investment_Variation',
    'Redemption_Request_form',
    'Limited_Partnership',
    'Agreement_to_Reinvest_Distributions',
    'Application_for_Product',
    'Terms_of_Issue'};
      
    
      List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];
      List<Id> fileIds = new List<Id>();
      for (ContentDocumentLink docLink : files) {
          fileIds.add(docLink.ContentDocumentId);
      }
      Map<String,List<String>> matchCriteria = new Map<String,List<String>>();
      matchCriteria.put('Investment Documents', investmentDocuments);
      matchCriteria.put('Investment Updates and Actions', new List<String>{'Corporate_Action','Investor Update','Fund Update','Corporate Action','Investor_Update','Fund_Update'});
      matchCriteria.put('Financial Statements and Distributions', new List<String>{'.*FY\\d{2} Tax Statement.*','.*FY\\d{2} Tax Statement_Amended.*','Distribution Statement','Remittance Advice','ESIC Offset Determination','Redemption Confirmation','Confirmation of Redemption and Re-investment','.*FY\\d{2}_Tax_Statement.*','.*FY\\d{2}_Tax_Statement_Amended.*','Distribution_Statement','Remittance_Advice','ESIC_Offset_Determination','Redemption_Confirmation','Confirmation_of_Redemption_and Re-investment','FY Tax Statement','FY_Tax_Statement'});
      Map<String,List<FileDetails>> retMap = new Map<String,List<FileDetails>>();
      retMap.put('Investment Documents', new List<FileDetails>());
      retMap.put('Investment Updates and Actions', new List<FileDetails>());
      retMap.put('Financial Statements and Distributions', new List<FileDetails>());
      // Filter PDF files 
      List<ContentVersion> docs = [SELECT ContentDocumentId, FileExtension, Title,CreatedDate  FROM ContentVersion WHERE ContentDocumentId IN : fileIds ORDER BY CreatedDate DESC];
      for (ContentVersion docLink : docs) {
          if(fileNameCheck(docLink.Title,matchCriteria.get('Investment Updates and Actions'))){
              retMap.get('Investment Updates and Actions').add(new FileDetails(docLink.ContentDocumentId, docLink.Title,docLink.CreatedDate.format()));
          }else if(fileNameCheck(docLink.Title,matchCriteria.get('Financial Statements and Distributions'))){
            system.debug(docLink.Title+'Financial Statements and Distributions');
              retMap.get('Financial Statements and Distributions').add(new FileDetails(docLink.ContentDocumentId, docLink.Title,docLink.CreatedDate.format()));
          }else{
              retMap.get('Investment Documents').add(new FileDetails(docLink.ContentDocumentId, docLink.Title,docLink.CreatedDate.format()));
          }
      }
      return retMap;
  }
  public static Boolean fileNameCheck(string fileName, List<String> matchList){
      Boolean isFileMatch = false;
      for(String s : matchList){
        system.debug(fileName +'-------' +s+'---------'+fileName.contains(s));
        if(s.contains('\\d{2}')){
          Pattern stringPattern = Pattern.compile(s);
          Matcher stringMatcher = stringPattern.matcher(fileName);
          isFileMatch = stringMatcher.matches();
          if(isFileMatch)
          break;
        }else if(fileName.contains(s)){
          system.debug(fileName +'-------' +s);
          isFileMatch = true;
          break;
        }
      }
      return isFileMatch;
  }
  public class FileDetails{
      @AuraEnabled public string fileId;
      @AuraEnabled public string fileName;
      @AuraEnabled public string fileUrl;
      @AuraEnabled public string createdDate;
      public FileDetails(string fileId,string fileName, string createdDate){
          this.fileId = fileId;
          this.fileName = fileName;
          this.createdDate = createdDate;
          this.fileUrl = '/sfc/servlet.shepherd/document/download/'+fileId;
      }
  }
}