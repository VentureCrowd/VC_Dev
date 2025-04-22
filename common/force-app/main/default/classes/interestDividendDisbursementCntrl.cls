public without sharing class interestDividendDisbursementCntrl {
    @AuraEnabled
    public static List<selOptions> availableProdOptns(){
        Map<Id,string> prodIdVsName = new Map<Id,string>();
        List<selOptions> retopnslst = new List<selOptions>();
        for(Product2 p : [SELECT Id,Name,(SELECT Id,Name FROM Opportunities__r WHERE StageName ='Closed Won') FROM Product2]){
            if(!p.Opportunities__r.isEmpty())
            retopnslst.add(new selOptions(p.Name,p.Id));
        }
        return retopnslst;
    }
    @AuraEnabled
    public static retwrapper getProdsetails(Id prodID){
        Product2 prod = [SELECT Id,Name,Return_Type__c,Fixed_Returns__c, Forecast_Returns__c,Monthly_Distributions__c,CreatedDate,(SELECT Id,Name,Active__c,End_Date__c,Start_Date__c,List_Price__c FROM Pricebook_Entry_Logs__r ORDER BY Name DESC),(SELECT Id,UnitPrice FROM PricebookEntries WHERE IsActive = true),(SELECT Id,Active__c,Start_Date__c,End_Date__c,Name,Returns_Percentage__c FROM ROI_Log__r ORDER BY Name DESC) FROM Product2 WHERE Id =:prodID];
        retwrapper retwrap = new retwrapper();
        retwrap.prod = prod;
        List<Opportunity> opplst = [SELECT Id,Name,Unit_Certificate_Amount__c,Unit_Cert_Issued__c,Invested_Product_ADMIN_FIELD__c,Invested_Product_ADMIN_FIELD__r.Fixed_Returns__c,(SELECT Id,Name,End_Date__c FROM Interest_Dividend_Transaction_Log__r ORDER BY createddate desc LIMIT 1),(SELECT Id,Quantity,UnitPrice FROM OpportunityLineItems) FROM opportunity WHERE StageName ='Closed Won' AND Invested_Product_ADMIN_FIELD__c = :prodID LIMIT 200];
        retwrap.prod = prod;
        retwrap.opplst = opplst;
        return retwrap;
    }

    public class selOptions{
        @AuraEnabled public string label;
        @AuraEnabled public string value;
        public selOptions(string label,string value){
            this.label = label;
            this.value = value;
        }
    }
    public class retwrapper{
        @AuraEnabled public Product2 prod;
        @AuraEnabled public List<Opportunity> opplst;
    }
    @AuraEnabled
    public static void createFunddisuirsment(Id prodId, string endate, string jsonstr){
        List<localwrapper1> wraplst = (List<localwrapper1>) JSON.deserialize(jsonstr,List<localwrapper1>.class);
        Interest_Dividend_Disbursement__c disbursemnet = new Interest_Dividend_Disbursement__c();
        disbursemnet.End_Date__c = dateformatter(endate);
        disbursemnet.Product__c = prodId;
        insert disbursemnet;
        Map<Id,Id> oppIdVSlogId = new Map<Id,Id>();
        list<Interest_Dividend_Transaction_Log__c> loglst = new list<Interest_Dividend_Transaction_Log__c>();
        for(localwrapper1 wrap : wraplst){
            Interest_Dividend_Transaction_Log__c log = new Interest_Dividend_Transaction_Log__c();
            log.Days_included_in_Calculation__c = wrap.dayscnt;
            log.Opportunity__c = wrap.oppId;
            log.Interest__c = wrap.totalint;
            log.Interest_Dividend_Disbursement__c = disbursemnet.Id;
            log.End_Date__c = dateformatter(wrap.enddate);
            log.Start_Date__c = dateformatter(wrap.startdate);
            loglst.add(log);
        }
        insert loglst;
        List<Interest_Dividend_Transaction_Log_Detail__c> detaillst = new list<Interest_Dividend_Transaction_Log_Detail__c>();
        for(Interest_Dividend_Transaction_Log__c log : loglst){
            oppIdVSlogId.put(log.Opportunity__c,log.Id);
        }
        for(localwrapper1 wrap1 : wraplst){
            for(localwrapper2 wrap2 : wrap1.children){
                Interest_Dividend_Transaction_Log_Detail__c detail = new Interest_Dividend_Transaction_Log_Detail__c();
                detail.Interest_Dividend_Transaction_Log__c = oppIdVSlogId.get(wrap2.opporId);
                detail.End_Date__c = dateformatter(wrap2.enddate);
                detail.Start_Date__c = dateformatter(wrap2.startdate);
                detail.Interest__c = wrap2.totalint;
                detail.Investment_Value__c = wrap2.totalworth;
                detail.Number_of_Days__c = wrap2.dayscnt;
                detail.Returns_Percentage__c = wrap2.returnspercentage;
                detaillst.add(detail);
            }
        }
        insert detaillst;
    }
    public static Date dateformatter(string dat){
        List<String> datlst = dat.split('-');
        return Date.newInstance(Integer.valueof(datlst[2]),Integer.valueof(datlst[1]),Integer.valueof(datlst[0]));
    }
    public class localwrapper1{
        @AuraEnabled public Integer dayscnt;
        @AuraEnabled public decimal totalint;
        @AuraEnabled public Id oppId;
        @AuraEnabled public string startdate;
        @AuraEnabled public string enddate;
        @AuraEnabled public List<localwrapper2> children;
    }
    public class localwrapper2{
        @AuraEnabled public string startdate;
        @AuraEnabled public string enddate;
        @AuraEnabled public decimal totalworth;
        @AuraEnabled public Integer dayscnt;
        @AuraEnabled public decimal totalint;
        @AuraEnabled public decimal returnspercentage;
        @AuraEnabled public Id opporId;
    }
    @AuraEnabled
    public static Map<string,object>  getProddetails(Id ProdId){
        Map<string,object> retobj = new Map<string,object>();
        Product2 prod = [SELECT Id,Name,(SELECT Id,UnitPrice FROM PricebookEntries WHERE IsActive = true) FROM Product2 WHERE Id = :ProdId];
        retobj.put('prodName',prod.Name);
        retobj.put('currentprice',prod.PricebookEntries[0].UnitPrice);
        return retobj;
    }
    @AuraEnabled
    public static void updatePriceBookEntry(Id ProdId,Decimal newListprice){
        Product2 prod = [SELECT Id,Name,createdDate,(SELECT Id,UnitPrice FROM PricebookEntries WHERE IsActive = true),(SELECT Id,Name,Active__c,End_Date__c,Start_Date__c FROM Pricebook_Entry_Logs__r ORDER BY Name DESC) FROM Product2 WHERE Id = :ProdId];
        PricebookEntry pe = new PricebookEntry(Id = prod.PricebookEntries[0].Id);
        pe.UnitPrice = newListprice;
        update pe;
        List<Pricebook_Entry_Log__c> pelst = new List<Pricebook_Entry_Log__c>();
        if(prod.Pricebook_Entry_Logs__r.isEmpty()){
            Pricebook_Entry_Log__c pe1 = new Pricebook_Entry_Log__c();
            pe1.Active__c = false;
            pe1.Start_Date__c = prod.createdDate;
            pe1.End_Date__c = system.NOW();
            pe1.Product__c = prod.Id;
            pe1.List_Price__c = prod.PricebookEntries[0].UnitPrice;
            pelst.add(pe1);
            Pricebook_Entry_Log__c pe2 = new Pricebook_Entry_Log__c();
            pe2.Active__c = true;
            pe2.Start_Date__c = system.NOW();
            pe2.Product__c = prod.Id;
            pe2.List_Price__c = newListprice;
            pelst.add(pe2);
        }else{
            Pricebook_Entry_Log__c pe1 = new Pricebook_Entry_Log__c(Id=prod.Pricebook_Entry_Logs__r[0].Id);
            pe1.Active__c = false;
            pe1.End_Date__c = system.NOW();
            pelst.add(pe1);
            Pricebook_Entry_Log__c pe2 = new Pricebook_Entry_Log__c();
            pe2.Active__c = true;
            pe2.Start_Date__c = system.NOW();
            pe2.Product__c = prod.Id;
            pe2.List_Price__c = newListprice;
            pelst.add(pe2);
        }
        upsert pelst;
    }
}