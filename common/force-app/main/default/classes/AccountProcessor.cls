public with sharing class AccountProcessor implements Queueable, Database.AllowsCallouts {
    // Accounts from trigger context (for AFTER INSERT/UPDATE processing)
    private List<Account> accounts;
    // For update operations only
    private Map<Id, Account> accountsOldMap;
    private Map<Id, Account> accountsNewMap;
    // Operation type (e.g., 'AFTER_INSERT', 'AFTER_UPDATE', 'BEFORE_UPDATE')
    private String updateType;
    
    // Constructor – for AFTER triggers the oldMap is available; for insert, it will be null
    public AccountProcessor(List<Account> accounts, Map<Id, Account> accountsOldMap, 
                            Map<Id, Account> accountsNewMap, String updateType) {
        this.accounts = accounts;
        this.accountsOldMap = accountsOldMap;
        this.accountsNewMap = accountsNewMap;
        this.updateType = updateType;
    }
    
    public void execute(QueueableContext context) {
        // Choose processing based on the update type
        if(updateType == 'AFTER_INSERT') {
            processAfterInsert();
        } else if(updateType == 'AFTER_UPDATE') {
            processAfterUpdate();
        } else if(updateType == 'BEFORE_UPDATE') {
            processBeforeUpdate();
        }
        // You can add a BEFORE_INSERT branch if needed.
    }
    
    // -------------------- AFTER INSERT PROCESSING --------------------
    private void processAfterInsert() {
        // Replicate heavy processing from accTriggerHandler.afterinsert()
        List<Id> filteredAccIds = new List<Id>();
        List<Account> acclst_community = new List<Account>();
        for(Account a : accounts) {
            if(a.BPAY__c == null) {
                filteredAccIds.add(a.Id);
            }
            if(a.Account_Created_via_Portal__c) {
                acclst_community.add(a);
            }
        }
        
        Integer bpaysreq = filteredAccIds.size();
        // Query BPAY__c records in bulk
        List<BPAY__c> bpaylst = [SELECT Id, Name 
                                  FROM BPAY__c 
                                  WHERE Active__c = false AND Account_ID__c = null 
                                  ORDER BY Name 
                                  LIMIT :bpaysreq];
        List<Account> accountsToUpdate = new List<Account>();
        // Loop through BPAY records and assign them to the filtered accounts
        for(Integer i = 0; i < bpaylst.size(); i++) {
            bpaylst[i].Active__c = true;
            bpaylst[i].Allocated_Account__c = filteredAccIds[i];
            Account acc = new Account(Id = filteredAccIds[i]);
            acc.BPAY__c = bpaylst[i].Id;
            acc.put('Assign_BPAY__c', true);
            accountsToUpdate.add(acc);
        }
        if(!bpaylst.isEmpty()) {
            update bpaylst;
        }
        if(!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
        // Process syncing marketing preferences
        processSyncMarketPreferences(accounts);
        // Process sending community emails if needed
        // REMOVED KKAM - Moved to a flow
        // if(!acclst_community.isEmpty()) {
        //     processSendAccEmails(acclst_community);
        // }
    }
    
    // -------------------- AFTER UPDATE PROCESSING --------------------
    private void processAfterUpdate() {
        List<Id> filteredAccIds = new List<Id>();
        List<Account> acclst_community = new List<Account>();
        // Use the accountsNewMap for updated values
        for(Account a : accounts) {
            // Check if ID_Checked__pc changed
            if(a.ID_Checked__pc && accountsOldMap.get(a.Id).get('ID_Checked__pc') != a.get('ID_Checked__pc')) {
                filteredAccIds.add(a.Id);
            }
            // If created via portal, active, and Active__c field has changed, add to community list
            if(a.Account_Created_via_Portal__c && a.Active__c && isChanged(a, accountsOldMap.get(a.Id), 'Active__c')) {
                acclst_community.add(a);
            }
        }
        // Query Opportunities related to these accounts to update ID_Verified__c flag
        List<Opportunity> oppList = [SELECT Id 
                                     FROM Opportunity 
                                     WHERE AccountId IN :filteredAccIds 
                                     AND StageName = 'Application Received'
                                     AND Sent_Verify_ID_Email__c = true 
                                     AND Bpay_Email_Sent__c = false 
                                     AND ID_Verified__c = false];
        for(Opportunity opp : oppList) {
            opp.ID_Verified__c = true;
        }
        if(!oppList.isEmpty()) {
            update oppList;
        }
        // REMOVED KKAM - Moved to a flow
        // if(!acclst_community.isEmpty()) {
        //     processSendCustomerVerificationEmail(acclst_community);
        // }
        // Update ownership based on approval status changes
        processUpdateOwnershipAfterApproval(accountsNewMap, accountsOldMap, accounts);
        // Sync marketing preferences
        processSyncMarketPreferences(accounts);
    }
    
    // -------------------- BEFORE UPDATE PROCESSING --------------------
    private void processBeforeUpdate() {
        // Although before update logic is typically lightweight, if you face SOQL limits here you can process it asynchronously
        List<Id> filteredAccIds = new List<Id>();
        for(Account a : accounts) {
            if(a.ID_Checked__pc && accountsOldMap.get(a.Id).get('ID_Checked__pc') != a.get('ID_Checked__pc') && a.BPAY__c == null) {
                filteredAccIds.add(a.Id);
            }
            if(a.Approval_Status__c == 'Approved' && accountsOldMap.get(a.Id).get('Approval_Status__c') != a.get('Approval_Status__c')) {
                a.OwnerId = a.Approval_Requested_For__c;
            }
            // Set flag based on Total_Investment__c
            a.Has_Made_1_Investment__c = a.Total_Investment__c >= 1;
        }
        Integer bpaysreq = filteredAccIds.size();
        if(bpaysreq > 0) {
            List<BPAY__c> bpaylst = [SELECT Id, Name 
                                      FROM BPAY__c 
                                      WHERE Active__c = false AND Account_ID__c = null 
                                      ORDER BY Name 
                                      LIMIT :bpaysreq];
            if(!bpaylst.isEmpty()) {
                // For each BPAY record, update the corresponding account fields.
                List<Account> accountsToUpdate = new List<Account>();
                for(Integer i = 0; i < bpaysreq; i++){
                    bpaylst[i].Active__c = true;
                    bpaylst[i].Allocated_Account__c = filteredAccIds[i];
                    Account aToUpdate = new Account(Id = filteredAccIds[i]);
                    aToUpdate.put('BPAY__c', bpaylst[i].Id);
                    aToUpdate.put('Assign_BPAY__c', true);
                    accountsToUpdate.add(aToUpdate);
                }
                update bpaylst;
                if(!accountsToUpdate.isEmpty()){
                    update accountsToUpdate;
                }
            }
        }
    }
    
    // -------------------- HELPER METHODS --------------------
    // Sync marketing preferences similar to accTriggerHandler.syncmarketpreferences()
    private void processSyncMarketPreferences(List<Account> accs) {
        List<Id> marketingPrefFilteredIds = new List<Id>();
        // For insert or if PersonAccount and certain fields changed (for update)
        for(Account a : accs) {
            if(updateType == 'AFTER_INSERT' ||
               (a.IsPersonAccount && (isChanged(a, accountsOldMap.get(a.Id), 'Investor_Updates_OptIn__c') ||
                                       isChanged(a, accountsOldMap.get(a.Id), 'Email_Opt_In__pc') ||
                                       isChanged(a, accountsOldMap.get(a.Id), 'PersonHasOptedOutOfEmail')))) {
                marketingPrefFilteredIds.add(a.Id);
            }
        }
        if(!marketingPrefFilteredIds.isEmpty()){
            Map<Id, Marketing_Preference__c> accPrefMap = new Map<Id, Marketing_Preference__c>();
            for(Marketing_Preference__c mp : [SELECT Id, Account__c 
                                               FROM Marketing_Preference__c 
                                               WHERE Account__c IN :marketingPrefFilteredIds 
                                               ORDER BY CreatedDate DESC]) {
                accPrefMap.put(mp.Account__c, mp);
            }
            for(Id accId : marketingPrefFilteredIds) {
                if(!accPrefMap.containsKey(accId)) {
                    accPrefMap.put(accId, new Marketing_Preference__c(Account__c = accId));
                }
                Marketing_Preference__c mpRec = accPrefMap.get(accId);
                // Use a safe conversion method to ensure Boolean values are assigned
                mpRec.Regular_Marketing_Communications_Optout__c = convertToBoolean(accountsNewMap.get(accId).get('PersonHasOptedOutOfEmail'));
                mpRec.Regular_Marketing_Communications_Optin_c__c = convertToBoolean(accountsNewMap.get(accId).get('Email_Opt_In__pc'));
            }
            if(!accPrefMap.values().isEmpty()){
                MarketingPrerenceTriggerHandler.performSyncFromMarketingPreference = false;
                upsert accPrefMap.values();
            }
        } 
    }
    
    // Helper method to safely convert an Object value to Boolean
    private Boolean convertToBoolean(Object value) {
        if(value == null) return false;
        if(value instanceof Boolean) {
            return (Boolean)value;
        } else if(value instanceof String) {
            // Convert string values to Boolean (treat 'true' as true, everything else as false)
            return String.valueOf(value).toLowerCase() == 'true';
        }
        return false;
    }
    
    // Process sending community account emails (from sendAccemails)
    // REMOVE THIS METHOD - Moved to a flow
    // private void processSendAccEmails(List<Account> communityAccs) {
    //     List<String> emailTemplateLst = new List<String>{'New_Entity_Notify_Investor','New_Entity_Notify_AccountOwner'};
    //     Map<String, EmailTemplate> etMap = new Map<String, EmailTemplate>();
    //     for(EmailTemplate et : [SELECT Id, DeveloperName 
    //                             FROM EmailTemplate 
    //                             WHERE DeveloperName IN :emailTemplateLst]) {
    //         etMap.put(et.DeveloperName, et);
    //     }
    //     List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
    //     OrgWideEmailAddress orgEmail = [SELECT Id, Address, DisplayName 
    //                                     FROM OrgWideEmailAddress 
    //                                     WHERE Address = 'investor@venturecrowd.com.au' LIMIT 1];
    //     User currentUser = [SELECT Id, ContactId, Contact.Account.OwnerId 
    //                         FROM User 
    //                         WHERE Id = :UserInfo.getUserId() LIMIT 1];
    //     for(Account acc : communityAccs) {
    //         Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
    //         msg.setTemplateId(etMap.get('New_Entity_Notify_Investor').Id);
    //         msg.setTargetObjectId(currentUser.ContactId);
    //         msg.setWhatId(acc.Id);
    //         msg.setOrgWideEmailAddressId(orgEmail.Id);
    //         messages.add(msg);
            
    //         msg = new Messaging.SingleEmailMessage();
    //         msg.setTemplateId(etMap.get('New_Entity_Notify_AccountOwner').Id);
    //         msg.setTargetObjectId(currentUser.ContactId);
    //         msg.setWhatId(acc.Id);
    //         msg.setTreatTargetObjectAsRecipient(false);
    //         msg.setCcAddresses(new List<String>{acc.OwnerId});
    //         msg.setOrgWideEmailAddressId(orgEmail.Id);
    //         messages.add(msg);
    //     }
    //     if(currentUser.ContactId != null) {
    //         Messaging.sendEmail(messages);
    //     }
    // }
    
    // Process sending customer verification emails
    // REMOVE THIS METHOD
    // private void processSendCustomerVerificationEmail(List<Account> accs) {
    //     List<String> emailTemplateLst = new List<String>{'New_Entity_Notify_Investor_Verification_Completed'};
    //     Map<String, EmailTemplate> etMap = new Map<String, EmailTemplate>();
    //     for(EmailTemplate et : [SELECT Id, DeveloperName 
    //                             FROM EmailTemplate 
    //                             WHERE DeveloperName IN :emailTemplateLst]) {
    //         etMap.put(et.DeveloperName, et);
    //     }
    //     List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
    //     OrgWideEmailAddress orgEmail = [SELECT Id, Address, DisplayName 
    //                                     FROM OrgWideEmailAddress 
    //                                     WHERE Address = 'investor@venturecrowd.com.au' LIMIT 1];
    //     Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id, CreatedBy.ContactId 
    //                                                     FROM Account 
    //                                                     WHERE Id IN :accs]);
    //     for(Account acc : accs) {
    //         Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
    //         msg.setTemplateId(etMap.get('New_Entity_Notify_Investor_Verification_Completed').Id);
    //         // Retrieve the contact id from the account's CreatedBy
    //         Id targetId = accMap.get(acc.Id).CreatedBy.ContactId;
    //         if(targetId == null) {
    //             // Fallback to current user if no contact is available.
    //             targetId = UserInfo.getUserId();
    //             msg.setTargetObjectId(targetId);
    //             // Do NOT set whatId when the target is a user.
    //         } else {
    //             msg.setTargetObjectId(targetId);
    //             msg.setWhatId(acc.Id);
    //         }
    //         msg.setOrgWideEmailAddressId(orgEmail.Id);
    //         msg.setSaveAsActivity(false);
    //         messages.add(msg);
    //     }
    //     Messaging.sendEmail(messages);
    // }
    
    
    
    // Process updating ownership after approval
    private void processUpdateOwnershipAfterApproval(Map<Id, Account> newMap, Map<Id, Account> oldMap, List<Account> newAccs) {
        List<Account> qualifiedAccs = new List<Account>();
        List<Account> accToUpdate = new List<Account>();
        for(Account acc : newAccs) {
            if(acc.Approval_Status__c == 'Approved' && isChanged(newMap.get(acc.Id), oldMap.get(acc.Id), 'Approval_Status__c')) {
                qualifiedAccs.add(acc);
            }
        }
        Map<Id, List<Account>> relAccMap = getRelatedAccounts(qualifiedAccs);
        for(Id accId : relAccMap.keySet()) {
            for(Account relatedAcc : relAccMap.get(accId)) {
                relatedAcc.OwnerId = newMap.get(accId).Approval_Requested_For__c;
                accToUpdate.add(relatedAcc);
            }
        }
        if(!accToUpdate.isEmpty()) {
            update accToUpdate;
        }
    }
    
    // -------------------- HELPER METHODS --------------------
    public static Map<Id, List<Account>> getRelatedAccounts(List<Account> acclst) {
         Map<Id, List<Account>> retMap = new Map<Id, List<Account>>();
         Map<Id, Account> personalAccMap = new Map<Id, Account>();
         Map<Id, Account> businessAccMap = new Map<Id, Account>();
         Map<Id, Id> conToAccId = new Map<Id, Id>();
         for(Account acc : acclst) {
             if(acc.IsPersonAccount) {
                 personalAccMap.put(acc.PersonContactId, acc);
                 conToAccId.put(acc.PersonContactId, acc.Id);
             } else {
                 businessAccMap.put(acc.Id, acc);
             }
         }
         if(!personalAccMap.isEmpty()){
             for(AccountContactRelation acr : [SELECT Id, AccountId, ContactId 
                                               FROM AccountContactRelation 
                                               WHERE ContactId IN :personalAccMap.keySet()]) {
                 String accId = conToAccId.get(acr.ContactId);
                 if(!retMap.containsKey(accId)) {
                     retMap.put(accId, new List<Account>());
                 }
                 retMap.get(accId).add(new Account(Id = acr.AccountId));
             }
         }
         if(!businessAccMap.isEmpty()){
             for(AccountContactRelation acr : [SELECT Id, AccountId, Contact.AccountId 
                                               FROM AccountContactRelation 
                                               WHERE AccountId IN :businessAccMap.keySet()]) {
                 String accId = acr.AccountId;
                 if(!retMap.containsKey(accId)) {
                     retMap.put(accId, new List<Account>());
                 }
                 retMap.get(accId).add(new Account(Id = acr.Contact.AccountId));
             }
         }
         return retMap;
    }
    
    private Boolean isChanged(sObject newRecord, sObject oldRecord, String fieldName) {
         return newRecord.get(fieldName) != oldRecord.get(fieldName);
    }
}