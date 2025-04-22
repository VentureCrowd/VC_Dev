@isTest
public class Test_DataFactory {
    public static Comment__c prepareComment(boolean isUpsert, String productId){
        Comment__c comObj = new Comment__c();
        comObj.comments__c = 'Can i write Test Class';
        comObj.Response__c = 'Yes';
        comObj.Reponse_Date__c = Date.today();
        comObj.Product__c = productId;
        comObj.Approved__c = true;
        if(isUpsert){
            upsert comObj;
        }
        return comObj;  
    }

    public static Account prepareAccount(){
        Account acc = new Account();
        acc.name = 'Test';
        acc.Active__c = True;
        insert acc;
        return acc;
    }

    public static Contact prepareContact(id accId){
        Contact cont = new Contact();
        cont.AccountId = accId;
        cont.LastName = 'Test Contact';
        insert cont;
        return cont;
    }

public static Opportunity prepareOpportunity(boolean isUpsert,Id accId,Id prodId){
    opportunity opp1 = new opportunity();
    opp1.AccountId = accId;
    opp1.Amount = 500000;
    opp1.StageName = InvestmentDetailsController.OPPORTUNITY_STAGENAME_APPLICATION_RECEIVED;
    opp1.Funds_received_in_Bank__c = true;
    opp1.CRC_Assigned__c = UserInfo.getuserId();
    opp1.CM_Assigned__c = UserInfo.getuserId();
    opp1.Name = 'New Transferred';
    opp1.CloseDate = System.today();
    //opp1.ownerId = oppListToUpdate.get(0).ownerId;
    opp1.Opportunity_Type__c = 'Transferor';
    opp1.Amount = 50;
    opp1.Invested_Product_ADMIN_FIELD__c =  prodId;
    opp1.Unit_Certificate_Amount__c=100;
    opp1.Funds_received_in_Bank__c=true;
    opp1.Unit_Cert_Issued__c = system.today();
    
    if(isUpsert){
        upsert opp1;
    }
    return opp1;  
}

public static PricebookEntry preparePricebook(Id prodId){
    Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        Update standardPricebook;
        standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = prodId,
            UnitPrice = 1,
            IsActive = true
        );
        Insert pbe;
        return pbe;
 
}

public static product2 prepareProduct(){
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
        prod.Private_Deal__c = false;
        prod.Publish_on_Community_Site__c = TRUE;
        prod.Offer_Launch_Date__c = system.now();
        prod.Offer_Close_Date__c = system.now();
        insert prod;
        return prod;
    }

public static OpportunityLineItem prepareProductLineItem(Id oppId, Id pbeId, Id prodId){
    OpportunityLineItem OLI2 = new OpportunityLineItem();
        OLI2.OpportunityId = oppId;
        OLI2.Quantity = 500000;
        OLI2.PricebookEntryId = pbeId;
        OLI2.Description = 'Test';
        OLI2.TotalPrice = 500;
        OLI2.Product2Id = prodId;
        insert OLI2;
        return OLI2;
}
}