public class Logger {
    public static void logError(String application, String source, String sourceFunction, String referenceId, String recordDetails, String dmlInfo, String statusCode, Exception e, String logMessage) {
        Log_Message__c logEntry = new Log_Message__c();
        logEntry.Application__c = application;
        logEntry.Source__c = source;
        logEntry.Source_Function__c = sourceFunction;
        logEntry.refrence_Id__c = referenceId;
        logEntry.Record_details__c = recordDetails;
        logEntry.DML_info__c = dmlInfo;
        logEntry.Status_Code__c = statusCode;
        logEntry.log_message__c = logMessage + ': ' + e.getMessage();
        logEntry.Stack_Trace__c = e.getStackTraceString();
        logEntry.Type__c = 'Error';
        
        try {
            insert logEntry;
        } catch (Exception logException) {
            System.debug('Error logging exception: ' + logException.getMessage());
            System.debug('Original exception: ' + e.getMessage());
            System.debug('Original stack trace: ' + e.getStackTraceString());
        }
    }

    public static void logMessage(String application, String source, String sourceFunction, String logMessage) {
        Log_Message__c logEntry = new Log_Message__c();
        logEntry.Application__c = application;
        logEntry.Source__c = source;
        logEntry.Source_Function__c = sourceFunction;
        logEntry.log_message__c = logMessage;
        logEntry.Type__c = 'Info';

        try {
            insert logEntry;
        } catch (Exception logException) {
            System.debug('Error logging message: ' + logException.getMessage());
            System.debug('Log message: ' + logMessage);
        }
    }
}