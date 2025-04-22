public inherited sharing class OpportunitiesService {
    
    public RecordsWrapper getRecords(Id recordId, Integer pageSize, Integer pageNumber, String sortBy, String sortDirection, List<String> columnNames){
        try{
            OpportunitiesFactory factory = new OpportunitiesFactory();

            return factory.getRecords(recordId, pageSize, pageNumber, sortBy, sortDirection, columnNames);
        }catch(AuraHandledException e){
            throw e;
        }
       
    }

    public Map<String,Object> updateOpportunity(Id recordId, String objectName,Map<String,Object> fieldsToUpdate){
        OpportunitiesFactory factory = new OpportunitiesFactory();

        Map<String,Object> retResult = factory.updateOpportunity(recordId, objectName,fieldsToUpdate,opportunityFieldMapping);

        return retResult;
    }

    public class RecordsWrapper {
        @AuraEnabled public List<sObject> records { get; set; }
        @AuraEnabled public List<AggregateResult> totalRecords { get; set; }

        public RecordsWrapper(List<sObject> records, List<AggregateResult> totalRecords) {
            this.records = records;
            this.totalRecords = totalRecords;
        }
    }

    public static BidiMap opportunityFieldMapping = new BidiMap(new Map<String, String>{
        'comments' => 'Comments__c',
        'callBackReq' => 'Call_back_required__c',
        'founderStatus' => 'Founder_status__c'
    });

    public OpportunityLineItem getProductId(Id oppLineItem) {
            OpportunitiesFactory factory = new OpportunitiesFactory();
            OpportunityLineItem productId = factory.getProductId(oppLineItem);
            return productId;

    }
}