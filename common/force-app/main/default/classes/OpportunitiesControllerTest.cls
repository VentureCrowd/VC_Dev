@IsTest
public class OpportunitiesControllerTest {
    @testSetup
    static void setup() {

        User owner = [SELECT Id FROM USER WHERE Name = 'The VentureCrowd Team'];

         // Create and insert a test account
         Account personAccount = new Account(Name='Related Person');
         insert personAccount;
 
         Account businessAccount = new Account(Name='Test Business', Related_Person_Account__c=personAccount.Id);
         insert businessAccount;
 
         // Optional: Create and insert related records if needed (like EOI)
         EOI__c testEOI = new EOI__c(Name = 'Test EOI', Account__c = businessAccount.Id, Internal_Owner__c=owner.Id);
         insert testEOI;

         Lead testLead = new Lead(
            FirstName ='Test',
            LastName='Lead',
            Email='mail@mail.com',
            Related_EOI__c=testEOI.Id
         );
         insert testLead;

         
         
         Id ownerId = 'a3XXX000000cXXXAAI';
 
         List<User> benQuery = [SELECT Id FROM User WHERE Name='Ben Crow' LIMIT 1];
         if(benQuery.size() > 0){
             ownerId = benQuery[0].Id;
         }
 
 
         // Creating a Raise__c record to test existing raise functionality
         Raise__c testRaise = new Raise__c(
             Name = 'Test Raise',
             Account__c = personAccount.Id,
             Owner__c = ownerId,
             Company__c = businessAccount.Id,
             EOI__c = testEOI.Id,
             Status__c = 'In Progress',
             Payment_received__c = true,
             Content_approved__c = true,
             Course_unlocked__c = false,
             Learning_completed__c = false,
             Form_Problem_or_Opportunity__c = 'Test Problem',
             Form_Solution__c = 'Test Solution',
             Form_Differentiation__c = 'Test Differentiation',
             Form_Intellectual_Property__c = 'Test Intellectual Property',
             Form_Total_addressable_market__c = 'Test Market',
             Form_Progress__c = 'Test Progress',
             Form_Growth_plan__c = 'Test Growth Plan',
             Form_Valuation__c = 1000000,
             Form_Company_one_liner__c = 'Test Company Overview',
             Form_Offer_close_date__c = Date.today()
         );
         insert testRaise;

         Product2 product1 = new Product2(
            Name = 'Test Product 1',
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
        insert product1;

         Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity x Raise',
            AccountId = personAccount.Id,
            CloseDate = Date.today(),
            StageName = 'ApplicatCion Received',
            Raise__c = testRaise.Id
         );
         insert testOpp;

        PricebookEntry priceBook = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = product1.Id,
            UnitPrice = 1000,
            IsActive = true
        );
        insert priceBook;

        // Create Opp Line Item
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = testOpp.Id,
            Product2Id = product1.Id,
            PricebookEntryId = priceBook.Id,
            Quantity = 1,
            UnitPrice = 1000
        );
        insert oli;
    }


    @isTest
    static void testGetRecords() {
        // Retrieve the test data
        Raise__c testRaise = [SELECT Id FROM Raise__c  LIMIT 1];
        
        // Set parameters
        Id recordId = testRaise.Id;
        Integer pageSize = 10;
        Integer pageNumber = 1;
        String sortBy = 'Name';
        String sortDirection = 'ASC';
        List<String> columnNames = new List<String>{'Name', 'Id'};

        // Call the method
        OpportunitiesService.RecordsWrapper result = OpportunitiesController.getRecords(recordId, pageSize, pageNumber, sortBy, sortDirection, columnNames);

        // Verify the result
        System.assertNotEquals(null, result);
        System.assertNotEquals(null, result.records);
        System.assert(result.records.size() > 0, 'Expected records to be returned');
    }


    @isTest
    static void testGetRecordsException() {
        // Retrieve the test data
        
        // Set parameters
        Id recordId = 'a3XXX000000cXXXAAI';
        Integer pageSize = 10;
        Integer pageNumber = 1;
        String sortBy = 'LastName';
        String sortDirection = 'ASC';
        List<String> columnNames = new List<String>{'LastName', 'FirstName', 'Id'};

        Exception expectedE;

        // Call the method
        try{
            OpportunitiesService.RecordsWrapper result = OpportunitiesController.getRecords(recordId, pageSize, pageNumber, sortBy, sortDirection, columnNames);
        }catch(Exception e){
            expectedE = e;
        }

        // Verify the result
        System.assertNotEquals(null, expectedE);
    }

    @isTest
    static void testUpdateLead() {
        // Retrieve the test data
        Opportunity testOpp = [SELECT Id, Comments__c FROM Opportunity LIMIT 1];
        
        // Set parameters
        Id recordId = testOpp.Id;
        String objectName = 'Opportunity';
        Map<String, Object> fieldsToUpdate = new Map<String, Object>{
            'comments' => 'new Comment'
        };

        // Call the method
        Map<String, Object> result = OpportunitiesController.updateOpportunity(recordId, objectName, fieldsToUpdate);

        // Verify the result
        System.assertNotEquals(null, result);
        System.assertEquals(recordId, result.get('Id'));

        // Verify the update
        Opportunity updatedLead = [SELECT Comments__c FROM Opportunity WHERE Id = :recordId];
        System.assertEquals('new Comment', updatedLead.Comments__c);
    }

    @isTest
    static void testUpdateLeadException() {
        // Retrieve the test data
        
        // Set parameters
        Id recordId = 'a3XXX000000cXXXAAI';
        String objectName = 'Opportunity';
        Map<String, Object> fieldsToUpdate = new Map<String, Object>{
            'comments' => 'new Comment'
        };
        Exception expectedE;
        // Call the method
        try{
            Map<String, Object> result = OpportunitiesController.updateOpportunity(recordId, objectName, fieldsToUpdate);
        }catch(Exception e){
            expectedE = e;
        }

        // Verify the result
        System.assertNotEquals(null, expectedE);
    }

    @isTest
    static void testUpdateLeadFieldUnmapped() {
        Opportunity testOpp = [SELECT Id, Comments__c FROM Opportunity LIMIT 1];
        
        // Set parameters
        Id recordId = testOpp.Id;
        String objectName = 'Opportunity';
        Map<String, Object> fieldsToUpdate = new Map<String, Object>{
            'unmapped' => 'new Comment'
        };

        // Call the method
        Map<String, Object> result = OpportunitiesController.updateOpportunity(recordId, objectName, fieldsToUpdate);

        // Verify the result
        System.assertNotEquals(null, result);
        System.assertEquals(recordId, result.get('Id'));
        System.assertNotEquals(null, result.get('unmapped'));
    }

    @isTest
    static void testGetProductIdSuccess() {
        // Retrieve the test data
        OpportunityLineItem testOpp = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        
        // Set parameters
        Id opportunityId = testOpp.Id;

        // Call the method
        OpportunityLineItem result = OpportunitiesController.getProductId(opportunityId);

        // Verify the result
        System.assertNotEquals(null, result, 'Expected opportunity to be returned');
        System.assertEquals(testOpp.Id, result.Id, 'Expected opportunity IDs to match');
    }
    
    @isTest
    static void testGetProductIdException() {
        // Use a fake Opportunity Id to force an exception
        Id invalidOpportunityId = 'a3XXX000000cXXXAAI';

        Exception expectedE;

        // Call the method
        try {
            OpportunityLineItem result = OpportunitiesController.getProductId(invalidOpportunityId);
        } catch (Exception e) {
            expectedE = e;
        }

        // Verify the result
        System.assertNotEquals(null, expectedE, 'Expected an exception to be thrown');
        System.assert(expectedE instanceof AuraHandledException, 'Expected an AuraHandledException to be thrown');
    }
}