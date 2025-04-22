public with sharing class SecurityService {

    @TestVisible private static SecurityFactory factory = new SecurityFactory();

    public String getLoggedInAccountId(){
        Id userId = UserInfo.getUserId();
            // get accountId from userId
        Id accountId = [SELECT AccountId FROM User WHERE Id =: userId].AccountId;
        return accountId;
    }

    public Boolean checkRaiseAccess(String raiseId){
        Id accountId = getLoggedInAccountId();
        

        Id raiseAccountId = factory.getRaiseAccountId(raiseId);

        
        if(raiseAccountId == accountId){
            return true;
        }else{
            return false;
        }
    }

    public Boolean checkEoiAccess(String eoiId){
        Id accountId = getLoggedInAccountId();
        Id eoiAccountId = factory.getEoiAccountId(eoiId);

        if(eoiAccountId == accountId){
            return true;
        }else{
            return false;
        }
    }

}