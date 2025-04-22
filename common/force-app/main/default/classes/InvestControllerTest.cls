@isTest
public class InvestControllerTest {
    @isTest
    public static void testCreateOpportunityNInvestMentInfo(){         
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
        database.insert(prod,false);
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        Update standardPricebook;
        standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = prod.Id,
            UnitPrice = 1,
            IsActive = true
        );
        Insert pbe;
        PageReference pageRef = new PageReference('test/hgg?jjh=uu&amount=500&recordId='+String.valueOf(prod.Id));
    	Test.setCurrentPage(pageRef);//Applying page context here
         Map<String,Object> registerComponentInfo = new Map<String,Object>{
            'firstName' => 'tes','lastName'=>'test','terms'=>true,
            'mobile'=>'+61410436322', 'investPimpa'=>false,'investSYield'=>false,'investBotanic'=>false,
            'password'=>'Testo123','email'=>'tgyh@rfv.com'
        };       
        InvestController.investingAsName = 'test';        
        string r = InvestController.investingAsName;        
        InvestController.userName = 'test';        
        r = InvestController.userName;        
        InvestController.getInvestmentInfo(prod.Id);        
    }
    @isTest
    public static void testCreateOpportunityMethod(){
        try{
            String orgId = UserInfo.getOrganizationId();  
            String dateString =   
            String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');  
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));  
            String uniqueName = orgId + dateString + randomInt;  
            Profile profileObj = [select id,name from Profile where name='VC Investor Community Plus Login'];
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
            database.insert(prod,false);
            Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
            Update standardPricebook;
            standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
            PricebookEntry pbe = new PricebookEntry(
                Pricebook2Id = standardPricebook.Id,
                Product2Id = prod.Id,
                UnitPrice = 1,
                IsActive = true
            );
            Insert pbe;
            Account actObj = new Account();
            actObj.Name='Test Name';
            actObj.OwnerId = UserInfo.getUserId();
            insert actObj;
            Contact contObj = new Contact();
            contObj.AccountId = actObj.Id;
            contObj.FirstName = 'Test First name';
            contObj.LastName = 'Test Last Name';
            contObj.Email ='test@test.com';
            contObj.MailingStreet ='test Street';
            contObj.MailingCity ='Test City';
            contObj.MailingCountry='Australia';
            contObj.MailingState = 'Test state';
            contObj.MailingPostalCode='34234';
            insert contObj;
            User userObj = new User();
            userObj.FirstName = contObj.FirstName;
            userObj.LastName = contObj.LastName;
            userObj.ContactId = contObj.Id;
            userObj.ProfileId = profileObj.Id;
            userObj.email = uniqueName + '@sfdc' + orgId + '.org';
            userObj.Username = uniqueName + '@sfdc' + orgId + '.org';
            userObj.EmailEncodingKey = 'ISO-8859-1';  
            userObj.Alias = uniqueName.substring(18, 23);  
            userObj.TimeZoneSidKey = 'America/Los_Angeles'; 
            userObj.LocaleSidKey = 'en_US';
            userObj.LanguageLocaleKey = 'en_US';
            userObj.ProfileId = profileObj.Id;       
            insert userObj;
            
            system.runAs(userObj){
			Test.startTest();
                PageReference pageRef = new PageReference('test/hgg?jjh=uu&amount=500&recordId='+String.valueOf(prod.Id)+'&investingAs=Test Name&quantity=20');
                Test.setCurrentPage(pageRef);//Applying page context here
                Map<String,Object> registerComponentInfo = new Map<String,Object>{
                    'firstName' => 'tes','lastName'=>'test','terms'=>true,
                    'mobile'=>'+61410436322', 'investPimpa'=>false,'investSYield'=>false,'investBotanic'=>false,
                    'password'=>'Testo123','email'=>'tgyh@rfv.com'
                };       
                InvestController inc = new InvestController();
                InvestController.fetchRecordDetails(prod.Id);
                InvestController.getInvestmentInfo(prod.Id);   
				Map<string,string> datmap = new Map<string,string>{'utm_source__c'=>'utm_source__c'};
			Test.stopTest();
            String createOpportunityResult = InvestController.createOpportunity(prod.Id,'5','4','9',true, actObj.Id,'2','0',datmap);  
			}			
        }catch(exception e){}
                
    }
    @isTest
    public static void testCreateOpportunityNInvestMentInfoNegativeCase(){  
        try{
            Account actObj = new Account();
            actObj.Name='Test Name';
            actObj.OwnerId = UserInfo.getUserId();
            insert actObj;        
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
            database.insert(prod,false);
            Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
            Update standardPricebook;
            standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
            PricebookEntry pbe = new PricebookEntry(
                Pricebook2Id = standardPricebook.Id,
                Product2Id = prod.Id,
                UnitPrice = 1,
                IsActive = true
            );
            Insert pbe;
            PageReference pageRef = new PageReference('test/hgg?jjh=uu&amount=500&recordId='+String.valueOf(prod.Id));
            Test.setCurrentPage(pageRef);//Applying page context here
            Map<String,Object> registerComponentInfo = new Map<String,Object>{
                'firstName' => 'tes','lastName'=>'test','terms'=>true,
                'mobile'=>'+61410436322', 'investPimpa'=>false,'investSYield'=>false,'investBotanic'=>false,
                'password'=>'Testo123','email'=>'tgyh@rfv.com'
            };        
            InvestController.getInvestmentInfo(prod.Id);
            Map<string,string> datmap = new Map<string,string>{'utm_source__c'=>'utm_source__c'};
			Test.startTest();
            String createOpportunityResult = InvestController.createOpportunity(prod.Id,'5','4','9',true,  actObj.Id,'0','26',datmap);
            InvestController.fetchRecordDetails(prod.Id);
            InvestController.getProddetails(prod.Id);
	        Test.stopTest();
        }catch(exception e){

        }        
    }
}