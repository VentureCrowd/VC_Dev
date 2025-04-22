@istest
class createCaseCntrlTest {
    @istest
    static void testmethod1(){
        createCaseCntrl.getUserDEtails();
        Account acc = new Account();
        acc.name = 'Test Acount';
        insert acc;
        contact con = new contact();
        con.AccountId = acc.Id;
        con.LastName = 'LastName';
        insert con;
        Id recordTypeId = [SELECT Id,name FROM recordtype WHERE Name = 'Investor Support Register'].Id;
        Id assigneQueueId = [SELECT Id,name FROM Group WHERE Name ='CM'].Id;
        string casedetails = '{"Subject":"Investment Further Detail","Description":"bvbnbvnbv","FirstName":"Harmony","LastName":"Lam","Email":"harmychan@gmail.com","ContactId":"'+con.Id+'","AccountId":"'+acc.Id+'","recordtypeId":"'+recordTypeId+'","assigneQueueId":"'+assigneQueueId+'","Phone":"+61dfdsfds"}';
        createCaseCntrl.createCase((Map<string,string>)JSON.deserialize(casedetails,Map<string,string>.class));
        createCaseCntrl.fetchAcc('test@test.com',(Map<string,string>)JSON.deserialize(casedetails,Map<string,string>.class));
    }
}