public without sharing class logMsgUtility {
    public static void logMessage(Exception e, string ClassName, String appName, string methodname, Map<String,Object> inParamsMap ){   
        List<Log_Message__c> logmsglst = new List<Log_Message__c>();
        Log_Message__c msg = new Log_Message__c();
        string message = '';
        message += 'Exception Type: ' + e.getTypeName() + '\nException Line Nr: ' + e.getLineNumber(); 
        msg.Record_details__c = '';
        msg.Application__c = appName;
        if(inParamsMap != null){
            for(String ipKey : inParamsMap.keyset()){
                msg.Record_details__c += '<p>'+ ipKey + ': ' + inparamsMap.get(ipKey) + '</p>';
            }
        }
        
        if (e instanceof DmlException){
           DmlException dmlExc = (DmlException) e;
           String dmlMessage ;
           for (integer i= 0; i<dmlExc.getNumDml(); i++){
               dmlMessage += '  \nException Message:' + dmlExc.getDmlMessage(i);
               dmlMessage +=  ' Batch Row #:' + dmlExc.getDmlIndex(i);
               String fieldsInError = '';               
               for (String fieldName : dmlExc.getDmlFieldNames(i))
               {
                   if (fieldsInError == '')
                       fieldsInError = fieldName;
                   else
                       fieldsInError += ', ' + fieldName;
               }
               dmlMessage += fieldsInError;             
               msg.Stack_Trace__c = e.getStackTraceString();
               msg.Source_Function__c = methodname;
               msg.Source__c = ClassName;
               msg.log_message__c = message;
               msg.Status_Code__c = dmlExc.getDmlStatusCode(i);
               msg.DML_info__c = dmlMessage;
               logmsglst.add(msg);
           }        
       }else{
            message += '\nException Message: ' + e.getMessage();
            msg.Stack_Trace__c = e.getStackTraceString();
            msg.Source_Function__c = methodname;
            msg.Source__c = ClassName;
            msg.log_message__c = message;
            logmsglst.add(msg);
        }
        insert logmsglst;
    }
}