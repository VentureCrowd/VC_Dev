@isTest
public class StringSplitHandlerNEWTest {
    
    @isTest
    static void testSplitTransactionItems() {
        // Create test data
        String descriptions = 'desc1,desc2,desc3';
        String accounts = 'acc1,acc2,acc3';
        String amounts = '100,200,300';
        String taxRates = '10,20,30';
        
        // Create a request instance
        StringSplitHandlerNEW.Request request = new StringSplitHandlerNEW.Request();
        request.descriptions = descriptions;
        request.accounts = accounts;
        request.amounts = amounts;
        request.taxRates = taxRates;
        
        // Create a list of requests
        List<StringSplitHandlerNEW.Request> requests = new List<StringSplitHandlerNEW.Request>();
        requests.add(request);
        
        // Invoke the method
        List<StringSplitHandlerNEW.Result> results = StringSplitHandlerNEW.splitTransactionItems(requests);
        
        // Verify the results
        System.assertEquals(1, results.size());
        StringSplitHandlerNEW.Result result = results[0];
        
        List<String> expectedDescriptions = new List<String>{'desc1', 'desc2', 'desc3'};
        List<String> expectedAccounts = new List<String>{'acc1', 'acc2', 'acc3'};
        List<String> expectedAmounts = new List<String>{'100', '200', '300'};
        List<String> expectedTaxRates = new List<String>{'10', '20', '30'};
        
        System.assertEquals(expectedDescriptions, result.descriptions);
        System.assertEquals(expectedAccounts, result.accounts);
        System.assertEquals(expectedAmounts, result.amounts);
        System.assertEquals(expectedTaxRates, result.taxRates);
    }
    
    @isTest
    static void testEmptyValues() {
        // Create test data with empty values
        String descriptions = '';
        String accounts = '';
        String amounts = '';
        String taxRates = '';
        
        // Create a request instance
        StringSplitHandlerNEW.Request request = new StringSplitHandlerNEW.Request();
        request.descriptions = descriptions;
        request.accounts = accounts;
        request.amounts = amounts;
        request.taxRates = taxRates;
        
        // Create a list of requests
        List<StringSplitHandlerNEW.Request> requests = new List<StringSplitHandlerNEW.Request>();
        requests.add(request);
        
        // Invoke the method
        List<StringSplitHandlerNEW.Result> results = StringSplitHandlerNEW.splitTransactionItems(requests);
        
        // Verify the results
        System.assertEquals(1, results.size());
        StringSplitHandlerNEW.Result result = results[0];
        
        List<String> expectedDescriptions = new List<String>{''};
        List<String> expectedAccounts = new List<String>{''};
        List<String> expectedAmounts = new List<String>{''};
        List<String> expectedTaxRates = new List<String>{''};
        
        System.assertEquals(expectedDescriptions, result.descriptions);
        System.assertEquals(expectedAccounts, result.accounts);
        System.assertEquals(expectedAmounts, result.amounts);
        System.assertEquals(expectedTaxRates, result.taxRates);
    }
    
  
}