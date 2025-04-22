public without sharing class InvestController {
    public static String recordId;
    public static String family{get;set;}
    public static String investingAsName{get;set;}
    public static String investingAs{get;set;}
    public static String userName{get;set;}
    public static decimal amount{get;set;}
    public static decimal quantity{get;set;}
    public static String address{get;set;}    
    public static Product2 product{get;set;}
    public static OpportunityLineItem oppInfo{get;set;}
    public InvestController() {
        amount = decimal.valueOf(Apexpages.currentPage().getparameters().get('amount'));
        quantity = decimal.valueOf(Apexpages.currentPage().getparameters().get('quantity'));
        recordId = Apexpages.currentPage().getparameters().get('id');
        family =  Apexpages.currentPage().getparameters().get('family');
        investingAs = Apexpages.currentPage().getparameters().get('investingAs').replace('+', ' ');
        if(!Test.isRunningTest()){
            fetchRecordDetails(recordId);
        }
        
    }
    // to show the data on Invest page of community
    @AuraEnabled
    public static String getInvestmentInfo(String recordId){
        String result='Failure';
        try{
            Map<ID, Product2> prodInfo = new Map<ID, Product2>([SELECT id,Name,Target_Market_Determination__c,Company__c,Trust_Deed_Link__c,Investor_Contribution_Fee__c, Trust_Deed_Name__c ,Trust_Deed_Text__c ,Trustee__c ,DisplayUrl,IM_PDS__c,AFSL_Licence__c,Information_Memorandum__c,IM_PDS_CSF_Offer__c,Nominee__c,
                                                                General_CSF_Risk_Warning__c,VentureCrowd_Group__c ,VentureCrowd_Fee_Text__c , Investment_Contract__c,Issuer__c, VentureCrowd__c, Currency__c,Type__c,Finacial_Services_Guide__c,General_Warnig_Statement__c,PDS_Part_1__c,PDS_Part_2__c,TMDD__c,General_Risk_Warning__c,Prospectus_Document__c,
                                                                Minimum_Investment__c,Maximum_Investment__c,Investment_Contract_Text__c,Unit_Holder_Proportion__c ,Family,ProductCode,Fully_Funded__c,Wholesale_Direct__c  FROM product2 WHERE Id = :recordId]);
            List<OpportunityLineItem> oppInfo = [select id,Quantity,UnitPrice,TotalPrice,Product2Id,opportunityid, opportunity.Amount, opportunity.account.name, opportunity.account.PersonMailingStreet, opportunity.account.PersonMailingCity, opportunity.account.PersonMailingState, opportunity.account.PersonMailingPostalCode, opportunity.account.PersonMailingCountry from OpportunityLineItem where Product2Id in :prodInfo.keyset() limit 1];
            List<PricebookEntry> priceBookList = [select id,UnitPrice from PricebookEntry where product2Id in :prodInfo.keyset()];
            List<User> uList = [select id,Name,SmallPhotourl,Contact.Name, Contact.accountId,Contact.MailingStreet,Contact.MailingCity,Contact.MailingState,Contact.MailingPostalCode,Contact.MailingCountry  from User where Id = :UserInfo.getUserId()];
            List<Account> acc = [SELECT Id, Contact_Id__pc,Name,Wholesale__pc ,EIC_Startup__pc  FROM Account WHERE Id =: uList[0].Contact.accountId];
            List<AccountContactRelation> relatedAccountList = [SELECT AccountId, Account.Name, Account.PersonMailingStreet, account.PersonMailingPostalCode, Account.PersonMailingCity, Account.PersonMailingState,
                                                               Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode, Account.BillingCountry,
                                                               Account.IsPersonAccount, Id,Account.Active__c,Account.Account_Created_via_Portal__c FROM AccountContactRelation where contactid =: acc[0].Contact_Id__pc];
            Set<Id> accIdset = new Set <Id>();
            accIdset.add(acc[0].Id);
            for(AccountContactRelation acr : relatedAccountList){
                accIdset.add(acr.AccountId);
            }
            Map<Id,Account> accmap = new Map<Id,Account>([SELECT Id,Name,(SELECT Id FROM Memberships__r WHERE Membership_Status__c = 'Active' AND Type__c = 'Platinum Partner') FROM Account WHERE Id in : accIdset]);
            Boolean b = accmap.get(acc[0].Id).Memberships__r == NULL || accmap.get(acc[0].Id).Memberships__r.isEmpty();
            Map<Id,Boolean> accMembershipmap = new Map<Id,Boolean>();
            for(Account ac : accmap.values()){
                accMembershipmap.put(ac.Id,b);
            }
            Map<String,Object> investInfo = new Map<String,Object>{
                'prodinfo' => prodInfo.values(),
                    'OppDetail' => oppInfo,
                    'uinfo' => uList,
                    'account'=>acc,
                    'relatedAccountList' => relatedAccountList,
                    'priceBookInfo'=> priceBookList,
                    'accMembershipmap'=> accMembershipmap
                    };
                        result = JSON.serialize(investInfo);   
        } catch(Exception e){
            
        } finally{
            
        }
        return result;
    }  
    @AuraEnabled
    public static String createOpportunity(String recordId, String amount, String quantity, String totalAmount, Boolean reqtoInvest, String investingAs, String donationamount, String contributionfee, Map<String, Object> utmmap) {
        try {
            Decimal donationAmountDec = Decimal.valueOf(donationamount);
            Decimal totalAmountDec = Decimal.valueOf(totalAmount) - donationAmountDec - Decimal.valueOf(contributionfee);

            Product2 product = [SELECT Id, Name, Trust_Deed_Link__c, Trust_Deed_Name__c, Trust_Deed_Text__c, Trustee__c, DisplayUrl, IM_PDS__c, Type__c, Legal_Name__c, General_CSF_Risk_Warning__c, VentureCrowd_Group__c, VentureCrowd_Fee_Text__c, Investment_Contract__c, Issuer__c, VentureCrowd__c, Currency__c, Minimum_Investment__c, Maximum_Investment__c, Investment_Contract_Text__c, Unit_Holder_Proportion__c, Family 
                                 FROM Product2 WHERE Id = :recordId LIMIT 1];

            User currentUser = [SELECT Id, ContactId, AccountId, Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

            Account investingAccount = [SELECT Id, Name, OwnerId, Web_Source__pc, PersonLeadSource FROM Account WHERE Id = :investingAs LIMIT 1];

            Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('VC').getRecordTypeId();

            Opportunity opportunity = new Opportunity();
            
            if(investingAccount.PersonLeadSource != null && !String.isBlank(investingAccount.PersonLeadSource)){
                opportunity.LeadSource = investingAccount.PersonLeadSource;
            }else{
                opportunity.LeadSource = 'VC Website Organic';

            }

            if(investingAccount.Web_Source__pc != null && !String.isBlank(investingAccount.Web_Source__pc) ){
                opportunity.Web_Source__c = investingAccount.Web_Source__pc;
            }else{
                opportunity.Web_Source__c = 'The form url with parameters';

            }
            
            opportunity.Name = (investingAccount.Name.length() > 55 ? investingAccount.Name.substring(0, 52) + '...' : investingAccount.Name) + '-' + (product.Name.length() > 55 ? product.Name.substring(0, 52) + '...' : product.Name);
            opportunity.AccountId = investingAccount.Id;
            opportunity.StageName = 'Application Received';
            opportunity.CloseDate = System.today();
            opportunity.Invested_Product_ADMIN_FIELD__c = recordId;
            opportunity.Contribution_Fee_Original__c = Decimal.valueOf(contributionfee);
            opportunity.VentureCrowd_Fee__c = Decimal.valueOf(contributionfee);
            populateValuesFromMap(opportunity, utmmap);

            if (donationAmountDec > 0) {
                opportunity.Donation__c = true;
                opportunity.Donation_Amount__c = donationAmountDec;
            }

            if (Test.isRunningTest()) {
                opportunity.OwnerId = UserInfo.getUserId();
            } else if (investingAccount != null) {
                opportunity.OwnerId = investingAccount.OwnerId;
            }

            opportunity.Req_to_Invest_Under_Different_Account__c = reqtoInvest;
            insert opportunity;

            PricebookEntry priceBookEntry = [SELECT Id, UnitPrice FROM PricebookEntry WHERE Product2Id = :recordId LIMIT 1];

            OpportunityLineItem oppLineItem = new OpportunityLineItem();
            oppLineItem.UnitPrice = priceBookEntry.UnitPrice;
            oppLineItem.PricebookEntryId = priceBookEntry.Id;
            oppLineItem.OpportunityId = opportunity.Id;
            oppLineItem.Contribution_Fee__c = Decimal.valueOf(contributionfee);
            oppLineItem.Contribution_Fee_Original__c = Decimal.valueOf(contributionfee);
            oppLineItem.Quantity = Decimal.valueOf(quantity);
            insert oppLineItem;

            opportunity.Invested_Opp_Prod_ADMIN__c = oppLineItem.Id;
            opportunity.Associated_Product_Type__c = product.Type__c;
            update opportunity;

            String url = '/apex/GeneratePDFforInvest?id=' + recordId + '&family=' + product.Family + '&amount=' + totalAmountDec + '&investingAs=' + investingAs + '&quantity=' + quantity;
            PageReference pageRef = new PageReference(url);
            Blob ret;

            if (!Test.isRunningTest()) {
                ret = pageRef.getContent();
            } else {
                ret = Blob.valueOf('TEST');
            }

            String base64 = EncodingUtil.base64Encode(ret);
            String fileTitle = 'Trust Deed ' + product.Name;
            List<ContentDocumentLink> trustDeedFiles = [SELECT Id, LinkedEntityId, LinkedEntity.Name, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId = :product.Id AND ContentDocument.Title = :fileTitle LIMIT 1];

            if (trustDeedFiles.size()>0) {
                ContentDocumentLink trustDeedFile = trustDeedFiles[0];

                ContentDocumentLink trustDeedLink = new ContentDocumentLink();
                trustDeedLink.ContentDocumentId = trustDeedFile.ContentDocumentId;
                trustDeedLink.LinkedEntityId = opportunity.Id;
                trustDeedLink.ShareType = 'V';
                insert trustDeedLink;
            }

            ContentVersion contentVersion = new ContentVersion();
            contentVersion.VersionData = EncodingUtil.base64Decode(base64);
            
            Opportunity getOppData = [SELECT Id,Opportunity_ID__c,Related_Product_Code__c FROM Opportunity WHERE Id=:opportunity.id  LIMIT 1];

            String fileTitleWithDetails = 'Investment_Contract - ' + investingAccount.Name + ' - ' + getOppData.Opportunity_ID__c + ' ' + getOppData.Related_Product_Code__c + ' ' + product.Legal_Name__c + '.pdf';
            contentVersion.Title = fileTitleWithDetails.length() > 250 ? fileTitleWithDetails.substring(0, 250) + '...' : fileTitleWithDetails;
            contentVersion.PathOnClient = 'InvestmentContractDetails.pdf';
            insert contentVersion;

            Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1].ContentDocumentId;

            ContentDocumentLink contentDocLink = new ContentDocumentLink();
            contentDocLink.ContentDocumentId = contentDocumentId;
            contentDocLink.LinkedEntityId = opportunity.Id;
            contentDocLink.ShareType = 'I';
            contentDocLink.Visibility = 'AllUsers';
            insert contentDocLink;

            ContentDistribution contentDist = new ContentDistribution();
            contentDist.Name = 'InvestmentContractDetails';
            contentDist.ContentVersionId = contentVersion.Id;
            contentDist.PreferencesAllowViewInBrowser = true;
            contentDist.PreferencesLinkLatestVersion = true;
            contentDist.PreferencesNotifyOnVisit = false;
            contentDist.PreferencesPasswordRequired = false;
            contentDist.PreferencesAllowOriginalDownload = true;
            insert contentDist;

            return 'success';
        } catch (Exception ex) {
            logException(ex, recordId, amount, quantity, totalAmount, reqtoInvest, investingAs, donationamount, contributionfee, utmmap);
            return 'failure';
        }
    }

    private static void logException(Exception ex, String recordId, String amount, String quantity, String totalAmount, Boolean reqtoInvest, String investingAs, String donationamount, String contributionfee, Map<String, Object> utmmap) {
        Map<String, Object> inParamsMap = new Map<String, Object>();
        inParamsMap.put('recordID', recordId);
        inParamsMap.put('amount', amount);
        inParamsMap.put('quantity', quantity);
        inParamsMap.put('totalAmount', totalAmount);
        inParamsMap.put('reqtoInvest', String.valueOf(reqtoInvest));
        inParamsMap.put('investingAs', investingAs);
        inParamsMap.put('donationamount', donationamount);
        inParamsMap.put('contributionfee', contributionfee);

        if (utmmap != null) {
            for (String ukey : utmmap.keySet()) {
                inParamsMap.put(ukey, utmmap.get(ukey));
            }
        }

        logMsgUtility.logMessage(ex, 'InvestController', 'Invest Page', 'createOpportunity', inParamsMap);
    }
    // for generating PDF
    public static void fetchRecordDetails(String recordId){
        try {
            Map<ID, Product2> prodInfo = new Map<ID, Product2>([select id,Name,Company__c,Trust_Deed_Link__c,Trust_Deed_Name__c ,Trust_Deed_Text__c ,Trustee__c ,DisplayUrl,IM_PDS__c,IM_PDS_CSF_Offer__c,Nominee__c,
                                                                General_CSF_Risk_Warning__c,VentureCrowd_Group__c ,VentureCrowd_Fee_Text__c , Investment_Contract__c,Issuer__c, VentureCrowd__c, Currency__c, 
                                                                Minimum_Investment__c,Maximum_Investment__c,Investment_Contract_Text__c,Unit_Holder_Proportion__c ,Family,Type__c from product2 where Id = :recordId]);
            User uList = [select id,Name,SmallPhotourl,Contact.Name,ContactId, Contact.MailingStreet,Contact.MailingCity,Contact.MailingState,Contact.MailingPostalCode,Contact.MailingCountry  from User where Id = :UserInfo.getUserId()];
            Account acc = [SELECT Id, Name,PersonMailingStreet, PersonMailingCity, PersonMailingState, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry,
                           IsPersonAccount, PersonMailingPostalCode, PersonMailingCountry FROM Account 
                           WHERE Id =: investingAs];
            if(uList.ContactId != null) {
                userName = uList.Contact.Name;
            }
            if(uList.ContactId != null && uList.Contact.MailingStreet != null) {
                address = uList.Contact.MailingStreet + ' ';
            }
            if(uList.ContactId != null && uList.Contact.MailingCity != null) {
                address = address + uList.Contact.MailingCity+ ' ';
            }
            if(uList.ContactId != null && uList.Contact.MailingState != null) {
                address = address + uList.Contact.MailingState + ' ';
            }
            if(uList.ContactId != null && uList.Contact.MailingPostalCode != null) {
                address = address + uList.Contact.MailingPostalCode + ' ';
            }
            if(uList.ContactId != null && uList.Contact.MailingCountry != null) {
                address = address + uList.Contact.MailingCountry + ' ';
            }
			investingAsName = acc.Name;
            product = prodInfo.Values(); 
            oppInfo = [select id,Quantity,UnitPrice,TotalPrice,Product2Id,opportunityid, opportunity.Amount, opportunity.account.name from OpportunityLineItem where Product2Id in :prodInfo.keyset() limit 1];
        }catch(Exception ex) {
            system.debug('exception :'+ex.getMessage()+'stackTrace'+ex.getStackTraceString());
        }
    }
    public static void populatevaluesfromMap(sobject sobj, Map<string,Object> datmap){
        for(string s : datmap.keyset()){
            if(datmap.get(s) <> NULL && datmap.get(s) <> 'null')
            sobj.put(s,datmap.get(s));
        }
    }
    public class customexception extends exception{}
    //to get data for invest thankyou page
    @AuraEnabled
    public static Product2 getProddetails(Id recordId){
        return [SELECT Id,DisplayUrl,Name FROM Product2 WHERE Id = :recordId];
    }
}