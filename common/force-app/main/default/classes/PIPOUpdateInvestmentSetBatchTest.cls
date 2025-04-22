@isTest
public class PIPOUpdateInvestmentSetBatchTest {
    
    @testSetup
    static void setupTestData() {
        // Fetch the User record for 'The VentureCrowd Team'
        User owner = [SELECT Id FROM User WHERE Name = 'The VentureCrowd Team' LIMIT 1];

        // Get Record Type Id for VC Person Account
        Id recordTypeId = Schema.getGlobalDescribe().get('Account')
            .getDescribe().getRecordTypeInfosByName().get('VC Person Account').getRecordTypeId();

        // Create a test Account
        Account testAccount = new Account(
            FirstName = 'TestPersonAccountFirst',
            LastName = 'TestPersonAccountLast',
            PersonEmail = 'test@user.com',
            RecordTypeId = recordTypeId,
            OwnerId = owner.Id
        );
        insert testAccount;

        Raise__c testRaise = new Raise__c(
            Name = 'Test Raise',
            Account__c = testAccount.Id,
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

        // Create a test Product
        Product2 testProduct = new Product2(
            Name = 'Test Product',
            Portal_Display_Name__c = 'Product Display 1',
            Tile_Heading__c = 'Heading 1',
            Deal_Description__c = 'Deal Description 1',
            Tile_Offer_Type__c = 'Offer Type 1',
            Tile_Banner__c = 'Banner 1',
            Family = 'Test Family',
            Deal_Page_Link__c = 'http://example.com/product1',
            DisplayUrl = 'http://example.com/product1',
            Publish_on_Community_Site__c = true,
            IsActive = true,
            Raise__c = testRaise.Id,
            Offer_Close_Date__c = Date.today().addDays(1)
        );
        insert testProduct;

        // Create an Opportunity
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            AccountId = testAccount.Id,
            Invested_Product_ADMIN_FIELD__c = testProduct.Id
        );
        insert testOpportunity;

        // Create Investments with NULL `Related_Product__c`
        Investment__c investment1 = new Investment__c(
            Opportunity__c = testOpportunity.Id, 
            Account__c = testAccount.Id,
            Related_Product__c = null
        );
        
        Investment__c investment2 = new Investment__c(
            Opportunity__c = testOpportunity.Id, 
            Account__c = testAccount.Id,
            Related_Product__c = null
        );
        
        insert new List<Investment__c>{ investment1, investment2 };
    }

    @isTest
    static void testUpdateInvestmentProductBatch() {
        // Ensure test data exists
        List<Investment__c> investmentsBefore = [SELECT Id FROM Investment__c WHERE Related_Product__c = NULL];
        System.assertNotEquals(0, investmentsBefore.size(), 'There should be Investments with NULL Related_Product__c before batch execution.');

        // Execute batch
        Test.startTest();
        PIPOUpdateInvestmentSetBatch batch = new PIPOUpdateInvestmentSetBatch();
        Database.executeBatch(batch, 200);
        Test.stopTest();

        // Verify that Related_Product__c is updated correctly
        List<Investment__c> investmentsAfter = [SELECT Id, Related_Product__c FROM Investment__c];
        for (Investment__c inv : investmentsAfter) {
            System.assertNotEquals(null, inv.Related_Product__c, 'Investment record should have Related_Product__c updated.');
        }
    }

}