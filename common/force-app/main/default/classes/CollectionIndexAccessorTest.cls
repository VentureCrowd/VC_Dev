@IsTest
private class CollectionIndexAccessorTest {
    
    @IsTest
    static void testGetItemAtIndex() {
        // Create a test request
        CollectionIndexAccessor.IndexRequest request = new CollectionIndexAccessor.IndexRequest();
        request.index = 1;
        request.accounts = new List<String>{ 'Account1', 'Account2', 'Account3' };
        request.amounts = new List<String>{ '100', '200', '300' };
        request.taxRates = new List<String>{ '5%', '10%', '15%' };

        // Add the request to a list as the method expects a list
        List<CollectionIndexAccessor.IndexRequest> requests = new List<CollectionIndexAccessor.IndexRequest>{ request };

        // Call the method
        Test.startTest();
        List<CollectionIndexAccessor.IndexResponse> responses = CollectionIndexAccessor.getItemAtIndex(requests);
        Test.stopTest();

        // Verify the results
        System.assertEquals(1, responses.size(), 'There should be one response');
        CollectionIndexAccessor.IndexResponse response = responses[0];
        System.assertEquals('Account2', response.account, 'Account at index 1 should be Account2');
        System.assertEquals('200', response.amount, 'Amount at index 1 should be 200');
        System.assertEquals('10%', response.taxRate, 'Tax rate at index 1 should be 10%');
    }

    @IsTest
    static void testGetItemAtIndex_OutOfBounds() {
        // Create a test request with an out-of-bounds index
        CollectionIndexAccessor.IndexRequest request = new CollectionIndexAccessor.IndexRequest();
        request.index = 5; // Index out of bounds
        request.accounts = new List<String>{ 'Account1', 'Account2', 'Account3' };
        request.amounts = new List<String>{ '100', '200', '300' };
        request.taxRates = new List<String>{ '5%', '10%', '15%' };

        // Add the request to a list as the method expects a list
        List<CollectionIndexAccessor.IndexRequest> requests = new List<CollectionIndexAccessor.IndexRequest>{ request };

        // Call the method
        Test.startTest();
        List<CollectionIndexAccessor.IndexResponse> responses = CollectionIndexAccessor.getItemAtIndex(requests);
        Test.stopTest();

        // Verify the results
        System.assertEquals(1, responses.size(), 'There should be one response');
        CollectionIndexAccessor.IndexResponse response = responses[0];
        System.assertEquals(null, response.account, 'Account should be null for out-of-bounds index');
        System.assertEquals(null, response.amount, 'Amount should be null for out-of-bounds index');
        System.assertEquals(null, response.taxRate, 'Tax rate should be null for out-of-bounds index');
    }

    @IsTest
    static void testGetItemAtIndex_EmptyLists() {
        // Create a test request with empty lists
        CollectionIndexAccessor.IndexRequest request = new CollectionIndexAccessor.IndexRequest();
        request.index = 0;
        request.accounts = new List<String>();
        request.amounts = new List<String>();
        request.taxRates = new List<String>();

        // Add the request to a list as the method expects a list
        List<CollectionIndexAccessor.IndexRequest> requests = new List<CollectionIndexAccessor.IndexRequest>{ request };

        // Call the method
        Test.startTest();
        List<CollectionIndexAccessor.IndexResponse> responses = CollectionIndexAccessor.getItemAtIndex(requests);
        Test.stopTest();

        // Verify the results
        System.assertEquals(1, responses.size(), 'There should be one response');
        CollectionIndexAccessor.IndexResponse response = responses[0];
        System.assertEquals(null, response.account, 'Account should be null for empty list');
        System.assertEquals(null, response.amount, 'Amount should be null for empty list');
        System.assertEquals(null, response.taxRate, 'Tax rate should be null for empty list');
    }
}