@isTest
public class MediaLinkFactoryTest {
    @testSetup
    static void setupTestData() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Raise__c testRaise = new Raise__c(Name = 'Test Raise', Account__c = testAccount.Id, Company__c = testAccount.Id);
        insert testRaise;

        Raise_Media_Links__c testMediaLink = new Raise_Media_Links__c(Name = 'Test Media Link', Media_URL__c = 'https://testlink.com', Related_Raise__c = testRaise.Id);
        insert testMediaLink;
    }

    @isTest
    static void testGetMediaLinksByRaiseId() {
        Raise__c testRaise = [SELECT Id FROM Raise__c LIMIT 1];
        MediaLinkFactory factory = new MediaLinkFactory();

        Test.startTest();
        List<Raise_Media_Links__c> mediaLinks = factory.getMediaLinksByRaiseId(testRaise.Id);
        Test.stopTest();

        System.assertEquals(1, mediaLinks.size());
        System.assertEquals('Test Media Link', mediaLinks[0].Name);
        System.assertEquals('https://testlink.com', mediaLinks[0].Media_URL__c);
    }


    @isTest
    static void testCreateMediaLink() {
        Raise__c testRaise = [SELECT Id FROM Raise__c LIMIT 1];
        MediaLinkFactory factory = new MediaLinkFactory();

        Test.startTest();
        Raise_Media_Links__c newMediaLink = factory.createMediaLink(testRaise.Id, 'New Media Link', 'https://newlink.com');
        Test.stopTest();

        System.assertNotEquals(null, newMediaLink.Id);
        System.assertEquals('New Media Link', newMediaLink.Name);
        System.assertEquals('https://newlink.com', newMediaLink.Media_URL__c);
    }

    @isTest
    static void testCreateMediaLink_Exception() {
        MediaLinkFactory factory = new MediaLinkFactory();

        Test.startTest();
        try {
            factory.createMediaLink(null, 'Invalid Media Link', 'https://invalidlink.com');
            System.assert(false, 'Expected exception not thrown');
        } catch (Exception e) {
            System.assert(e instanceof AuraHandledException, 'Expected AuraHandledException');
        }
        Test.stopTest();
    }

    @isTest
    static void testDeleteMediaLink() {
        Raise_Media_Links__c testMediaLink = [SELECT Id FROM Raise_Media_Links__c LIMIT 1];
        MediaLinkFactory factory = new MediaLinkFactory();

        Test.startTest();
        factory.deleteMediaLink(testMediaLink.Id);
        Test.stopTest();
        try{
            Raise_Media_Links__c deletedMediaLink = [SELECT Id FROM Raise_Media_Links__c WHERE Id = :testMediaLink.Id LIMIT 1];
        }catch(Exception e){
            System.assertNotEquals(null, e);
        }
    }

    @isTest
    static void testDeleteMediaLink_Exception() {
        MediaLinkFactory factory = new MediaLinkFactory();

        Test.startTest();
        try {
            factory.deleteMediaLink(null);
            System.assert(false, 'Expected exception not thrown');
        } catch (Exception e) {
            System.assert(e instanceof AuraHandledException, 'Expected AuraHandledException');
        }
        Test.stopTest();
    }

    @isTest
    static void testEditMediaLink() {
        Raise_Media_Links__c testMediaLink = [SELECT Id FROM Raise_Media_Links__c LIMIT 1];
        MediaLinkFactory factory = new MediaLinkFactory();

        Test.startTest();
        Raise_Media_Links__c updatedMediaLink = factory.editMediaLink(testMediaLink.Id, 'Updated Media Link', 'https://updatedlink.com');
        Test.stopTest();

        System.assertEquals('Updated Media Link', updatedMediaLink.Name);
        System.assertEquals('https://updatedlink.com', updatedMediaLink.Media_URL__c);
    }

    @isTest
    static void testEditMediaLink_Exception() {
        MediaLinkFactory factory = new MediaLinkFactory();

        Test.startTest();
        try {
            factory.editMediaLink(null, 'Invalid Media Link', 'https://invalidlink.com');
            System.assert(false, 'Expected exception not thrown');
        } catch (Exception e) {
            System.assert(e instanceof AuraHandledException, 'Expected AuraHandledException');
        }
        Test.stopTest();
    }

    @isTest
    static void testGetMediaLinkById() {
        Raise_Media_Links__c testMediaLink = [SELECT Id, Name, Media_URL__c FROM Raise_Media_Links__c LIMIT 1];
        MediaLinkFactory factory = new MediaLinkFactory();

        Test.startTest();
        Raise_Media_Links__c mediaLink = factory.getMediaLinkById(testMediaLink.Id);
        Test.stopTest();

        System.assertEquals(testMediaLink.Id, mediaLink.Id);
        System.assertEquals(testMediaLink.Name, mediaLink.Name);
        System.assertEquals(testMediaLink.Media_URL__c, mediaLink.Media_URL__c);
    }

    @isTest
    static void testGetMediaLinkById_Exception() {
        MediaLinkFactory factory = new MediaLinkFactory();

        Test.startTest();
        try {
            factory.getMediaLinkById(null);
            System.assert(false, 'Expected exception not thrown');
        } catch (Exception e) {
            System.assert(e instanceof AuraHandledException, 'Expected AuraHandledException');
        }
        Test.stopTest();
    }
}