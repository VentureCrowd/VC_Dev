@isTest
public class GenericObjectFactoryTest {
    
    /**
     * Test method for successful record update with multiple field types.
     */
    @isTest
    static void testUpdateRecord_SuccessfulUpdate_MultipleFieldTypes() {
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('VC Person Account').getRecordTypeId();
        // Create a test Account record
        Account testAccount = new Account(
            RecordTypeId = accRecordTypeId,
            LastName='firstName Test',
            FirstName='lastName Test',
            PersonEmail='test@test.com',
            PersonMobilePhone = '1234567890', 
            Website = 'https://initialaccount.com',
            Description = 'Initial Description',
            Industry = 'Technology',
            NumberOfEmployees = 50,
            Retail__c = false,
            PersonHasOptedOutOfEmail = true,
            PersonBirthdate= Date.today()
        );
        insert testAccount;
        
        // Prepare fields to update for Account (STRING, TEXTAREA, URL, PICKLIST, INTEGER)
        Map<String, Object> accountFieldsToUpdate = new Map<String, Object>{
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
        Test.startTest();
        Map<String, Object> accountResult = factory.updateRecord(
            testAccount.Id, 
            'Account', 
            accountFieldsToUpdate, 
            accountFieldMap
        );
        Test.stopTest();
        
        // Assertions for Account
        System.assertEquals(testAccount.Id, accountResult.get('Id'), 'The returned Id should match the updated Account record Id.');
        
        // Retrieve the updated Account record
        Account updatedAccount = [SELECT Name, Phone, Website, Description, Industry, NumberOfEmployees FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals('1122334455', updatedAccount.Phone, 'Account Phone should be updated.');
        System.assertEquals('https://updatedaccount.com', updatedAccount.Website, 'Account Website should be updated.');
        System.assertEquals('Updated Description', updatedAccount.Description, 'Account Description should be updated.');
        System.assertEquals('Healthcare', updatedAccount.Industry, 'Account Industry should be updated.');
        System.assertEquals(100, updatedAccount.NumberOfEmployees, 'Account NumberOfEmployees should be updated.');
        
        // Verify that there are no unmapped fields for Account
        System.assert(accountResult.containsKey('unmapped'), 'Result should contain an "unmapped" key for Account.');
        Map<String, Object> accountUnmappedFields = (Map<String, Object>)accountResult.get('unmapped');
        System.assertEquals(0, accountUnmappedFields.size(), 'There should be no unmapped fields for Account.');
 
    }
    
    /**
     * Test method for handling unmapped fields.
     */
    @isTest
    static void testUpdateRecord_UnmappedFields() {
        // Create a test Account record
        Account testAccount = new Account(
            Name = 'Initial Account', 
            Phone = '1234567890', 
            Website = 'https://initialaccount.com',
            Description = 'Initial Description',
            Industry = 'Technology',
            NumberOfEmployees = 50
        );
        insert testAccount;
        
        // Prepare fields to update with some unmapped fields
        Map<String, Object> fieldsToUpdate = new Map<String, Object>{
            'customName' => 'Updated Account Name',
            'customPhone' => '0987654321',
            'customWebsite' => 'https://updatedaccount.com',
            'customDescription' => 10101010,
            'customIndustry' => 'Healthcare',
            'customNumberOfEmployees' => 100,
            'numberEmp' => 1.5,
            'unmappedField1' => 'Value1',
            'unmappedField2' => 'Value2',
            'daysSinceAcc' => '10',
            'nofieldmapped' => 'hello'
        };
        
        // Prepare fieldMap with mappings only for known custom keys
        Map<String, String> initializerMap = new Map<String, String>{
            'customName' => 'Name',
            'customPhone' => 'Phone',
            'customWebsite' => 'Website',
            'customDescription' => 'Description',
            'customIndustry' => 'Industry',
            'customNumberOfEmployees' => 'NumberOfEmployees',
            'unmappedField2' => 'unmappedField2',
            'unmappedField1' => 'unmappedField1',
            'numberEmp' => 'Number_of_Employees__c',
            'daysSinceAcc' => 'Days_Since_Account_Created__c'
        };
        BidiMap fieldMap = new BidiMap(initializerMap);
        
        // Instantiate the GenericObjectFactory
        GenericObjectFactory factory = new GenericObjectFactory();
        
        // Call the updateRecord method for Account
        Test.startTest();
        Map<String, Object> result = factory.updateRecord(
            testAccount.Id, 
            'Account', 
            fieldsToUpdate, 
            fieldMap
        );
        Test.stopTest();
        
        // Assertions
        System.assertEquals(testAccount.Id, result.get('Id'), 'The returned Id should match the updated Account record Id.');
        
        // Retrieve the updated Account record
        Account updatedAccount = [SELECT Name, Phone, Website, Description, Industry, NumberOfEmployees FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals('Updated Account Name', updatedAccount.Name, 'Account Name should be updated.');
        System.assertEquals('0987654321', updatedAccount.Phone, 'Account Phone should be updated.');
        System.assertEquals('https://updatedaccount.com', updatedAccount.Website, 'Account Website should be updated.');
        System.assertEquals('10101010', updatedAccount.Description, 'Account Description should be updated.');
        System.assertEquals('Healthcare', updatedAccount.Industry, 'Account Industry should be updated.');
        System.assertEquals(100, updatedAccount.NumberOfEmployees, 'Account NumberOfEmployees should be updated.');
        
        // Verify that unmapped fields are correctly identified
        System.assert(result.containsKey('unmapped'), 'Result should contain an "unmapped" key.');
        Map<String, Object> unmappedFields = (Map<String, Object>)result.get('unmapped');
        System.assertEquals(4, unmappedFields.size(), 'There should be three unmapped fields.');
        System.assertEquals('Value1', unmappedFields.get('unmappedField1'), 'unmappedField1 should be unmapped.');
        System.assertEquals('Value2', unmappedFields.get('unmappedField2'), 'unmappedField2 should be unmapped.');
    }
    
    /**
     * Test method for handling DML exceptions (e.g., updating a non-existent record).
     */
    @isTest
    static void testUpdateRecord_DmlException() {
        // Use a non-existent record Id
        // Generate a random Id for testing purposes
        Id nonExistentId = 'a5RIk000000GmdVMAS';
        
        // Prepare fields to update
        Map<String, Object> fieldsToUpdate = new Map<String, Object>{
            'customName' => 'Should Fail'
        };
        
        // Prepare fieldMap with mapping for 'customName'
        Map<String, String> initializerMap = new Map<String, String>{
            'customName' => 'Name'
        };
        BidiMap fieldMap = new BidiMap(initializerMap);
        
        // Instantiate the GenericObjectFactory
        GenericObjectFactory factory = new GenericObjectFactory();
        
        // Call the updateRecord method
        Test.startTest();
        Map<String, Object> result = factory.updateRecord(
            nonExistentId, 
            'Account', 
            fieldsToUpdate, 
            fieldMap
        );
        Test.stopTest();
        
        // Assertions
        System.assert(result.containsKey('error'), 'Result should contain an "error" key.');
        String errorMessage = (String)result.get('error');
        System.assert(errorMessage != null && errorMessage != '', 'Error message should not be null or empty.');
    }
    
    /**
     * Test method for handling invalid object names.
     */
    @isTest
    static void testUpdateRecord_InvalidObject() {
        // Create a test Account record
        Account testAccount = new Account(
            Name = 'Initial Account', 
            Phone = '1234567890', 
            Website = 'https://initialaccount.com',
            Description = 'Initial Description',
            Industry = 'Technology',
            NumberOfEmployees = 50
        );
        insert testAccount;
        
        // Prepare fields to update
        Map<String, Object> fieldsToUpdate = new Map<String, Object>{
            'customName' => 'Updated Account Name'
        };
        
        // Prepare fieldMap with mapping for 'customName'
        Map<String, String> initializerMap = new Map<String, String>{
            'customName' => 'Name'
        };
        BidiMap fieldMap = new BidiMap(initializerMap);
        
        // Instantiate the GenericObjectFactory
        GenericObjectFactory factory = new GenericObjectFactory();
        
        // Call the updateRecord method with an invalid object name
        Test.startTest();
        Map<String, Object> result = factory.updateRecord(
            testAccount.Id, 
            'InvalidObject', // Invalid object name
            fieldsToUpdate, 
            fieldMap
        );
        Test.stopTest();
        
        // Assertions
        System.assert(result.containsKey('error'), 'Result should contain an "error" key.');
        String errorMessage = (String)result.get('error');
        System.assert(errorMessage != null && errorMessage != '', 'Error message should not be null or empty.');
        System.assert(
            errorMessage.contains('Invalid object name') || 
            errorMessage.contains('Failed to instantiate object'), 
            'Error message should indicate an invalid object name or instantiation failure.'
        );
    }

    /** Test method for successful record creation with multiple field types.
    */
    @isTest
    static void testCreateRecord_SuccessfulCreate_MultipleFieldTypes() {
        // Get the RecordTypeId for 'VC Person Account'
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('VC Person Account').getRecordTypeId();
        
        // Define dynamic Date and Datetime values
        Date customBirthDate = Date.valueOf('1999-12-22');
        Date dateInvestment = Date.today();
        Datetime lastRefDate = Datetime.now();
        String someDateTimeValStr = '2022-12-22 12:00:00';
        Datetime someDateTimeVal = Datetime.valueOfGmt(someDateTimeValStr);
        
        // Prepare fields to create for Account (STRING, TEXTAREA, EMAIL, PHONE, BOOLEAN, DATE, DATETIME, DOUBLE, etc.)
        Map<String, Object> accFieldsToCreate = new Map<String, Object>{
            'customNameF' => 'Updated Account Name',
            'customNameL' => 'Updated',
            'customPhone' => '1122334455',
            'customWebsite' => 'https://updatedaccount.com',
            'customDescription' => 'Updated Description',
            'customIndustry' => 'Healthcare',
            'customNumberOfEmployees' => '100', // Treat as INTEGER
            'customRetail'  => 'true',
            'email' => 'hello@mail.com',
            'customEmailOptOut' => false,
            'customBirthDate' => customBirthDate,
            'dateInvestment' => dateInvestment,
            'lastRefDate' => lastRefDate,
            'someDateTimeVal' => someDateTimeValStr,
            'numberEmp' => '1.5',
            'recordId' => accRecordTypeId
        };
        
        // Prepare fieldMap for Account
        Map<String, String> accFieldMapInitializer = new Map<String, String>{
            'customNameF' => 'FirstName',
            'customNameL' => 'LastName',
            'customPhone' => 'PersonMobilePhone',
            'customWebsite' => 'Website',
            'customDescription' => 'Description',
            'customIndustry' => 'Industry',
            'customNumberOfEmployees' => 'NumberOfEmployees',
            'customRetail' => 'Retail__c',
            'customEmailOptOut' => 'PersonHasOptedOutOfEmail',
            'customBirthDate' => 'PersonBirthdate',
            'dateInvestment' => 'Date_of_first_Investment__c',
            'lastRefDate' => 'SIC_EIC_Approved_Date__pc',
            'someDateTimeVal' => 'PersonEmailBouncedDate',
            'numberEmp' => 'Number_of_Employees__c',
            'recordId' => 'RecordTypeId',
            'email' => 'PersonEmail'
        };
        BidiMap accFieldMap = new BidiMap(accFieldMapInitializer);
        
        // Instantiate the GenericObjectFactory
        GenericObjectFactory factory = new GenericObjectFactory();
        
        // Call the createRecord method for Account
        Test.startTest();
        Map<String, Object> accResult = factory.createRecord(
            'Account', 
            accFieldsToCreate, 
            accFieldMap
        );
        Test.stopTest();
        
        // Assertions for Account
        // Assert that the 'Id' key exists in the result
        System.assert(accResult.containsKey('Id'), 'Result should contain an "Id" key for the created Account.');
        Id createdAccId = (Id)accResult.get('Id');
        
        // Retrieve the created Account record
        Account createdAcc = [
            SELECT FirstName, LastName, PersonMobilePhone, Website, Description, Industry, 
                   NumberOfEmployees, Retail__c, PersonHasOptedOutOfEmail, PersonBirthdate, 
                   Date_of_first_Investment__c, SIC_EIC_Approved_Date__pc, PersonEmailBouncedDate, 
                   Number_of_Employees__c, PersonEmail, RecordTypeId 
            FROM Account 
            WHERE Id = :createdAccId
        ];
        
        // Verify field values
        System.assertEquals('Updated Account Name', createdAcc.FirstName, 'FirstName should be updated.');
        System.assertEquals('Updated', createdAcc.LastName, 'LastName should be updated.');
        System.assertEquals('1122334455', createdAcc.PersonMobilePhone, 'PersonMobilePhone should be updated.');
        System.assertEquals('https://updatedaccount.com', createdAcc.Website, 'Website should be updated.');
        System.assertEquals('Updated Description', createdAcc.Description, 'Description should be updated.');
        System.assertEquals('Healthcare', createdAcc.Industry, 'Industry should be updated.');
        System.assertEquals(100, createdAcc.NumberOfEmployees, 'NumberOfEmployees should be updated.');
        System.assertEquals(true, createdAcc.Retail__c, 'Retail__c should be updated.');
        System.assertEquals(false, createdAcc.PersonHasOptedOutOfEmail, 'PersonHasOptedOutOfEmail should be updated.');
        System.assertEquals(customBirthDate, createdAcc.PersonBirthdate, 'PersonBirthdate should be updated.');
        System.assertEquals(dateInvestment, createdAcc.Date_of_first_Investment__c, 'Date_of_first_Investment__c should be updated.');
        System.assertEquals(lastRefDate, createdAcc.SIC_EIC_Approved_Date__pc, 'SIC_EIC_Approved_Date__pc should be updated.');
        System.assertEquals(someDateTimeVal, createdAcc.PersonEmailBouncedDate, 'PersonEmailBouncedDate should be updated.');
        System.assertEquals(1.5, createdAcc.Number_of_Employees__c, 'Number_of_Employees__c should be updated.');
        System.assertEquals('hello@mail.com', createdAcc.PersonEmail, 'PersonEmail should be updated.');
        System.assertEquals(accRecordTypeId, createdAcc.RecordTypeId, 'RecordTypeId should be set correctly.');
        
        // Verify that there are no unmapped fields for Account
        System.assert(accResult.containsKey('unmapped'), 'Result should contain an "unmapped" key for Account.');
        Map<String, Object> accUnmappedFields = (Map<String, Object>)accResult.get('unmapped');
        System.assertEquals(0, accUnmappedFields.size(), 'There should be no unmapped fields for Account.');
    }
    
    @isTest
static void testCreateRecord_UnmappedFields() {
    // Get the RecordTypeId for 'VC Person Account'
    Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('VC Person Account').getRecordTypeId();
    
    // Define dynamic Date and Datetime values
    Date customBirthDate = Date.valueOf('1999-12-22');
    Date dateInvestment = Date.today();
    Datetime lastRefDate = Datetime.now();
    String someDateTimeValStr = '2022-12-22 12:00:00';
    Datetime someDateTimeVal = Datetime.valueOfGmt(someDateTimeValStr);
    
    // Prepare fields to create for Account with some unmapped fields
    Map<String, Object> accFieldsToCreate = new Map<String, Object>{
        'customNameF' => 'Updated Account Name',
        'customNameL' => 'Updated',
        'customPhone' => '1122334455',
        'customWebsite' => 'https://updatedaccount.com',
        'customDescription' => 'Updated Description',
        'customIndustry' => 'Healthcare',
        'customNumberOfEmployees' => '100', // Treat as INTEGER
        'customRetail'  => 'true',
        'email' => 'hello@mail.com',
        'customEmailOptOut' => false,
        'customBirthDate' => customBirthDate,
        'dateInvestment' => dateInvestment,
        'lastRefDate' => lastRefDate,
        'someDateTimeVal' => someDateTimeValStr,
        'numberEmp' => '1.5',
        'recordId' => accRecordTypeId,
        'unmappedField1' => 'Value1',
        'unmappedField2' => 'Value2',
        'daysSinceAcc' => '100',
        'testNoExist' => 'Value3'
    };
    
    // Prepare fieldMap for Account with some fields intentionally unmapped
    Map<String, String> accFieldMapInitializer = new Map<String, String>{
        'customNameF' => 'FirstName',
        'customNameL' => 'LastName',
        'customPhone' => 'PersonMobilePhone',
        'customWebsite' => 'Website',
        'customDescription' => 'Description',
        'customIndustry' => 'Industry',
        'customNumberOfEmployees' => 'NumberOfEmployees',
        'customRetail' => 'Retail__c',
        'customEmailOptOut' => 'PersonHasOptedOutOfEmail',
        'customBirthDate' => 'PersonBirthdate',
        'dateInvestment' => 'Date_of_first_Investment__c',
        'lastRefDate' => 'SIC_EIC_Approved_Date__pc',
        'someDateTimeVal' => 'PersonEmailBouncedDate',
        'numberEmp' => 'Number_of_Employees__c',
        'recordId' => 'RecordTypeId',
        'email' => 'PersonEmail',
        'testNoExist' => 'non_existent__c',
        'daysSinceAcc' => 'Days_Since_Account_Created__c'
        // 'unmappedField1' and 'unmappedField2' are intentionally not mapped
    };
    BidiMap accFieldMap = new BidiMap(accFieldMapInitializer);
    
    // Instantiate the GenericObjectFactory
    GenericObjectFactory factory = new GenericObjectFactory();
    
    // Call the createRecord method for Account with unmapped fields
    Test.startTest();
    Map<String, Object> accResult = factory.createRecord(
        'Account', 
        accFieldsToCreate, 
        accFieldMap
    );
    Test.stopTest();
    
    // Assertions for Account
    // Assert that the 'Id' key exists in the result
    System.assert(accResult.containsKey('Id'), 'Result should contain an "Id" key for the created Account.');
    Id createdAccId = (Id)accResult.get('Id');
    
    // Retrieve the created Account record
    Account createdAcc = [
        SELECT FirstName, LastName, PersonMobilePhone, Website, Description, Industry, 
               NumberOfEmployees, Retail__c, PersonHasOptedOutOfEmail, PersonBirthdate, 
               Date_of_first_Investment__c, SIC_EIC_Approved_Date__pc, PersonEmailBouncedDate, 
               Number_of_Employees__c, PersonEmail, RecordTypeId 
        FROM Account 
        WHERE Id = :createdAccId
    ];
    
    // Verify mapped field values
    System.assertEquals('Updated Account Name', createdAcc.FirstName, 'FirstName should be updated.');
    System.assertEquals('Updated', createdAcc.LastName, 'LastName should be updated.');
    System.assertEquals('1122334455', createdAcc.PersonMobilePhone, 'PersonMobilePhone should be updated.');
    System.assertEquals('https://updatedaccount.com', createdAcc.Website, 'Website should be updated.');
    System.assertEquals('Updated Description', createdAcc.Description, 'Description should be updated.');
    System.assertEquals('Healthcare', createdAcc.Industry, 'Industry should be updated.');
    System.assertEquals(100, createdAcc.NumberOfEmployees, 'NumberOfEmployees should be updated.');
    System.assertEquals(true, createdAcc.Retail__c, 'Retail__c should be updated.');
    System.assertEquals(false, createdAcc.PersonHasOptedOutOfEmail, 'PersonHasOptedOutOfEmail should be updated.');
    System.assertEquals(customBirthDate, createdAcc.PersonBirthdate, 'PersonBirthdate should be updated.');
    System.assertEquals(dateInvestment, createdAcc.Date_of_first_Investment__c, 'Date_of_first_Investment__c should be updated.');
    System.assertEquals(lastRefDate, createdAcc.SIC_EIC_Approved_Date__pc, 'SIC_EIC_Approved_Date__pc should be updated.');
    System.assertEquals(someDateTimeVal, createdAcc.PersonEmailBouncedDate, 'PersonEmailBouncedDate should be updated.');
    System.assertEquals(1.5, createdAcc.Number_of_Employees__c, 'Number_of_Employees__c should be updated.');
    System.assertEquals('hello@mail.com', createdAcc.PersonEmail, 'PersonEmail should be updated.');
    System.assertEquals(accRecordTypeId, createdAcc.RecordTypeId, 'RecordTypeId should be set correctly.');
    
    // Verify that there are unmapped fields
    System.assert(accResult.containsKey('unmapped'), 'Result should contain an "unmapped" key for Account.');
    Map<String, Object> accUnmappedFields = (Map<String, Object>)accResult.get('unmapped');
    System.assertEquals(4, accUnmappedFields.size(), 'There should be two unmapped fields for Account.');
    System.assertEquals('Value1', accUnmappedFields.get('unmappedField1'), 'unmappedField1 should be unmapped.');
    System.assertEquals('Value2', accUnmappedFields.get('unmappedField2'), 'unmappedField2 should be unmapped.');
}

}