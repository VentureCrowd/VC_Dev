public class LeadTriggerHandler{

    public static Map<String, Integer> amountRangeMap = new Map<String, Integer>{
        '$250 to $500'      => 250,
        '$500 to $1,000'    => 500,
        '$1,000 to $2,000'  => 1000,
        '$2,000 to $5,000'  => 2000,
        '$1,000 to $3,000'  => 1000,
        '$3,000 to $5,000'  => 3000,
        '$5,000 to $8,000'  => 5000,
        '$8,000 to $10,000' => 8000,
        '$10,000 to $20,000' => 10000,
        '$20,000 to $50,000' => 20000,
        '$50,000 to $100,000' => 50000,
        '$100,000 to $200,000' => 100000,
        '$200,000+'         => 200000
    };

    public static void beforeInsert(){
        Integer vcppLeadCount = [SELECT count() FROM Lead WHERE RecordType.Name ='VCPP'];
        Id VCPPRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('VCPP').getRecordTypeId();
        for(Lead l : (List<lead>)Trigger.new){
            if(l.RecordTypeId == VCPPRecordTypeId){
                l.Lead_Auto_Number_VCPP__c = vcppLeadCount;
                vcppLeadCount++;
            }
        }
        populateMatchingaccount(Trigger.new); 

        populateMinInvestment(Trigger.new);   
        // before();
    }
    public static void beforeUpdate(){
        populateMatchingaccount(Trigger.new); 

        populateMinInvestment(Trigger.new); 
        // before();
    }

    /**
     * 2. Method to populate Min_Investment__c based on Investment_Amount__c and Investment_Amount_Currency__c
     */
    public static void populateMinInvestment(List<Lead> leads){
        for(Lead l : leads){
            Decimal minInvestment = 0;
            
            // Check and add the minimum from the Investment Amount Range
            if(String.isNotEmpty(l.Investment_Amount__c)){
                Integer minFromRange = amountRangeMap.get(l.Investment_Amount__c);
                if(minFromRange != null){
                    minInvestment += minFromRange;
                } else {
                    // Optionally handle unexpected picklist values
                    System.debug('Unexpected Investment Amount Range: ' + l.Investment_Amount__c);
                }
            }
            
            // Check and add the Investment Amount Currency
            if(l.Investment_Amount_Currency__c != null){
                minInvestment += l.Investment_Amount_Currency__c;
            }
            
            // Set the Min Investment field
            l.Min_Investment__c = minInvestment;
        }
    }
    
    // public static void before(){
    //     for(Lead l : (List<lead>)Trigger.new){
    //         lead oldlead = (Lead)trigger.oldMap.get(l.id);
    //         if(l.Lost_Stages__c == 'CR Lost' && (trigger.oldMap == null || oldlead.Lost_Stages__c <> l.Lost_Stages__c)){
    //             l.HasOptedOutOfEmail = true;
    //             l.Email_Opt_In__c = false;
    //         }
    //     }
    // }
    public static void populateMatchingaccount(List<Lead> triggernew){
        Id VCPPRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('VCPP').getRecordTypeId();
        Id VCRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('VC').getRecordTypeId();
        Id VCPP_accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('VCPP Person Account').getRecordTypeId();
        Id VC_accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('VC Person Account').getRecordTypeId();
        List<string> emailst = new List<string>();
        List<string> lastNamelst = new List<string>();
        for(Lead l : (List<lead>)triggernew){
            if(string.isNotEmpty(l.Email)){
                emailst.add(l.Email);
            }
            lastNamelst.add(l.LastName);
        }
        Map<Id,Id> leadVSaccrecordMap = new Map<Id,Id>{VCPPRecordTypeId => VCPP_accRecordTypeId,VCRecordTypeId => VC_accRecordTypeId};
        Map<string,Account> accMap = new Map<string,Account>();
        for(Account acc : [SELECT  Id,PersonEmail,LastName,RecordTypeId FROM ACCOUNT WHERE PersonEmail IN:emailst AND LastName IN :lastNamelst AND RecordTypeId IN (:VCPP_accRecordTypeId,:VC_accRecordTypeId)]){
            accMap.put(acc.PersonEmail.toUpperCase()+acc.LastName.toUpperCase()+acc.RecordTypeId,acc);
        }
        for(Lead l : (List<lead>)triggernew){
            if(string.isNotEmpty(l.Email) && string.isNotEmpty(l.LastName)){
                string key = l.Email.toUpperCase()+l.LastName.toUpperCase()+leadVSaccrecordMap.get(l.RecordTypeId);
                if(accMap.containsKey(key) && string.isempty(l.Matching_Account__c)){
                    l.Matching_Account__c = accMap.get(key).Id;
                }
            }
            
        }
    }
	// public static void leadReEnquiry(List<Lead> leadList)
    // {
    //     list<String> leadEmailList = new list<String>();
    //     list<String> leadEmailList2 = new list<String>();
    //     list<String> leadLastNameList = new list<String>();
    //     list<String> leadLastNameList2 = new list<String>();
    //     list<String> leadPhoneList = new list<String>();
    //     list<String> leadPhoneList2 = new list<String>();
    //     list<Opportunity> opportunityListToInsert = new list<Opportunity>();
    //     list<Opportunity> opportunityListToInsert2 = new list<Opportunity>();
    //     list<Opportunity> opportunityListToInsert3 = new list<Opportunity>();
        
    //     for(Lead leadObj: leadList)
    //     {
    //         if(leadObj.Email != '' && leadObj.Email != null)
    //         {
    //             leadEmailList.add(leadObj.Email);
    //         }
    //         if(leadObj.lastname != '' && leadObj.lastname != null)
    //         {
    //             leadLastNameList.add(leadObj.lastname);
    //         }
    //         if(leadObj.MobilePhone != '' && leadObj.MobilePhone != null)
    //         {
    //             leadPhoneList.add(leadObj.MobilePhone);
    //         }
    //     }
    //     List<contact> conList = [select id, firstname, lastname, email, accountId, ownerId ,MobilePhone,Phone
    //                              from contact
    //                              where  (lastname IN : leadLastNameList) AND 
    //                              (email IN:leadEmailList OR phone IN : leadPhoneList OR MobilePhone IN : leadPhoneList) ];
       
    //     List<Account> accList = [select id, name,firstName, LastName, ownerId, phone,PersonEmail, (select id, CRC_Assigned__c, CM_Assigned__c, ownerId from opportunities order by createddate desc limit 1 ) 
    //                              from Account
    //                              where ( PersonEmail IN:leadEmailList OR phone IN : leadPhoneList) AND lastname IN : leadLastNameList];
        
        
    //     if(conList.isEmpty() && accList.isEmpty())
    //     {
    //         //do nothing
    //     }
    //     else
    //     {
    //         for(Lead leadObj: leadList)
    //         {
    //             Boolean processConList = true;
    //             for(Account acc:accList)
    //             {
    //                 if(leadObj.lastname == acc.lastName  && (leadObj.email == acc.PersonEmail || leadObj.MobilePhone == acc.phone) )
    //                 {
    //                     //make lead is duplicate
    //                     leadObj.Is_Duplicate__c  = true;
                        
    //                     //create opportunity
    //                     Opportunity oppObj = new Opportunity();
    //                     oppObj.name = acc.firstName+' '+acc.lastName+' - opportunity';
    //                     oppObj.accountId = acc.id;
    //                     oppObj.StageName = 'Why Appt Set Pending';
    //                     Date dt = system.today();
    //                     oppObj.closedate = dt.addMonths(1);
    //                     if(acc.opportunities.size() > 0)
    //                     {
    //                         oppObj.CRC_Assigned__c = acc.opportunities[0].CRC_Assigned__c;
    //                         oppObj.CM_Assigned__c = acc.opportunities[0].CM_Assigned__c;
    //                         oppObj.ownerId = acc.opportunities[0].ownerId;
    //                     }
    //                     else
    //                     {
    //                         oppObj.ownerId = acc.ownerId;
    //                     }
                        
    //                     if(leadObj.Products_Interested_In__c != null && leadObj.Products_Interested_In__c != '')
    //                     {
    //                         oppObj.Products_Interested_In__c = leadObj.Products_Interested_In__c;
    //                     }
    //                     if(leadObj.LeadSource != null && leadObj.LeadSource != '')
    //                     {
    //                         oppObj.LeadSource = leadObj.LeadSource;
    //                     }
    //                     if(leadObj.Loss_Reason__c != null && leadObj.Loss_Reason__c != '')
    //                     {
    //                         oppObj.Loss_Reasons__c = leadObj.Loss_Reason__c;
    //                     }
                        
                        
    //                     opportunityListToInsert.add(oppObj);
    //                     processConList = false;
    //                     break;
    //                 }
    //             }
    //             if(processConList)
    //             {
    //                 for(Contact con:conList)
    //                 {
    //                     if(leadObj.lastname == con.lastName  && (leadObj.email == con.email || leadObj.MobilePhone == con.phone || leadObj.MobilePhone == con.MobilePhone ))
    //                     {
    //                         //make lead is duplicate
    //                         leadObj.Is_Duplicate__c  = true;
    //                         //create opportunity
    //                         Opportunity oppObj = new Opportunity();
    //                         oppObj.name = con.firstName+' '+con.lastName+' - opportunity';
    //                         oppObj.accountId = con.accountId;
    //                         oppObj.StageName = 'Why Appt Set Pending';
    //                         Date dt = system.today();
    //                         oppObj.closedate = dt.addMonths(1);
    //                         oppObj.ownerId = con.ownerId;
                            
    //                         if(leadObj.Products_Interested_In__c != null && leadObj.Products_Interested_In__c != '')
    //                         {
    //                             oppObj.Products_Interested_In__c = leadObj.Products_Interested_In__c;
    //                         }
    //                         if(leadObj.LeadSource != null && leadObj.LeadSource != '')
    //                         {
    //                             oppObj.LeadSource = leadObj.LeadSource;
    //                         }
    //                         if(leadObj.Loss_Reason__c != null && leadObj.Loss_Reason__c != '')
    //                         {
    //                             oppObj.Loss_Reasons__c = leadObj.Loss_Reason__c;
    //                         }
                            
                            
    //                         opportunityListToInsert.add(oppObj);
    //                         break;
    //                     }
    //                 }
    //             }
    //         }
            
    //         if(!opportunityListToInsert.isEmpty())
    //         {
    //             insert opportunityListToInsert;
    //         }
    //     }
    // }
    public static void deleteLead(List<Lead> leadList)
    {
        List<Id> leadListToDelete = new List<Id>();
        for(Lead leadObj:leadList)
        {
            if(leadObj.Is_Duplicate__c)
            {
                leadListToDelete.add(leadObj.Id);
            }
        }
        if(!leadListToDelete.isEmpty())
        {
            myFutureMethod(leadListToDelete);
        }
    }
    
    public static void deleteLead2(List<Lead> leadList)
    {
        List<Id> leadListToDelete = new List<Id>();
        for(Lead leadObj:leadList)
        {
            if(leadObj.Is_Duplicate__c)
            {
                leadListToDelete.add(leadObj.Id);
            }
        }
        if(!leadListToDelete.isEmpty())
        {
            myFutureMethod(leadListToDelete);
        }
    }
    
    public static void deleteLead3(List<Lead> leadList)
    {
        List<Id> leadListToDelete = new List<Id>();
        for(Lead leadObj:leadList)
        {
            if(leadObj.Is_Duplicate__c)
            {
                leadListToDelete.add(leadObj.Id);
            }
        }
        if(!leadListToDelete.isEmpty())
        {
            myFutureMethod(leadListToDelete);
        }
    }

    // MODIFIED AS PART OF INFSD-505 - KENDRICK KAM 14/11/2024
    // ADDED: logic to only update the CRC assigned and CM assigned if they were previously empty. If not empty - then dont change them. 
    // This is to prevent the re-assigning of these fields when a lead is converted (e.g. they exist already, but when they are converted to an opp - they change due to the pre-existing code)
    public static void roundRobinOnOpportunity(List<Lead> newleadList, List<Lead> oldleadList)
    {
        id leadRecordTypeId =  [SELECT id FROM recordType where Name = 'VC' and SobjectType = 'Lead'].id;
        Map<id,Boolean> leadOldStatusMap = new Map<id,Boolean>();
        map<id, Lead> oppIdToLeadObjMap = new map<id, Lead>();

        for(Lead oldLeadObj : oldleadList) 
        {
            leadOldStatusMap.put(oldLeadObj.Id, oldLeadObj.IsConverted);
        }

        for(Lead newLeadObj : newleadList) 
        {
            if (newLeadObj.IsConverted && leadOldStatusMap.get(newLeadObj.Id) == false && newLeadObj.RecordTypeId == leadRecordTypeId)            
            {
                oppIdToLeadObjMap.put(newLeadObj.ConvertedOpportunityId, newLeadObj);
            }
        }

        List<Opportunity> oppList = [SELECT Id, Name, StageName, OwnerId, CRC_Assigned__c, CM_Assigned__c, Opportunity_auto_number__c
                                 FROM Opportunity
                                 WHERE Id IN :oppIdToLeadObjMap.keySet()];

        List<User> queueUserMemberList =[select Id from user where Id IN (select userOrgroupId 
                                            from GroupMember
                                            where Group.Name = 'CM') and IsActive = true];
        Integer CMListSize = queueUserMemberList.size();


        List<Opportunity> oppListToUpdate = new List<Opportunity>();

        for (Opportunity oppObj : oppList) {
            // 
            Boolean isAdded = false;

            // update OwnerID if its empty
            if(oppObj.OwnerId == null){
                oppObj.OwnerId = queueUserMemberList[Math.mod(Integer.valueOf(oppObj.Opportunity_auto_number__c), CMListSize)].Id;
                isAdded = true;
            }

            // check if CM_Assigned__c and CRC_Assigned__c is null
            if (oppObj.CM_Assigned__c == null) {  // Check if fields are blank
                oppObj.CM_Assigned__c = queueUserMemberList[Math.mod(Integer.valueOf(oppObj.Opportunity_auto_number__c), CMListSize)].Id;
                isAdded = true;
            }

            if( oppObj.CRC_Assigned__c == null){
                oppObj.CRC_Assigned__c = oppIdToLeadObjMap.get(oppObj.Id).ownerId;
                isAdded = true;
            }

            if(!isAdded){
                oppListToUpdate.add(oppObj);
            }
        }

        // update opps
        if (!oppListToUpdate.isEmpty()) {
            update oppListToUpdate;
        }

        // INFSD-505 pre-existing code
        // for(Opportunity oppObj: oppList)
        // {
        //     oppObj.OwnerId = queueUserMemberList[Math.mod(Integer.valueOf(oppObj.Opportunity_auto_number__c), CMListSize)].Id;
        //     // oppObj.CM_Assigned__c = queueUserMemberList[Math.mod(Integer.valueOf(oppObj.Opportunity_auto_number__c), CMListSize)].Id;
        //     // oppObj.CRC_Assigned__c = oppIdToLeadObjMap.get(oppObj.Id).ownerId;
        //     //oppObj.OwnerId = queueMemberList[Math.mod(Integer.valueOf(oppObj.Opportunity_auto_number__c), CMListSize)].userOrgroupId;
        //     //oppObj.CM_Assigned__c = queueMemberList[Math.mod(Integer.valueOf(oppObj.Opportunity_auto_number__c), CMListSize)].userOrgroupId;
        //     //oppObj.CRC_Assigned__c = oppIdToLeadObjMap.get(oppObj.Id).ownerId;
        //     //oppObj.StageName = 'Closing Pending';
        // }
        // if(!oppList.isEmpty())
        // {
        //     update oppList;
        // }
    }

    //New method added to remove dependancy on accTriggerHandler
    private static Boolean isChanged(sObject newRecord, sObject oldRecord, String fieldName) {
        return newRecord.get(fieldName) != oldRecord.get(fieldName);
   }

    public static void syncMarketingPreferences(List<Lead> newleadList, Map<Id,Lead> oldleadMap, Map<Id,Lead> newleadMap){
        List<Id> marketingPreferencesFilteredIds = new List<Id>();
        for(Lead l : newleadList){
            if(oldleadMap == null || (isChanged(l, Trigger.oldMap.get(l.Id),'Email_Opt_In__c') || isChanged(l, Trigger.oldMap.get(l.Id),'HasOptedOutOfEmail'))){
                marketingPreferencesFilteredIds.add(l.Id);
            }
        }
        if(!marketingPreferencesFilteredIds.isEmpty()){
            Map<Id,Marketing_Preference__c> leadIdVsMapMap = new Map<Id,Marketing_Preference__c>();
            for(Marketing_Preference__c mp : [SELECT Id,Lead__c FROM Marketing_Preference__c WHERE Lead__c = :marketingPreferencesFilteredIds ORDER BY createddate DESC]){
                leadIdVsMapMap.put(mp.Lead__c,mp);
            }
            for(Id i : marketingPreferencesFilteredIds){
                if(!leadIdVsMapMap.containsKey(i)){
                    leadIdVsMapMap.put(i, new Marketing_Preference__c(Lead__c=i));
                }
                leadIdVsMapMap.get(i).Marketing_Updates_About_Product_OptIn__c = (Boolean)newleadMap.get(i).get('Email_Opt_In__c');
                leadIdVsMapMap.get(i).Marketing_Updates_About_Product_Optout__c = (Boolean)newleadMap.get(i).get('HasOptedOutOfEmail');
            }
            if(!leadIdVsMapMap.values().isempty()){
                MarketingPrerenceTriggerHandler.performSyncFromMarketingPreference = false;
                upsert leadIdVsMapMap.values();
            }
        }
    }
    public static void validateLostLead(List<Lead> newleadList, Map<Id,Lead> oldleadMap){
        for(Lead l : newleadList){
            if(l.HasOptedOutOfEmail && (oldleadMap == null || isChanged(l, Trigger.oldMap.get(l.Id),'HasOptedOutOfEmail'))){
                // l.Loss_Reason__c = 'Opted out';
                // l.Status = 'Lost';
            }
            if(l.Status == 'Lost' && (oldleadMap == null || isChanged(l, Trigger.oldMap.get(l.Id),'Status'))){
                if(l.Lost_Stages__c == 'CR Lost'  && (oldleadMap == null || isChanged(l, Trigger.oldMap.get(l.Id),'Lost_Stages__c'))){

                }else{
                    // l.HasOptedOutOfEmail = true;
                    // l.Email_Opt_In__c = false;
                }              
                
            }
        }
    }
    @future 
	public static void myFutureMethod(List<Id> leadList)
    {
        delete [select id from lead where id in:leadList];
    }
}