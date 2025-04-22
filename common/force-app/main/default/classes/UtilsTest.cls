@IsTest
public class UtilsTest {
    
    /**
 	  * Test method for the getRecordTypeId utility method.
      * 
      * This test case verifies the functionality of the Utils.getRecordTypeId method,
      * which retrieves the RecordTypeId for a given object and record type label.
      */
    @IsTest
    public static void getRecordTypeIdTest(){
        // Specify the object name and record type label for testing
        String objectName = 'Account';
        String recordTypeLabel = 'VC Business Account';
        
        // Retrieve the expected Record Type Id using the Salesforce Schema
        String excpectedRecordId = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByName().get(recordTypeLabel).getRecordTypeId();
        
        // Perform the getRecordTypeId method and assert the result
        System.assertEquals(excpectedRecordId, Utils.getRecordTypeId(objectName, recordTypeLabel));
        
        // Assert that the result is not an empty string
        System.assertNotEquals('',Utils.getRecordTypeId(objectName, recordTypeLabel));
    }

    /**
      * Test method for the deleteRecord utility method.
      * 
      * This test case verifies the functionality of the Utils.deleteRecord method,
      * which deletes a record by its Id and returns 'Success' if successful.
      */
    @IsTest
    public static void deleteRecordTest(){
       // Retrieve the Record Type Id for VC Business Account
       Id recordIdByName = Schema.SObjectType.Account.getRecordTypeInfosByName().get('VC Business Account').getRecordTypeId();
       
       // Prepare test data by inserting a new Account record
       List<Account> lstOfAccount = new List<Account>();
       Account accObj = new Account();
        	accObj.Name = 'Test deleteRecordTest method';
        	accObj.RecordTypeId = recordIdByName;
       lstOfAccount.add(accObj);
       
       // Insert the test data within a test context
       Test.startTest();
       Database.SaveResult[] saveResults  = Database.insert(lstOfAccount,false);
       Test.stopTest();
       
       // Assert that the deleteRecord method returns 'Success' for a valid record Id
       System.assertEquals('Success',Utils.deleteRecord(saveResults[0].getId()));
        
       // Assert that the deleteRecord method does not return 'Success' for an invalid record Id
       System.assertNotEquals('Success',Utils.deleteRecord('0010T00000hCab1raC'));
       
       // Assert that the deleteRecord method throws an exception for an invalid record Id within a try-catch block	
        System.assert(!Utils.deleteRecord(recordIdByName).contains('Success'));
    }
}