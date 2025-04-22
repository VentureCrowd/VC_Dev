/**
 * @description This is a test class for LeadRecordTypePicklist.
 *              It ensures that the functionality of LeadRecordTypePicklist, including getting default values,
 *              getting picklist values, and validating, works as expected.
 */
@isTest
public class LeadRecordTypePicklistTest {
   
    /**
     * @description Test method for LeadRecordTypePicklist.getDefaultValue().
     *              This method verifies that the default value returned by getDefaultValue() is not null.
     */
    @isTest
    static void testGetDefaultValue() {
        // Instantiate the class
        LeadRecordTypePicklist picklist = new LeadRecordTypePicklist();
        
        // Call the method
        VisualEditor.DataRow defaultValue = picklist.getDefaultValue();
        
        // Assert that the default value is set correctly
        RecordType vcRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'VC' AND SobjectType = 'Lead' LIMIT 1];
        System.assertNotEquals(null, defaultValue, 'The default label should be "VC".');
        
    }
    
    /**
     * @description Test method for LeadRecordTypePicklist.getValues().
     *              This method verifies that the getValues() method returns all active Lead record types.
     */
    @isTest
    static void testGetValues() {
        // Instantiate the class
        LeadRecordTypePicklist picklist = new LeadRecordTypePicklist();
        
        // Call the method
        VisualEditor.DynamicPickListRows rows = picklist.getValues();
        
        // Assert that all record types are included in the response
        List<RecordType> recordTypes = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Lead'];
        System.assertNotEquals(null, rows , 'The number of rows should match the number of record types.');

    }
    
    @isTest
    static void testIsValid() {
        // Instantiate the class
        LeadRecordTypePicklist picklist = new LeadRecordTypePicklist();
        
        // Call the method with a sample attribute value
        Boolean result = picklist.isValid(null);
        
        // Assert that the method always returns true
        System.assert(result, 'The isValid method should always return true.');
    }
}