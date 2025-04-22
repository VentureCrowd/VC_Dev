@isTest
class LeadControllerTest {
    @isTest
    static void testmethod1() {
        LeadController l =new LeadController();
        l.lastName='firstName';
        l.firstName='lastName';
        l.email='test@test.com';
        l.mobilephone='123467890';
        l.websource='websource=test/test';
        l.setmobilephone('0161616141616111');
        l.getmobilephone();
        l.getItems();
        l.getCountry(); 
        l.getTypeOfinvestorOptions();
        String country = 'True';
       	l.setCountry(country);
        l.save();
    }
    @isTest
    static void testmethod3() {
        LeadController l =new LeadController();
        l.firstName='lastName';
        l.email='test@test.com';
        l.mobilephone='123467890';
        l.websource='websource=test/test';
        l.setmobilephone('0161616141616111');
        l.getmobilephone();
        l.getItems();
        l.getCountry(); 
        l.getTypeOfinvestorOptions();
        String country = 'True';
       	l.setCountry(country);
        l.save();
    }
    @isTest
    static void testmethod2() {
        webtoleadcontroller l =new webtoleadcontroller();
        l.lastName='firstName';
        l.firstName='lastName';
        l.email='test@test.com';
        l.mobilephone='123467890';
        l.urlVal='websource=test/test';
        l.numberofshares = 20;
        l.investorId = 'investorId';
        l.setmobilephone('0161616141616111');
        l.getmobilephone();
       	l.save();
    }
    @isTest
    static void testmethod4() {
        webtoleadcontroller l =new webtoleadcontroller();
        l.firstName='lastName';
        l.email='test@test.com';
        l.mobilephone='123467890';
        l.urlVal='websource=test/test';
        l.numberofshares = 20;
        l.investorId = 'investorId';
        l.setmobilephone('0161616141616111');
        l.getmobilephone();
       	l.save();
    }
}