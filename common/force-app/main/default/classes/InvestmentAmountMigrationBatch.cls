/**
 * @description
 * Batch class to migrate Investment Amount values from the old picklist field to the new currency field on Lead records.
 * This class implements Database.Batchable and Database.Stateful interfaces to process records in batches and maintain state.
 * 
 * The batch job performs the following actions:
 * - Queries Lead records where Related_EOI__c and Investment_Amount__c (old picklist field) are not null.
 * - Maps the old picklist values to their corresponding minimum investment amounts using a predefined mapping.
 * - Updates the new Investment Amount currency field with the mapped values.
 * - Logs any errors encountered during processing and emails the error log to the administrator upon completion.
 *
 * @author
 * Kendrick Kam
 *
 * @date
 * 18/11/2024
 */
public class InvestmentAmountMigrationBatch implements Database.Batchable<SObject>, Database.Stateful {
   /**
     * @description
     * A list to store error logs encountered during the batch execution.
     * This list maintains state across batch executions due to the Database.Stateful interface.
     */
   public List<String> errorLogs = new List<String>();

   /**
     * @description
     * A list to store information about updated Lead records.
     * Each entry contains the Lead ID, old picklist value, and new currency value.
     */
    public List<String> updatedLeadsInfo = new List<String>();

    
   /**
     * @description
     * Mapping from old Investment Amount picklist values to their corresponding minimum investment amounts.
     * This map is used to translate picklist ranges into numeric currency values for the new field.
     */
   public static Map<String, Integer> amountRangeMap = new Map<String, Integer>{
       '$250 to $500'       => 250,
       '$500 to $1,000'     => 500,
       '$1,000 to $2,000'   => 1000,
       '$2,000 to $5,000'   => 2000,
       '$1,000 to $3,000'   => 1000,
       '$3,000 to $5,000'   => 3000,
       '$5,000 to $8,000'   => 5000,
       '$8,000 to $10,000'  => 8000,
       '$10,000 to $20,000' => 10000,
       '$20,000 to $50,000' => 20000,
       '$50,000 to $100,000' => 50000,
       '$100,000 to $200,000' => 100000,
       '$200,000+'          => 200000
   };
   
    /**
     * @description
     * The start method is called at the beginning of the batch job execution.
     * It defines the scope of the records to be processed by returning a QueryLocator.
     *
     * @param BC The batch context.
     * @return Database.QueryLocator A QueryLocator containing the Lead records to process.
     */
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // Query Lead records where Related_EOI__c and Investment_Amount__c (old picklist field) are not null
        return Database.getQueryLocator([
            SELECT Id, Investment_Amount__c, Related_EOI__c
            FROM Lead
            WHERE Related_EOI__c != null AND Investment_Amount__c != null
        ]);
    }

     /**
     * @description
     * The execute method is called for each batch of records processed.
     * It performs the migration logic for each Lead in the current scope.
     *
     * @param BC The batch context.
     * @param scope A list of Lead records to process in the current batch.
     */
    public void execute(Database.BatchableContext BC, List<Lead> scope) {
        // List to hold Lead records that need to be updated
        List<Lead> leadsToUpdate = new List<Lead>();

        // Iterate over each Lead in the current batch scope
        // Iterate over each Lead in the current batch scope
        for (Lead lead : scope) {
            try {
                // Retrieve the picklist value from the old Investment Amount field
                String oldPicklistValue = lead.Investment_Amount__c;

                // Check if the picklist value exists in the mapping
                if (amountRangeMap.containsKey(oldPicklistValue)) {
                    // Get the minimum investment amount corresponding to the picklist value
                    Integer minAmount = amountRangeMap.get(oldPicklistValue);

                    // Update the new Investment Amount currency field with the minimum amount
                    lead.Investment_Amount_Currency__c = Decimal.valueOf(minAmount);

                    // Add the Lead to the list of records to update
                    leadsToUpdate.add(lead);

                    // Collect information about the updated Lead
                    String leadInfo = 'Lead ID: ' + lead.Id + ', Old Value: ' + oldPicklistValue + ', New Value: ' + lead.Investment_Amount_Currency__c;
                    updatedLeadsInfo.add(leadInfo);
                } else {
                    // Log an error if the picklist value is not found in the mapping
                    errorLogs.add('Lead ID: ' + lead.Id + ', Unknown picklist value: ' + oldPicklistValue);
                }
            } catch (Exception e) {
                // Log any exceptions encountered during processing and continue with the next record
                errorLogs.add('Lead ID: ' + lead.Id + ', Error: ' + e.getMessage());
            }
        }

        // Check if there are any records to update
        if (!leadsToUpdate.isEmpty()) {
            try {
                // Perform the update operation on the list of Lead records
                update leadsToUpdate;
            } catch (DmlException de) {
                // Handle DML exceptions and log errors for individual records
                for (Integer i = 0; i < de.getNumDml(); i++) {
                    errorLogs.add('Lead ID: ' + leadsToUpdate[i].Id + ', DML Error: ' + de.getDmlMessage(i));
                }
            }
        }
    }



    /**
     * @description
     * The finish method is called after all batches have been processed.
     * It sends an email to the administrator with any errors that were logged during processing.
     *
     * @param BC The batch context.
     */
    public void finish(Database.BatchableContext BC) {
         // Build the email content
         String emailSubject = 'Investment Amount Migration Results';
         String emailBody = 'The Investment Amount migration batch job has completed.\n\n';
 
         // Add summary information
         Integer totalUpdated = updatedLeadsInfo.size();
         Integer totalErrors = errorLogs.size();
         emailBody += 'Total Leads Updated: ' + totalUpdated + '\n';
         emailBody += 'Total Errors: ' + totalErrors + '\n\n';
 
         // Include updated Leads information
         emailBody += 'List of Updated Leads (ID, Old Value, New Value):\n';
 
         // Limit the number of records included in the email to avoid exceeding email size limits
         Integer maxRecordsInEmail = 500; // Adjust this number as needed to stay within limits
         Integer recordsToInclude = Math.min(maxRecordsInEmail, updatedLeadsInfo.size());
 
         for (Integer i = 0; i < recordsToInclude; i++) {
             emailBody += updatedLeadsInfo[i] + '\n';
         }
 
         if (updatedLeadsInfo.size() > maxRecordsInEmail) {
             emailBody += '...\nNote: Only the first ' + maxRecordsInEmail + ' updated Leads are displayed.\n';
         }
 
         emailBody += '\n';
 
         // Include error logs if any
         if (!errorLogs.isEmpty()) {
             emailBody += 'Errors Encountered:\n';
             for (String error : errorLogs) {
                 emailBody += error + '\n';
             }
         }
 
         // Send the email to the administrator
         Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
         mail.setToAddresses(new String[] { 'kendrick.kam@venturecrowd.com.au' }); // TODO: Replace with the actual admin email
         mail.setSubject(emailSubject);
         mail.setPlainTextBody(emailBody);
         Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
     }
}