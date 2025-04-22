@istest
class logMsgUtility_Test {
    @istest
    static void testmethod1(){
        try{
            List<string> strset = new List<string>();
            strset[2] = 'Hello';
        }catch(Exception e){
            Map<string,object> ss = new Map<string,object>{'sds'=>'dsfsdfds'};
            logMsgUtility.logMessage(e,'logMsgUtility_Test','Test Coverage','testmethod1',ss);
        }
    }
    @istest
    static void testmethod2(){
        try{
            Log_Message__c msg = new Log_Message__c();
            update msg;
        }catch(Exception e){
            Map<string,object> ss = new Map<string,object>{'sds'=>'dsfsdfds'};
            logMsgUtility.logMessage(e,'logMsgUtility_Test','Test Coverage','testmethod2',ss);
        }
    }
}