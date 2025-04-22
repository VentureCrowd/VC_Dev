@isTest
public class LoqateHelperTest {
    @isTest
    static void testmethod1(){
        Test.setMock(HttpCalloutMock.class, new LoqateHelper_Mock1());
        LoqateHelper.loqateFinder('au','au');
    }
    @isTest
    static void testmethod2(){
        Test.setMock(HttpCalloutMock.class, new LoqateHelper_Mock2());
        LoqateHelper.loqateRetriever('au');
    }
}