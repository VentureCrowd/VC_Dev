@isTest
public class ConvertRecordType_Test {

    @isTest
    public static void createAccCont(){
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc; 
        
        Contact cont = new Contact();
        cont.AccountId = acc.Id;
        cont.LastName = 'Test Contact';
        insert cont;
        
        ConvertRecordType.convertToPerson(acc.Id);
        ConvertRecordType.convertToBusiness(acc.Id);
        
    }
}