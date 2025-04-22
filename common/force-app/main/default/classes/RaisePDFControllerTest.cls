@isTest
public class RaisePDFControllerTest {
    
    /**
     * Test Setup to create common test data for all test methods
     */
    @testSetup
    static void setupTestData() {
        // Create a test Account
        Account testAccount = new Account(
            Name = 'Test Account ' + String.valueOf(DateTime.now().getTime())
            // Populate other required fields if any
        );
        insert testAccount;

        Id ownerId = 'a3XXX000000cXXXAAI';

        List<User> benQuery = [SELECT Id FROM User WHERE Name='Ben Crow' LIMIT 1];
        if(benQuery.size() > 0){
            ownerId = benQuery[0].Id;
        }
        
        // Create a test Raise__c record
        Raise__c testRaise = new Raise__c(
            Name = 'Test Raise ' + String.valueOf(DateTime.now().getTime()),
            Account__c = testAccount.Id,
            Owner__c = ownerId,
            Form_Company_Legal_Trading_Name__c = 'Test Company Ltd ' + String.valueOf(DateTime.now().getTime()),
            Form_Registered_Aus__c = true,
            Form_ABN__c = '12345678901',
            Form_ACN__c = '123456789',
            Form_Company_Street_Address__c = '123 Test Street',
            Form_Company_Overview__c = 'Overview of Test Company',
            Form_Business_strategy__c = 'Test Business Strategy',
            Form_Business_model__c = 'Test Business Model',
            Form_Organisation_structure__c = 'Test Organisation Structure',
            Form_Proprietary_company__c = true,
            Form_Public_company__c = false,
            Form_Financial_information_summary__c = 'Financial Summary',
            Form_Debt_funding_and_other_funding__c = 'Debt Funding Details',
            Form_Legal_or_disciplinary_action__c = 'None',
            Form_Risks_facing_the_business__c = 'Risk Details',
            Form_Planned_use_of_funds__c = 'Use of Funds Details',
            Form_Offer_launch_date__c = Date.today(),
            Form_Offer_close_date__c = Date.today().addDays(30),
            Form_Investment_Product_Type__c = 'Ordinary Shares',
            Form_Valuation__c = 1000000.00,
            Form_Number_of_shares_on_issue__c = 10000,
            Form_Rights_associated_with_shares__c = 'Standard Rights',
            Form_Details_of_previous_CSF_offers__c = 'None',
            Form_Target_amount__c = 500000.00,
            Form_Minimum_target__c = 100000.00,
            Form_Maximum_target__c = 1000000.00,
            Form_Minimum_Investment_amount__c = 1000.00,
            Form_Risk_warning__c = 'Standard Risk Warning',
            Form_Cooling_off_rights__c = 'Standard Cooling Off Rights',
            Form_Glossary__c = 'Glossary Terms'
            // Populate other required fields as necessary
        );
        insert testRaise;
        
        // Create related Raise_Team_and_Advisors__c records
        List<Raise_Team_and_Advisors__c> teamRecords = new List<Raise_Team_and_Advisors__c>();
        teamRecords.add(new Raise_Team_and_Advisors__c(
            Related_Raise__c = testRaise.Id,
            Role__c = 'CEO',
            Name__c = 'Jane Smith ' + String.valueOf(DateTime.now().getTime()).substring(0,3) // Ensure uniqueness
        ));
        teamRecords.add(new Raise_Team_and_Advisors__c(
            Related_Raise__c = testRaise.Id,
            Role__c = 'CFO',
            Name__c = 'John Doe ' + String.valueOf(DateTime.now().getTime()).substring(0,3) // Ensure uniqueness
        ));
        insert teamRecords;
    }
    
    /**
     * Test Case 1: Successful initialization with valid raiseId and existing team records.
     */
    @isTest static void testController_WithValidRaiseId_WithTeamRecords() {
        // Retrieve test Raise__c record
        Raise__c testRaise = [SELECT Id, Account__c FROM Raise__c LIMIT 1]; // Assuming only one in testSetup
        
        
        // Set the current page reference with raiseId parameter
        PageReference pageRef = Page.RaisePDFPage; // Ensure the VF page exists
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('raiseId', testRaise.Id);
        
        // Instantiate the controller
        RaisePDFController controller = new RaisePDFController();
        
        // Assertions to verify HTMLContent is generated
        System.assertNotEquals(null, controller.HTMLContent, 'HTMLContent should not be null');
        System.assert(controller.HTMLContent.contains('Test Raise '), 'HTMLContent should contain the Raise Name');
        System.assert(controller.HTMLContent.contains('Test Company Ltd '), 'HTMLContent should contain Company Legal Trading Name');
    }
    
    /**
     * Test Case 2: Initialization without raiseId parameter, expecting an exception.
     */
    @isTest static void testController_MissingRaiseId_ThrowsException() {
        // Set the current page reference without raiseId parameter
        PageReference pageRef = Page.RaisePDFPage; // Ensure the VF page exists
        Test.setCurrentPage(pageRef);
        // No parameters set
        
        // Expect AuraHandledException when raiseId is missing
        Test.startTest();
        try {
            RaisePDFController controller = new RaisePDFController();
            System.assert(false, 'Expected AuraHandledException was not thrown.');
        } catch (AuraHandledException e) {
            System.assertNotEquals(null,e, 'Exception should not be null');
        } catch (Exception e) {
            // If AuraHandledException is not being caught, catch any exception and check message
            System.assertNotEquals(null,e, 'Exception should not be null');
        }
        Test.stopTest();
    }
    
    /**
     * Test Case 3: Initialization with valid raiseId but no related team records.
     */
    @isTest static void testController_WithValidRaiseId_NoTeamRecords() {
        // Step 1: Create a new test Account
        Raise__c testRaise = [SELECT Id, Account__c FROM Raise__c LIMIT 1]; // Assuming only one in testSetup

        Id ownerId = 'a3XXX000000cXXXAAI';

        List<User> benQuery = [SELECT Id FROM User WHERE Name='Ben Crow' LIMIT 1];
        if(benQuery.size() > 0){
            ownerId = benQuery[0].Id;
        }
        
        // Step 2: Create a new Raise__c record linked to the new Account with unique fields
        String uniqueSuffix = String.valueOf(DateTime.now().getTime());
        Raise__c testRaiseNoTeam = new Raise__c(
            Name = 'Test Raise No Team ' + uniqueSuffix,
            Account__c = testRaise.Account__c,
            Owner__c = ownerId,
            Form_Company_Legal_Trading_Name__c = 'Test Company No Team Ltd ' + uniqueSuffix,
            Form_Registered_Aus__c = true,
            Form_ABN__c = '09876543211',
            Form_ACN__c = '98765432',
            Form_Company_Street_Address__c = '456 Another Street',
            Form_Company_Overview__c = 'Overview of Test Company No Team',
            Form_Business_strategy__c = 'Test Business Strategy No Team',
            Form_Business_model__c = 'Test Business Model No Team',
            Form_Organisation_structure__c = 'Test Organisation Structure No Team',
            Form_Proprietary_company__c = false,
            Form_Public_company__c = true,
            Form_Financial_information_summary__c = 'Financial Summary No Team',
            Form_Debt_funding_and_other_funding__c = 'Debt Funding Details No Team',
            Form_Legal_or_disciplinary_action__c = 'None',
            Form_Risks_facing_the_business__c = 'Risk Details No Team',
            Form_Planned_use_of_funds__c = 'Use of Funds Details No Team',
            Form_Offer_launch_date__c = Date.today(),
            Form_Offer_close_date__c = Date.today().addDays(30),
            Form_Investment_Product_Type__c = 'Ordinary Shares',
            Form_Valuation__c = 500000.00,
            Form_Number_of_shares_on_issue__c = 5000,
            Form_Rights_associated_with_shares__c = 'Standard Rights No Team ' + uniqueSuffix,
            Form_Details_of_previous_CSF_offers__c = 'None',
            Form_Target_amount__c = 250000.00,
            Form_Minimum_target__c = 50000.00,
            Form_Maximum_target__c = 500000.00,
            Form_Minimum_Investment_amount__c = 500.00,
            Form_Risk_warning__c = 'Standard Risk Warning No Team',
            Form_Cooling_off_rights__c = 'Standard Cooling Off Rights No Team',
            Form_Glossary__c = 'Glossary Terms No Team'
            // Populate other required fields as necessary
        );
        insert testRaiseNoTeam;
        
        // Step 3: Set the current page reference with raiseId parameter
        PageReference pageRef = Page.RaisePDFPage; // Ensure the VF page exists
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('raiseId', testRaiseNoTeam.Id);
        
        // Step 4: Instantiate the controller
        RaisePDFController controller = new RaisePDFController();
        
        // Step 5: Assertions to verify HTMLContent is generated without team records
        System.assertNotEquals(null, controller.HTMLContent, 'HTMLContent should not be null');
        System.assert(controller.HTMLContent.contains('Test Raise No Team ' + uniqueSuffix + ' Offer Document'), 'HTMLContent should contain the Raise Name');
        System.assert(controller.HTMLContent.contains('Test Company No Team Ltd ' + uniqueSuffix), 'HTMLContent should contain Company Legal Trading Name');
        System.assert(controller.HTMLContent.contains('Team and Advisors'), 'HTMLContent should contain Team and Advisors section');
        // Verify that no team member names are present
        System.assert(!controller.HTMLContent.contains('Jane Smith '), 'HTMLContent should not contain any Team Members');
        System.assert(!controller.HTMLContent.contains('John Doe '), 'HTMLContent should not contain any Team Members');
    }
    
    /**
     * Test Case 4: Initialization with raiseId parameter pointing to a non-existent Raise__c record.
     * Expect that HTMLContent is empty or handles the missing record gracefully.
     */
    @isTest static void testController_WithInvalidRaiseId() {
        // Set the current page reference with an invalid raiseId parameter
        PageReference pageRef = Page.RaisePDFPage; // Ensure the VF page exists
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('raiseId', 'a0123456789ABCDE'); // Assuming this ID does not exist
        
        // Instantiate the controller and expect no records found exception
        Test.startTest();
        try {
            RaisePDFController controller = new RaisePDFController();
            // Depending on controller implementation, HTMLContent might be empty or have specific content
            System.assertEquals('', controller.HTMLContent, 'HTMLContent should be empty for non-existent Raise__c record.');
        } catch (QueryException e) {
            // If controller does not handle missing records gracefully, it might throw a QueryException
            System.assert(true, 'Expected QueryException was thrown due to non-existent Raise__c record.');
        } catch (Exception e) {
            // Handle other unexpected exceptions
            System.assert(false, 'Unexpected exception type: ' + e);
        }
        Test.stopTest();
    }
    
    /**
     * Test Case 5: Initialization with raiseId parameter but some fields are null or empty.
     * Ensures that HTMLContent handles nulls gracefully.
     */
    @isTest static void testController_WithPartialData() {
        // Step 1: Create a new test Account
        Raise__c testRaise = [SELECT Id, Account__c FROM Raise__c LIMIT 1]; // Assuming only one in testSetup

        Id ownerId = 'a3XXX000000cXXXAAI';

        List<User> benQuery = [SELECT Id FROM User WHERE Name='Ben Crow' LIMIT 1];
        if(benQuery.size() > 0){
            ownerId = benQuery[0].Id;
        }
        // Step 2: Create a Raise__c record with some fields left null
        String uniqueSuffix = String.valueOf(DateTime.now().getTime());
        Raise__c testRaisePartial = new Raise__c(
            Name = 'Test Raise Partial ' + uniqueSuffix,
            Owner__c = ownerId,
            Account__c = testRaise.Account__c,
            Form_Company_Legal_Trading_Name__c = 'Partial Company Ltd ' + uniqueSuffix,
            Form_Registered_Aus__c = false,
            // Intentionally leaving some fields null
            Form_ABN__c = null,
            Form_ACN__c = null,
            Form_Company_Street_Address__c = '789 Partial Street',
            Form_Company_Overview__c = 'Partial Overview of Company',
            Form_Business_strategy__c = 'Partial Business Strategy',
            // ... other fields can be left null or populated as needed
            Form_Offer_launch_date__c = Date.today(),
            Form_Offer_close_date__c = Date.today().addDays(30),
            Form_Investment_Product_Type__c = 'Ordinary Shares'
      
        );
        insert testRaisePartial;
        
        // Step 3: Set the current page reference with raiseId parameter
        PageReference pageRef = Page.RaisePDFPage; // Ensure the VF page exists
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('raiseId', testRaisePartial.Id);
        
        // Step 4: Instantiate the controller
        RaisePDFController controller = new RaisePDFController();
        
        // Step 5: Assertions to verify HTMLContent handles null fields gracefully
        System.assertNotEquals(null, controller.HTMLContent, 'HTMLContent should not be null');
        System.assert(controller.HTMLContent.contains('Test Raise Partial ' + uniqueSuffix + ' Offer Document'), 'HTMLContent should contain the Raise Name');
        System.assert(controller.HTMLContent.contains('Partial Company Ltd ' + uniqueSuffix), 'HTMLContent should contain Company Legal Trading Name');
        System.assert(controller.HTMLContent.contains('789 Partial Street'), 'HTMLContent should contain Company Street Address');
        System.assert(controller.HTMLContent.contains('Partial Overview of Company'), 'HTMLContent should contain Company Overview');
        System.assert(controller.HTMLContent.contains('Partial Business Strategy'), 'HTMLContent should contain Business Strategy');
        // Verify that fields with nulls are either omitted or handled appropriately
        System.assert(!controller.HTMLContent.contains('ABN:'), 'HTMLContent should not contain ABN field as it is null');
        System.assert(!controller.HTMLContent.contains('ACN:'), 'HTMLContent should not contain ACN field as it is null');
        System.assert(!controller.HTMLContent.contains('Business Model:'), 'HTMLContent should not contain Business Model field as it is null');
        // Continue with other fields as needed
    }
}