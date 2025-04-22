@isTest(SeeAllData=true)
Private class VenturecrowdVerificationControllerTest {
    static testmethod void shouldGetVerificationUser() {
        Test.startTest();
        VenturecrowdVerificationController v = new VenturecrowdVerificationController();
        PageReference pageRef = v.upsertRecord();
        //VenturecrowdVerificationController.upsertRecord();
        Test.stopTest();
    }
}