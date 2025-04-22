@isTest
public class TestRaisePDFGenerator {

    @isTest
    static void testGenerateAndSaveRaisePDF() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Account testCompany = new Account(Name = 'Test Company');
        insert testCompany;

        Raise__c raiseRecord = new Raise__c(
            Name = 'Test Raise',
            Account__c = testAccount.Id,
            Company__c = testCompany.Id,
            Form_Company_Legal_Trading_Name__c = 'Test Legal Name',
            Form_Registered_Aus__c = true,
            Form_ABN__c = '123456789',
            Form_ACN__c = '987654321',
            Form_Company_Street_Address__c = '123 Test Street',
            Form_Company_Overview__c = 'Test Overview',
            Form_Business_strategy__c = 'Test Strategy',
            Form_Business_model__c = 'Test Model',
            Form_Organisation_structure__c = 'Test Structure',
            Form_Proprietary_company__c = true,
            Form_Public_company__c = false,
            Form_Financial_information_summary__c = 'Test Summary',
            Form_Debt_funding_and_other_funding__c = 'Test Funding',
            Form_Legal_or_disciplinary_action__c = 'None',
            Form_Risks_facing_the_business__c = 'Test Risks',
            Form_Planned_use_of_funds__c = 'Test use of funds',
            Form_Offer_launch_date__c = Date.today(),
            Form_Offer_close_date__c = Date.today().addDays(30),
            Form_Investment_Product_Type__c = 'ordinary shares',
            Form_Valuation__c = 1000000.00,
            Form_Number_of_shares_on_issue__c = 1000,
            Form_Rights_associated_with_shares__c = 'Test Rights',
            Form_Details_of_previous_CSF_offers__c = 'None',
            Form_Target_amount__c = 100000.00,
            Form_Minimum_target__c = 50000.00,
            Form_Maximum_target__c = 150000.00,
            Form_Minimum_Investment_amount__c = 1000.00,
            Form_Risk_warning__c = 'Test Warning',
            Form_Cooling_off_rights__c = 'Test Rights',
            Form_Glossary__c = 'Test Glossary'
        );
        insert raiseRecord;

        Raise_Team_and_Advisors__c teamRecord = new Raise_Team_and_Advisors__c(
            Role__c = 'Advisor',
            Name__c = 'Test Advisor',
            Related_Raise__c = raiseRecord.Id
        );
        insert teamRecord;

        RaisePDFGenerator.PDFGenerationRequest request = new RaisePDFGenerator.PDFGenerationRequest();
        request.raiseId = raiseRecord.Id;
        request.targetRecordId = raiseRecord.Id;

        Test.startTest();
        TestRaisePDFGeneratorMock mock = new TestRaisePDFGeneratorMock();
        mock.generateAndSaveRaisePDFInternal(new List<RaisePDFGenerator.PDFGenerationRequest>{ request });
        Test.stopTest();

        ContentVersion cv = [
            SELECT Id, Title 
            FROM ContentVersion 
            WHERE Title = :('Offer Document_' + raiseRecord.Name + '.pdf') 
            LIMIT 1
        ];
        System.assertNotEquals(null, cv, 'PDF ContentVersion should be created');

        ContentDocumentLink cdl = [
            SELECT Id, LinkedEntityId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :raiseRecord.Id 
            LIMIT 1
        ];
        System.assertNotEquals(null, cdl, 'ContentDocumentLink should be created');
    }

    @isTest
    static void testGenerateAndSaveRaisePDF_MissingIDs() {
        RaisePDFGenerator.PDFGenerationRequest invalidRequest = new RaisePDFGenerator.PDFGenerationRequest();
        invalidRequest.raiseId = null;
        invalidRequest.targetRecordId = null;

        Test.startTest();
        RaisePDFGenerator.generateAndSaveRaisePDF(new List<RaisePDFGenerator.PDFGenerationRequest>{ invalidRequest });
        Test.stopTest();

        Integer cvCount = [SELECT COUNT() FROM ContentVersion];
        System.assertEquals(0, cvCount, 'No ContentVersion should be created with missing IDs.');
    }

@isTest
static void testGetPDFBlob_ExceptionScenario() {
    Account testAccount = new Account(Name = 'Test Exception Account');
    insert testAccount;

    Raise__c raiseRecord = new Raise__c(Name = 'Test Raise Exception', Account__c = testAccount.Id);
    insert raiseRecord;

    RaisePDFGenerator.PDFGenerationRequest request = new RaisePDFGenerator.PDFGenerationRequest();
    request.raiseId = raiseRecord.Id;
    request.targetRecordId = raiseRecord.Id;

    TestRaisePDFGeneratorFailMock mock = new TestRaisePDFGeneratorFailMock();

    Test.startTest();
    try {
        mock.generateAndSaveRaisePDFInternal(new List<RaisePDFGenerator.PDFGenerationRequest>{ request });
    } catch (Exception e) {
        System.debug('Caught (but not asserting on) exception: ' + e.getMessage());
    }
    Test.stopTest();
}
}