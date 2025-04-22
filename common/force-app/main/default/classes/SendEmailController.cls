public class SendEmailController {
    
    @AuraEnabled
    public static void notifyEmail(String name,String email, String helptext,String message) {
        System.debug('sendemail email='+email);
        
        List<Messaging.SingleEmailMessage> mails = 
            new List<Messaging.SingleEmailMessage>();
        
        
        // Step 1: Create a new Email
        Messaging.SingleEmailMessage mail = 
            new Messaging.SingleEmailMessage();
        
        // Step 2: Set list of people who should get the email
        List<String> sendTo = new List<String>();
        sendTo.add('hello@venturecrowd.com.au');  // This is for Production
        // sendTo.add('harmony.lam@akcelo.com');   
        //sendTo.add('{!Label.VC_CF_Sendemail}');   
        
        // sendTo.add('mayurkumar.maisuriya@akcelo.com');    // This is for Developer purpose
        mail.setToAddresses(sendTo);
        
        // Step 3: Set who the email is sent from
        mail.setReplyTo(email);
        
        // Step 4. Set email contents - you can use variables!
        mail.setSubject(helptext);
        String body = ' <b> Name: </b> ' + name +'<br/>'+ 
                      '<b> Email: </b>' + email +'<br/>'+
                      '<b>What can we help with: </b>' + helptext  +'<br/>'+
                      '<b>Message: </b>' + message+ '<br/>' ;
        
        
        mail.setHtmlBody(body);
        mails.add(mail);
        
        
        // Step 6: Send all emails in the master list
        Messaging.sendEmail(mails);
        
        
    }
    
    public class EmailData{
        @AuraEnabled public String name{get;set;}
        @AuraEnabled public String email{get;set;}
        @AuraEnabled public String message{get;set;}
        @AuraEnabled public String helptext{get;set;}
    }
}