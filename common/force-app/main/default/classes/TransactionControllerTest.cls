@isTest
private class TransactionControllerTest {

    @testSetup
    static void setupTestData() {
        // Fetch the User record for 'The VentureCrowd Team'
        User owner = [SELECT Id FROM User WHERE Name = 'The VentureCrowd Team' LIMIT 1];
        
        // Get Record Type Id for 'VC Person Account'
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('VC Person Account').getRecordTypeId();
        
        // Create first test Account
        Account testAccount1 = new Account(
            FirstName = 'TestPersonAccountFirst',
            LastName = 'TestPersonAccountLast',
            RecordTypeId = recordTypeId,
            PersonEmail = 'test@user.com',
            Preferred_Name__pc = 'PreferredTestName',
            ID_Checked__pc = true,
            OwnerId = owner.Id
        );
        insert testAccount1;
        
        // Create second test Account (without Investment)
        Account testAccount2 = new Account(
            FirstName = 'TestPersonAccountSecond',
            LastName = 'TestPersonAccountSecondLast',
            RecordTypeId = recordTypeId,
            PersonEmail = 'test@user.com.co',
            Preferred_Name__pc = 'PreferredTestName',
            ID_Checked__pc = true,
            OwnerId = owner.Id
        );
        insert testAccount2;
        
        // Create an Investment record associated with the first test Account
        Investment__c investment = new Investment__c(
            Account__c = testAccount1.Id,
            Amount__c = 50000,
            Stage__c = 'Closed Won',
            Investment_Product_Name__c = 'Test Product'
        );
        insert investment;

        // Create a Transaction record associated with the Investment
        Transaction__c transactions = new Transaction__c(
            Account__c = testAccount1.Id,
            Transaction_Type__c = 'Bill',
            Status__c = 'Paid',
            Investment__c = investment.Id,
            XI_Line_Items_Description__c = 'Test Int_IP Description',
            XI_Line_item_amount__c = '1000',
            Transaction_Amount__c = 1000,
            CreatedDate = Date.today().addDays(-1),
            XI_Issue_Date__c = Date.today().addDays(-1)
        );
        insert transactions;
    }

    @isTest
    static void testGetInterestTransactions() {
        // Fetch the Investment record created in @testSetup
        Investment__c investment = [SELECT Id FROM Investment__c LIMIT 1];

        // Call the method under test
        List<Transaction__c> interestTransactions = null;

        try {
            interestTransactions = TransactionController.getInterestTransactions(investment.Id);
        } catch (Exception e) {
            System.assert(false, 'Method threw an unexpected exception: ' + e.getMessage());
        }

        // Assert that the transactions were retrieved successfully
        System.assertNotEquals(null, interestTransactions, 'The method should return a non-null list.');
        System.assertEquals(1, interestTransactions.size(), 'The method should return exactly one transaction.');
        System.assertEquals('Bill', interestTransactions[0].Transaction_Type__c, 'The transaction type should be Bill.');
    }
}