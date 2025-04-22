@isTest
private class EOI_Controller_Test {

    @TestSetup
    static void setup() {
        User owner = [SELECT Id FROM USER WHERE Name = 'The VentureCrowd Team'];
        Id recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('VC Person Account').getRecordTypeId();

        // Create a test Business Account and related Person Account
        Account personAccount = new Account(
            FirstName = 'TestPersonAccountFirst',
            LastName = 'TestPersonAccountLast',
            PersonEmail = 'test@user.com',
            RecordTypeId = recordTypeId,
            // Name = 'Test Account',
            OwnerId = owner.Id
        );
        insert personAccount;

        Account businessAccount = new Account(Name = 'Test Business', Related_Person_Account__c = personAccount.Id);
        insert businessAccount;

        Profile testProfile = [SELECT Id, Name FROM Profile WHERE Name = 'VC Investor Community Plus Login' LIMIT 1];
    
        Contact getContact = [SELECT Id, Name FROM Contact WHERE FirstName = 'TestPersonAccountFirst'];

        User testUser = new User(
        FirstName = 'TestingUserN2',
        Username = 'testUser_n2@test.com',
        LastName = 'TestAds',
        // ContactId = testContact.Id,
        Email = 'testUser_n2@test.com',
        Alias = 'tuser',
        TimeZoneSidKey = 'America/Los_Angeles',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        ProfileId = testProfile.Id,
        ContactId = getContact.Id
        );
        insert testUser;

         // Create a test EOI
        EOI__c eoi = new EOI__c(
            Name = 'Test EOI',
            Account__c = businessAccount.Id,
            EOI_Status__c = 'Published',
            Publish_on_Community_Site__c = true,
            URL_Files_Img__c = 'http://example.com/image.png',
            Published_EOI_URL__c = 'http://example.com/eoi',
            One_liner_about_business__c = 'Innovative business idea',
            SXSW_Finalist__c = true,
            EOI_Title__c = 'Exciting EOI Title',
            Internal_Owner__c=owner.Id
        );
        insert eoi;

        EOI__c eoi2 = new EOI__c(
            Name = 'EOI new',
            Account__c = businessAccount.Id,
            EOI_Status__c = 'Published',
            Publish_on_Community_Site__c = true,
            URL_Files_Img__c = 'http://example.com/image.png',
            Published_EOI_URL__c = 'http://example.com/eoi',
            One_liner_about_business__c = 'Innovative business idea',
            SXSW_Finalist__c = true,
            EOI_Title__c = 'Exciting EOI Title',
            Internal_Owner__c=owner.Id
        );
        insert eoi2;

         // Create a test Raise (unrelated to this test but provided in the setup)
        Raise__c testRaise = new Raise__c(
            Name = 'Existing Raise',
            Company__c = businessAccount.Id,
            EOI__c = eoi.Id,
            Account__c = personAccount.Id,
            Owner__c = owner.Id
        );
        insert testRaise;

         // Create a test Raise (unrelated to this test but provided in the setup)
        Raise__c testRaise2 = new Raise__c(
            Name = 'Existing Raise 2',
            Company__c = businessAccount.Id,
            EOI__c = eoi2.Id,
            Account__c = personAccount.Id,
            Form_Company_Name__c = 'TEST NAME',
            Owner__c = owner.Id,
            Status__c = 'Live'
        );
        insert testRaise2;
    }

    @isTest
    static void testGetEoiOfferInformation_Success() {
        // Call the controller method to get EOI offer information
        Test.startTest();
        String jsonResult = EOI_Controller.getEoiOfferInformation();
        Test.stopTest();

        // Deserialize the JSON result to a list of EOI_Service.EoiOfferData
        List<EOI_Service.EoiOfferData> eoiDataList = (List<EOI_Service.EoiOfferData>) JSON.deserialize(jsonResult, List<EOI_Service.EoiOfferData>.class);

        // Validate the results
        System.assertNotEquals(null, eoiDataList, 'EOI data list should not be null');
        System.assertEquals(1, eoiDataList.size(), 'There should be 2 EOI records returned');
        System.assertEquals('Exciting EOI Title', eoiDataList[0].tileHeading, 'The EOI title should match the expected value');
        System.assertEquals('http://example.com/eoi', eoiDataList[0].dealPageLink, 'The EOI deal page link should match the expected value');
    }

    @isTest
    static void testGetSXSWEoiOfferInformation_Success() {
        // Call the controller method to get EOI offer information
        Test.startTest();
        String jsonResult = EOI_Controller.getEoiSXSWOfferInformation('');
        Test.stopTest();

        // Deserialize the JSON result to a list of EOI_Service.EoiOfferData
        List<EOI_Service.EoiOfferData> eoiDataList = (List<EOI_Service.EoiOfferData>) JSON.deserialize(jsonResult, List<EOI_Service.EoiOfferData>.class);

        // Validate the results
        System.assertNotEquals(null, eoiDataList, 'EOI data list should not be null');
        System.assertEquals(1, eoiDataList.size(), 'There should be one EOI record returned');
        System.assertEquals('Exciting EOI Title', eoiDataList[0].tileHeading, 'The EOI title should match the expected value');
        System.assertEquals('http://example.com/eoi', eoiDataList[0].dealPageLink, 'The EOI deal page link should match the expected value');
    }

    @isTest
    static void testGetSXSWEoiOfferInformation_SuccessSearch() {
        // Call the controller method to get EOI offer information
        Test.startTest();
        String jsonResult = EOI_Controller.getEoiSXSWOfferInformation('Test');
        Test.stopTest();

        // Deserialize the JSON result to a list of EOI_Service.EoiOfferData
        List<EOI_Service.EoiOfferData> eoiDataList = (List<EOI_Service.EoiOfferData>) JSON.deserialize(jsonResult, List<EOI_Service.EoiOfferData>.class);

        // Validate the results
        System.assertNotEquals(null, eoiDataList, 'EOI data list should not be null');
        System.assertEquals(1, eoiDataList.size(), 'There should be one EOI record returned');
        System.assertEquals('Exciting EOI Title', eoiDataList[0].tileHeading, 'The EOI title should match the expected value');
        System.assertEquals('http://example.com/eoi', eoiDataList[0].dealPageLink, 'The EOI deal page link should match the expected value');
    }

    @isTest
    static void testGetLiveRaises() {
        EOI__c eoi = [SELECT Id, Name FROM EOI__c WHERE Name='EOI new'];
        // Call the controller method to get EOI offer information
        
        Test.startTest();
        
        Map<String,Object> raises = EOI_Controller.getLiveRaiseFromEOI(eoi.Id);


        Test.stopTest();

        System.assertNotEquals(null, raises, 'Raise data list should not be null');
    }

    @isTest
    static void testGetLiveRaisesNone() {
        EOI__c eoi = [SELECT Id, Name FROM EOI__c WHERE Name='Test EOI'];
        // Call the controller method to get EOI offer information
        Test.startTest();
        try {
            Map<String,Object> raises = EOI_Controller.getLiveRaiseFromEOI(eoi.Id);
            System.assert(false, 'An exception should have been thrown because no Raises are available');
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage(), 'Expected exception message not received');
        }
        Test.stopTest();
    }

    @isTest
    static void testGetEoiOfferInformation_NoEOIs() {
        // Delete all EOIs to simulate the scenario where no records exist

        // Call the controller method to get EOI offer information
        Test.startTest();
        delete [SELECT Id FROM EOI__c];

        try {
            EOI_Controller.getEoiOfferInformation();
            System.assert(false, 'An exception should have been thrown because no EOIs are available');
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage(), 'Expected exception message not received');
        }
        Test.stopTest();
    }

    @isTest
    static void testGetSXSWEoiOfferInformation_NoEOIs() {
        // Delete all EOIs to simulate the scenario where no records exist

        // Call the controller method to get EOI offer information
        Test.startTest();
        delete [SELECT Id FROM EOI__c];

        try {
            EOI_Controller.getEoiSXSWOfferInformation('');
            System.assert(false, 'An exception should have been thrown because no EOIs are available');
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage(), 'Expected exception message not received');
        }
        Test.stopTest();
    }

    // Test case to check that the EOI is correctly returned when an ID is provided
    @isTest
    static void testGetEoiInformation_Success() {
        // Get the test EOI record's ID
        EOI__c testEoi = [SELECT Id FROM EOI__c WHERE Name = 'Test EOI' LIMIT 1];
        
        // Call the controller method to get EOI information
        Test.startTest();
        List<EOI__c> result = EOI_Controller.getEoiInformation(testEoi.Id);
        Test.stopTest();

        // Validate the results
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(1, result.size(), 'There should be one EOI record returned');
    }

    // Test case to check the behavior when an invalid or non-existing EOI ID is provided
    // @isTest
    // static void testGetEoiInformation_InvalidId() {
    //     Test.startTest();
    //     try {
    //         // Pass a non-existent EOI Id
    //         Id eoiID = '005000000000001';
    //         EOI_Controller.getEoiInformation(eoiID);
    //         System.assert(false, 'An exception should have been thrown for an invalid EOI ID');
    //     } catch (Exception e) {
    //         System.assert(true, 'Exception should have been thrown for wrong user ID');
    //     }
    //     Test.stopTest();
    // }

    @isTest
    static void testGetEOIbyID(){
        EOI__c testEOI = [SELECT Id, Name FROM EOI__c WHERE Name='Test EOI'];

        Test.startTest();
        EOI_Controller.getEOIByID(testEOI.Id);

        Test.stopTest();
    }

    @isTest
    static void testGetEOIbyIDInvalidEOIID(){
        Id testEOIID = 'a2vIo00000009HsIAI';

        Test.startTest();
        try{
            EOI_Controller.getEOIByID(testEOIID);
            System.assert(false, 'An exception should have been thrown because no EOIs are available');
        }catch(Exception e){
            System.assertNotEquals(null, e.getMessage(), 'Expected exception message not received');
        }
       

        Test.stopTest();
    }
}