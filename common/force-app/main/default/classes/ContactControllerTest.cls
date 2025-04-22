@isTest
public class ContactControllerTest {

    @isTest
    public static void sendEmailTest(){
        ContactController ctrl=new ContactController();
        ctrl.name='Send Email';
         ctrl.email='SendEmail@gmail.com';
         ctrl.message='This is test email';
         ctrl.helptext='Investing';
        ctrl.showsuccess = true;
        
        ctrl.sendEmail();
        
    }
 @isTest
    public static void PageLoadTest(){
       PageReference pageRef=Page.VC_CF_About;
       Test.setCurrentPage(pageRef);   
        ContactController ctrl=new ContactController();
        ctrl.verifycaptcha();
        
         System.assertEquals(true,ctrl.iscapthcaverified);
        List<SelectOption> options= ctrl.gethelppicklist();
        System.assertEquals(6,options.size());
    }    
    
}