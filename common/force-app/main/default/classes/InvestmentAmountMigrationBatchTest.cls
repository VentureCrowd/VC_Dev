/**
 * @description
 * Test class for InvestmentAmountMigrationBatch.
 * This class contains test methods to verify the functionality of the batch class,
 * including successful migration of Investment Amounts, handling of unknown picklist values,
 * and ensuring that the batch class runs without errors when emails are sent.
 *
 * The test class covers the following scenarios:
 * - Test migration with valid picklist values.
 * - Test handling of unknown picklist values (error condition).
 * - Test batch execution with a large number of records.
 *
 * Adjustments have been made to remove the invalid mocking of Messaging.SendEmailResult.
 * Since emails are not actually sent during test execution, we can proceed without mocking.
 *
 * Author: [Your Name]
 * Date: [Current Date]
 */
@IsTest
private class InvestmentAmountMigrationBatchTest {

    /**
     * @description
     * Test method to verify that the batch class correctly updates Lead records with valid picklist values.
     */
    @IsTest
    static void testBatchMigrationWithValidData() {
        // Set up test data

        // Create a test Account (required for EOI__c)
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create a test EOI__c record
        EOI__c testEOI = new EOI__c(
            Name = 'Test EOI',
            Account__c = testAccount.Id,
            EOI_Status__c = 'Published',
            Publish_on_Community_Site__c = true,
            // Include any other required fields for EOI__c
            URL_Files_Img__c = 'http://example.com/image.png',
            Published_EOI_URL__c = 'http://example.com/eoi',
            One_liner_about_business__c = 'Innovative business idea',
            SXSW_Finalist__c = true,
            EOI_Title__c = 'Exciting EOI Title',
            Internal_Owner__c = UserInfo.getUserId()
        );
        insert testEOI;

        // Create Leads with valid picklist values and set Related_EOI__c to the EOI__c record ID
        List<Lead> testLeads = new List<Lead>();
        testLeads.add(new Lead(
            LastName = 'Test Lead 1',
            Company = 'Test Company',
            Investment_Amount__c = '$500 to $1,000',
            Related_EOI__c = testEOI.Id
            // Lead_Sub_Status__c = 'Contact Made' // Mandatory field
        ));
        testLeads.add(new Lead(
            LastName = 'Test Lead 2',
            Company = 'Test Company',
            Investment_Amount__c = '$10,000 to $20,000',
            Related_EOI__c = testEOI.Id
            // Lead_Sub_Status__c = 'Contact Made' // Mandatory field
        ));
        testLeads.add(new Lead(
            LastName = 'Test Lead 3',
            Company = 'Test Company',
            Investment_Amount__c = '$200,000+',
            Related_EOI__c = testEOI.Id
            // Lead_Sub_Status__c = 'Contact Made' // Mandatory field
        ));

        insert testLeads;

        // Verify that the new Investment Amount field is null before batch execution
        for (Lead lead : testLeads) {
            System.assertEquals(null, lead.Investment_Amount_Currency__c, 'New Investment Amount should be null before batch execution.');
        }

        // Start test context
        Test.startTest();

        // Instantiate and execute the batch class
        InvestmentAmountMigrationBatch batch = new InvestmentAmountMigrationBatch();
        Database.executeBatch(batch, 200); // Using batch size of 1 for simplicity

        // Stop test context to execute asynchronous batch job
        Test.stopTest();

        // Refresh the Lead records from the database
        testLeads = [SELECT Id, Investment_Amount__c, Investment_Amount_Currency__c FROM Lead WHERE Id IN :testLeads];

        // Verify that the Leads have been updated correctly
        for (Lead lead : testLeads) {
            Integer expectedAmount = InvestmentAmountMigrationBatch.amountRangeMap.get(lead.Investment_Amount__c);
            System.assertEquals(Decimal.valueOf(expectedAmount), lead.Investment_Amount_Currency__c, 'New Investment Amount should be updated correctly.');
        }
    }

    /**
     * @description
     * Test method to verify that the batch class handles unknown picklist values gracefully.
     */
    @IsTest
    static void testBatchMigrationWithInvalidData() {
        // Set up test data

        // Create a test Account (required for EOI__c)
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create a test EOI__c record
        EOI__c testEOI = new EOI__c(
            Name = 'Test EOI',
            Account__c = testAccount.Id,
            EOI_Status__c = 'Published',
            Publish_on_Community_Site__c = true,
            // Include any other required fields for EOI__c
            URL_Files_Img__c = 'http://example.com/image.png',
            Published_EOI_URL__c = 'http://example.com/eoi',
            One_liner_about_business__c = 'Innovative business idea',
            SXSW_Finalist__c = true,
            EOI_Title__c = 'Exciting EOI Title',
            Internal_Owner__c = UserInfo.getUserId()
        );
        insert testEOI;

        // Create a Lead with an unknown picklist value
        List<Lead> testLeads = new List<Lead>();
        testLeads.add(new Lead(
            LastName = 'Test Lead 4',
            Company = 'Test Company',
            Investment_Amount__c = 'Unknown Value',
            Related_EOI__c = testEOI.Id
            // Lead_Sub_Status__c = 'Contact Made' // Mandatory field
        ));

        insert testLeads;

        // Start test context
        Test.startTest();

        // Instantiate and execute the batch class
        InvestmentAmountMigrationBatch batch = new InvestmentAmountMigrationBatch();
        Database.executeBatch(batch, 200);

        // Stop test context to execute asynchronous batch job
        Test.stopTest();

        // Refresh the Lead records from the database
        testLeads = [SELECT Id, Investment_Amount__c, Investment_Amount_Currency__c FROM Lead WHERE Id IN :testLeads];

        // Verify that the New Investment Amount is still null due to the unknown picklist value
        for (Lead lead : testLeads) {
            System.assertEquals(null, lead.Investment_Amount_Currency__c, 'New Investment Amount should remain null for unknown picklist values.');
        }
    }

    /**
     * @description
     * Test method to verify that the batch class runs without errors when processing emails.
     */
    @IsTest
    static void testBatchExecutionWithEmail() {
        // Set up test data

        // Create a test Account (required for EOI__c)
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create a test EOI__c record
        EOI__c testEOI = new EOI__c(
            Name = 'Test EOI',
            Account__c = testAccount.Id,
            EOI_Status__c = 'Published',
            Publish_on_Community_Site__c = true,
            // Include any other required fields for EOI__c
            URL_Files_Img__c = 'http://example.com/image.png',
            Published_EOI_URL__c = 'http://example.com/eoi',
            One_liner_about_business__c = 'Innovative business idea',
            SXSW_Finalist__c = true,
            EOI_Title__c = 'Exciting EOI Title',
            Internal_Owner__c = UserInfo.getUserId()
        );
        insert testEOI;

        // Create Leads with both valid and invalid picklist values
        List<Lead> testLeads = new List<Lead>();
        testLeads.add(new Lead(
            LastName = 'Test Lead 5',
            Company = 'Test Company',
            Investment_Amount__c = '$1,000 to $2,000',
            Related_EOI__c = testEOI.Id
            // Lead_Sub_Status__c = 'Contact Made' // Mandatory field
        ));
        testLeads.add(new Lead(
            LastName = 'Test Lead 6',
            Company = 'Test Company',
            Investment_Amount__c = 'Invalid Value',
            Related_EOI__c = testEOI.Id
            // Lead_Sub_Status__c = 'Contact Made' // Mandatory field
        ));

        insert testLeads;

        // Start test context
        Test.startTest();

        // Instantiate and execute the batch class
        InvestmentAmountMigrationBatch batch = new InvestmentAmountMigrationBatch();
        Database.executeBatch(batch, 200);

        // Stop test context to execute asynchronous batch job
        Test.stopTest();

        // Since emails are not sent in test context, we ensure the batch completes without exceptions
        // We can verify that the Leads were updated appropriately

        // Refresh the Lead records from the database
        List<Lead> updatedLeads = [SELECT Id, Investment_Amount__c, Investment_Amount_Currency__c FROM Lead WHERE Id IN :testLeads];

        // Verify that the valid Lead was updated and the invalid one was not
        for (Lead lead : updatedLeads) {
            if (lead.Investment_Amount__c == '$1,000 to $2,000') {
                Integer expectedAmount = InvestmentAmountMigrationBatch.amountRangeMap.get(lead.Investment_Amount__c);
                System.assertEquals(Decimal.valueOf(expectedAmount), lead.Investment_Amount_Currency__c, 'New Investment Amount should be updated correctly.');
            } else if (lead.Investment_Amount__c == 'Invalid Value') {
                System.assertEquals(null, lead.Investment_Amount_Currency__c, 'New Investment Amount should remain null for invalid picklist values.');
            }
        }
    }

    /**
     * @description
     * Test method to simulate a large number of Lead records to test batch processing.
     */
    @IsTest
    static void testBatchWithLargeNumberOfRecords() {
        // Set up test data

        // Create a test Account (required for EOI__c)
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create a test EOI__c record
        EOI__c testEOI = new EOI__c(
            Name = 'Test EOI',
            Account__c = testAccount.Id,
            EOI_Status__c = 'Published',
            Publish_on_Community_Site__c = true,
            // Include any other required fields for EOI__c
            URL_Files_Img__c = 'http://example.com/image.png',
            Published_EOI_URL__c = 'http://example.com/eoi',
            One_liner_about_business__c = 'Innovative business idea',
            SXSW_Finalist__c = true,
            EOI_Title__c = 'Exciting EOI Title',
            Internal_Owner__c = UserInfo.getUserId()
        );
        insert testEOI;

        List<Lead> testLeads = new List<Lead>();
        Integer numberOfLeads = 150; // More than the maxRecordsInEmail in the batch class

        // Create a large number of Leads with valid picklist values
        for (Integer i = 0; i < numberOfLeads; i++) {
            testLeads.add(new Lead(
                LastName = 'Test Lead ' + i,
                Company = 'Test Company',
                Investment_Amount__c = '$5,000 to $8,000',
                Related_EOI__c = testEOI.Id
                // Lead_Sub_Status__c = 'Contact Made' // Mandatory field
            ));
        }

        insert testLeads;

        // Start test context
        Test.startTest();

        // Instantiate and execute the batch class
        InvestmentAmountMigrationBatch batch = new InvestmentAmountMigrationBatch();
        Database.executeBatch(batch, 200); // Using a batch size of 200

        // Stop test context to execute asynchronous batch job
        Test.stopTest();

        // Verify that the Leads have been updated
        testLeads = [SELECT Id, Investment_Amount_Currency__c FROM Lead WHERE Id IN :testLeads];
        for (Lead lead : testLeads) {
            System.assertEquals(5000, lead.Investment_Amount_Currency__c, 'New Investment Amount should be updated to 5000.');
        }

        // Since emails are not sent in test context, we ensure the batch completes without exceptions
    }
}