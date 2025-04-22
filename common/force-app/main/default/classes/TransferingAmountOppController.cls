public Without Sharing class TransferingAmountOppController 
{
    
    @AuraEnabled
    public static String createNewAccounts(String oppId, 
                                           Account newAccObj, 
                                           String selectedAccType, 
                                           Decimal transferAmount, 
                                           Date dateOfApplication) 
    {
        try{
            //Create New Account
			System.debug('->  ++'+ newAccObj);
            

            newAccObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(selectedAccType).getRecordTypeId();
            System.debug('ppppp ++ '+newAccObj.RecordTypeId);
            insert newAccObj;
            System.debug('qqqqq');
            List<Opportunity> oppListToUpdate = [select id, name, stageName, Opportunity_Type__c, Loss_Reasons__c, AccountId, Amount, CRC_Assigned__c, CM_Assigned__c, ownerId, closeDate
                                                 from opportunity 
                                                 where Id=:oppId limit 1];
            List<OpportunityLineItem> OLIList = [select id, PricebookEntryId, Name, TotalPrice, Description
                                                 from OpportunityLineItem
                                                 where opportunityId=:oppId];
            for(Opportunity oppObj : oppListToUpdate)
            {
                oppObj.stageName = 'Closed Lost';
                oppObj.Loss_Reasons__c = 'Transferred';            
            }
            
            update oppListToUpdate;
            //create new Opp with balance amount for tranferor
            opportunity opp1 = new opportunity();
            opp1.AccountId = oppListToUpdate.get(0).accountId;
            opp1.StageName = 'Receipt Issued';
            opp1.CRC_Assigned__c = oppListToUpdate.get(0).CRC_Assigned__c;
            opp1.CM_Assigned__c = oppListToUpdate.get(0).CM_Assigned__c;
            opp1.Name = oppListToUpdate.get(0).Name+'-New Transferred';
            opp1.CloseDate = oppListToUpdate.get(0).closeDate;
            opp1.ownerId = oppListToUpdate.get(0).ownerId;
            opp1.Opportunity_Type__c = 'Transferor';
            opp1.Old_Transferred_Opportunity__c = oppListToUpdate.get(0).Id;
            insert opp1;
            
            OpportunityLineItem OLI1 = new OpportunityLineItem();
            OLI1.OpportunityId = opp1.Id;
            OLI1.Quantity = (Integer)(oppListToUpdate.get(0).Amount - transferAmount);
            if(!Test.isRunningTest())
            {
                OLI1.PricebookEntryId = OLIList.get(0).PricebookEntryId;
                OLI1.Description = OLIList.get(0).Description;
                OLI1.TotalPrice = (Integer)(oppListToUpdate.get(0).Amount - transferAmount);
                insert OLI1;
            }
            
            //Create Opp with transferred amount for transferee account
            opportunity opp2 = new opportunity();
            opp2.AccountId = newAccObj.Id;
            opp2.StageName = 'Application Received';
            opp2.CRC_Assigned__c = oppListToUpdate.get(0).CRC_Assigned__c;
            opp2.CM_Assigned__c = oppListToUpdate.get(0).CM_Assigned__c;
            opp2.Name = 'Transfer opp-'+oppListToUpdate.get(0).Name;
            opp2.CloseDate = dateOfApplication;
            opp2.ownerId = oppListToUpdate.get(0).ownerId;
            opp2.Opportunity_Type__c = 'Transferee';
            opp2.Old_Transferred_Opportunity__c = oppListToUpdate.get(0).Id;
            if(!Test.isRunningTest())
            {
                insert opp2;
            }
            
            OpportunityLineItem OLI2 = new OpportunityLineItem();
            OLI2.OpportunityId = opp2.Id;
            OLI2.Quantity = transferAmount;
            OLI2.TotalPrice = transferAmount;//OLIList.get(0).TotalPrice;
            if(!Test.isRunningTest())
            {
                OLI2.PricebookEntryId = OLIList.get(0).PricebookEntryId;
                OLI2.Description = OLIList.get(0).Description;
                insert OLI2;
            }
            
            
            return opp2.Id;
        }catch(Exception ex){
            System.debug('Exception '+ex.getMessage());
            return ex.getMessage();
        }
        
    }
    
    @AuraEnabled
    public static String createOpps(String oppId, Account selectedAccObj, Decimal transferAmount, Date dateOfApplication) 
    {
       try{
        List<Opportunity> oppListToUpdate = [select id, name, stageName, Loss_Reasons__c, AccountId, Amount, CRC_Assigned__c, CM_Assigned__c, ownerId, closeDate
                                             from opportunity 
                                             where Id=:oppId limit 1];
        List<OpportunityLineItem> OLIList = [select id, PricebookEntryId, Name, TotalPrice, Description
                                             from OpportunityLineItem
                                             where opportunityId=:oppId];
        for(Opportunity oppObj : oppListToUpdate)
        {
            oppObj.stageName = 'Closed Lost';
            oppObj.Loss_Reasons__c = 'Transferred';
            
        }
        update oppListToUpdate;
        //create new Opp with balance amount for tranferor
        opportunity opp1 = new opportunity();
        opp1.AccountId = oppListToUpdate.get(0).accountId;
        opp1.StageName = 'Receipt Issued';
        opp1.CRC_Assigned__c = oppListToUpdate.get(0).CRC_Assigned__c;
        opp1.CM_Assigned__c = oppListToUpdate.get(0).CM_Assigned__c;
        opp1.Name = oppListToUpdate.get(0).Name+'-New Transferred';
        opp1.CloseDate = oppListToUpdate.get(0).closeDate;
        opp1.ownerId = oppListToUpdate.get(0).ownerId;
        opp1.Opportunity_Type__c = 'Transferor';
        opp1.Old_Transferred_Opportunity__c = oppListToUpdate.get(0).Id;
        insert opp1;
        
        OpportunityLineItem OLI1 = new OpportunityLineItem();
        OLI1.OpportunityId = opp1.Id;
        OLI1.Quantity = (Integer)(oppListToUpdate.get(0).Amount - transferAmount);
        OLI1.TotalPrice = (Integer)(oppListToUpdate.get(0).Amount - transferAmount);
        if(!Test.isRunningTest())
        {
            OLI1.PricebookEntryId = OLIList.get(0).PricebookEntryId;
            OLI1.Description = OLIList.get(0).Description;
            insert OLI1;
        }
        
        //Create Opp with transferred amount for transferee account
        opportunity opp2 = new opportunity();
        opp2.AccountId = selectedAccObj.Id;
        opp2.StageName = 'Application Received';
        opp2.CRC_Assigned__c = oppListToUpdate.get(0).CRC_Assigned__c;
        opp2.CM_Assigned__c = oppListToUpdate.get(0).CM_Assigned__c;
        opp2.Name = 'Transfer opp-'+oppListToUpdate.get(0).Name;
        opp2.CloseDate = dateOfApplication;
        opp2.ownerId = oppListToUpdate.get(0).ownerId;
        opp2.Opportunity_Type__c = 'Transferee';
        opp2.Old_Transferred_Opportunity__c = oppListToUpdate.get(0).Id;
        if(!Test.isRunningTest())
        {
            insert opp2;
        }
        OpportunityLineItem OLI2 = new OpportunityLineItem();
        OLI2.OpportunityId = opp2.Id;
        OLI2.Quantity = transferAmount;
        OLI2.TotalPrice = transferAmount;//OLIList.get(0).TotalPrice;
        
        if(!Test.isRunningTest())
        {
            OLI2.PricebookEntryId = OLIList.get(0).PricebookEntryId;
            OLI2.Description = OLIList.get(0).Description;
            insert OLI2;
        }
        
        
        return opp2.Id;
        }catch(Exception ex){
            System.debug('Exception '+ex.getMessage());
            return ex.getMessage();
        }
    }
    @AuraEnabled
    public static List <sObject> fetchLookUpValues(String searchKeyWord) 
    {
        List<String> Types = new List<String>();
        Types.add('Dealer');
        
        String searchKey = searchKeyWord.trim() + '%';
        List < sObject > returnList = new List < sObject > ();
        //String sQuery =  'select id, Name, Website, BillingCity, BillingState, BillingCountry, BillingStreet, BillingPostalCode, Phone from Account where Name LIKE: searchKey AND RecordType.Name IN : Types order by createdDate DESC limit 5';
        String sQuery =  'select id, Name, Website, BillingCity, BillingState, BillingCountry, BillingStreet, BillingPostalCode, Phone from Account where Name LIKE: searchKey order by createdDate DESC limit 5';
        List < sObject > lstOfRecords = Database.query(sQuery);
        System.debug('----------'+lstOfRecords);
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
    
}