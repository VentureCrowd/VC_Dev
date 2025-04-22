@isTest
public class MediaLinkServiceTest {
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
        MediaLinkService service = new MediaLinkService();

        Test.startTest();
        List<Map<String, String>> mediaLinks = service.getMediaLinksByRaiseId(testRaise.Id);
        Test.stopTest();

        System.assertEquals(1, mediaLinks.size());
        System.assertEquals('Test Media Link', mediaLinks[0].get('name'));
        System.assertEquals('https://testlink.com', mediaLinks[0].get('link'));
    }

        @isTest
    static void testCreateMediaLink() {
        Raise__c testRaise = [SELECT Id FROM Raise__c LIMIT 1];
        MediaLinkService service = new MediaLinkService();

        Test.startTest();
        Map<String, String> newMediaLink = service.createMediaLink(testRaise.Id, 'New Media Link', 'https://newlink.com');
        Test.stopTest();

        System.assertNotEquals(null, newMediaLink.get('id'));
        System.assertEquals('New Media Link', newMediaLink.get('name'));
        System.assertEquals('https://newlink.com', newMediaLink.get('link'));
    }

    @isTest
    static void testDeleteMediaLink() {
        Raise_Media_Links__c testMediaLink = [SELECT Id FROM Raise_Media_Links__c LIMIT 1];
        MediaLinkService service = new MediaLinkService();

        Test.startTest();
        service.deleteMediaLink(testMediaLink.Id);
        Test.stopTest();

        Boolean isDeleted = [SELECT COUNT() FROM Raise_Media_Links__c WHERE Id = :testMediaLink.Id] == 0;
        System.assert(isDeleted);
    }

    @isTest
    static void testEditMediaLink() {
        Raise_Media_Links__c testMediaLink = [SELECT Id, Related_Raise__c FROM Raise_Media_Links__c LIMIT 1];
        MediaLinkService service = new MediaLinkService();

        Test.startTest();
        Map<String, String> updatedMediaLink = service.editMediaLink(testMediaLink.Id, 'Updated Media Link', 'https://updatedlink.com');
        Test.stopTest();

        System.assertEquals('Updated Media Link', updatedMediaLink.get('name'));
        System.assertEquals('https://updatedlink.com', updatedMediaLink.get('link'));
    }

    @isTest
    static void testGetMediaLinkById() {
        Raise_Media_Links__c testMediaLink = [SELECT Id, Name, Media_URL__c FROM Raise_Media_Links__c LIMIT 1];
        MediaLinkService service = new MediaLinkService();

        Test.startTest();
        Map<String, String> mediaLink = service.getMediaLinkById(testMediaLink.Id);
        Test.stopTest();

        System.assertEquals(testMediaLink.Id, mediaLink.get('id'));
        System.assertEquals(testMediaLink.Name, mediaLink.get('name'));
        System.assertEquals(testMediaLink.Media_URL__c, mediaLink.get('link'));
    }
}