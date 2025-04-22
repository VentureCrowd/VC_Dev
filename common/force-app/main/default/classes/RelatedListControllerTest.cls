/**

**/
@isTest
public with sharing class RelatedListControllerTest {
    @isTest public static void testInit(){
        Account acc = new Account(Name = 'test');
        insert acc;
        Contact cnt = new Contact(LastName = 'test', AccountId = acc.Id);
        insert cnt;
                
        Map<String, Object> requestMap = new Map<String, Object>(); 
        requestMap.put(RelatedListController.FIELDS_PARAM, 'Name, Title, Email, Phone');
        requestMap.put(RelatedListController.RELATED_FIELD_API_NAME_PARAM, 'AccountId');
        requestMap.put(RelatedListController.RECORD_ID_PARAM, acc.Id);
        requestMap.put(RelatedListController.NUMBER_OF_RECORDS_PARAM, 1);
        requestMap.put(RelatedListController.SOBJECT_API_NAME_PARAM, 'Contact');
        requestMap.put(RelatedListController.SORTED_BY_PARAM, 'Name');
        requestMap.put(RelatedListController.SORTED_DIRECTION_PARAM, 'ASC');
                
        String jsonData = RelatedListController.initData(JSON.serialize(requestMap));
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(jsonData);
        List<Object> records = (List<Object>)responseMap.get(RelatedListController.RECORDS_PARAM);
        System.assert(!records.isEmpty());
        String iconName = (String)responseMap.get(RelatedListController.ICON_NAME_PARAM);
        System.assert(String.isNotBlank(iconName));
    }

    @isTest public static void createCreation_Test(){
        Account acc = new Account();
        acc.name = 'Test Acount';
        insert acc;

        Id pricebookId = Test.getStandardPricebookId();
        
        List<Opportunity> oppList = new List<Opportunity>();
        //Opporutnity 1
        Opportunity oppObj = new Opportunity();
        oppObj.name = 'Test1lname';
        oppObj.stageName = 'Why Appt Set Pending';
        oppObj.Pricebook2Id = pricebookId;
        date dt = System.today();
        dt = dt.addDays(5);
        oppObj.delete_opportunity__c = true;
        oppObj.closedate = dt;
        oppObj.Amount = 50000;
        oppList.add(oppObj);

        //Opporutnity 2
        Opportunity oppObj2 = new Opportunity();
        oppObj2.name = 'Test2lname';
        oppObj2.stageName = 'Why Appt Set Pending';
        oppObj2.Pricebook2Id = pricebookId;
        date dt1 = System.today();
        dt1 = dt1.addDays(5);
        oppObj2.delete_opportunity__c = true;
        oppObj2.closedate = dt;
        oppObj2.Amount = 50000;
        oppList.add(oppObj2);

        insert oppList;    
        
        //Create Product
        Product2 oProduct = new Product2(name='Test');
        oProduct.Offer_Launch_Date__c = System.today().addDays(-4);
        insert oProduct;

        //Price Book entry creation
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = oProduct.Id,
            UnitPrice = 12000, IsActive = true);
        insert customPrice;
        
       //Create Opportunity Line item 1
       OpportunityLineItem oppLineItem = new OpportunityLineItem();
       oppLineItem.Product2Id = oProduct.Id;
       oppLineItem.OpportunityId = oppList[0].Id;
       oppLineItem.Quantity = 1;
       oppLineItem.TotalPrice = 10;
       oppLineItem.PricebookEntryId = customPrice.Id;

       //Create Opportunity Line item 2
       OpportunityLineItem oppLineItem2 = new OpportunityLineItem();
       oppLineItem2.Product2Id = oProduct.Id;
       oppLineItem2.OpportunityId = oppList[1].Id;
       oppLineItem2.Quantity = 1;
       oppLineItem2.TotalPrice = 10;
       oppLineItem2.PricebookEntryId = customPrice.Id;
       insert oppLineItem2;


       RelatedListController.createCreation(oppLineItem);
    }

    @isTest
    static void search_should_return_Account_and_Opportunity() {
        Account acc = new Account();
        acc.name = 'Test Acount';
        insert acc;

        Id pricebookId = Test.getStandardPricebookId();
        
        List<Opportunity> oppList = new List<Opportunity>();
        //Opporutnity 1
        Opportunity oppObj = new Opportunity();
        oppObj.name = 'Test1lname';
        oppObj.stageName = 'Why Appt Set Pending';
        oppObj.Pricebook2Id = pricebookId;
        date dt = System.today();
        dt = dt.addDays(5);
        oppObj.delete_opportunity__c = true;
        oppObj.closedate = dt;
        oppObj.Amount = 50000;
        oppList.add(oppObj);

        //Opporutnity 2
        Opportunity oppObj2 = new Opportunity();
        oppObj2.name = 'Test2lname';
        oppObj2.stageName = 'Why Appt Set Pending';
        oppObj2.Pricebook2Id = pricebookId;
        date dt1 = System.today();
        dt1 = dt1.addDays(5);
        oppObj2.delete_opportunity__c = true;
        oppObj2.closedate = dt;
        oppObj2.Amount = 50000;
        oppList.add(oppObj2);

        insert oppList;    
        
        //Create Product
        Product2 oProduct = new Product2(name='Test');
        oProduct.Offer_Launch_Date__c = System.today().addDays(-4);
        insert oProduct;

        //Price Book entry creation
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = oProduct.Id,
            UnitPrice = 12000, IsActive = true);
        insert customPrice;
        
       //Create Opportunity Line item 1
       OpportunityLineItem oppLineItem = new OpportunityLineItem();
       oppLineItem.Product2Id = oProduct.Id;
       oppLineItem.OpportunityId = oppList[0].Id;
       oppLineItem.Quantity = 1;
       oppLineItem.TotalPrice = 10;
       oppLineItem.PricebookEntryId = customPrice.Id;
       insert oppLineItem;

       //Create Opportunity Line item 2
       OpportunityLineItem oppLineItem2 = new OpportunityLineItem();
       oppLineItem2.Product2Id = oProduct.Id;
       oppLineItem2.OpportunityId = oppList[1].Id;
       oppLineItem2.Quantity = 1;
       oppLineItem2.TotalPrice = 10;
       oppLineItem2.PricebookEntryId = customPrice.Id;
       insert oppLineItem2;

       Masterplan__c oMaster = new Masterplan__c();
       oMaster.recordTypeId = Schema.SObjectType.Masterplan__c.getRecordTypeInfosByName().get('Master Plan').getRecordTypeId();
       oMaster.Name = 'Test'; 
       insert oMaster;

       Masterplan__c oStaging = new Masterplan__c();
       oStaging.recordTypeId = Schema.SObjectType.Masterplan__c.getRecordTypeInfosByName().get('Staging Plan').getRecordTypeId();
       oStaging.Name = 'Test2'; 
       oStaging.Master_Plan__c = oMaster.Id; 
       insert oStaging;
       List<String> selectedIds = new List<String> {oMaster.Id};
       RelatedListController.search('Test', selectedIds);

        List<LookupSearchResult> results = new List<LookupSearchResult>();
        String accountIcon = 'standard:account';
        results.add(new LookupSearchResult(oStaging.Id, 'StagginPlan', accountIcon, oStaging.Name, ''));
        results.add(new LookupSearchResult(oMaster.Id, 'StagginPlan', accountIcon, oMaster.Name, ''));
        results.sort();

        LookupSearchResult ls = new LookupSearchResult(oStaging.Id, 'StagginPlan', accountIcon, oStaging.Name, '');
        ls.getId();
        ls.getIcon();
        ls.getSObjectType();
        ls.getTitle();
        ls.getSubtitle();
        
    }
}