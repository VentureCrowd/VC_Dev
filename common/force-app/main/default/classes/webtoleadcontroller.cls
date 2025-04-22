public without sharing class webtoleadcontroller {
 
    public Lead lead {get;set;}
    public String lastName {get;set;}
    public String firstName {get;set;}
    public String email {get;set;}
    public String mobilephone;
    public String urlVal {get;set;}
    public String cntrucode {get;set;}
    public String investorId {get;set;}
    public Integer numberofshares {get;set;}
    public List<SelectOption> countryOptions {get;set;}
    public string getMobilephone(){
        return mobilephone;
    }
    public void setMobilephone(string s){
        if(s.length() > 11)
        mobilephone = s.substring(0, 10);
        else
        mobilephone = s;
        if(s.substring(0, 1) == '0')
        mobilephone = s.substring(1, s.length());
    } 
    public webtoleadcontroller() {    
        lead = new Lead();
        urlVal = Apexpages.currentPage().getUrl();
        cntrucode = '+61' ;
        countryOptions = new List<SelectOption>();
        string s ='+61,+93,+355,+213,+1,+376,+244,+54,+374,+297,+247,+43,+994,+973,+880,+375,+32,+501,+229,+975,+591,+387,+267,+55,+246,+673,+359,+226,+257,+855,+237,+238,+599,+236,+235,+56,+86,+57,+269,+243,+242,+682,+506,+225,+385,+53,+357,+420,+45,+253,+593,+20,+503,+240,+291,+372,+268,+251,+500,+298,+679,+358,+33,+594,+689,+241,+220,+995,+49,+233,+350,+30,+299,+590,+502,+44,+224,+245,+592,+509,+504,+852,+36,+354,+91,+62,+98,+964,+353,+972,+39,+81,+962,+7,+254,+686,+383,+965,+996,+856,+371,+961,+266,+231,+218,+423,+370,+352,+853,+389,+261,+265,+60,+960,+223,+356,+692,+596,+222,+230,+262,+52,+691,+373,+377,+976,+382,+212,+258,+95,+264,+674,+977,+31,+687,+64,+505,+227,+234,+683,+672,+850,+47,+968,+92,+680,+970,+507,+675,+595,+51,+63,+48,+351,+974,+40,+250,+290,+508,+685,+378,+239,+966,+221,+381,+248,+232,+65,+421,+386,+677,+252,+27,+82,+211,+34,+94,+249,+597,+46,+41,+963,+886,+992,+255,+66,+670,+228,+690,+676,+216,+90,+993,+688,+256,+380,+971,+598,+998,+678,+58,+84,+681,+967,+260,+263';
        for(string s1: s.split(',')){
            countryOptions.add(new SelectOption(s1,s1));
        }
    }  
    public void save() {
        try{
            lead.FirstName = firstName;
            lead.LastName = lastName;
            lead.Email = email;
            lead.MobilePhone = cntrucode+mobilephone;
            lead.LeadSource = 'Other';
            lead.Investor_ID__c = investorId;
            lead.Number_of_shares_to_sell__c = numberofshares;
            lead.Web_Source__c = urlVal.split('websource=')[1];
            List<user> u = [SELECT Id FROM USER WHERE USERNAME ='jason@venturecrowd.com.au' AND isActive = true LIMIT 1];
            if(u.size()>0)
            lead.ownerId = u[0].Id;
            insert lead;
        }catch(Exception e){
            Map<String,Object> ss = new Map<String,Object>();
            ss.put('FirstName',FirstName);
            ss.put('lastName',lastName);
            ss.put('email',email);
            ss.put('MobilePhone',cntrucode+mobilephone);
            ss.put('investorId',investorId);
            ss.put('numberofshares',numberofshares);
            ss.put('Web_Source__c',urlVal.split('websource=')[1]);
            logMsgUtility.logMessage(e,'LeadController','Investor Share sell Campaign','save',ss);
        }
    }
}