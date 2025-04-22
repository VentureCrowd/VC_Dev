public without sharing class prodTriggerHandler {
    public static void handleROIlogs(){
        Map<Id,Decimal> prodIdVSfixedreturndmap = new Map<Id,Decimal>();
        for(Product2 p : (List<Product2>)Trigger.new){
            if((Trigger.old == NULL && p.Fixed_Returns__c <> NULL) || (Trigger.old <> NULL && isfieldchanged(Trigger.oldmap.get(p.Id),p,'Fixed_Returns__c'))){
                prodIdVSfixedreturndmap.put(p.Id,p.Fixed_Returns__c);
            }
        }
        List<ROI_Log__c> loglst = new List<ROI_Log__c>();
        for(Product2 p : [SELECT Id,Fixed_Returns__c, (SELECT Id,Active__c,Start_Date__c,End_Date__c,Name FROM ROI_Log__r ORDER BY Name DESC) FROM Product2 WHERE ID IN :prodIdVSfixedreturndmap.keyset()]){
            if(p.ROI_Log__r.isEmpty()){
                ROI_Log__c log1 = new ROI_Log__c();
                log1.Start_Date__c = System.Now();
                log1.Active__c = true;
                log1.Product__c = p.Id;
                log1.Returns_Percentage__c = p.Fixed_Returns__c;
                loglst.add(log1);
            }else{
                ROI_Log__c log2 = p.ROI_Log__r[0];
                log2.Active__c = false;
                log2.End_Date__c = System.Now();
                loglst.add(log2);

                ROI_Log__c log1 = new ROI_Log__c();
                log1.Start_Date__c = System.Now();
                log1.Active__c = true;
                log1.Product__c = p.Id;
                log1.Returns_Percentage__c = p.Fixed_Returns__c;
                loglst.add(log1);
            }
        }
        upsert loglst;
    }
    public static Boolean isfieldchanged(Sobject oldrecord, Sobject newrecord, string field){
        return oldrecord.get(field) <> newrecord.get(field);
    }
}