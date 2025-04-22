@isTest
public class LoggerTest {
    @isTest
    static void testLogError() {
        // Test data
        String application = 'TestApp';
        String source = 'TestSource';
        String sourceFunction = 'TestFunction';
        String referenceId = '001xx000003DHP0';
        String recordDetails = 'Test record details';
        String dmlInfo = 'Insert operation';
        String statusCode = '500';
        String logMessage = 'This is a test error message';

        // Simulate an exception
        Exception e = new DmlException('Test exception message');

        // Call the logError method
        Test.startTest();
        Logger.logError(application, source, sourceFunction, referenceId, recordDetails, dmlInfo, statusCode, e, logMessage);
        Test.stopTest();

        // Verify that the log entry was created
        Log_Message__c[] logEntries = [SELECT Id, Application__c, Source__c, Source_Function__c, refrence_Id__c, Record_details__c, DML_info__c, Status_Code__c, log_message__c, Stack_Trace__c, Type__c FROM Log_Message__c];
        System.assertEquals(1, logEntries.size(), 'One log entry should have been created');
        Log_Message__c logEntry = logEntries[0];
        System.assertEquals(application, logEntry.Application__c, 'Application should match');
        System.assertEquals(source, logEntry.Source__c, 'Source should match');
        System.assertEquals(sourceFunction, logEntry.Source_Function__c, 'Source function should match');
        System.assertEquals(referenceId, logEntry.refrence_Id__c, 'Reference ID should match');
        System.assertEquals(recordDetails, logEntry.Record_details__c, 'Record details should match');
        System.assertEquals(dmlInfo, logEntry.DML_info__c, 'DML info should match');
        System.assertEquals(statusCode, logEntry.Status_Code__c, 'Status code should match');
        System.assertEquals(logMessage + ': ' + e.getMessage(), logEntry.log_message__c, 'Log message should match');
        System.assertEquals('Error', logEntry.Type__c, 'Type should be Error');
    }

    @isTest
    static void testLogMessage() {
        // Test data
        String application = 'TestApp';
        String source = 'TestSource';
        String sourceFunction = 'TestFunction';
        String logMessage = 'This is a test log message';

        // Call the logMessage method
        Test.startTest();
        Logger.logMessage(application, source, sourceFunction, logMessage);
        Test.stopTest();

        // Verify that the log entry was created
        Log_Message__c[] logEntries = [SELECT Id, Application__c, Source__c, Source_Function__c, log_message__c, Type__c FROM Log_Message__c];
        System.assertEquals(1, logEntries.size(), 'One log entry should have been created');
        Log_Message__c logEntry = logEntries[0];
        System.assertEquals(application, logEntry.Application__c, 'Application should match');
        System.assertEquals(source, logEntry.Source__c, 'Source should match');
        System.assertEquals(sourceFunction, logEntry.Source_Function__c, 'Source function should match');
        System.assertEquals(logMessage, logEntry.log_message__c, 'Log message should match');
        System.assertEquals('Info', logEntry.Type__c, 'Type should be Info');
    }

}