/**
**/
public class OpportunityTriggerHandler
{
    public static final string  LINEITEM_STAGENAME_EOI = 'EOI';
    public static final string  LINEITEM_STAGENAME_CONTRACT = 'Contract';
    public static final string  LINEITEM_SUBSTAGE_CONTRACT_EXECUTED = 'Contract Executed';
    public static final string  PRODUCT_STATUS_EXPRESSION_OF_INTREST = 'Expression Of Interest';
    public static final string  PRODUCT_STATUS_SOLD_OUT = 'Sold Out';
    public static final string  OPPORTUNITY_STAGE_CLOSED_LOST = 'Closed Lost';
    public static final string  OPPORTUNITY_LOST_REASON_SOLD_TO_OTHER_PARTY = 'Sold to other party';
    public static final string  OPPORTUNITY_STAGE_SETTLEMENT_BOOKED = 'Settlement Booked';	
    public static final string  PRODUCT_STATUS_AVAILABLE = 'Available';	
    public static boolean emailsent = false;
    public static Id vcpprecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('VCPP').getRecordTypeId();
    public static Boolean isProcessInvestmentRecordRunning = false;

   
    public static void updateContact(){
        Set<Id> accIdset = new Set<Id>();
        // Only add non-null AccountIds.
        for(Opportunity opp : (List<Opportunity>) Trigger.New){
            if(opp.AccountId != null) {
                accIdset.add(opp.AccountId);
            }
        }
        // Query Accounts with their RecordType info and related Contacts.
        Map<Id,Account> accMap = new Map<Id,Account>(
            [SELECT Id, RecordType.Name, Account_Type_Dynamic__c, 
                    (SELECT Id, Name FROM Contacts)
             FROM Account WHERE Id IN : accIdset]
        );
        // Query AccountContactRelation records.
        Map<Id,List<AccountContactRelation>> accIdVSconlstmap = new Map<Id,List<AccountContactRelation>>();
        for(AccountContactRelation acr : [SELECT Id, Roles, Account.RecordType.Name, IsDirect, AccountId, ContactId 
                                          FROM AccountContactRelation 
                                          WHERE AccountId IN : accIdset]){
            if(!accIdVSconlstmap.containsKey(acr.AccountId))
                accIdVSconlstmap.put(acr.AccountId, new List<AccountContactRelation>());
            accIdVSconlstmap.get(acr.AccountId).add(acr);
        }
        // Loop through the Opportunities in trigger context.
        for(Opportunity opp : (List<Opportunity>) Trigger.New){
            // Check that the Account exists in our query.
            if(opp.AccountId != null && accMap.containsKey(opp.AccountId)){
                Account a = accMap.get(opp.AccountId);
                // If Opportunity.Type is null and the Account's dynamic type field is not null, then assign it.
                if(opp.Type == null && a.Account_Type_Dynamic__c != null){
                    opp.Type = a.Account_Type_Dynamic__c;
                }
                // Set Primary_Contact__c if not already set.
                if(opp.Primary_Contact__c == null){
                    // If the Account's record type name indicates a 'person' and it has at least one contact, use that.
                    if(a.RecordType != null && a.RecordType.Name != null && a.RecordType.Name.containsIgnoreCase('person') && !a.Contacts.isEmpty()){
                        opp.Primary_Contact__c = a.Contacts[0].Id;
                    } else {
                        AccountContactRelation accr1;
                        AccountContactRelation accr2;
                        AccountContactRelation accr3;
                        if(accIdVSconlstmap.containsKey(opp.AccountId)){
                            for(AccountContactRelation acr : accIdVSconlstmap.get(opp.AccountId)){
                                accr1 = acr;
                                if(acr.Roles != null && acr.Roles.containsIgnoreCase('Decision Maker'))
                                    accr2 = acr;
                                if(acr.IsDirect)
                                    accr3 = acr;
                            }
                            if(accr3 != null) {
                                opp.Primary_Contact__c = accr3.ContactId;
                            } else if(accr2 != null) {
                                opp.Primary_Contact__c = accr2.ContactId;
                            } else if(accr1 != null) {
                                opp.Primary_Contact__c = accr1.ContactId;
                            }
                        } else if(!a.Contacts.isEmpty()){
                            opp.Primary_Contact__c = a.Contacts[0].Id;
                        }                    
                    }
                }
            }
        }
    }
    

    // Process builder logic to trigger
    public static void commonLogic(){
        // before update
        if(Trigger.isBefore){   
            List<Id> accountIdlst = new List<Id>();         
            for(Opportunity opp : (List<Opportunity>) Trigger.new){
                if(Trigger.isInsert){
                    if(opp.stagename == 'Application Received' && opp.LeadSource == 'VC Website Organic'){
                        // opp.CM_Assigned__c = opp.ownerId;
                        opp.Web_Source__c = 'Invest Now Form';
                    }
                }
                if(Trigger.isUpdate){
                    Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>([SELECT Id, Account.PersonContactId, Account.Account_Type_Dynamic__c, Recordtype.Name, Primary_Contact__r.Email, Primary_Contact__r.FirstName, Primary_Contact__r.LastName, Primary_Contact__r.MobilePhone, Primary_Contact__r.MailingCity, Primary_Contact__r.MailingPostalCode, Primary_Contact__r.MailingState, Primary_Contact__r.MailingStreet, Invested_Product_ADMIN_FIELD__c, Invested_Product_ADMIN_FIELD__r.Land_Size__c, Invested_Product_ADMIN_FIELD__r.Suburb__c, Invested_Product_ADMIN_FIELD__r.Product_Number__c, Invested_Product_ADMIN_FIELD__r.Postcode__c, Invested_Product_ADMIN_FIELD__r.Street_Address__c, Invested_Product_ADMIN_FIELD__r.State__c FROM Opportunity WHERE Id IN :Trigger.newMap.keyset()]);
                    if(opp.Unit_Cert_Issued__c <> NULL && Trigger.oldMap.get(opp.Id).get('Unit_Cert_Issued__c') == NULL && opp.Initial_Term_Expiry__c <> null){
                        opp.Maturation_Date__c = opp.Unit_Cert_Issued__c.addMonths(Integer.valueOf(opp.Initial_Term_Expiry__c));
                    }
                    system.debug(opp.stagename+'GSAC');
                    system.debug(oppMap.get(opp.Id).Recordtype.Name+'GSAC'); system.debug(!opp.Create_EOI_Application__c+'GSAC');
                    if(opp.stagename == 'EOI' && oppMap.get(opp.Id).Recordtype.Name == 'VCPP' && !opp.Create_EOI_Application__c){
                        Application__c app = new Application__c();
                        app.Account__c = opp.AccountId;
                        app.Buyer_1_Email__c = oppMap.get(opp.Id).Primary_Contact__r.Email;
                        app.Buyer_1_First_Name__c = oppMap.get(opp.Id).Primary_Contact__r.FirstName;
                        app.Buyer_1_Last_Name__c = oppMap.get(opp.Id).Primary_Contact__r.LastName;
                        app.Buyer_1_Phone__c = oppMap.get(opp.Id).Primary_Contact__r.MobilePhone;
                        app.Buyer_1_Postal_City__c = oppMap.get(opp.Id).Primary_Contact__r.MailingCity;
                        app.Buyer_1_Postal_Code__c = oppMap.get(opp.Id).Primary_Contact__r.MailingPostalCode;
                        app.Buyer_1_Postal_State__c = oppMap.get(opp.Id).Primary_Contact__r.MailingState;
                        app.Buyer_1_Postal_Street_Address__c = oppMap.get(opp.Id).Primary_Contact__r.MailingStreet;
                        app.Land_Size_in_Sqm__c = oppMap.get(opp.Id).Invested_Product_ADMIN_FIELD__r.Land_Size__c;
                        app.Opportunity__c = opp.Id;
                        app.Product__c = oppMap.get(opp.Id).Invested_Product_ADMIN_FIELD__c;
                        app.Property_City__c = oppMap.get(opp.Id).Invested_Product_ADMIN_FIELD__r.Suburb__c;
                        app.Property_Lot_Unit_No__c = oppMap.get(opp.Id).Invested_Product_ADMIN_FIELD__r.Product_Number__c;
                        app.Property_Postal_Code__c = oppMap.get(opp.Id).Invested_Product_ADMIN_FIELD__r.Postcode__c;
                        app.Property_Street_Address__c = oppMap.get(opp.Id).Invested_Product_ADMIN_FIELD__r.Street_Address__c;
                        app.State_Province__c = oppMap.get(opp.Id).Invested_Product_ADMIN_FIELD__r.State__c;
                        app.Type__c = 'EOI';
                        // Correct assignment: use the Contact Id from the Opportunity lookup field or relationship.
                        app.Contact__c = oppMap.get(opp.Id).Primary_Contact__c;
                        insert app;
                        opp.Create_EOI_Application__c = true;
                    }
                    
                }
                accountIdlst.add(opp.AccountId);
            }
            Map<Id,Account> accMap = new Map<Id,Account>([SELECT Id, Account_Type_Dynamic__c FROM Account WHERE Id IN :accountIdlst]);
            // for both insert and update
            for(Opportunity opp : (List<Opportunity>) Trigger.new){
                if(opp.Type == NULL && accMap.get(opp.AccountId).Account_Type_Dynamic__c <> NULL){
                    opp.Type = accMap.get(opp.AccountId).Account_Type_Dynamic__c;
                }
            }
        }
        if(Trigger.isAfter){
            system.debug('Afetr Updat');
            // set<Id> oppIsdet = 
            Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>([SELECT Id, Account.PersonContactId, Account.Account_Type_Dynamic__c FROM Opportunity WHERE Id IN :Trigger.newMap.keyset()]);
            for(Opportunity opp : (List<Opportunity>) Trigger.new){
                if(Trigger.isInsert){
                    // Removed as part of INFSD-369 KENDRICK KAM 12-09-2024
                    // if(opp.stagename == 'Application Received' && opp.LeadSource == 'VC Website Organic'){
                    //     List<Task> tasklst = new List<Task>();
                    //     tasklst.add(new Task(ActivityDate= Date.Valueof(opp.createddate),Description = 'Received a new request to invest submission. Please review if ID has been verified',OwnerId = opp.CM_Assigned__c,Priority='Normal',Status='Open',Subject='Request to Invest Submission - ID Verified?',WhatId=opp.Id,WhoId=oppMap.get(opp.Id).Account.PersonContactId));
                    //     tasklst.add(new Task(ActivityDate= Date.Valueof(opp.createddate),Description = 'Received a new request to invest submission. If investment product is wholesale, verify if the account is verified for Wholesale',OwnerId = opp.CM_Assigned__c,Priority='Normal',Status='Open',Subject='Request to Invest Submission - If Wholesale Product?',WhatId=opp.Id,WhoId=oppMap.get(opp.Id).Account.PersonContactId));
                    //     tasklst.add(new Task(ActivityDate= Date.Valueof(opp.createddate),Description = 'Received a new request to invest submission. Review if ‘Req to Invest Under Different Account’ field is checked.',OwnerId = opp.CM_Assigned__c,Priority='Normal',Status='Open',Subject='Request to Invest Submission - Different Account',WhatId=opp.Id,WhoId=oppMap.get(opp.Id).Account.PersonContactId));
                    //     tasklst.add(new Task(ActivityDate= Date.Valueof(opp.createddate),Description = 'Please update the closed date to a new date to refelect the changes in opportunity status',OwnerId = opp.CM_Assigned__c,Priority='High',Status='Open',Subject='Update closed date on opportuntity',WhatId=opp.Id,WhoId=oppMap.get(opp.Id).Account.PersonContactId));
                    //     insert tasklst;
                    // }
                }
            }
        }
    }
}