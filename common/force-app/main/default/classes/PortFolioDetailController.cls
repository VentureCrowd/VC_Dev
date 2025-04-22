public class PortFolioDetailController {
	 @AuraEnabled
    public static MyPortfolio initlializeMyportfolio(){
       List<user> users= [SELECT Id, Name,AccountId, profile.Name,SmallPhotourl,FullPhotoUrl FROM User WHERE Id =: Userinfo.getUserId()];
        List<Account> accList=[Select Id,Name,Total_Investment__c,(Select Id,Total_Investment__c,Investment_Date__c,Investment_Amount__c,Funds_Received__c,Account__r.Name from Investments__r) from Account where Id=:users[0].AccountId];
        return new MyPortfolio(users.size()>0?users[0]:null,accList.size()>0?accList[0]:null);
    }
    
    public class MyPortfolio{
        @AuraEnabled
        public User currentUser;
         @AuraEnabled
        public Account currentAccount;
        
        public MyPortfolio( User currentUser,Account currentAccount){
         this.currentUser=currentUser;
         this.currentAccount=currentAccount;
        }
    }
}