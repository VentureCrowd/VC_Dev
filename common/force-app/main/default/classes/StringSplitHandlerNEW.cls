public class StringSplitHandlerNEW {
    public class Request {
        @InvocableVariable(required=true)
        public String descriptions;
        @InvocableVariable(required=false)
        public String accounts;
        @InvocableVariable(required=true)
        public String amounts;
        @InvocableVariable(required=false)
        public String taxRates;
    }

    public class Result {
        @InvocableVariable
        public List<String> descriptions;
        @InvocableVariable
        public List<String> accounts;
        @InvocableVariable
        public List<String> amounts;
        @InvocableVariable
        public List<String> taxRates;
    }

    @InvocableMethod
    public static List<Result> splitTransactionItems(List<Request> requests) {
        List<Result> results = new List<Result>();
        for (Request req : requests) {
            Result res = new Result();
            res.descriptions = new List<String>(req.descriptions.split(','));
            res.accounts = new List<String>(req.accounts.split(','));
            res.amounts = new List<String>(req.amounts.split(','));
            res.taxRates = new List<String>(req.taxRates.split(','));
            results.add(res);
        }
        return results;
    }
}