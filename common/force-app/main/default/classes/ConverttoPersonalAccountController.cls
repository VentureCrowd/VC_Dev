public class ConverttoPersonalAccountController{

    @AuraEnabled
    public static String convertToPersonalAccount(Id contactId){
        String statusCode;
        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();
        Contact contactObj = [Select Id,Name,AccountId,OwnerId from Contact where Id=:contactId];
        
        try{
        Account personAccountObj = new Account();
        personAccountObj.Name = contactObj.Name;
        personAccountObj.recordtypeId = rtMapByName.get('VC Business Account').getRecordTypeId();
        personAccountObj.OwnerId = contactObj.OwnerId;
        Insert personAccountObj;
        
        contactObj.AccountId = personAccountObj.Id;
        update contactObj;
        
        Account newpersonAccountObj = new Account();
        newpersonAccountObj.Id =personAccountObj.Id;
        newpersonAccountObj.recordtypeId = rtMapByName.get('VC Person Account').getRecordTypeId();
        update newpersonAccountObj ; 
        
        statusCode = 'Contact converted successfully';
        }
        catch(exception ex){
            statusCode = ex.getMessage();
        }
        return statusCode;
    }
}