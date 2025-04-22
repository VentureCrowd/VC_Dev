public class DynamicLookupController {  
    @AuraEnabled(cacheable=true)  
    public static List<sobject> findRecords(String searchKey, String objectName, String recordLabel) { 
        string query = '';
        if(String.isBlank(searchKey) || String.isBlank(objectName)) {
            return null;
        }
        string searchText = '\'%%' + String.escapeSingleQuotes(searchKey) + '%%\'';          
        query = 'SELECT Id, '+recordLabel +' FROM ' +objectName+ ' WHERE Name LIKE ' +searchText;
        return Database.query(query);  
    }  
}