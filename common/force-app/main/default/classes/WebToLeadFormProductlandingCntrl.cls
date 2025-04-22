/**
 * Description  :    Handler Class used in LWC : WebToLeadFormProductlanding
 */
public without sharing class WebToLeadFormProductlandingCntrl {

    @AuraEnabled(Cacheable=false)
    public static Boolean createLeadRec(String leadFirstName, String leadLastName, String leadEmail, String leadMobile, String leadSource, String webSource){
        try {
            Lead objlead = new Lead(FirstName = leadFirstName,
                                    LastName = leadLastName,
                                    Email = leadEmail,
                                    MobilePhone = leadMobile,
                                    LeadSource = leadSource,
                                    Web_Source__c = webSource);
            insert  objlead;
            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}