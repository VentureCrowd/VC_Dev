public without sharing class LeadController {
 
    public Lead lead {get;set;}
    public String lastName {get;set;}
    public String firstName {get;set;}
    public String email {get;set;}
    public String mobilephone;
    public String websource {get;set;}
    public String utm_source {get;set;}
    public String utm_medium {get;set;}
    public String utm_campaign {get;set;}
    public String utm_content {get;set;}
    public String utm_keyword {get;set;}
    public String cntrucode {get;set;}
    public String investorType {get;set;}
    public String investor {get;set;}
    public Boolean showinvestorType {get;set;}
    public List<SelectOption> countryOptions {get;set;}
    public List<SelectOption> investorOptions {get;set;}
    public String investorOption {get;set;}
    public String country {get;set;}
    
    public Boolean modal {get;set;}  



    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('True','Yes')); 
        options.add(new SelectOption('False','No')); 
        return options; 
    }
    public List<SelectOption> getTypeOfinvestorOptions() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('Retail','Retail')); 
        options.add(new SelectOption('Wholesale','Wholesale')); 
        return options; 
    }
                   
    public String getCountry() {
        return country;
    }
   
    public void setCountry(String country) { this.country = country; }

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
    public LeadController() {  
        country = 'True';
        modal = false;
        investor = 'Retail';
        lead = new Lead();
        websource = ApexPages.currentPage().getParameters().get('websource');
        utm_source = ApexPages.currentPage().getParameters().get('utm_source');
        utm_medium = ApexPages.currentPage().getParameters().get('utm_medium');
        utm_campaign = ApexPages.currentPage().getParameters().get('utm_campaign');
        utm_content = ApexPages.currentPage().getParameters().get('utm_content');
        utm_keyword = ApexPages.currentPage().getParameters().get('utm_keyword');
        investorType = ApexPages.currentPage().getParameters().get('investortype');
        cntrucode = '+61' ;
        countryOptions = new List<SelectOption>();
        string s ='+61,+93,+355,+213,+1,+376,+244,+54,+374,+297,+247,+43,+994,+973,+880,+375,+32,+501,+229,+975,+591,+387,+267,+55,+246,+673,+359,+226,+257,+855,+237,+238,+599,+236,+235,+56,+86,+57,+269,+243,+242,+682,+506,+225,+385,+53,+357,+420,+45,+253,+593,+20,+503,+240,+291,+372,+268,+251,+500,+298,+679,+358,+33,+594,+689,+241,+220,+995,+49,+233,+350,+30,+299,+590,+502,+44,+224,+245,+592,+509,+504,+852,+36,+354,+91,+62,+98,+964,+353,+972,+39,+81,+962,+7,+254,+686,+383,+965,+996,+856,+371,+961,+266,+231,+218,+423,+370,+352,+853,+389,+261,+265,+60,+960,+223,+356,+692,+596,+222,+230,+262,+52,+691,+373,+377,+976,+382,+212,+258,+95,+264,+674,+977,+31,+687,+64,+505,+227,+234,+683,+672,+850,+47,+968,+92,+680,+970,+507,+675,+595,+51,+63,+48,+351,+974,+40,+250,+290,+508,+685,+378,+239,+966,+221,+381,+248,+232,+65,+421,+386,+677,+252,+27,+82,+211,+34,+94,+249,+597,+46,+41,+963,+886,+992,+255,+66,+670,+228,+690,+676,+216,+90,+993,+688,+256,+380,+971,+598,+998,+678,+58,+84,+681,+967,+260,+263';
        for(string s1: s.split(',')){
            countryOptions.add(new SelectOption(s1,s1));
        }
        investorOptions = new List<SelectOption>();
        showinvestorType = false;
        if(investorType == 'Retail'){
            investorOptions.add(new SelectOption('$500 - $1,000','$500 - $1,000'));
            investorOptions.add(new SelectOption('$1,000 - $3,000','$1,000 - $3,000'));
            investorOptions.add(new SelectOption('$3,000 - $5,000','$3,000 - $5,000'));
            investorOptions.add(new SelectOption('$5,000 - $8,000','$5,000 - $8,000'));
            investorOptions.add(new SelectOption('$8,000 - $10,000','$8,000 - $10,000'));
            investorOptions.add(new SelectOption('$10,000 - $20,000','$10,000 - $20,000'));
            investorOptions.add(new SelectOption('$20,000 - $50,000','$20,000 - $50,000'));
            investorOptions.add(new SelectOption('$50,000 - $100,000','$50,000 - $100,0000'));
            investorOptions.add(new SelectOption('$100,000 - $200,000','$100,000 - $200,000'));
            investorOptions.add(new SelectOption('$200,000+','$200,000+'));
            showinvestorType = true;
        }else if(investorType == 'Wholesale'){
            investorOptions.add(new SelectOption('$5,000 - $10,000','$5,000 - $10,000'));
            investorOptions.add(new SelectOption('$10,000 - $20,000','$10,000 - $20,000'));
            investorOptions.add(new SelectOption('$20,000 - $50,000','$20,000 - $50,000'));
            investorOptions.add(new SelectOption('$50,000 - $100,000','$50,000 - $100,0000'));
            investorOptions.add(new SelectOption('$100,000 - $200,000','$100,000 - $200,000'));
            investorOptions.add(new SelectOption('$200,000+','$200,000+'));
            showinvestorType = true;
        }
    }  

    public void showModal(){
        modal = true;
    }
    public void hideModal(){
        modal = false;
    }


    public void save() {
        try{
            String RecordTypeID = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('VC').getRecordTypeId();
            lead.FirstName = firstName;
            lead.LastName = lastName;
            lead.Email = email;
            lead.MobilePhone = cntrucode+mobilephone;
            lead.LeadSource = 'Other';
            lead.Web_Source__c = websource;
            lead.utm_campaign__c = utm_campaign;
            lead.utm_content__c = utm_content;
            lead.utm_keyword__c = utm_keyword;
            lead.utm_medium__c = utm_medium;
            lead.utm_source__c = utm_source;
            lead.Investment_Amount__c = investorOption;
            lead.RecordTypeID = RecordTypeID;
            lead.Email_Opt_In__c = true;
            if(country == 'True'){
                lead.Are_you_located_in_Australia__c = true;
            } else if(country == 'False') {
                lead.Are_you_located_in_Australia__c = false;
            }
            lead.Wholesale_Status__c = investor=='Retail' ? 'No' : 'Yes';
            insert lead;
        }catch(Exception e){
            system.debug(e);
            Map<String,Object> ss = new Map<String,Object>();
            ss.put('FirstName',FirstName);
            ss.put('lastName',lastName);
            ss.put('email',email);
            ss.put('MobilePhone',cntrucode+mobilephone);
            ss.put('websource',websource);
            ss.put('utm_campaign',utm_campaign);
            ss.put('utm_content',utm_content);
            ss.put('utm_keyword',utm_keyword);
            ss.put('utm_medium',utm_medium);
            ss.put('utm_source',utm_source);
            ss.put('investorOption',investorOption);
            ss.put('Wholesale_Status__c',investor=='Retail');
            logMsgUtility.logMessage(e,'LeadController','Lead from Community','save',ss);
        }
    }
}