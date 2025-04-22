public class CollectionIndexAccessor {
    // Defines the structure of the input expected from the Flow
    public class IndexRequest {
        @InvocableVariable(label='Index')
        public Integer index;

        @InvocableVariable(label='Account List')
        public List<String> accounts;

        @InvocableVariable(label='Amount List')
        public List<String> amounts;

        @InvocableVariable(label='Tax Rate List')
        public List<String> taxRates;
    }

    // Defines the structure of the response to be sent back to the Flow
    public class IndexResponse {
        @InvocableVariable
        public String account;

        @InvocableVariable
        public String amount;

        @InvocableVariable
        public String taxRate;
    }

    @InvocableMethod
    public static List<IndexResponse> getItemAtIndex(List<IndexRequest> requests) {
        List<IndexResponse> results = new List<IndexResponse>();
        for (IndexRequest req : requests) {
            IndexResponse res = new IndexResponse();
            if(req.index >= 0 && req.index < req.accounts.size()) {
                res.account = req.accounts[req.index];
                res.amount = req.amounts[req.index];
                res.taxRate = req.taxRates[req.index];
            }
            results.add(res);
        }
        return results;
    }
}