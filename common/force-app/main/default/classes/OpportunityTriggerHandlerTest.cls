@isTest(seeAllData=true)
public class OpportunityTriggerHandlerTest {

    // Helper method to generate a unique Account name.
    private static String uniqueAccountName() {
        return 'Test Account ' + String.valueOf(System.currentTimeMillis());
    }

    @isTest 
    static void testUpdateContact() {
        // Create an Account with a unique name.
        Account acc = new Account(Name = uniqueAccountName());
        insert acc;
        
        // Create a Contact for the Account.
        Contact con = new Contact(LastName = 'Tester', AccountId = acc.Id);
        insert con;
        
        // Insert an Opportunity without Primary_Contact__c.
        Opportunity opp = new Opportunity(
            Name = 'Test Opp for updateContact',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10),
            AccountId = acc.Id
        );
        insert opp;
        
        // Update the Opportunity to fire the before update trigger that calls updateContact.
        opp.StageName = 'Qualification';
        update opp;
        
        // Query back the Opportunity.
        opp = [SELECT Id, Primary_Contact__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertNotEquals(null, opp.Primary_Contact__c, 'Primary_Contact__c should be set by updateContact logic.');
    }

    @isTest 
    static void testCommonLogicInsert() {
        // Create an Account with a unique name.
        Account acc = new Account(Name = uniqueAccountName());
        insert acc;
        
        Opportunity opp = new Opportunity(
            Name = 'Test Opp Insert',
            StageName = 'Application Received',
            LeadSource = 'VC Website Organic',
            CloseDate = Date.today().addDays(10),
            AccountId = acc.Id
        );
        insert opp;
        
        // Query the Opportunity to verify that Web_Source__c was set.
        opp = [SELECT Id, Web_Source__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals('Invest Now Form', opp.Web_Source__c,
                            'Web_Source__c should be set to "Invest Now Form" on insert.');
    }
    @isTest 
    static void testCommonLogicUpdateEOI() {
        // Retrieve the VCPP record type Id.
        Id vcppRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('VCPP').getRecordTypeId();
        
        // Create an Account with a unique name.
        Account acc = new Account(Name = uniqueAccountName());
        insert acc;
        
        // Create a Contact.
        Contact con = new Contact(
            LastName = 'EOI Tester',
            Email = 'eoi@test.com',
            MobilePhone = '1234567890',
            AccountId = acc.Id
        );
        insert con;
        
        // Create a Product record to supply Invested_Product_ADMIN_FIELD__c.
        Product2 prod = new Product2(
            Name = 'Test Product',
            Tile_Banner__c = 'http://example.com/banner.png'
        );
        insert prod;
        
        // Insert an Opportunity with stage 'EOI'
        // and with Unit_Cert_Issued__c left null.
        Opportunity opp = new Opportunity(
            Name = 'Test Opp EOI',
            StageName = 'EOI',
            CloseDate = Date.today().addDays(10),
            AccountId = acc.Id,
            RecordTypeId = vcppRtId,
            Create_EOI_Application__c = false,
            Unit_Cert_Issued__c = null,  // Initially null so trigger condition is met on update
            Initial_Term_Expiry__c = 12,
            Primary_Contact__c = con.Id,
            Invested_Product_ADMIN_FIELD__c = prod.Id
        );
        insert opp;
        
        // Now update the Opportunity and set Unit_Cert_Issued__c.
        opp.Unit_Cert_Issued__c = Date.today();
        update opp;
        
        // Query back the updated Opportunity.
        opp = [SELECT Id, Create_EOI_Application__c, Maturation_Date__c 
            FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(true, opp.Create_EOI_Application__c,
                            'Create_EOI_Application__c should be set to true after update.');
        System.assertNotEquals(null, opp.Maturation_Date__c,
                            'Maturation_Date__c should be calculated based on Unit_Cert_Issued__c and Initial_Term_Expiry__c.');
        
        // Verify that an Application__c record was created.
        List<Application__c> apps = [SELECT Id, Contact__c 
                                    FROM Application__c 
                                    WHERE Opportunity__c = :opp.Id];
        System.assert(apps.size() > 0, 'An Application__c record should have been created for the Opportunity.');
        if(apps[0].Contact__c != null) {
            System.assert(String.valueOf(apps[0].Contact__c).length() == 18,
                        'Application__c.Contact__c should be a valid Salesforce Id.');
        }
    }

    
}