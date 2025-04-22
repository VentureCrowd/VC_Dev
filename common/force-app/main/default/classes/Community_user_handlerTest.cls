@isTest
public class Community_user_handlerTest {

     @isTest
    public static void testGetCurrentUser(){
         Test.startTest();
        Community_user_handler.getCurrentUser();
         Test.stopTest();

        System.assert( Community_user_handler.getCurrentUser() != null);
    }
}