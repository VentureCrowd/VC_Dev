public class ProcessInvestmentRecordQueueable implements Queueable, Database.AllowsCallouts {
    private Map<Id, Opportunity> oldOppMap;
    private Map<Id, Opportunity> newOppMap;
    private Boolean isInsert;

    public ProcessInvestmentRecordQueueable(Map<Id, Opportunity> oldOppMap, Map<Id, Opportunity> newOppMap, Boolean isInsert) {
        this.oldOppMap = oldOppMap;
        this.newOppMap = newOppMap;
        this.isInsert = isInsert;
    }

    public void execute(QueueableContext context) {
        // Removed as this was transferred to a flow
        //OpportunityTriggerHandler.processInvestmentRecord(oldOppMap, newOppMap, isInsert);
    }
}