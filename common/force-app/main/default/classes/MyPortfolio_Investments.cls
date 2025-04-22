public with sharing class MyPortfolio_Investments {
    @AuraEnabled
    public static String getInvestments(){

        //get logged in accId
        List<Id> accidlst = new List<Id>();
        User usr = [SELECT Id,contact.AccountId,contactId  FROM USER WHERE ID =:UserInfo.getuserId()];
        Id loggedinaccId = usr.contact.AccountId;

        // add to acc id list
        accidlst.add(loggedinaccId);

        // get other accounts related to the logged in acc Id & add them to the acc id list
        List<AccountContactRelation> acrlst = [SELECT Id, Account.Name,AccountId FROM AccountContactRelation WHERE ContactId = :usr.contactId];
        for(AccountContactRelation acr:acrlst){
            accidlst.add(acr.AccountId);
        }

        if(accidlst.size() > 0){
            return JSON.serialize([select SUM(Total_Investment__c) Investments,RecordTypeId,RecordType.Name,sum(Total_Personal_Investments__c) NumberOfInvestments  from Account WHERE Id=:accIdLst group by RecordTypeId ,RecordType.Name]);

        }else{
            return JSON.serialize([select SUM(Total_Investment__c) Investments,RecordTypeId,RecordType.Name,sum(Total_Personal_Investments__c) NumberOfInvestments  from Account group by RecordTypeId ,RecordType.Name]);
        }
    }
    

    
    @AuraEnabled
	public static List<User> getCurrentUser(){
	return  [SELECT Id, Name,Contact.ID_Checked__c , AccountId FROM User WHERE Id =: Userinfo.getUserId()];
   }
    
    @AuraEnabled
    public static Integer getInvestmentFromInvestmentObject(){
        return [SELECT COUNT() FROM  Investment__c WHERE Stage__c = 'Receipt Issued' OR Stage__c = 'Application Received' OR Stage__c = 'Closed Won'];        
    }
    
}