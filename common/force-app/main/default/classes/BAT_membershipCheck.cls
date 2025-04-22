public without sharing class BAT_membershipCheck implements Database.Batchable<Sobject>,Schedulable{
    public Database.QueryLocator start(Database.BatchableContext BC){
        Id VC_accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('VC Person Account').getRecordTypeId();
        string query = 'SELECT Id,EIC_Property__pc,Wholesale__pc,EIC_Startup__pc,(SELECT Membership_Status__c,Type__c FROM Memberships__r WHERE Type__c <> null ORDER by Start_Date__c desc) FROM ACCOUNT WHERE RecordtypeId =:VC_accRecordTypeId';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Account> scope){
        Map<string,string> statusVSfldMap =new Map<string,string>{'Platinum Partner' =>'Platinum_Partner__c','Wholesale'=>'Wholesale__pc','EIC - Property'=>'EIC_Property__pc','EIC - Start up'=>'EIC_Startup__pc'};
        Map<string,Map<string,Boolean>> accIdVSmembershipstatusmap = new Map<string,Map<string,Boolean>>();
        for(Account acc : scope){
            if(!acc.Memberships__r.isEmpty()){
                if(!accIdVSmembershipstatusmap.containsKey(acc.Id)){
                    accIdVSmembershipstatusmap.put(acc.Id,new Map<string,Boolean>());
                }
                for(Membership__c m:acc.Memberships__r ){
                    if(!accIdVSmembershipstatusmap.get(acc.Id).containsKey(m.Type__c)){
                        accIdVSmembershipstatusmap.get(acc.Id).put(m.Type__c,m.Membership_Status__c == 'Active');
                    }
                }
            }
        }
        Map<Id,Account> accMap = new Map<Id,Account>();
        Account acc;
        for(string s1 : accIdVSmembershipstatusmap.keyset()){
            for(string s2 : accIdVSmembershipstatusmap.get(s1).keyset()){
                if(accMap.containsKey(s1)){
                    acc = accMap.get(s1);
                }else{
                    acc = new Account(Id = s1);
                }
                acc.put(statusVSfldMap.get(s2),accIdVSmembershipstatusmap.get(s1).get(s2));
                accMap.put(s1,acc);
            }
        }
        update accMap.values();
    }
    public void finish(Database.BatchableContext BC){

    }
    public void execute(SchedulableContext sc){
        Database.executeBatch(this);
    }
}