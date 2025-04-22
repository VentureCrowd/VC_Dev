@isTest
public class PortFolioDetailControllerTest {
@TestSetup
    public static void createdata(){
        Account a=new Account();
        a.Name='Protfolitio venture Test';

        insert a;
        Contact c=new Contact();
        c.FirstName='portfolio';
        c.LastName='test';
        c.email='portfoliotest@gmail.com';
        c.AccountId=a.Id;
        insert c;
        createInvestments(a.Id,10,true);

    }

    @isTest
    public static void initlializeMyportfolioTest(){
        
        List<User> users=createUser('portfolio','test','portfoliotest@gmail.com','portfoliotest@gmail.com','Customer Community Plus Login User',1,false);
        Contact con=[Select Id from Contact where email='portfoliotest@gmail.com' Limit 1];
      //  UserRole role=[Select Id from UserRole where Name='cball Customer Person Account' Limit 1];
       
        users[0].ContactId=con.Id;
        insert users;
        System.runAs(users[0]){
          PortFolioDetailController.MyPortfolio protfoliodetail=PortFolioDetailController.initlializeMyportfolio();
            System.assertEquals(users[0].Id,protfoliodetail.currentUser.Id);
            System.assertEquals(10,protfoliodetail.currentAccount.Investments__r.size());
        }
    }

    public static List<Investment__c> createInvestments(Id accountId,Integer count,Boolean isInsert) {
          List<Investment__c> investments=new List<Investment__c>();
        for (Integer i = 0; i < count; i++) {
         Investment__c investment=new Investment__c();
         investment.Total_Investment__c=(i+2)*100;
         investment.Investment_Date__c=System.Today();
         investment.Investment_Amount__c=(i+1)*100;
         investment.Funds_Received__c=true;
         investment.Account__c=accountId;
         investments.add(investment);
        }
        System.debug('investments=' + investments);
        if (isInsert)
          insert investments;
        return investments;
      }

    public static List<User> createUser(
    String firstName,
    String lastname,
    String email,
    String userName,
    String profilename,
    Integer count,
    Boolean isInsert
  ) {
    String langKey = 'en_US';
    String timeZonekIdkey = 'America/Los_Angeles';
    String emailencodingkey = 'UTF-8';
    List<user> userList = new List<User>();
    Profile pf1 = [SELECT Id FROM Profile WHERE Name = :profilename];
    for (Integer i = 0; i < count; i++) {
      String alias = userName.subString(0, 4);
      System.debug('alias=' + alias);
      User u = new user();
      u.Email = email;
      u.ProfileId = pf1.id;
      u.IsActive = true;
      u.FirstName = firstName;
      u.LastName = lastname;
      u.languagelocalekey = langKey;
      u.localesidkey = langKey;
      u.timezonesidkey = timeZonekIdkey;
      u.emailencodingkey = emailencodingkey;
      u.Username = userName + i;
      u.Alias = alias + i;
      userList.add(u);
    }
    System.debug('userList=' + userList);
    if (isInsert)
      insert userList;
    return userList;
  }
}