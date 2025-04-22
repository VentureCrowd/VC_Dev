@isTest
public class MediaLinkControllerTest {
    // Setup test data before running the tests
    @testSetup
    static void setupTestData() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Raise__c testRaise = new Raise__c(Name = 'Test Raise', Account__c = testAccount.Id, Company__c = testAccount.Id);
        insert testRaise;

        Raise_Media_Links__c testMediaLink = new Raise_Media_Links__c(Name = 'Test Media Link', Media_URL__c = 'https://testlink.com', Related_Raise__c = testRaise.Id);
        insert testMediaLink;
    }

    // Test the retrieval of media links by Raise ID
    @isTest
    static void testGetMediaLinksByRaiseId() {
        Raise__c testRaise = [SELECT Id FROM Raise__c LIMIT 1];

        Test.startTest();
        List<Map<String, String>> mediaLinks = MediaLinkController.getMediaLinksByRaiseId(testRaise.Id);
        Test.stopTest();

        System.assertEquals(1, mediaLinks.size());
        System.assertEquals('Test Media Link', mediaLinks[0].get('name'));
        System.assertEquals('https://testlink.com', mediaLinks[0].get('link'));
    }

    // Test the creation of a new media link
    @isTest
    static void testCreateMediaLink() {
        Raise__c testRaise = [SELECT Id FROM Raise__c LIMIT 1];

        Test.startTest();
        Map<String, String> newMediaLink = MediaLinkController.createMediaLink(testRaise.Id, 'New Media Link', 'https://newlink.com');
        Test.stopTest();

        System.assertNotEquals(null, newMediaLink.get('id'));
        System.assertEquals('New Media Link', newMediaLink.get('name'));
        System.assertEquals('https://newlink.com', newMediaLink.get('link'));
    }

    // Test exception handling during media link creation
    @isTest
    static void testCreateMediaLink_Exception() {
        Test.startTest();
        try {
            MediaLinkController.createMediaLink(null, 'Invalid Media Link', 'https://invalidlink.com');
            System.assert(false, 'Expected exception not thrown');
        } catch (Exception e) {
            System.assert(e instanceof AuraHandledException, 'Expected AuraHandledException');
        }
        Test.stopTest();
    }

    // Test the deletion of a media link
    @isTest
    static void testDeleteMediaLink() {
        Raise_Media_Links__c testMediaLink = [SELECT Id FROM Raise_Media_Links__c LIMIT 1];

        Test.startTest();
        Boolean result = MediaLinkController.deleteMediaLink(testMediaLink.Id);
        Test.stopTest();

        System.assert(result, 'Expected true but got false');
    }

    // Test exception handling during media link deletion
    @isTest
    static void testDeleteMediaLink_Exception() {
        Test.startTest();
        Boolean result = MediaLinkController.deleteMediaLink(null);
        System.assertEquals(false, result);
        Test.stopTest();
    }

    // Test the editing of a media link
    @isTest
    static void testEditMediaLink() {
        Raise_Media_Links__c testMediaLink = [SELECT Id FROM Raise_Media_Links__c LIMIT 1];

        Test.startTest();
        Map<String, String> updatedMediaLink = MediaLinkController.editMediaLink(testMediaLink.Id, 'Updated Media Link', 'https://updatedlink.com');
        Test.stopTest();

        System.assertEquals('Updated Media Link', updatedMediaLink.get('name'));
        System.assertEquals('https://updatedlink.com', updatedMediaLink.get('link'));
    }

    // Test exception handling during media link editing
    @isTest
    static void testEditMediaLink_Exception() {
        Test.startTest();
        try {
            MediaLinkController.editMediaLink(null, 'Invalid Media Link', 'https://invalidlink.com');
            System.assert(false, 'Expected exception not thrown');
        } catch (Exception e) {
            System.assert(e instanceof AuraHandledException, 'Expected AuraHandledException');
        }
        Test.stopTest();
    }

    // Test the retrieval of a media link by its ID
    @isTest
    static void testGetMediaLinkById() {
        Raise_Media_Links__c testMediaLink = [SELECT Id, Name, Media_URL__c FROM Raise_Media_Links__c LIMIT 1];

        Test.startTest();
        Map<String, String> mediaLink = MediaLinkController.getMediaLinkById(testMediaLink.Id);
        Test.stopTest();

        System.assertEquals(testMediaLink.Id, mediaLink.get('id'));
        System.assertEquals(testMediaLink.Name, mediaLink.get('name'));
        System.assertEquals(testMediaLink.Media_URL__c, mediaLink.get('link'));
    }

    // Test exception handling during media link retrieval by ID
    @isTest
    static void testGetMediaLinkById_Exception() {
        Test.startTest();
        try {
            MediaLinkController.getMediaLinkById(null);
            System.assert(false, 'Expected exception not thrown');
        } catch (Exception e) {
            System.assert(e instanceof AuraHandledException, 'Expected AuraHandledException');
        }
        Test.stopTest();
    }
}