public class EntitiesService {
     private EntitiesFactory factory = new EntitiesFactory();

     public List<Map<String,Object>> getRelatedBusinessAccounts(Id contactId){
         try{
            // setup return structure
            List<Map<String,Object>> returnList = new  List<Map<String,Object>>();
            
            // get accounts from factory
            List<Account> accounts = factory.getRelatedBusinessAccounts(contactId);
            
            //loop thru return result and create the accounts structure
            for(Account acc : accounts){
                Map<String,Object> accountReturn = new Map<String,Object>();
                accountReturn.put('id',acc.Id);
                accountReturn.put('name',acc.Name);

                // Check if the account has a BSB number and the length is equal or more than 2
                String maskedBSB = (acc.BSB_Number__c != null && acc.BSB_Number__c.length() >= 2)
                    ? '****' + acc.BSB_Number__c.substring(2)
                    : null;
                accountReturn.put('bsb', maskedBSB);
            
                // Check if the account has a Account number and the length is equal or more than 4
                String maskedAccNumber = (acc.Bank_Account_Number__c != null && acc.Bank_Account_Number__c.length() >= 4)
                    ? '****' + acc.Bank_Account_Number__c.substring(4)
                    : null;
                accountReturn.put('accNumber', maskedAccNumber);
            

                returnList.add(accountReturn);
            }
            
            return returnList;
        }catch(Exception e){
            throw e;
        }
     }

    public Id getLoggedInUser(){
        return factory.getContactFromLoggedInUser();
    }
    
}