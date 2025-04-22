public class ContactController {
    public String name{get;set;}
    public String email{get;set;}
    public String message{get;set;}
    public String helptext{get;set;}
    public String publicKey {get;set;}
    public String succesMessage {get;set;}
    public Boolean iscapthcaverified {get;set;}
    public Boolean showsuccess {get;set;}
    
    public EmailData emailinfo{get;set;}
    
    
    //Google Secret Key
    private static String secretKey = '6LeAF1IaAAAAACZU-reod-LIe34M-5k27AWuWMbi';
    private static String baseUrl = '<a class="vglnk" href="https://www.google.com/recaptcha/api/siteverify" rel="nofollow"><span>https</span><span>://</span><span>www</span><span>.</span><span>google</span><span>.</span><span>com</span><span>/</span><span>recaptcha</span><span>/</span><span>api</span><span>/</span><span>siteverify</span></a>';
    public Boolean verified { get; private set; }
    public String response  { 
        get {
            return ApexPages.currentPage().getParameters().get('g-recaptcha-response');
        }
    }
    
    public  List<SelectOption> gethelppicklist(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('SELECT ONE','SELECT ONE'));
        options.add(new SelectOption('Investing','Investing'));
        options.add(new SelectOption('Raising Capital','Raising Capital'));
        options.add(new SelectOption('Listing a Property','Listing a Property'));
        options.add(new SelectOption('Private Sendicate form','Private Sendicate form'));
        options.add(new SelectOption('Other','Other'));
        return options;
        
    }

    public ContactController(){
        this.publicKey = '6LeAF1IaAAAAALOpsWcpS43YiTB5okf-xNa7PCms';//Google Site Key or Public Key
        this.verified = false;
        this.emailinfo=new EmailData();
        this.succesMessage='';
        if(ApexPages.currentPage().getparameters().containsKey('succesMessage')){
        this.succesMessage=ApexPages.currentPage().getparameters().get('succesMessage');
        ApexPages.currentPage().getparameters().put('succesMessage','');
            
        }
    }
    
    public pagereference sendEmail() {
        System.debug('sendemail');
        
        List<Messaging.SingleEmailMessage> mails = 
            new List<Messaging.SingleEmailMessage>();
        
        
        // Step 1: Create a new Email
        Messaging.SingleEmailMessage mail = 
            new Messaging.SingleEmailMessage();
        
        // Step 2: Set list of people who should get the email
        List<String> sendTo = new List<String>();
        // sendTo.add('hello@venturecrowd.com.au');  // This is for Production
        sendTo.add('harmony.lam@akcelo.com');    // This is for QA purpose
       // sendTo.add('mayurkumar.maisuriya@akcelo.com');    // This is for Developer purpose
        mail.setToAddresses(sendTo);
        
        // Step 3: Set who the email is sent from
        mail.setReplyTo(emailinfo.email);
        // mail.setSenderDisplayName('Official Bank of Nigeria');
        // Step 4. Set email contents - you can use variables!
        mail.setSubject(emailinfo.helptext);
        String body = emailinfo.message+ '<br/>' +' Thanks' + '<br/>' +emailinfo.name;
        
        mail.setHtmlBody(body);
        mails.add(mail);
        
        
        // Step 6: Send all emails in the master list
        Messaging.sendEmail(mails);
        this.iscapthcaverified=false;
        this.emailinfo=new EmailData();
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Success! Thanks for your enquiry, we’ll be in touch with you soon.'));
        
       PageReference myPage = Page.VC_CF_About;
        myPage.setRedirect(true);
        myPage.getParameters().put('succesMessage','Success! Thanks for your enquiry, we’ll be in touch with you soon.');
        return myPage;
     //   return null;
        
    }
    public PageReference verifycaptcha(){
        system.debug('verifying captcha');
        this.iscapthcaverified=true;
        return null;
    }
    public class EmailData{
    public String name{get;set;}
    public String email{get;set;}
    public String message{get;set;}
    public String helptext{get;set;}
    }
       
}