/**

**/
public with sharing class RelatedListController {
    public static final String FIELDS_PARAM = 'fields';
    public static final String NUMBER_OF_RECORDS_PARAM = 'numberOfRecords';
    public static final String RECORD_ID_PARAM = 'recordId';
    public static final String SOBJECT_API_NAME_PARAM = 'sobjectApiName';
    public static final String SOBJECT_LABEL_PARAM = 'sobjectLabel';
    public static final String SOBJECT_LABEL_PLURAL_PARAM = 'sobjectLabelPlural';
    public static final String PARENT_RELATIONSHIP_API_NAME_PARAM = 'parentRelationshipApiName';
    public static final String RELATED_FIELD_API_NAME_PARAM = 'relatedFieldApiName';
    public static final String SORTED_DIRECTION_PARAM = 'sortedDirection';
    public static final String SORTED_BY_PARAM = 'sortedBy';
    public static final String RECORDS_PARAM = 'records';
    public static final String ICON_NAME_PARAM = 'iconName';
    private final static Integer MAX_RESULTS = 5;

    @AuraEnabled
    public static String initData(String jsonData){
        system.debug(jsonData);
        Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(jsonData);  
        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put(RECORDS_PARAM, getRecords(jsonData));
        
        String sobjectApiName = (String)requestMap.get(SOBJECT_API_NAME_PARAM);
        responseMap.put(ICON_NAME_PARAM, getIconName(sobjectApiName));
        String recordId = (String)requestMap.get(RECORD_ID_PARAM);
        String relatedFieldApiName = (String)requestMap.get(RELATED_FIELD_API_NAME_PARAM);
        responseMap.put(PARENT_RELATIONSHIP_API_NAME_PARAM, getParentRelationshipName(recordId, sobjectApiName, relatedFieldApiName));

        Schema.SObjectType sobjectType = Schema.getGlobalDescribe().get(sobjectApiName);
        Schema.DescribeSObjectResult sobjectDescribe = sobjectType.getDescribe();
        responseMap.put(SOBJECT_LABEL_PARAM, sobjectDescribe.getLabel());
        responseMap.put(SOBJECT_LABEL_PLURAL_PARAM, sobjectDescribe.getLabelPlural());
        return JSON.serialize(responseMap);
    }
    
	@AuraEnabled
    public static List<Sobject> getRecords(String jsonData){
		Map<String, Object> root = (Map<String, Object>)JSON.deserializeUntyped(jsonData);  
        String fields = (String)root.get(FIELDS_PARAM);
		// Integer numberOfRecords = (Integer)root.get(NUMBER_OF_RECORDS_PARAM);
        String recordId = (String)root.get(RECORD_ID_PARAM);
		String relatedFieldApiName = (String)root.get(RELATED_FIELD_API_NAME_PARAM);
		String sobjectApiName = (String)root.get(SOBJECT_API_NAME_PARAM);        
		String orderBy = (String)root.get(SORTED_BY_PARAM) + ' ' + (String)root.get(SORTED_DIRECTION_PARAM);        
        
        String query = 'Select '+fields+' From '+sobjectApiName+' WHERE ' +relatedFieldApiName+ '= :recordId ORDER BY ' +orderBy;
        return Database.query(String.escapeSingleQuotes(query));
	}
        
    private static String getParentRelationshipName(Id recordId, String childSobjectApiName, String relatedFieldApiName){
        Schema.DescribeSObjectResult descrRes = recordId.getSObjectType().getDescribe();
        String name;
        for (Schema.ChildRelationship cr: descrRes.getChildRelationships()){ 
            if(cr.getChildSObject().getDescribe().getName() == childSobjectApiName
            && cr.getField().getDescribe().getName() == relatedFieldApiName){
          	 	name = cr.getRelationshipName();
                break;
            }
        }     
        return name;
    }      
    
    @AuraEnabled
    public static String getIconName(String sobjectApiName){
        String iconName;
        List<Schema.DescribeTabSetResult> tabSetDesc = Schema.DescribeTabs();
        List<Schema.DescribeTabResult> tabDesc = new List<Schema.DescribeTabResult>();
        List<Schema.DescribeIconResult> iconDesc = new List<Schema.DescribeIconResult>();

        for(Schema.DescribeTabSetResult tsr : tabSetDesc) { 
            tabDesc.addAll(tsr.getTabs()); 
        }

        for(Schema.DescribeTabResult tr : tabDesc) {
            if( sobjectApiName == tr.getSobjectName() ) {
                if( tr.isCustom() ) {
                    iconDesc.addAll(tr.getIcons());
                } else {
                    iconName = 'standard:' + sobjectApiName.toLowerCase();
                }
            }
        }
        for (Schema.DescribeIconResult ir : iconDesc) {
            if (ir.getContentType() == 'image/svg+xml'){
                iconName = 'custom:' + ir.getUrl().substringBetween('custom/','.svg').substringBefore('_');
                break;
            }
        }
        return iconName;
    }
    
    @AuraEnabled
    public static Boolean createCreation(OpportunityLineItem lineItemRecord){
        Boolean isSuccesful = false;
        try {
            PricebookEntry[] lstProductEntries = [select Id,IsActive, Name,ProductCode,UnitPrice,product2.Type__c from PricebookEntry WHERE product2Id = :lineItemRecord.Product2Id LIMIT 1];
            Id PricebookEntryId;
            Decimal unitPrice;
            if (!lstProductEntries.isEmpty()) {
                if (!lstProductEntries[0].isActive) {
                    lstProductEntries[0].IsActive = true;
                    update lstProductEntries;
                } 
                PricebookEntryId = lstProductEntries[0].Id;
                unitPrice = lstProductEntries[0].UnitPrice;
            } else {
                PricebookEntry ObjPriceBookEntry =  new PricebookEntry();
                ObjPriceBookEntry.Product2Id = lineItemRecord.Product2Id;
                ObjPriceBookEntry.Pricebook2Id = Id.valueOf(System.Label.Standard_Price_Book_Id);
                ObjPriceBookEntry.UnitPrice = 1;
                ObjPriceBookEntry.IsActive = true;
                insert ObjPriceBookEntry;
                PricebookEntryId = ObjPriceBookEntry.Id;
                unitPrice = ObjPriceBookEntry.unitPrice;
            }

           lineItemRecord.PricebookEntryId = PricebookEntryId;
           lineItemRecord.UnitPrice = UnitPrice;
           lineItemRecord.TotalPrice = null;
           insert lineItemRecord;
            isSuccesful =true;
            return isSuccesful;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> search(String searchTerm, List<String> selectedIds) {
        // Prepare query paramters
        searchTerm += '*';

        // Execute search query
        List<List<SObject>> searchResults = [
            FIND :searchTerm
            IN ALL FIELDS
            RETURNING
                Masterplan__c(Id, Name,Master_Plan__c WHERE (Master_Plan__c IN :selectedIds) AND RecordType.Name = 'Staging Plan')
            LIMIT :MAX_RESULTS
        ];

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        String accountIcon = 'standard:account';
        Masterplan__c[] staggingPlanList = (List<Masterplan__c>) searchResults[0];

        for (Masterplan__c oStagging : staggingPlanList) {
            // String subtitle = oStagging.BillingCity == null ? 'Account' : 'Account • ' + account.BillingCity;
            results.add(new LookupSearchResult(oStagging.Id, 'StagginPlan', accountIcon, oStagging.Name, ''));
        }

        // Optionnaly sort all results on title
        results.sort();

        return results;
    }
    
}