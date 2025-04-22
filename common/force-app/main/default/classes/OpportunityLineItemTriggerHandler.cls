public class OpportunityLineItemTriggerHandler {
    public static void beforeInsert(List<OpportunityLineItem> TriggerNew) {
        prepopulateDefaultValues(TriggerNew);
    }
    public static void prepopulateDefaultValues(List<OpportunityLineItem> TriggerNew){
        for(OpportunityLineItem oli : TriggerNew){
            if(oli.Quantity <> null && oli.UnitPrice<> null){
                oli.Original_Invested_Quantity__c = oli.Quantity;
                oli.Original_Sales_Price__c = oli.UnitPrice * oli.Quantity;
            }
        }
    }
}