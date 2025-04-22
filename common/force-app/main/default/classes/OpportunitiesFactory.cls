public inherited sharing class OpportunitiesFactory {
    public OpportunitiesService.RecordsWrapper getRecords(Id recordId, Integer pageSize, Integer pageNumber, String sortBy, String sortDirection, List<String> columnNames){
        try{
              // Construct the SOQL query dynamically based on column names
            Integer offset = (pageNumber - 1) * pageSize;

            // Manually join column names into a single string
            String fields = '';
            for (String column : columnNames) {
                fields += column + ', ';
            }
            fields = fields.removeEnd(', ');

            String query = 'SELECT ' + fields + ' FROM Opportunity WHERE Raise__c=:recordId' ;

            if (sortBy != null && sortDirection != null) {
                query += ' ORDER BY ' + sortBy + ' ' + sortDirection;
            }

            query += ' LIMIT :pageSize OFFSET :offset';

            List<sObject> records = Database.query(query);

            List<AggregateResult> totalRecords = [SELECT COUNT(Id) FROM Opportunity WHERE Raise__c =: recordId];

            return new OpportunitiesService.RecordsWrapper(records, totalRecords);  
        }catch(Exception e){
            throw new AuraHandledException(e.getStackTraceString());
        }
      
    }

    public Map<String,Object> updateOpportunity(Id recordId, String objectName, Map<String, Object> fieldsToUpdate, BidiMap fieldMapping){
        Map<String,Object> returnData = new Map<String,Object>();
        // Opportunity recordToUpdate = new Opportunity();
        SObject recordToUpdate = Schema.getGlobalDescribe().get(objectName).newSObject();

        recordToUpdate.put('Id',recordId);

        Map<String, SObjectField> objectFieldsMap = recordToUpdate.getSObjectType().getDescribe().fields.getMap();
        Map<String, Object> unmappedFields = new Map<String,Object>();

        for(String field : fieldsToUpdate.keySet()){
            if(fieldMapping.containsKey(field)){
                // get api field name
                String sObjectFieldName = fieldMapping.getValue(field);

                // check if field exists in the object
                if(objectFieldsMap.containsKey(sObjectFieldName)){
                    //get the field type
                    SObjectField sObjectField = objectFieldsMap.get(sObjectFieldName);
                    // check if its a calculated field
                    if(sObjectField.getDescribe().isCalculated()){
                        unmappedFields.put(field, fieldsToUpdate.get(field));
                    }else{
                        Schema.DisplayType fieldType = sObjectField.getDescribe().getType();
                        Object fieldValue = fieldsToUpdate.get(field);

                        // convert value to field type
                        Object convertedValue = convertFieldValue(fieldType, fieldValue);

                        // put
                        recordToUpdate.put(sObjectFieldName, convertedValue);
                    }
                }else{
                    unmappedFields.put(field, fieldsToUpdate.get(field));
                }

            }else{
                unmappedFields.put(field, fieldsToUpdate.get(field));
            }
        }
        update recordToUpdate;
        returnData.put('Id', recordId);
        returnData.put('unmapped', unmappedFields);
        
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
                return Boolean.valueOf((String) fieldValue);
            }
            when DATE {
                return Date.valueOf((String) fieldValue);
            }
            when DATETIME {
                return Datetime.valueOfGmt((String) fieldValue);
            }
            when INTEGER {
                return Integer.valueOf((String) fieldValue);
            }
            when DOUBLE, CURRENCY, PERCENT {
                return Double.valueOf((String) fieldValue);
            }
            when STRING, TEXTAREA, URL, EMAIL, PHONE {
                return (String) fieldValue;
            }
            when ID {
                return (Id) fieldValue;
            }
            when REFERENCE {
                return (Id) fieldValue;
            }
            when else {
                return (String) fieldValue;
            }
        }
    }

    /**
     * Get productId, investmentId and raiseId based on the OpportunityId.
     * @param opportunityId.
     * @return The converted value.
     */

    public OpportunityLineItem getProductId (Id oppLineItem) {
            OpportunityLineItem opportunityId = [SELECT Product2Id FROM OpportunityLineItem WHERE Id=:oppLineItem LIMIT 1];
            return opportunityId;
    }
}