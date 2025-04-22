@isTest
public class InvestmentControllerTest {
    
    @testSetup
    static void setupTestData() {
        // Fetch the User record for 'The VentureCrowd Team'
        // Ensure that a user with this name exists in your test environment
        User owner = [SELECT Id FROM User WHERE Name = 'The VentureCrowd Team' LIMIT 1];
        
        // Get Record Type Id for 'VC Person Account'
        // Ensure that the Record Type 'VC Person Account' exists for Account object
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
        
        Raise__c testRaise = new Raise__c(
            Name = 'Test Raise',
            Account__c = testAccount2.Id,
            Status__c = 'New',
            Form_Problem_or_Opportunity__c = 'Problem statement',
            Form_Solution__c = 'Solution statement',
            Form_Differentiation__c = 'Differentiation statement',
            Form_Intellectual_Property__c = 'IP statement',
            Form_Total_addressable_market__c = 'Market size statement',
            Form_Progress__c = 'Progress statement',
            Form_Growth_plan__c = 'Growth plan statement',
            Form_Valuation__c = 1000000,
            Owner__c = owner.Id,
            Form_Company_one_liner__c = 'One liner',
            Form_Offer_close_date__c = Date.today().addDays(30),
            Form_Offer_launch_date__c = Date.today()
        );
        insert testRaise;

        // Create test Product2 records that match the criteria
        Product2 product1 = new Product2(
            Name = 'Test Product 1',
            Portal_Display_Name__c = 'Product Display 1',
            Tile_Heading__c = 'Heading 1',
            Deal_Description__c = 'Deal Description 1',
            Tile_Offer_Type__c = 'Offer Type 1',
            Tile_Banner__c = 'Banner 1',
            Family = 'Test Family',
            Type__c = 'CSF Product',
            Deal_Page_Link__c = 'http://example.com/product1',
            DisplayUrl = 'http://example.com/product1',
            Publish_on_Community_Site__c = true,
            IsActive = true,
            Raise__c = testRaise.Id,
            Offer_Close_Date__c = Date.today().addDays(1)
        );
        insert product1;

        // Create an Investment record associated with the first test Account
        Investment__c investment = new Investment__c(
            Account__c = testAccount1.Id,
            Amount__c = 50000,
            Stage__c = 'Closed Won',
            Related_product__c = product1.Id,
            Investment_Product_Name__c = 'Test Product'
        );
        insert investment;
    }

    /**
     * Test the successful retrieval of Investment records for a valid Account ID.
     */
    @isTest
    static void testGetInvestmentInformationSuccess() {
        // Retrieve the first test Account (which has an Investment)
        Account account = [SELECT Id FROM Account LIMIT 1];
        
        List<Id> accountId = new List<Id>();
        accountId.add(account.Id);
        Test.startTest();
        // Invoke the method under test
        List<Investment__c> investments = InvestmentController.getInvestmentInformation(accountId, 10, 0);
        Test.stopTest();
        
        // Assertions to verify the correctness of the returned data
        System.assertNotEquals(null, investments, 'Investment list should not be null');
        System.assertEquals(1, investments.size(), 'There should be one investment record');
        
        Investment__c retrievedInvestment = investments[0];
        System.assertEquals(50000, retrievedInvestment.Amount__c, 'Investment amount should match');
    }
    
    /**
     * Test the behavior when an invalid Account ID is provided, expecting an exception.
     */
    // @isTest
    // static void testGetInvestmentInformationException() {
    //     // Define an invalid Account ID (non-existent)
    //     Id invalidAccountId = 'a3XXX000000cXXXAAI';

    //     Exception expectedE;
        
    //     Test.startTest();
    //     try {
    //         // Invoke the method under test with an invalid ID
    //         InvestmentController.getInvestmentInformation(invalidAccountId);
    //     } catch (Exception e) {
    //         // Optionally, verify the exception type or message
    //         expectedE = e;
    //     }
    //     Test.stopTest();
    //     System.assert(expectedE instanceof AuraHandledException, 'Expected an AuraHandledException to be thrown');
    // }
    

        /**
     * Test the successful retrieval of Investment records for a valid Account ID.
     */
    @isTest
    static void testGetInvestmentIds() {
        // Retrieve the first test Account (which has an Investment)
        Account testAccount = [SELECT Id FROM Account WHERE FirstName = 'TestPersonAccountFirst' LIMIT 1];
        
        Test.startTest();
        // Invoke the method under test
        List<Investment__c> investments = InvestmentController.getInvestmentIds(testAccount.Id);
        Test.stopTest();
        
        // Assertions to verify the correctness of the returned data
        System.assertNotEquals(null, investments, 'Investment list should not be null');
        System.assertEquals(1, investments.size(), 'There should be one investment record');
        Investment__c retrievedInvestment = investments[0];
    }


        /**
     * Test the successful retrieval of Investment records for a valid Account ID.
     */
    @isTest
    static void testGetInvestmentDetailsSuccess() {
        // Retrieve the first test Account (which has an Investment)
        Investment__c investmentId = [SELECT Id FROM Investment__c LIMIT 1];
        
        Test.startTest();
        // Invoke the method under test
        List<Investment__c> investments = InvestmentController.getInvestmentDetails(investmentId.Id);
        Test.stopTest();
        
        // Assertions to verify the correctness of the returned data
        System.assertNotEquals(null, investments, 'Investment list should not be null');
        System.assertEquals(1, investments.size(), 'There should be one investment record');
        
        Investment__c retrievedInvestment = investments[0];
        System.assertEquals(50000, retrievedInvestment.Amount__c, 'Investment amount should match');
    }
    
    /**
     * Test the behavior when an invalid Investment ID is provided, expecting an exception.
     */
    @isTest
    static void testGetInvestmentDetailsException() {
        // Define an invalid Account ID (non-existent)
        Id invalidAccountId = 'a3XXX000000cXXXAAI';

        Exception expectedE;
        
        Test.startTest();
        try {
            // Invoke the method under test with an invalid ID
            InvestmentController.getInvestmentDetails(invalidAccountId);
        } catch (Exception e) {
            // Optionally, verify the exception type or message
            expectedE = e;
        }
        Test.stopTest();
        System.assert(expectedE instanceof AuraHandledException, 'Expected an AuraHandledException to be thrown');
    }

    /**
     * Test getInvestmentSpotlightData method
     */
    @isTest
    static void testGetInvestmentSpotlightData() {
        InvestmentService investmentService = new InvestmentService();

        Account testAccount = [SELECT Id FROM Account WHERE FirstName = 'TestPersonAccountFirst' LIMIT 1];
        
        Test.startTest();
        List<Investment__c> investments = investmentService.getInvestmentSpotlightData(testAccount.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, investments, 'Investment list should not be null');
        System.assertEquals(1, investments.size(), 'There should be one investment record');
        System.assertEquals(50000, investments[0].Amount__c, 'Investment amount should match');
    }
    
    /**
     * Test getPendingAndClosedInvestments method
     */
    @isTest
    static void testGetPendingAndClosedInvestments() {
        InvestmentService investmentService = new InvestmentService();

        List<Id> accountIds = new List<Id>();
        Account testAccount = [SELECT Id FROM Account WHERE FirstName = 'TestPersonAccountFirst' LIMIT 1];
        accountIds.add(testAccount.Id);
        
        Test.startTest();
        List<Investment__c> investments = investmentService.getPendingAndClosedInvestments(accountIds);
        Test.stopTest();
        
        System.assertNotEquals(null, investments, 'Investment list should not be null');
    }

    /**
     * Test getPendingAndClosedInvestments method
     */
    @isTest
    static void testShowBannerCSF() {
        InvestmentService investmentService = new InvestmentService();

        Account testAccount = [SELECT Id FROM Account WHERE FirstName = 'TestPersonAccountFirst' LIMIT 1];

        
        Test.startTest();
        Boolean investments = investmentService.showCSFBanner(testAccount.Id);
        Test.stopTest();
        
        System.assertNotEquals(false, investments, 'Investment list should not be false');
    }
}