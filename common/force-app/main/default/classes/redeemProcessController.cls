public with sharing class redeemProcessController {
    @AuraEnabled
    public static void transactionLogs(String opportunityId,string opportunityProdId,Decimal amount,Decimal quantity,Date appliedDate) {
        try{
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity oppObj;
        List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
        OpportunityLineItem oppLineItemObj;
        oppList = [Select Id,Total_Redeemed_Amount__c,Total_Redeemed_Units__c,Original_invested_Quantity__c,
        Original_invested_Amount__c from opportunity where Id=:opportunityId];
        if(oppList.size()>0){
            oppObj = oppList[0];
        }

        oppLineItemList = [Select Id,TotalPrice,Quantity,Original_Sales_Price__c, Original_Invested_Quantity__c,Current_Investment_Value__c
                   from opportunityLineItem where Id=:opportunityProdId];
        if(oppLineItemList.size()>0){
            oppLineItemObj = oppLineItemList[0];
            oppLineItemObj.Original_Invested_Quantity__c = oppLineItemObj.Original_Invested_Quantity__c>0? oppLineItemObj.Original_Invested_Quantity__c-quantity:oppLineItemObj.Original_Invested_Quantity__c;
            oppLineItemObj.Original_Sales_Price__c = oppLineItemObj.Original_Sales_Price__c>0? oppLineItemObj.Current_Investment_Value__c-amount:oppLineItemObj.Original_Sales_Price__c;
            update oppLineItemObj;
            
            oppObj.Total_Redeemed_Amount__c = oppObj.Total_Redeemed_Amount__c!=null ? oppObj.Total_Redeemed_Amount__c + amount:amount;
            oppObj.Total_Redeemed_Units__c = oppObj.Total_Redeemed_Units__c!=null ? oppObj.Total_Redeemed_Units__c + Quantity:Quantity;
            oppObj.Original_invested_Quantity__c = oppObj.Original_invested_Quantity__c!=null ? oppObj.Original_invested_Quantity__c :oppLineItemObj.Quantity;
            oppObj.Original_invested_Amount__c = oppObj.Original_invested_Amount__c!=null ? oppObj.Original_invested_Amount__c :oppLineItemObj.TotalPrice;
            oppObj.StageName = 'Closed Won';
            oppObj.Current_Total_Price__c = oppLineItemObj.Original_Sales_Price__c;
            oppObj.Current_Holdings__c = oppLineItemObj.Original_Invested_Quantity__c;
            oppObj.Closed_Won_Stages__c = 0 == oppLineItemObj.Original_Sales_Price__c ? 'Fully Redeemed' : 'Partially Redeemed';
            update oppObj;

            Redemption_Transaction_Log__c logObj = new Redemption_Transaction_Log__c();
            logObj.Opportunity__c = oppObj.Id;
            logObj.Redeemed_Amount__c = amount;
            logObj.Redeemed_Holding__c = quantity;
            logObj.Date_of_Application__c = appliedDate;
            logObj.Original_Invested_Quantity__c = oppLineItemObj.Quantity;
            logObj.Original_invested_Amount__c = oppLineItemObj.TotalPrice;
            logObj.Current_Invested_Amount__c = oppLineItemObj.Original_Sales_Price__c;
            logObj.Current_Invested_Holding__c = oppLineItemObj.Original_Invested_Quantity__c;    
            logObj.Status__c = 'Processed';
            logObj.Opportunity_Product__c = oppLineItemObj.Id;
            Insert logObj;
        }
    }catch(exception ex){
        throw new AuraHandledException(ex.getMessage());
    }
    }

}