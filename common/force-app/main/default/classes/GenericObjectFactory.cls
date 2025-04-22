public without sharing class GenericObjectFactory {
    /**
     * Example Usage
     * // Prepare fields to update for Account (STRING, TEXTAREA, URL, PICKLIST, INTEGER)
     *  Map<String, Object> accountFieldsToUpdate = new Map<String, Object>{
            'customNameF' => 'Updated Account Name',
            'customNameL' => 'Updated',
            'customPhone' => '1122334455',
            'customWebsite' => 'https://updatedaccount.com',
            'customDescription' => 'Updated Description',
            'customIndustry' => 'Healthcare',
            'customNumberOfEmployees' => '100', // Treat as INTEGER,
            'customRetail'  => 'true',
            'customEmailOptOut' => false,
            'customBirthDate' => '1999-12-22',
            'dateInvestment' => Date.today(),
            'lastRefDate' => Datetime.now(),
            'someDateTimeVal' => '2022-12-22 12:00:00',
            'numberEmp' => '1.5'
        };
        
        // Prepare fieldMap for Account
        Map<String, String> accountFieldMapInitializer = new Map<String, String>{
            'customNameF' => 'FirstName',
            'customNameL' => 'LastName',
            'customPhone' => 'Phone',
            'customWebsite' => 'Website',
            'customDescription' => 'Description',
            'customIndustry' => 'Industry',
            'customNumberOfEmployees' => 'NumberOfEmployees',
            'customRetail' => 'Retail__c',
            'customEmailOptOut'=>'PersonHasOptedOutOfEmail',
            'customBirthDate'=>'PersonBirthdate',
            'dateInvestment'=>'Date_of_first_Investment__c',
            'lastRefDate'=>'SIC_EIC_Approved_Date__pc',
            'someDateTimeVal' => 'PersonEmailBouncedDate',
            'numberEmp' => 'Number_of_Employees__c'
        };
        BidiMap accountFieldMap = new BidiMap(accountFieldMapInitializer);
        
        // Instantiate the GenericObjectFactory
        GenericObjectFactory factory = new GenericObjectFactory();
        
        // Call the updateRecord method for Account
        Map<String, Object> accountResult = factory.updateRecord(
            testAccount.Id, 
            'Account', 
            accountFieldsToUpdate, 
            accountFieldMap
        );
     */
    /**
     * Updates a record of a specified object type using a map of field values.
     * @param recordId The ID of the record to update.
     * @param objectName The API name of the object (e.g., 'Account', 'Contact').
     * @param fieldsToUpdate A map of field labels or custom keys to the values to update.
     * @param fieldMap A BidiMap of the custom keys to the object's field API names.
     * @return A map containing the record ID and any fields that were not mapped or updated.
     */
    public Map<String,Object> updateRecord(Id recordId, String objectName, Map<String, Object> fieldsToUpdate, BidiMap fieldMap) {
        Map<String,Object> returnData = new Map<String,Object>();
        
        // Get the global describe map
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        
        // Check if the object exists
        if (!gd.containsKey(objectName)) {
            returnData.put('error', 'Invalid object name: ' + objectName);
            return returnData;
        }
        
        // Instantiate the SObject
        SObject recordToUpdate;
        try {
            recordToUpdate = gd.get(objectName).newSObject();
        } catch (Exception e) {
            returnData.put('error', 'Failed to instantiate object: ' + e.getMessage());
            return returnData;
        }
        
        // Set the record ID
        recordToUpdate.put('Id', recordId);

        // Get the fields map for the object
        Map<String, SObjectField> objectFieldsMap = recordToUpdate.getSObjectType().getDescribe().fields.getMap();
        Map<String, Object> unmappedFields = new Map<String,Object>();

        for(String field : fieldsToUpdate.keySet()) {
            if(fieldMap.containsKey(field)) {
                String sObjectFieldName = fieldMap.getValue(field);
                if(objectFieldsMap.containsKey(sObjectFieldName)) {
                    SObjectField sObjectField = objectFieldsMap.get(sObjectFieldName);
                    if(!sObjectField.getDescribe().isCalculated()) {
                        Schema.DisplayType fieldType = sObjectField.getDescribe().getType();
                        Object fieldValue = fieldsToUpdate.get(field);
                        Object convertedValue = convertFieldValue(fieldType, fieldValue);
                        recordToUpdate.put(sObjectFieldName, convertedValue);
                    } else {
                        unmappedFields.put(field, fieldsToUpdate.get(field));
                    }
                } else {
                    unmappedFields.put(field, fieldsToUpdate.get(field));
                }
            } else {
                unmappedFields.put(field, fieldsToUpdate.get(field));
            }
        }
        
        try {
            update recordToUpdate;
            returnData.put('Id', recordId);
            returnData.put('unmapped', unmappedFields);
        } catch (DmlException e) {
            System.debug('Error occurred while updating record: ' + e.getMessage());
            returnData.put('error', e.getMessage());
        }
        
        return returnData;
    }

    /**
     * Creates a new record of a specified object type using a map of field values.
     * @param objectName The API name of the object (e.g., 'Account', 'Contact').
     * @param fieldsToCreate A map of field labels or custom keys to the values to set.
     * @param fieldMap A BidiMap of the custom keys to the object's field API names.
     * @return A map containing the new record ID and any fields that were not mapped or set.
     */
    public Map<String,Object> createRecord(String objectName, Map<String, Object> fieldsToCreate, BidiMap fieldMap) {
        Map<String,Object> returnData = new Map<String,Object>();
        
        // Get the global describe map
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        
        // Check if the object exists
        if (!gd.containsKey(objectName)) {
            returnData.put('error', 'Invalid object name: ' + objectName);
            return returnData;
        }
        
        // Instantiate the SObject
        SObject recordToCreate;
        try {
            recordToCreate = gd.get(objectName).newSObject();
        } catch (Exception e) {
            returnData.put('error', 'Failed to instantiate object: ' + e.getMessage());
            return returnData;
        }
        
        // Get the fields map for the object
        Map<String, SObjectField> objectFieldsMap = recordToCreate.getSObjectType().getDescribe().fields.getMap();
        Map<String, Object> unmappedFields = new Map<String,Object>();

        for(String field : fieldsToCreate.keySet()) {
            if(fieldMap.containsKey(field)) {
                String sObjectFieldName = fieldMap.getValue(field);
                if(objectFieldsMap.containsKey(sObjectFieldName)) {
                    SObjectField sObjectField = objectFieldsMap.get(sObjectFieldName);
                    if(!sObjectField.getDescribe().isCalculated()) {
                        Schema.DisplayType fieldType = sObjectField.getDescribe().getType();
                        Object fieldValue = fieldsToCreate.get(field);
                        Object convertedValue = convertFieldValue(fieldType, fieldValue);
                        recordToCreate.put(sObjectFieldName, convertedValue);
                    } else {
                        unmappedFields.put(field, fieldsToCreate.get(field));
                    }
                } else {
                    unmappedFields.put(field, fieldsToCreate.get(field));
                }
            } else {
                unmappedFields.put(field, fieldsToCreate.get(field));
            }
        }
        
        try {
            insert recordToCreate;
            returnData.put('Id', recordToCreate.Id);
            returnData.put('unmapped', unmappedFields);
        } catch (DmlException e) {
            System.debug('Error occurred while creating record: ' + e.getMessage());
            returnData.put('error', e.getMessage());
        }
        
        return returnData;
    }
    
    /**
     * Converts a field value to the appropriate type based on the field description.
     * @param fieldType The field type.
     * @param fieldValue The value to convert.
     * @return The converted value.
     */
    @TestVisible
    private Object convertFieldValue(Schema.DisplayType fieldType, Object fieldValue) {
        if (fieldValue == null) {
            return null;
        }
    
        switch on fieldType {
            when BOOLEAN {
                if (fieldValue instanceof Boolean) {
                    return (Boolean)fieldValue;
                } else if (fieldValue instanceof String) {
                    return Boolean.valueOf((String) fieldValue);
                } else {
                    return null;
                }
            }
            when DATE {
                if (fieldValue instanceof Date) {
                    return (Date)fieldValue;
                } else if (fieldValue instanceof String) {
                    return Date.valueOf((String) fieldValue);
                } else {
                    return null;
                }
            }
            when DATETIME {
                if (fieldValue instanceof Datetime) {
                    return (Datetime)fieldValue;
                } else if (fieldValue instanceof String) {
                    return Datetime.valueOfGmt((String) fieldValue);
                } else {
                    return null;
                }
            }
            when INTEGER {
                if (fieldValue instanceof Integer) {
                    return (Integer)fieldValue;
                } else if (fieldValue instanceof String) {
                    return Integer.valueOf((String) fieldValue);
                } else {
                    return null;
                }
            }
            when DOUBLE, CURRENCY, PERCENT {
                if (fieldValue instanceof Double) {
                    return (Double)fieldValue;
                } else if (fieldValue instanceof String) {
                    return Double.valueOf((String) fieldValue);
                } else {
                    return null;
                }
            }
            when STRING, TEXTAREA, URL, EMAIL, PHONE {
                if (fieldValue instanceof String) {
                    return (String)fieldValue;
                } else {
                    return String.valueOf(fieldValue);
                }
            }
            when ID, REFERENCE {
                if (fieldValue instanceof Id) {
                    return (Id)fieldValue;
                } else if (fieldValue instanceof String) {
                    return (Id)fieldValue;
                } else {
                    return null;
                }
            }
            when else {
                return String.valueOf(fieldValue);
            }
        }
    }
}