/*********************************************************************************************************************************************
Author		 :	 Prakash Borade
Description	 :   This is general purpose class with re-usable methods
History      :   -
Test Class   :   UtilsTest.cls
----------------------------------------------------------------------------------------------------------------------------------------------
Version      Date                 Author               Details
1            12/21/2023           Prakash Borade       Initial Development
**********************************************************************************************************************************************/

public without sharing class Utils {

    /* 
        getRecordTypeId - Methos is used to get Record Type Id of specific record Type with the help of Entity Name and Record Type Label
    */
    @AuraEnabled(cacheable=true)
    public static String getRecordTypeId(String objectName, String recordTypeLabel) {
        try {
            String gsRecordTypeID = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByName().get(recordTypeLabel).getRecordTypeId();
            return gsRecordTypeID;
        }catch (Exception ex) {
            return ex.getMessage();
        } 
    }

    /*
        Delete single record using record Id
    */
    @AuraEnabled
    public static string deleteRecord(Id recordId){
        try{
            List<Sobject> record = Database.query('Select Id  from '  + String.valueOf(recordId.getSObjectType())+ ' where id=:recordId'); 
            
            if(!record.isEmpty() && record.size() >0) {
                delete record; 
                return 'Success';
            } else { 
                return Null;
            }
        }catch(exception e){
            return e.getMessage();
        }
    }
}