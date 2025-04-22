public class ConvertLeadHandler {
	public static void convertLead(List<opportunity> oppList){
        Map<String,Opportunity> emailOppMap = new Map<String,Opportunity>();
        Map<Id,Account> personAccountMap = new Map<Id,Account>();
        Set<Id> accoutIdSet = new Set<Id>();       
        Map<id,Lead> emailLeadMap = new Map<id,Lead>();
        List<Lead> leadList = new List<Lead>();
        Map<String,id> actIdContIdMap = new Map<String,id>();
        for(Opportunity oppObj:oppList){
            if(oppObj.StageName == 'Application Received' 
               && oppObj.Web_Source__c == 'ZEGA-CSF' 
               && oppObj.LeadSource == 'VC Website Organic'
               	&& (oppObj.Person_Account_Email__c!=null || oppObj.Email_ID__c!=null) 
              	&& oppObj.AccountId!=null){
                    if(oppObj.Email_ID__c!=null){
                        emailOppMap.put(oppObj.Email_ID__c,oppObj);
                    }
                    if(oppObj.Person_Account_Email__c!=null){
                        emailOppMap.put(oppObj.Person_Account_Email__c,oppObj);
                    }
                   accoutIdSet.add(oppObj.AccountId);                    
            }
        }
        if(emailOppMap!=null && emailOppMap.size()>0){
            list<Database.LeadConvert> listLeadConvert = new list<Database.LeadConvert>();
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
            
            for(Contact contObj:[select id,email,accountId from Contact 
                                where email in:emailOppMap.keyset()]){
                                    actIdContIdMap.put(contObj.AccountId+'#'+contObj.email,contObj.Id);
            }
            
           	for(Lead leadObj:[SELECT id, Email, Web_Source__c FROM Lead 
                              WHERE Web_Source__c ='ZEGA-CSF' 
                              AND Email in: emailOppMap.keyset()
                              AND IsConverted  != true]){
                      emailLeadMap.put(leadObj.id,leadObj);
                      leadList.add(leadObj);
            }
            for(Opportunity oppObj:oppList){
                if(oppObj.StageName == 'Application Received' 
                   && oppObj.Web_Source__c == 'ZEGA-CSF' 
                   && oppObj.LeadSource == 'VC Website Organic'
                   && (oppObj.Person_Account_Email__c!=null || oppObj.Email_ID__c!=null) 
                   && oppObj.AccountId!=null 
                   && emailLeadMap!=null){
                       for(Lead leadObj:leadList){
                           if(leadObj.Email != null && (leadObj.Email == oppObj.Person_Account_Email__c || leadObj.Email == oppObj.Email_ID__c)){
                               Database.LeadConvert leadConvert = new Database.LeadConvert();
                               leadConvert.setLeadId(leadObj.id);
                               if(oppObj.Email_ID__c != null){
                                   leadConvert.setAccountId(emailOppMap.get(oppObj.Email_ID__c).AccountId);
                                   if(actIdContIdMap.get(emailOppMap.get(oppObj.Email_ID__c).AccountId+'#'+oppObj.Email_ID__c)!=null){
                                   		leadConvert.setContactId(actIdContIdMap.get(emailOppMap.get(oppObj.Email_ID__c).AccountId+'#'+oppObj.Email_ID__c));
                               	   }
                               }
                               if(oppObj.Person_Account_Email__c!=null){
                                   leadConvert.setAccountId(emailOppMap.get(oppObj.Person_Account_Email__c).AccountId);
                                   if(actIdContIdMap.get(emailOppMap.get(oppObj.Person_Account_Email__c).AccountId+'#'+oppObj.Person_Account_Email__c)!=null){
                                   		leadConvert.setContactId(actIdContIdMap.get(emailOppMap.get(oppObj.Person_Account_Email__c).AccountId+'#'+oppObj.Person_Account_Email__c));
                               	   }
                               }
                               leadConvert.setConvertedStatus(convertStatus.MasterLabel);
                               leadConvert.setDoNotCreateOpportunity(TRUE);
                               listLeadConvert.add(leadConvert);
                           }
                       }                   
                }
        	}
            if(!listLeadConvert.isEmpty()){
            	Database.convertLead(listLeadConvert);
        	}
        }
    }    
}