public class MarketingPrerenceTriggerHandler {
    public static Boolean performSyncFromMarketingPreference = true;
    public static void afterinsert(){
        if(performSyncFromMarketingPreference){
            syncMarketPreferences();
        }        
    }
    public static void afterupdate(){
        system.debug(performSyncFromMarketingPreference);
        if(performSyncFromMarketingPreference){
            syncMarketPreferences();
        }
    }
    public static void syncMarketPreferences(){
        List<Id> accIdlst = new List<Id>();
        List<Id> leadIdlst = new List<Id>();
        for(Marketing_Preference__c mp : (List<Marketing_Preference__c>) Trigger.new){
            if(string.isNotEmpty(mp.Account__c))accIdlst.add(mp.Account__c);
            if(string.isNotEmpty(mp.Lead__c))leadIdlst.add(mp.Lead__c);
        }
        Map<Id,Account> accMap = new Map<Id,Account>([SELECT Id,Investor_Updates_OptIn__c,PersonHasOptedOutOfEmail,Email_Opt_In__pc FROM Account WHERE Id IN :accIdlst]);
        Map<Id,Lead> leadMap = new Map<Id,Lead>([SELECT Id,Email_Opt_In__c,HasOptedOutOfEmail FROM Lead WHERE Id IN :leadIdlst]);
        List<Account> accLst = new List<Account>();
        List<Lead> leadLst = new List<Lead>();
        for(Marketing_Preference__c mp : (List<Marketing_Preference__c>) Trigger.new){
            if(string.isNotEmpty(mp.Account__c) && accMap.containsKey(mp.Account__c)){
                Account acc = accMap.get(mp.Account__c);
                if(acc.Investor_Updates_OptIn__c <> mp.Investor_Updates_OptIn__c || acc.PersonHasOptedOutOfEmail <> mp.Regular_Marketing_Communications_Optout__c || acc.Email_Opt_In__pc <> mp.Regular_Marketing_Communications_Optin_c__c){
                    acc.Investor_Updates_OptIn__c = mp.Investor_Updates_OptIn__c;
                    acc.PersonHasOptedOutOfEmail = mp.Regular_Marketing_Communications_Optout__c;
                    acc.Email_Opt_In__pc = mp.Regular_Marketing_Communications_Optin_c__c;
                    accLst.add(acc);
                }
            }
            if(string.isNotEmpty(mp.Lead__c) && leadMap.containsKey(mp.Lead__c)){
                Lead ld = leadMap.get(mp.Lead__c);
                if(ld.Email_Opt_In__c <> mp.Marketing_Updates_About_Product_OptIn__c || ld.HasOptedOutOfEmail <> mp.Marketing_Updates_About_Product_Optout__c ){
                    ld.Email_Opt_In__c = mp.Marketing_Updates_About_Product_OptIn__c;
                    ld.HasOptedOutOfEmail = mp.Marketing_Updates_About_Product_Optout__c;
                    leadLst.add(ld);
                }
            }
        }
        update accLst;
        update leadLst;
    }
}