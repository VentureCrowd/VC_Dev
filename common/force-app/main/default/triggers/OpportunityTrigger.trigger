/**

**/
trigger OpportunityTrigger on Opportunity (before insert, after insert, after update, before update) 
{   
    List<Opportunity> newOpportunities = Trigger.new;
    Map<Id,Opportunity> oppOldMap  = Trigger.oldMap;
    Map<Id,Opportunity> oppNewMap = Trigger.newMap;
    switch on Trigger.OperationType {
        when BEFORE_INSERT, BEFORE_UPDATE, AFTER_INSERT, AFTER_UPDATE {
            // Create a single instance of OpportunityProcessor for the transaction
            if(Trigger.operationType.name() == 'BEFORE_UPDATE'){
                OpportunityTriggerHandler.updateContact();
            }else if(Trigger.operationType.name() == 'BEFORE_INSERT'){
                OpportunityTriggerHandler.updateContact();
            }else{
                OpportunityProcessor processor = new OpportunityProcessor(newOpportunities, oppOldMap, oppNewMap, Trigger.operationType.name());

                 // Enqueue only one job per transaction
                if (!System.isFuture() && !System.isQueueable()) {
                    System.enqueueJob(processor);
                }
            }

           
        }
    }

    OpportunityTriggerHandler.commonLogic();
    // switch on Trigger.OperationType {
    //     when AFTER_INSERT {
            
    //             ConvertLeadHandler.convertLead(Trigger.new);

    //             System.enqueueJob(new OpportunityProcessor(newOpportunities,oppOldMap,oppNewMap,'AFTER_INSERT'));
    //             //OpportunityTriggerHandler.sendEmails();
                
    //             //OpportunityTriggerHandler.enqueueForProcessing(null, Trigger.newMap, true);
            
    //         //OpportunityTriggerHandler.processInvestmentRecord(Trigger.oldMap, Trigger.newMap, true);
    //         // OpportunityTriggerHandler.verifyAccountABN(Trigger.new,null);
    //         // OpportunityTriggerHandler.createCMIncentive(Trigger.new,null);
    //     }
    //     when AFTER_UPDATE {
    //         OpportunityTriggerHandler.deleteOpportunity(Trigger.new);
    //         OpportunityTriggerHandler.updateProductStatusOnOpportunityClosure(Trigger.newMap,Trigger.oldMap);
    //         // OpportunityTriggerHandler.oppfilesshare();
    //         // OpportunityTriggerHandler.oliCurrentValuesIpdate();
    //         // OpportunityTriggerHandler.updateChildOLIstatus();

    //         System.enqueueJob(new OpportunityProcessor(newOpportunities,oppOldMap,oppNewMap,'AFTER_UPDATE'));
    //         // OpportunityTriggerHandler.sendEmails();
            
    //         //OpportunityTriggerHandler.enqueueForProcessing(Trigger.oldMap, Trigger.newMap, false);

        
    //         //OpportunityTriggerHandler.processInvestmentRecord(Trigger.oldMap, Trigger.newMap, false);
    //         // OpportunityTriggerHandler.verifyAccountABN(Trigger.new,Trigger.oldMap);
    //         // OpportunityTriggerHandler.createCMIncentive(Trigger.new,Trigger.oldMap);
    //     }
    //     when BEFORE_UPDATE {
    //         // OpportunityTriggerHandler.updateContact();
          
    //         System.enqueueJob(new OpportunityProcessor(newOpportunities,oppOldMap,oppNewMap,'BEFORE_UPDATE'));
    //     }
    //     when BEFORE_INSERT {
    //         // OpportunityTriggerHandler.updateContact();
    //         System.enqueueJob(new OpportunityProcessor(newOpportunities,oppOldMap,oppNewMap,'BEFORE_INSERT'));
    //     }
    // }
    // OpportunityTriggerHandler.commonLogic();
}