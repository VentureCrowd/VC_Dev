public without sharing class tempProductService {
    public String getProductDetails(String productId){
        try{
            tempProductFactory factory = New tempProductFactory();
            Product2 productRecord = factory.getProductDetails(productId);
            if(productRecord != null){            
                productData productData = new productData();
                productData.id = productRecord.Id;
                productData.launchDate = productRecord.Offer_Launch_Date__c;
                productData.amountRaised = productRecord.Temp_Total_Opp_Amount__c;
                productData.offerCloseDate = productRecord.Offer_Close_Date__c;
                productData.companyName = productRecord.Portal_Display_Name__c;
                productData.companyOneLiner = productRecord.Deal_Description__c;
                productData.stage = productRecord.Stage__c;
                productData.minInvestAmount = productRecord.Minimum_Investment__c;
                productData.targetAmt = productRecord.Target_Amount__c;

                Logger.logMessage('ProductApp', 'tempProductService', 'getProductDetails', 'Successfully retrieved product details for productId: ' + productId);
                return JSON.serialize(productData);
            }else {
                throw new AuraHandledException('No product record found for the given ID.');
            }
        }catch(Exception e){
            Logger.logError('ProductApp', 'tempProductService', 'getProductDetails', productId, null, null, null, e, 'Failed to get product details for productId: ' + productId);
            throw new AuraHandledException('An unexpected error occurred: ' + e.getMessage());

        }
    }

    public class productData{
        String Id;
        Datetime launchDate;
        Decimal amountRaised;
        Datetime offerCloseDate;
        String companyOneLiner;
        String companyName;
        String stage;
        Decimal targetAmt;
        Decimal minInvestAmount;
    }
}