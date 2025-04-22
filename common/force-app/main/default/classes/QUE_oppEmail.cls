public without sharing class QUE_oppEmail implements Queueable {
    public List<opportunity> opplist;
    public QUE_oppEmail(List<opportunity> opplist) {
        this.opplist=opplist;
    }
    public void execute(QueueableContext context) {
        try{
            Opportunity opp1;
            List<opportunity> qualifiedopplst = new List<opportunity>();
            List<Id> conIdlst = new List<Id>();
            List<Id> prodIdlst = new List<Id>();
            List<opportunity> verifyIdopplst = new List<opportunity>();
            List<opportunity> verifyIdwithDonationlst = new List<opportunity>();
            List<opportunity> IdwithDonation = new List<opportunity>();
            List<opportunity> IdwithoutDonation = new List<opportunity>();
            List<opportunity> tsfdonation = new List<opportunity>();
            List<opportunity> oppToUpdate = new List<opportunity>();
            Id opprectypeId = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('VC').getRecordTypeId();
            List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
            List<string> emailtemplatelst = new List<string>{'CSF_Nominee_New_ID_Verified_Investor_without_Donation','CSF_Nominee_NEW_ID_NOT_Verified_Investor_without_Donation','GSL_New_ID_Verified_Investor_without_Donation','GSL_NEW_ID_NOT_Verified_Investor_without_Donation','NEW_ID_NOT_Verified_Investor_without_Donation','NEW_ID_NOT_Verified_Investor_with_Donation','New_ID_Verified_Investor_without_Donation','New_ID_Verified_Investor_with_Donation','TSF_Recipt_Email','New_ID_Verified_Investor_with_Donation_OURCOW','New_ID_Verified_Investor_without_Donation_OURCOW'};
            Map<string,EmailTemplate> etmap = new Map<string,EmailTemplate>();
            Map<String,List<Opportunity>> oppmap = new Map<String,List<Opportunity>>();
            for(string s : emailtemplatelst){
                oppmap.put(s,new List<opportunity>());
            }
            //OUR COW and With Dontation are depracted
            for(EmailTemplate et : [SELECT Id,DeveloperName FROM EmailTemplate WHERE DeveloperName IN :emailtemplatelst]){
                etmap.put(et.DeveloperName,et);
            }
            OrgWideEmailAddress orgwideemail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE Address = 'investor@venturecrowd.com.au'];
            //This for loop was modified to include PSP Products.
            for(Opportunity opp : opplist){
                if(opp.StageName == 'Application Received' && opp.RecordTypeId == opprectypeId 
                                                        && opp.Related_Product_Code__c != 'TSF' && opp.Invested_opp_prod_admin__c != NULL 
                                                        && opp.Primary_Contact_email__c != NULL && opp.Primary_Contact__c != NULL  && !opp.Bpay_Email_sent__c && opp.Amount <> NULL 
                                                        && (opp.Associated_Product_Type__c <> 'PSP Product' || opp.Associated_Product_Type__c == 'PSP Product')){
                    qualifiedopplst.add(opp);
                    conIdlst.add(opp.Primary_Contact__c);
                }
                if(opp.StageName == 'Receipt Issued' && opp.RecordTypeId == opprectypeId && opp.Related_Product_Code__c == 'TSF' 
                                                        && opp.Primary_Contact_email__c != NULL && !opp.TSF_receipt_email_sent__c 
                                                        && (opp.Associated_Product_Type__c <> 'PSP Product' || opp.Associated_Product_Type__c == 'PSP Product')){
                    // oppmap.get('TSF_Recipt_Email').add(opp);
                    // opp1 = new Opportunity(Id=opp.Id);
                    // opp1.TSF_receipt_email_sent__c = true;
                    // oppToUpdate.add(opp1);
                }
                prodIdlst.add(opp.Invested_Product_ADMIN_FIELD__c);
            }
            Map<Id,contact> conMap = new Map<Id,contact>([SELECT Id,ID_Checked__c,Account.BPAY__c FROM Contact WHERE Id In :conIdlst]); 
            Map<Id,Product2> prodMap = new Map<Id,Product2>([SELECT Id,Type__c,AFSL_Licence__c FROM Product2 WHERE Id In :prodIdlst]); 
            for(Opportunity opp : qualifiedopplst){
                product2 prod = prodMap.get(opp.Invested_Product_ADMIN_FIELD__c);
                if(!opp.Sent_verify_id_email__c && !opp.TSF_Donation_EMail_Sent__c && !conMap.get(opp.Primary_Contact__c).ID_Checked__c){
                    if(opp.Donation_related_investment_opp__c == NULL){
                        if(prod.Type__c == 'Retail IPO' && prod.AFSL_Licence__c == 'GSL'){
                            oppmap.get('GSL_NEW_ID_NOT_Verified_Investor_without_Donation').add(opp);
                        }else if(prod.Type__c == 'CSF Nominee'){
                            oppmap.get('CSF_Nominee_NEW_ID_NOT_Verified_Investor_without_Donation').add(opp);
                        }else{
                            oppmap.get('NEW_ID_NOT_Verified_Investor_without_Donation').add(opp);
                        }
                    }else{
                        oppmap.get('NEW_ID_NOT_Verified_Investor_with_Donation').add(opp);
                    }
                    opp1 = new Opportunity(Id=opp.Id);
                    opp1.Sent_verify_id_email__c = true;
                    oppToUpdate.add(opp1);
                }
                if(!opp.TSF_Donation_EMail_Sent__c && opp.Donation_related_investment_opp__c == NULL && conMap.get(opp.Primary_Contact__c).ID_Checked__c && conMap.get(opp.Primary_Contact__c).Account.BPAY__c !=NULL && !opp.Donation__c){
                    if(opp.Related_Product_Code__c != 'OURCOW'){
                        if(prod.Type__c == 'Retail IPO' && prod.AFSL_Licence__c == 'GSL'){
                            oppmap.get('GSL_New_ID_Verified_Investor_without_Donation').add(opp);
                        }else if(prod.Type__c == 'CSF Nominee'){
                            oppmap.get('CSF_Nominee_New_ID_Verified_Investor_without_Donation').add(opp);
                        }else{
                            oppmap.get('New_ID_Verified_Investor_with_Donation').add(opp);
                        } 
                    }else{
                        oppmap.get('New_ID_Verified_Investor_without_Donation_OURCOW').add(opp);
                    }                                        
                    opp1 = new Opportunity(Id=opp.Id);
                    opp1.Bpay_email_sent__c = true;
                    oppToUpdate.add(opp1);
                }
                if(!opp.TSF_Donation_EMail_Sent__c && opp.Donation_related_investment_opp__c <> NULL && conMap.get(opp.Primary_Contact__c).ID_Checked__c && conMap.get(opp.Primary_Contact__c).Account.BPAY__c !=NULL){
                    // if(opp.Related_Product_Code__c != 'OURCOW'){
                    //     if(prod.Type__c == 'Retail IPO' && prod.AFSL_Licence__c == 'GSL'){
                    //         oppmap.get('GSL_New_ID_Verified_Investor_without_Donation').add(opp);
                    //     }else{
                    //         oppmap.get('New_ID_Verified_Investor_without_Donation').add(opp);
                    //     }                        
                    // }
                    // else{
                    //     oppmap.get('New_ID_Verified_Investor_with_Donation_OURCOW').add(opp);
                    // }                    
                    // opp1 = new Opportunity(Id=opp.Id);
                    // opp1.TSF_Donation_EMail_Sent__c = true;
                    // oppToUpdate.add(opp1);
                }
            }
            for(string s : oppmap.keyset()){
                for(Opportunity opp : oppmap.get(s)){
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.setTemplateId(etmap.get(s).Id);
                    message.setTargetObjectId(opp.Primary_Contact__c);
                    message.setWhatId(opp.Id);
                    message.setOrgWideEmailAddressId(orgwideemail.Id);
                    messages.add(message);
                }
            }        
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            for(Messaging.SendEmailResult r : results){
                if(!r.success){
                    System.debug('The email failed to send: ' + r.errors);
                }
            }
            update oppToUpdate;  
        }catch(Exception e){
            system.debug(e);
        }
    }
}