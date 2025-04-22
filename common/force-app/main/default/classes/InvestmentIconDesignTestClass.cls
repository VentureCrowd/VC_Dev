@isTest
public class InvestmentIconDesignTestClass {
     @isTest
      static void testInvestmentIconCreation() { 
         
         Account acc = new Account();
        acc.name = 'Test';
        acc.Active__c = True;
        insert acc;
        
        Account newAccObj = new Account();
        newAccObj.name = 'new acc';

        Opportunity opp = new Opportunity();
        
        
        opportunity opp1 = new opportunity();
        opp1.AccountId = acc.Id;
        opp1.Amount = 500000;
        opp1.StageName = InvestmentDetailsController.OPPORTUNITY_STAGENAME_RECEIPT_ISSUED;
        //opp1.CRC_Assigned__c = oppListToUpdate.get(0).CRC_Assigned__c;
        //opp1.CM_Assigned__c = oppListToUpdate.get(0).CM_Assigned__c;
        opp1.Name = 'New Transferred';
        opp1.CloseDate = System.today();
        //opp1.ownerId = oppListToUpdate.get(0).ownerId;
        opp1.Opportunity_Type__c = 'Transferor';
        opp1.Amount = 50;
        //opp1.Old_Transferred_Opportunity__c = oppListToUpdate.get(0).Id;
        insert opp1;
        
        product2 prod = new product2();
        prod.Name = 'Test Prod ';
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
        prod.Sector__c = 'MEDTECH';
        prod.Private_Deal__c = false;
        prod.Publish_on_Community_Site__c = TRUE;
        prod.Offer_Launch_Date__c = system.now();
        prod.Offer_Close_Date__c = system.now();
        insert prod;
        
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

        // PricebookEntry PBE = new PricebookEntry();
        // PBE.IsActive = true;
        // PBE.UnitPrice = 1;
        // PBE.UseStandardPrice = true;
        // PBE.Pricebook2Id = pbe.Id;
        // PBE.Product2Id = prod.Id;
        // insert PBE;
        
        OpportunityLineItem OLI2 = new OpportunityLineItem();
        OLI2.OpportunityId = opp1.Id;
        OLI2.Quantity = 500000;
        OLI2.PricebookEntryId = pbe.Id;
        OLI2.Description = 'Test';
        OLI2.TotalPrice = 500;
        OLI2.Product2Id = prod.Id;

        insert OLI2;
         
         Investment__c invest=new Investment__c();
         invest.Total_Investment__c=100;
         invest.Investment_Date__c=System.Today();
         invest.Investment_Amount__c=50;
         invest.Funds_Received__c=true;
         invest.Account__c=acc.Id;
         invest.Opportunity_Product__c = OLI2.Id;
        
          insert invest;
          
          Test.startTest();
          InvestmentIconDesignClass.retrivePdtCategory(invest.Id); 
         Test.stopTest();

    }
    
}