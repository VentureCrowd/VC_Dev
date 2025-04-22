/**
 * @description This global class provides a dynamic picklist for Lead record types.
 *              It extends the VisualEditor.DynamicPickList class and provides methods to
 *              retrieve default values, list available record types, and validate selections.
 */
global class LeadRecordTypePicklist extends VisualEditor.DynamicPickList{
    
    /**
     * @description Returns the default value for the picklist.
     *              The default value is set to the record type with DeveloperName 'VC' for the Lead object.
     * @return VisualEditor.DataRow representing the default picklist value.
     */
    global override VisualEditor.DataRow getDefaultValue(){
        Id venturesRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('VC').getRecordTypeId();

        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('VC', (String)venturesRecordTypeId);

        return defaultValue;
    }


    /**
     * @description Retrieves all available record types for the Lead object and returns them as picklist values.
     * @return VisualEditor.DynamicPickListRows containing all Lead record types as picklist options.
     */
    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows  recordTypeNames = new VisualEditor.DynamicPickListRows();

        List<RecordType> recordTypes = [SELECT Id, Name, SobjectType, DeveloperName FROM RecordType WHERE SobjectType = 'Lead'];

        for (RecordType recordType : recordTypes) {
            
            VisualEditor.DataRow dRow = new VisualEditor.DataRow(recordType.Name, (String)recordType.Id);

            recordTypeNames.addRow(dRow);
        }

        return recordTypeNames;
    }

    global override Boolean isValid(Object attributeValue) {
        return true;
     }
}