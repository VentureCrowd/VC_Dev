@isTest
public class ConverttoPersonalAccountCtrlTest{
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
        ConverttoPersonalAccountController.convertToPersonalAccount(con.Id);
    }
}