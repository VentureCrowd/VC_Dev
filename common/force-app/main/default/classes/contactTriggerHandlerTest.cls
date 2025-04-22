@isTest
public class contactTriggerHandlerTest {
    public static TestMethod void convertToPersonalAccountTest(){
        Id accRectypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('VC Business Account').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'test account';
        acc.RecordTypeId = accRectypeId;
        acc.Phone = '6786789876';
        insert acc;
        
        Contact con = new Contact();
        con.LastName  = 'Test1lname';
        con.MobilePhone = '6786789876';
        con.AccountId = acc.Id;
        con.email = 'testemailn@yopmail.com1';
        insert con;
        List<Contact> contacts = new List<Contact>();
        contacts.add(con);
        try{
            contactTriggerHandler.updatetoPersonAcc(contacts);
        }catch(exception e){}
        
    }
}