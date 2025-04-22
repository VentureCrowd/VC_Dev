public class ConvertRecordType {

    //0121y0000008TXmAAM - to convert in PA , 0121y0000008TXcAAM -to convert in BA
    
    @auraEnabled
    public static void convertToPerson(String accId){
        
        System.debug('In convertToPerson '+ accId);
        
        List<recordType> accRecordType = [SELECT id, Name, isPersonType, SobjectType FROM recordType 
                                          WHERE isPersonType = TRUE AND SobjectType = 'Account'];

        Account acc = new Account(Id = accId);
        acc.recordTypeId  = accRecordType[0].Id;
        update acc;
        
    }
    
    @auraEnabled
    public static void convertToBusiness(String accId){
        
        System.debug('In convertToBusiness '+ accId);
        
        List<recordType> accRecordType = [SELECT id, Name FROM recordType WHERE Name = 'Business Account'];

        Account acc = new Account(Id = accId);
        acc.recordTypeId  = accRecordType[0].Id;
        update acc;
        
    }
}