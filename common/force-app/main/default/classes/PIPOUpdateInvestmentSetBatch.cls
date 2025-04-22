/**
 * AUTHOR: Cesar Vaca 17/01/2025
 * Batch Apex Class to Assign a ProductId to Investments based on Opportunity productId
 * 
 * 
 * Usage:
 * 1. Deploy this class to your Salesforce org.
 * 2. Execute the batch via the Developer Console or anonymously, passing in the required parameters.
 * 3. Monitor the batch job to ensure successful completion
    // Instantiate the batch class
    PIPOUpdateInvestmentSetBatch batch = new PIPOUpdateInvestmentSetBatch();

    // Execute the batch with a batch size of 200
    Database.executeBatch(batch, 200);.
 */

global class PIPOUpdateInvestmentSetBatch implements Database.Batchable<SObject>, Database.Stateful {

    // Track success and failure counts
    global Integer successCount = 0;
    global Integer failureCount = 0;

    /**
     * Start Method: Queries all Investment__c records that have a related Opportunity.
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id, Related_Product__c, Opportunity__c
            FROM Investment__c
            WHERE Opportunity__c != NULL AND Related_Product__c = NULL
        ]);
    }

    /**
     * Execute Method: Processes each batch of Investment__c records.
     */
    global void execute(Database.BatchableContext BC, List<Investment__c> scope) {
        // Collect Opportunity IDs
        Set<Id> opportunityIds = new Set<Id>();
        for (Investment__c inv : scope) {
            opportunityIds.add(inv.Opportunity__c);
        }

        // Query Opportunities to get Invested_Product_ADMIN_FIELD__c values
        Map<Id, String> opportunityProductMap = new Map<Id, String>();
        for (Opportunity opp : [
            SELECT Id, Invested_Product_ADMIN_FIELD__c 
            FROM Opportunity 
            WHERE Id IN :opportunityIds
        ]) {
            opportunityProductMap.put(opp.Id, opp.Invested_Product_ADMIN_FIELD__c);
        }

        // Update Investment__c records
        List<Investment__c> investmentsToUpdate = new List<Investment__c>();
        for (Investment__c inv : scope) {
            if (opportunityProductMap.containsKey(inv.Opportunity__c)) {
                inv.Related_Product__c = opportunityProductMap.get(inv.Opportunity__c);
                investmentsToUpdate.add(inv);
            }
        }

        // Perform bulk update
        if (!investmentsToUpdate.isEmpty()) {
            try {
                update investmentsToUpdate;
                successCount += investmentsToUpdate.size();
            } catch (DmlException e) {
                System.debug('Error updating Investments: ' + e.getMessage());
                failureCount += investmentsToUpdate.size();
            }
        }
    }

    /**
     * Finish Method: Logs results after processing all batches.
     */
    global void finish(Database.BatchableContext BC) {

        // Send email with batch job summary to admin user
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {'duvan.vaca@venturecrowd.com.au'});
        mail.setSubject('Investment Update - Product Id - Assignment Batch Job Summary');
        mail.setPlainTextBody('The batch job has completed.\n\n' +
                               'Number of users processed: ' + (successCount + failureCount) + '\n' +
                               'Permission Sets successfully assigned: ' + successCount + '\n' +
                               'Permission Sets failed to assign: ' + failureCount);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });


        System.debug('Batch Job Completed:');
        System.debug('Total Investments Processed: ' + (successCount + failureCount));
        System.debug('Successfully Updated: ' + successCount);
        System.debug('Failed to Update: ' + failureCount);
    }
}