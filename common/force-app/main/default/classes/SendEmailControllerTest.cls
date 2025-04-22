@isTest
public class SendEmailControllerTest {

    @isTest
    public static void sendEmailTest(){
        
        Test.StartTest();
        SendEmailController.notifyEmail('Mayur', 'abc@test.com', 'Investing', 'Test Message');
         Integer invocations = Limits.getEmailInvocations();
         SendEmailController.EmailData econ = new SendEmailController.EmailData();
        econ.name = 'Mayur';
        econ.helptext = 'Investing';
        econ.email = 'abc@test.com';
        econ.message = 'Test Message';
         Test.stopTest();
 
        System.assertEquals(1, invocations, 'An email has not been sent');
        
    }
    
   
}