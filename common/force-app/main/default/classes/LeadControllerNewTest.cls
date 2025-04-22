@IsTest
public class LeadControllerNewTest {
    @testSetup
    static void setup() {
        Id ownerId = 'a3XXX000000cXXXAAI';
         List<User> benQuery = [SELECT Id FROM User WHERE Name='Ben Crow' LIMIT 1];
         if(benQuery.size() > 0){
             ownerId = benQuery[0].Id;
         }
 
         // Create and insert a test account
         Account personAccount = new Account(Name='Related Person');
         insert personAccount;
 
         Account businessAccount = new Account(Name='Test Business', Related_Person_Account__c=personAccount.Id);
         insert businessAccount;
 
         // Optional: Create and insert related records if needed (like EOI)
         EOI__c testEOI = new EOI__c(
            Name = 'Test EOI', 
            Account__c = businessAccount.Id, 
            Internal_Owner__c=ownerId,
            URL_Files_Img__c = '[{"title":"logo","contentDownloadURL":"https://venturecrowd.my.salesforce.com/sfc/dist/version/download/?oid=00D8s000009HSSb&ids=0685i00000I3URJ&d=%2Fa%2F5i000000r2WZ%2FeABm2CrRetLvTDmslOcg9ise2vGxhK5EgoOKLtLlW_Y&asPdf=false"}]'
            );
         insert testEOI;

         Lead testLead = new Lead(
            FirstName ='Test',
            LastName='Lead',
            Email='mail@mail.com',
            Related_EOI__c=testEOI.Id,
            Investment_Amount_Currency__c = 100000
        );
         insert testLead;
         
 
 
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

    
    }

    @isTest
    static void getRecordById(){
        Lead leadRecord = [SELECT Id ,FirstName, LastName FROM Lead WHERE FirstName='Test'];

        Map<String,Object> result = LeadControllerNew.getLeadById(leadRecord.Id);

        System.assertEquals(leadRecord.FirstName, result.get('firstName'));
        System.assertEquals(leadRecord.LastName, result.get('lastName'));

    }


    @isTest
    static void testGetRecords() {
        // Retrieve the test data
        Raise__c testRaise = [SELECT Id FROM Raise__c WHERE EOI__c != NULL LIMIT 1];
        
        // Set parameters
        Id recordId = testRaise.Id;
        Integer pageSize = 10;
        Integer pageNumber = 1;
        String sortBy = 'LastName';
        String sortDirection = 'ASC';
        List<String> columnNames = new List<String>{'LastName', 'FirstName', 'Id'};

        // Call the method
        LeadService.RecordsWrapper result = LeadControllerNew.getRecords(recordId, pageSize, pageNumber, sortBy, sortDirection, columnNames);

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
            LeadService.RecordsWrapper result = LeadControllerNew.getRecords(recordId, pageSize, pageNumber, sortBy, sortDirection, columnNames);
        }catch(Exception e){
            expectedE = e;
        }

        // Verify the result
        System.assertNotEquals(null, expectedE);
    }

    @isTest
    static void testUpdateLead() {
        // Retrieve the test data
        Lead testLead = [SELECT Id, Comments__c FROM Lead LIMIT 1];
        
        // Set parameters
        Id recordId = testLead.Id;
        String objectName = 'Lead';
        Map<String, Object> fieldsToUpdate = new Map<String, Object>{
            'comments' => 'new Comment'
        };

        // Call the method
        Map<String, Object> result = LeadControllerNew.updateLead(recordId, objectName, fieldsToUpdate);

        // Verify the result
        System.assertNotEquals(null, result);
        System.assertEquals(recordId, result.get('Id'));

        // Verify the update
        Lead updatedLead = [SELECT Comments__c FROM Lead WHERE Id = :recordId];
        System.assertEquals('new Comment', updatedLead.Comments__c);
    }

    @isTest
    static void testUpdateLeadException() {
        // Retrieve the test data
        
        // Set parameters
        Id recordId = 'a3XXX000000cXXXAAI';
        String objectName = 'Lead';
        Map<String, Object> fieldsToUpdate = new Map<String, Object>{
            'comments' => 'new Comment'
        };
        Exception expectedE;
        // Call the method
        try{
            Map<String, Object> result = LeadControllerNew.updateLead(recordId, objectName, fieldsToUpdate);
        }catch(Exception e){
            expectedE = e;
        }

        // Verify the result
        System.assertNotEquals(null, expectedE);
    }

    @isTest
    static void testUpdateLeadFieldUnmapped() {
        // Retrieve the test data
        Lead testLead = [SELECT Id, Comments__c FROM Lead LIMIT 1];
        
        // Set parameters
        Id recordId = testLead.Id;
        String objectName = 'Lead';
        Map<String, Object> fieldsToUpdate = new Map<String, Object>{
            'unmapped' => 'value'
        };

        // Call the method
        Map<String, Object> result = LeadControllerNew.updateLead(recordId, objectName, fieldsToUpdate);

        // Verify the result
        System.assertNotEquals(null, result);
        System.assertEquals(recordId, result.get('Id'));
        System.assertNotEquals(null, result.get('unmapped'));
    }

    @isTest
    static void testGetEOILeadsEmail() {
        // Call the method being tested and pass a valid email
        List<Map<String, Object>> results = LeadControllerNew.getEOILeadsEmail('mail@mail.com');
        // Assert that the correct lead is returned
        System.assertEquals(1, results.size(), 'Expected one lead to be returned');
    }

    @isTest
    static void testCreateLeadSXSW(){
            // Set parameters
        Map<String, String> test = new Map<String, String>{
            'firstName'=>'John',
            'middleNames' => 'Test Names',
            'lastName'=>'Smith',
            'webSource'=>'SXSW 2024',
            'email' => 'jSmith@mail.com',
            'mobileCodeFormatted' => '+61455659874',
            'isWholesale' => 'No',
            'comments' => 'Hello Lead Created',
            'source' => 'Website Form',
            'company' => 'no Company',
            'emailOptIn' => 'true',
            'utm_source' => 'Ebay',
            'utm_medium' => 'cpc',
            'utm_campaign' => '2020 Campaign',
            'utm_term' => 'None',
            'utm_content' => 'None',
            'utm_keyword' => 'Hello'
        };

        // Call the method

        Map<String, Object> result = LeadControllerNew.createLeadSXSW(test);
        System.debug(result);
        System.assert(result.containsKey('Id'), 'Result should contain an "Id" key for the created Account.');
        Id createdLead = (Id)result.get('Id');

        Lead leadRecord = [
            SELECT FirstName, 
            LastName, 
            MiddleName, 
            Web_Source__c, 
            MobilePhone, 
            Wholesale_Status__c,
            Comments__c,
            LeadSource,
            Company,
            Email_Opt_In__c  FROM Lead WHERE Id=:createdLead LIMIT 1];

        // Verify the result
        System.Assert.areEqual('John', leadRecord.FirstName);
        System.Assert.areEqual('Test Names', leadRecord.MiddleName);
        System.Assert.areEqual('Smith', leadRecord.LastName);
        System.Assert.areEqual('SXSW 2024', leadRecord.Web_Source__c);
        System.Assert.areEqual('+61455659874', leadRecord.MobilePhone);
        System.Assert.areEqual('No', leadRecord.Wholesale_Status__c);
        System.Assert.areEqual('Hello Lead Created', leadRecord.Comments__c);
        System.Assert.areEqual('Website Form', leadRecord.LeadSource);
        System.Assert.areEqual('no Company', leadRecord.Company);
        System.Assert.areEqual(true, leadRecord.Email_Opt_In__c);
    }


    @isTest
    static void testCreateLead(){
            // Set parameters
        Map<String, String> test = new Map<String, String>{
            'firstName'=>'John',
            'middleNames' => 'Test Names',
            'lastName'=>'Smith',
            'webSource'=>'SXSW 2024',
            'email' => 'jSmith@mail.com',
            'mobileCodeFormatted' => '+61455659874',
            'isWholesale' => 'No',
            'comments' => 'Hello Lead Created',
            'source' => 'Website Form',
            'company' => 'no Company',
            'emailOptIn' => 'true',
            'utm_source' => 'Ebay',
            'utm_medium' => 'cpc',
            'utm_campaign' => '2020 Campaign',
            'utm_term' => 'None',
            'utm_content' => 'None',
            'utm_keyword' => 'Hello'
        };

        // Call the method

        Map<String, Object> result = LeadControllerNew.createLead(test);
        System.debug(result);
        System.assert(result.containsKey('Id'), 'Result should contain an "Id" key for the created Account.');
        Id createdLead = (Id)result.get('Id');

        Lead leadRecord = [
            SELECT FirstName, 
            LastName, 
            MiddleName, 
            Web_Source__c, 
            MobilePhone, 
            Wholesale_Status__c,
            Comments__c,
            LeadSource,
            Company,
            Email_Opt_In__c  FROM Lead WHERE Id=:createdLead LIMIT 1];

        // Verify the result
        System.Assert.areEqual('John', leadRecord.FirstName);
        System.Assert.areEqual('Test Names', leadRecord.MiddleName);
        System.Assert.areEqual('Smith', leadRecord.LastName);
        System.Assert.areEqual('SXSW 2024', leadRecord.Web_Source__c);
        System.Assert.areEqual('+61455659874', leadRecord.MobilePhone);
        System.Assert.areEqual('No', leadRecord.Wholesale_Status__c);
        System.Assert.areEqual('Hello Lead Created', leadRecord.Comments__c);
        System.Assert.areEqual('Website Form', leadRecord.LeadSource);
        System.Assert.areEqual('no Company', leadRecord.Company);
        System.Assert.areEqual(true, leadRecord.Email_Opt_In__c);
    }

    @isTest
    static void testGetLeads() {
        // Setup test data
        Lead testLead = [SELECT Id, FirstName, LastName, Email FROM Lead WHERE Email = 'mail@mail.com' LIMIT 1];

        // Call the method being tested
        List<Map<String, Object>> results = LeadControllerNew.getLeads('mail@mail.com');

        // Assertions to verify the result
        System.assertNotEquals(null, results, 'Results should not be null');
        System.assertEquals(1, results.size(), 'Expected exactly one lead to be returned');
}


}