@isTest
class InboundEmailHandler_test {
    @isTest
    public static void handleInboundEmailTest() {
        Messaging.InboundEmail email = new Messaging.InboundEmail();        
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'Test';
        email.fromAddress = 'someaddress@email.com';
        email.plainTextBody = 'ou have received a new email lead from realestate.com.au\n<https://us-west-2.protection.sophos.com/?d=realestate.com.au&u=aHR0cDovL3JlYWxlc3RhdGUuY29tLmF1&i=NjIwZGIwZDI1M2IyZDQxMTA4NDhiMjg0&t=R08rQlB1eWJtY3FlWVdLMVdWSzVVeWJNM2gzdTlsdXB4d1cyU2dUS1dIMD0=&h=54478706644346c79a2ae14b3839b40c>\n for:\n\n*Project ID:* 600036667\n\n*Project Name:* Stonewood Estate\n\n*Project Address:* Bryna Parade, Oxenford Qld 4210\n\n*User details:*\n\n*Name:* Archie Georgiou\n\n*Email:* archie@venturecrowd.com.au\n\n*Phone:* 0423613004\n\n*About me:* Buy but keep my current home\n\n*Comments:* Test Message Field\n\nMy property preferences:\n- Minimum Land Size: 200m²\n- My Budget: $250,000 - $400,000\n- When I am looking to buy: 1 - 3 months\n\nAdditional information:\n- I have finance pre-approval I would like to: be contacted about similar\nproperties.\n\nYou can only use the personal information contained in this email enquiry\nfor the purposes of co';
        
        InboundEmailHandler  testInbound=new InboundEmailHandler ();
        testInbound.handleInboundEmail(email, env);
    }
}