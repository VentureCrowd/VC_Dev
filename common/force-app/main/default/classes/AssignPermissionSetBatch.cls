/**
 * AUTHOR: KENDRICK 20/09/2024
 * Batch Apex Class to Assign a Permission Set to Users Based on Profile Names
 * 
 * This class assigns a specified Permission Set to users who belong to specified Profiles.
 * 
 * Usage:
 * 1. Deploy this class to your Salesforce org.
 * 2. Execute the batch via the Developer Console or anonymously, passing in the required parameters.
 * 3. Monitor the batch job to ensure successful completion
 * E.g.
 * // Define the Profile Names to filter users
    List<String> profilesToFilter = new List<String>{
        'Portal User Profile Name1',
        'Portal User Profile Name2' // Add more as needed
    };

    // Define the Permission Set Name
    String permSetName = 'Portal_User_Permission_Set'; // Replace with your Permission Set Name

    // Instantiate the batch class
    AssignPermissionSetBatch batch = new AssignPermissionSetBatch(profilesToFilter, permSetName);

    // Execute the batch with a batch size of 200
    Database.executeBatch(batch, 200);.
 */
global class AssignPermissionSetBatch implements Database.Batchable<SObject>, Database.Stateful {
    
    // Parameters for filtering and assignment
    private List<String> profileNames;
    private String permissionSetName;
    private Id permissionSetId;
    
    // To track the number of successful and failed assignments
    global Integer successCount = 0;
    global Integer failureCount = 0;
    
    /**
     * Constructor
    * 
     * @param profileNames List of Profile Names to filter users.
     * @param permissionSetName Name of the Permission Set to assign.
     */
    global AssignPermissionSetBatch(List<String> profileNames, String permissionSetName) {
        this.profileNames = profileNames;
        this.permissionSetName = permissionSetName;
    }
    
    /**
     * Start Method
     * 
     * Selects the users who belong to the specified Profiles and are active.
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        if (String.isBlank(permissionSetName)) {
            throw new SalesforceException('Permission Set Name must be provided.');
        }
        
        if (profileNames == null || profileNames.isEmpty()) {
            throw new SalesforceException('At least one Profile Name must be provided.');
        }
        
        // Retrieve the Permission Set by Name
        List<PermissionSet> psList = [SELECT Id FROM PermissionSet WHERE Name = :permissionSetName LIMIT 1];
        if (psList.isEmpty()) {
            throw new SalesforceException('Permission Set "' + permissionSetName + '" not found.');
        }
        permissionSetId = psList[0].Id;
        
        // Query users based on the provided Profile Names and active status
        return Database.getQueryLocator([
            SELECT Id, Name, Profile.Name
            FROM User
            WHERE Profile.Name IN :profileNames
            AND IsActive = true
        ]);
    }
    
    /**
     * Execute Method
     * 
     * Assigns the Permission Set to each user in the current batch if they don't already have it.
     */
    global void execute(Database.BatchableContext BC, List<User> scope) {
        // Prepare a list to hold PermissionSetAssignment records
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
        
        // Collect User IDs from the current scope
        Set<Id> userIds = new Set<Id>();
        for (User u : scope) {
            userIds.add(u.Id);
        }
        
        // Query existing PermissionSetAssignments for these users and the specified Permission Set
        Map<Id, PermissionSetAssignment> existingPSAMap = new Map<Id, PermissionSetAssignment>();
        for (PermissionSetAssignment psa : [
            SELECT Id, AssigneeId 
            FROM PermissionSetAssignment 
            WHERE AssigneeId IN :userIds 
            AND PermissionSetId = :permissionSetId
        ]) {
            existingPSAMap.put(psa.AssigneeId, psa);
        }
        
        // Iterate through the users and prepare PermissionSetAssignment records for those who don't have it
        for (User u : scope) {
            if (!existingPSAMap.containsKey(u.Id)) {
                psaList.add(new PermissionSetAssignment(
                    AssigneeId = u.Id,
                    PermissionSetId = permissionSetId
                ));
            }
        }
        
        // Insert the PermissionSetAssignment records
        if (!psaList.isEmpty()) {
            try {
                insert psaList;
                successCount += psaList.size();
            } catch (DmlException e) {
                // Handle DML exceptions (e.g., partial failures)
                System.debug('Error assigning Permission Set: ' + e.getMessage());
                failureCount += psaList.size();
                // Optionally, implement retry logic or logging
            }
        }
    }
    
    /**
     * Finish Method
     * 
     * Executes after all batches are processed. Useful for sending summary emails or logging.
     */
    global void finish(Database.BatchableContext BC) {
        // Example: Send an email summary of the batch job
        // Uncomment and customize the below code if email notifications are desired
        
        /*
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {'admin@yourdomain.com'});
        mail.setSubject('Permission Set Assignment Batch Job Summary');
        mail.setPlainTextBody('The batch job has completed.\n\n' +
                               'Number of users processed: ' + (successCount + failureCount) + '\n' +
                               'Permission Sets successfully assigned: ' + successCount + '\n' +
                               'Permission Sets failed to assign: ' + failureCount);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        */
        
        // Alternatively, log the results
        System.debug('Batch Job Completed:');
        System.debug('Total Users Processed: ' + (successCount + failureCount));
        System.debug('Permission Sets Successfully Assigned: ' + successCount);
        System.debug('Permission Sets Failed to Assign: ' + failureCount);
    }
    
    /**
     * Custom Exception Class
     * 
     * Throws a custom exception if required parameters are missing or invalid.
     */
    public class SalesforceException extends Exception {}
}