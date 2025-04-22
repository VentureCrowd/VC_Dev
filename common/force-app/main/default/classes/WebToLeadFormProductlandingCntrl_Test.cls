/**
 * Description  :   Test class for WebToLeadFormProductlandingCntrl
 */
@IsTest
public with sharing class WebToLeadFormProductlandingCntrl_Test {

    @IsTest
    static void Test_createLeadRec() {
        WebToLeadFormProductlandingCntrl.createLeadRec('Test', 'lead-1', 'test@test1.com', '+61423904827','Instagram', 'ESNCLEER - Landing Page');

        List<Lead> lstlead = [SELECT Id, Name FROM Lead WHERE Email = 'test@test1.com'];
        System.assertEquals(true, lstlead.size() > 0);
    }
}