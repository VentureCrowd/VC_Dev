public with sharing class OpportunityProcessor implements Queueable, Database.AllowsCallouts {
    private List<Opportunity> opportunities;
    private Map<Id, Opportunity> opportunitiesOldMap;
    private Map<Id, Opportunity> opportunitiesNewMap;
    private String updateType;
    
    // Existing constants and variables…
    public static final String LINEITEM_STAGENAME_EOI = 'EOI';
    public static final String LINEITEM_STAGENAME_CONTRACT = 'Contract';
    public static final String LINEITEM_SUBSTAGE_CONTRACT_EXECUTED = 'Contract Executed';
    public static final String PRODUCT_STATUS_EXPRESSION_OF_INTREST = 'Expression Of Interest';
    public static final String PRODUCT_STATUS_SOLD_OUT = 'Sold Out';
    public static final String OPPORTUNITY_STAGE_CLOSED_LOST = 'Closed Lost';
    public static final String OPPORTUNITY_LOST_REASON_SOLD_TO_OTHER_PARTY = 'Sold to other party';
    public static final String OPPORTUNITY_STAGE_SETTLEMENT_BOOKED = 'Settlement Booked';	
    public static final String PRODUCT_STATUS_AVAILABLE = 'Available';	
    public static Boolean emailsent = false;
    public static Id vcpprecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('VCPP').getRecordTypeId();
    public static Boolean isProcessInvestmentRecordRunning = false;
    
    // **Static flag to prevent recursive email processing**
    public static Boolean emailsProcessed = false;
    
    public OpportunityProcessor(List<Opportunity> opportunities, Map<Id, Opportunity> opportunitiesOldMap, 
                                Map<Id, Opportunity> opportunitiesNewMap, String updateType) {
        this.opportunities = opportunities;
        this.updateType = updateType;
        this.opportunitiesOldMap = opportunitiesOldMap;
        this.opportunitiesNewMap = opportunitiesNewMap;
    }
    
    public void execute(QueueableContext context) {
        if(this.updateType == 'AFTER_UPDATE'){
            updateProductStatusOnOpportunityClosure(opportunitiesNewMap, opportunitiesOldMap);
            oppfilesshare();
            oliCurrentValuesIpdate();
            updateChildOLIstatus();
            sendEmails();
        }
        if(this.updateType == 'AFTER_INSERT'){
            sendEmails();
        }
    }
    
    public void sendEmails(){
        // Prevent recursion: if emails have already been processed, exit.
        //if(emailsProcessed){
        //    return;
        //}
        //emailsProcessed = true;
        
        // Re-query the opportunities to ensure you have the latest data.
        Set<Id> oppIds = new Set<Id>();
        for(Opportunity opp : this.opportunities){
            oppIds.add(opp.Id);
        }
        List<Opportunity> currentOpps = [SELECT Id, StageName, RecordTypeId, Related_Product_Code__c, Invested_opp_prod_admin__c, Invested_Product_ADMIN_FIELD__c,
                                  Primary_Contact_email__c, Primary_Contact__c, Bpay_Email_sent__c, TSF_receipt_email_sent__c,
                                  Sent_verify_id_email__c, TSF_Donation_EMail_Sent__c,
                                  Amount, Donation_related_investment_opp__c, Donation__c, Associated_Product_Type__c
                                  FROM Opportunity
                                  WHERE Id IN :oppIds];
        
        System.debug('Opps found:' + JSON.serializePretty(currentOpps));
                                        
        // Cache the VC record type Id.
        Id vcRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('VC').getRecordTypeId();
        List<Opportunity> qualifiedList = new List<Opportunity>();
        List<Opportunity> tsfList = new List<Opportunity>();
        
        // Evaluate each Opportunity against email criteria.
        for(Opportunity opp : currentOpps){
            if(opp.StageName == 'Application Received' &&
               opp.RecordTypeId == vcRecordTypeId &&
               opp.Related_Product_Code__c != 'TSF' &&
               opp.Invested_opp_prod_admin__c != null &&
               opp.Primary_Contact_email__c != null &&
               opp.Primary_Contact__c != null &&
               !opp.Bpay_Email_sent__c &&
               opp.Amount != null &&
               ((opp.Donation_related_investment_opp__c == null && !opp.Donation__c) ||
                (opp.Donation_related_investment_opp__c != null && opp.Donation__c))){
                qualifiedList.add(opp);
            }
            if(opp.StageName == 'Receipt Issued' &&
               opp.RecordTypeId == vcRecordTypeId &&
               opp.Related_Product_Code__c == 'TSF' &&
               opp.Primary_Contact_email__c != null &&
               !opp.TSF_receipt_email_sent__c){
                tsfList.add(opp);
            }
        }
        
        System.debug('Opportunities found 2: ' + JSON.serializePretty(qualifiedList));
        
        // Only enqueue the email job if there is at least one matching record.
        if(!qualifiedList.isEmpty() || !tsfList.isEmpty()){
            Map<Id, Opportunity> oppUpdates = new Map<Id, Opportunity>();
            for(Opportunity opp : currentOpps){
                if(qualifiedList.contains(opp) || tsfList.contains(opp)){
                    Opportunity updatedOpp = new Opportunity(Id = opp.Id);
                    if(qualifiedList.contains(opp)){
                        updatedOpp.Bpay_Email_sent__c = true;
                    }
                    if(tsfList.contains(opp)){
                        updatedOpp.TSF_receipt_email_sent__c = true;
                    }
                    oppUpdates.put(opp.Id, updatedOpp);
                }
            }
            if(!oppUpdates.isEmpty()){
                update oppUpdates.values();
            }
            
            System.debug('Opportunities found 3: ' + JSON.serializePretty(currentOpps));
           
            System.enqueueJob(new QUE_oppEmail(currentOpps));
        }
    }
    
    
    

    public void oppfilesshare(){
        List<Id> oppidlst = new List<Id>();
        for(Opportunity o : this.opportunities){
            if(o.StageName == 'Closed Won')
                oppidlst.add(o.Id);
        }
        if(!oppidlst.isEmpty()){
            sharefiles(oppidlst);
        }
    } 

    public static void sharefiles(List<Id> oppidlst){
        // Bulk query Investments associated with these opportunities.
        Map<Id, Set<Id>> oppVSinv = new Map<Id, Set<Id>>();
        List<Id> invidlst = new List<Id>();
        for(Investment__c i : [SELECT Id, Opportunity__c FROM Investment__c WHERE Opportunity__c IN :oppidlst]){
            if(!oppVSinv.containsKey(i.Opportunity__c)){
                oppVSinv.put(i.Opportunity__c, new Set<Id>());
            }
            oppVSinv.get(i.Opportunity__c).add(i.Id);
            invidlst.add(i.Id);
        }
        List<ContentDocumentLink> cdlst = new List<ContentDocumentLink>();
        if(!oppVSinv.keySet().isEmpty()){
            cdlst = [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title 
                     FROM ContentDocumentLink WHERE LinkedEntityId IN :oppVSinv.keySet()];
        }
        List<ContentDocumentLink> childidlst = new List<ContentDocumentLink>();
        if(!invidlst.isEmpty()){
            childidlst = [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title 
                          FROM ContentDocumentLink WHERE LinkedEntityId IN :invidlst];
        }
        // Build a map for existing child links.
        Map<Id, Set<Id>> childmap = new Map<Id, Set<Id>>();
        for(ContentDocumentLink c : childidlst){
            if(!childmap.containsKey(c.LinkedEntityId)){
                childmap.put(c.LinkedEntityId, new Set<Id>());
            }
            childmap.get(c.LinkedEntityId).add(c.ContentDocumentId);
        }
        // Create new ContentDocumentLink records as needed.
        List<ContentDocumentLink> cdlinsert = new List<ContentDocumentLink>();
        for(ContentDocumentLink cd : cdlst){
            if(!cd.ContentDocument.Title.containsIgnoreCase('INTERNAL-')){
                for(Id i : oppVSinv.get(cd.LinkedEntityId)){
                    if(childmap.get(i) == null || !childmap.get(i).contains(cd.ContentDocumentId)){
                        ContentDocumentLink c = new ContentDocumentLink();
                        c.ContentDocumentId = cd.ContentDocumentId;
                        c.LinkedEntityId = i;
                        c.ShareType = 'V';
                        c.Visibility = 'AllUsers';
                        cdlinsert.add(c);
                    }
                }
            }
        }
        if(!cdlinsert.isEmpty()){
            insert cdlinsert;
        }
    }

    public void oliCurrentValuesIpdate(){
        if(this.opportunities == null || this.opportunitiesOldMap == null) {
            return;
        }
        List<Id> oppidlst = new List<Id>();
        for(Opportunity o : this.opportunities){
            // Compare current StageName with the old value.
            if(o.StageName == 'Closed Won' && o.StageName != this.opportunitiesOldMap.get(o.Id).get('StageName')){
                oppidlst.add(o.Id);
            }
        }
        if(!oppidlst.isEmpty()){
            List<OpportunityLineItem> olilst = new List<OpportunityLineItem>();
            for(OpportunityLineItem oli : [SELECT Id, Quantity, UnitPrice 
                                            FROM OpportunityLineItem 
                                            WHERE OpportunityId IN :oppidlst]){
                oli.Original_Invested_Quantity__c = oli.Quantity;
                oli.Original_Sales_Price__c = oli.UnitPrice * oli.Quantity;
                olilst.add(oli);
            }
            if(!olilst.isEmpty()){
                update olilst;
            }
        }
    }

    public void updateChildOLIstatus(){
        // Check if maps are provided to avoid NullPointerException
        if(this.opportunitiesOldMap == null || this.opportunitiesNewMap == null) {
            return;
        }
        Set<Id> oppIdset = new Set<Id>();
        for(Opportunity opp : this.opportunities){
            // Ensure we have an old version for comparison
            Opportunity oldOpp = this.opportunitiesOldMap.get(opp.Id);
            if(oldOpp != null &&
               (opp.Approval_Status__c == 'Completed' || opp.Approval_Status__c == 'Rejected') &&
               oldOpp.get('Approval_Status__c') != opp.Approval_Status__c) {
                oppIdset.add(opp.Id);
            }
        }
        if(!oppIdset.isEmpty()){
            List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
            for(OpportunityLineItem oli : [
                SELECT Id, OpportunityId 
                FROM OpportunityLineItem 
                WHERE OpportunityId IN :oppIdset
            ]){
                // Get the new version of the Opportunity for this OLI
                Opportunity newOpp = this.opportunitiesNewMap.get(oli.OpportunityId);
                // Update the Approval_Status__c based on the new Opportunity's status if available
                if(newOpp != null && newOpp.get('Approval_Status__c') == 'Completed'){
                    oli.Approval_Status__c = 'Completed';
                } else {
                    oli.Approval_Status__c = 'Rejected';
                }
                oliList.add(oli);
            }
            if(!oliList.isEmpty()){
                update oliList;
            }
        }
    }
    

    // ----------------------- UPDATED METHOD WITH FOUNDER FILTERING -----------------------
    public void updateProductStatusOnOpportunityClosure(Map<Id, Opportunity> mapNewOpportunity, Map<Id, Opportunity> mapOldOpportunity) {
        // Safely retrieve the 'Founders' record type Id.
        Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName();
        Id foundersRecordTypeId = rtMap.containsKey('Founders') ? rtMap.get('Founders').getRecordTypeId() : null;
        Set<Id> foundersRecordTypeIds = new Set<Id>();
        if (foundersRecordTypeId != null) {
            foundersRecordTypeIds.add(foundersRecordTypeId);
        }
        
        // If mapNewOpportunity is null, exit early.
        if (mapNewOpportunity == null) {
            return;
        }
        
        Map<Id, Opportunity> updatedOpportunities = new Map<Id, Opportunity>();
        Set<Id> soldOutOppSet = new Set<Id>();
    
        for (Id oppId : mapNewOpportunity.keySet()) {
            Opportunity newOpp = mapNewOpportunity.get(oppId);
            // Make sure we have an old version before comparing.
            Opportunity oldOpp = (mapOldOpportunity != null) ? mapOldOpportunity.get(oppId) : null;
            if (oldOpp == null) {
                continue;
            }
            // Process if StageName has changed (and either no 'Founders' record type exists or the opportunity is not a Founder)
            // OR if the Sub_Stage__c has changed.
            if (((newOpp.StageName != oldOpp.StageName && (foundersRecordTypeIds.isEmpty() || !foundersRecordTypeIds.contains(newOpp.RecordTypeId)))
                 || newOpp.Sub_Stage__c != oldOpp.Sub_Stage__c)
                && (newOpp.StageName == LINEITEM_STAGENAME_EOI || newOpp.StageName == LINEITEM_STAGENAME_CONTRACT)) {
                updatedOpportunities.put(oppId, newOpp);
                if (newOpp.StageName == LINEITEM_STAGENAME_CONTRACT) {
                    soldOutOppSet.add(oppId);
                }
            }
        }
        if (!soldOutOppSet.isEmpty()) {
            createTaskOnSoldOutProduct(soldOutOppSet);
        }
        if (!updatedOpportunities.isEmpty()) {
            List<OpportunityLineItem> oppLineItemList = [SELECT Id, Product2Id, OpportunityId, Opportunity.StageName, Opportunity.Sub_Stage__c 
                                                          FROM OpportunityLineItem 
                                                          WHERE OpportunityId IN :updatedOpportunities.keySet()];
            try {
                if (!oppLineItemList.isEmpty()) {
                    // Use a map to track products to update.
                    Map<Id, Product2> toBeUpdatedProductMap = new Map<Id, Product2>();
                    for (OpportunityLineItem oli : oppLineItemList) {
                        String oppStage = oli.Opportunity.StageName;
                        if (oppStage == LINEITEM_STAGENAME_EOI) {
                            if (!toBeUpdatedProductMap.containsKey(oli.Product2Id)) {
                                toBeUpdatedProductMap.put(oli.Product2Id, new Product2(
                                    Id = oli.Product2Id,
                                    Status__c = PRODUCT_STATUS_EXPRESSION_OF_INTREST
                                ));
                            }
                        }
                        if (oppStage == LINEITEM_STAGENAME_CONTRACT) {
                            if (!toBeUpdatedProductMap.containsKey(oli.Product2Id)) {
                                toBeUpdatedProductMap.put(oli.Product2Id, new Product2(
                                    Id = oli.Product2Id,
                                    Status__c = PRODUCT_STATUS_SOLD_OUT
                                ));
                            }
                            if (toBeUpdatedProductMap.containsKey(oli.Product2Id) &&
                                toBeUpdatedProductMap.get(oli.Product2Id).Status__c != PRODUCT_STATUS_SOLD_OUT) {
                                toBeUpdatedProductMap.get(oli.Product2Id).Status__c = PRODUCT_STATUS_SOLD_OUT;
                            }
                        }
                    }
                    if (!toBeUpdatedProductMap.isEmpty()) {
                        Database.SaveResult[] updateResult = Database.update(toBeUpdatedProductMap.values(), false);
                        Set<Id> updatedProductIdSet = new Set<Id>();
                        for (Database.SaveResult sr : updateResult) {
                            if (sr.isSuccess() && toBeUpdatedProductMap.get(sr.getId()).Status__c == PRODUCT_STATUS_SOLD_OUT) {
                                updatedProductIdSet.add(sr.getId());
                            }
                        }
                        if (!updatedProductIdSet.isEmpty()) {
                            List<OpportunityLineItem> finalOppLineItemList = [SELECT Id, Product2Id, OpportunityId 
                                                                               FROM OpportunityLineItem 
                                                                               WHERE Product2Id IN :updatedProductIdSet 
                                                                               AND Opportunity.StageName <> 'Closed Lost'];
                            Set<Id> oppIdToUpdate = new Set<Id>();
                            for (OpportunityLineItem oli : finalOppLineItemList) {
                                if (!mapNewOpportunity.containsKey(oli.OpportunityId)) {
                                    oppIdToUpdate.add(oli.OpportunityId);
                                }
                            }
                            if (!oppIdToUpdate.isEmpty()) {
                                List<Opportunity> tobeUpdatedOpps = new List<Opportunity>();
                                for (Id oppId : oppIdToUpdate) {
                                    tobeUpdatedOpps.add(new Opportunity(
                                        Id = oppId,
                                        StageName = OPPORTUNITY_STAGE_CLOSED_LOST,
                                        Loss_Reasons__c = OPPORTUNITY_LOST_REASON_SOLD_TO_OTHER_PARTY
                                    ));
                                }
                                if (!tobeUpdatedOpps.isEmpty()) {
                                    Database.SaveResult[] updateOppResults = Database.update(tobeUpdatedOpps, false);
                                    for (Database.SaveResult sr : updateOppResults) {
                                        if (!sr.isSuccess()) {
                                            System.debug('failure>>>' + sr.getErrors());
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } catch (Exception e) {
                System.debug('Something went wrong: ' + e.getMessage());
            }
        }
    }
    
    // ---------------------------------------------------------------------------------------

    // ----------------------- NEW METHOD: createTaskOnSoldOutProduct -----------------------
    public void createTaskOnSoldOutProduct(Set<Id> oppsId) {
        // Query OpportunityLineItems for given opportunities.
        Set<Id> prodIdSet = new Set<Id>();
        for(OpportunityLineItem oli : [SELECT Id, Product2Id FROM OpportunityLineItem WHERE OpportunityId IN :oppsId]){
            prodIdSet.add(oli.Product2Id);
        }
        
        // Build tasks for opportunities (excluding those in oppsId) that share these products.
        List<Task> newTaskList = new List<Task>();
        Set<Id> opportunityIdSet = new Set<Id>();
        if(!prodIdSet.isEmpty()){
            for(OpportunityLineItem oli : [SELECT Id, OpportunityId, Opportunity.OwnerId 
                                           FROM OpportunityLineItem 
                                           WHERE Product2Id IN :prodIdSet 
                                           AND OpportunityId NOT IN :oppsId 
                                           AND Opportunity.RecordTypeId = :vcpprecordTypeId 
                                           AND Opportunity.delete_opportunity__c = false]){
                Task tasObj = new Task();
                tasObj.OwnerId = oli.Opportunity.OwnerId;
                tasObj.ActivityDate = System.today() + 1;
                tasObj.Subject = 'This Lot is currently unavailable';
                tasObj.Description = 'This opportunity has been moved to Closed Lost because another opportunity associated with this product is marked as Sold Out. Please try to sell this client another product if available.';
                tasObj.WhatId = oli.OpportunityId;
                newTaskList.add(tasObj);
                opportunityIdSet.add(oli.OpportunityId);
            }
        }
        if(!newTaskList.isEmpty()){
            insert newTaskList;
        }
        if(!opportunityIdSet.isEmpty()){
            updateOpportunities(opportunityIdSet);
        }
    }
    // ---------------------------------------------------------------------------------------

    // ----------------------- UPDATED FUTURE METHOD WITH FOUNDER FILTERING -----------------------
    @future 
    public static void updateOpportunities(Set<Id> oppSet) {
        // Safely retrieve the 'Founders' record type Id.
        Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName();
        Id foundersRecordTypeId = rtMap.containsKey('Founders') ? rtMap.get('Founders').getRecordTypeId() : null;
        
        List<Opportunity> oppList = [SELECT Id, RecordTypeId FROM Opportunity WHERE Id IN :oppSet];
        List<Opportunity> updateOppList = new List<Opportunity>();
        for (Opportunity opp : oppList) {
            if (foundersRecordTypeId == null || opp.RecordTypeId != foundersRecordTypeId) {
                opp.StageName = 'Closed Lost';
                opp.Loss_Reasons__c = 'Product Unavailable';
                updateOppList.add(opp);
            }
        }
        if (!updateOppList.isEmpty()) {
            update updateOppList;
        }
    }

    // ---------------------------------------------------------------------------------------
}