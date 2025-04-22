@isTest
public class TransferingAmountOppControllerTest 
{
    static testMethod void m1()
    {
        Account acc = new Account();
        acc.name = 'Test';
        acc.Active__c = True;
        insert acc;
        
        Account newAccObj = new Account();
        newAccObj.name = 'new acc';

        Opportunity opp = new Opportunity();
        
        
        opportunity opp1 = new opportunity();
        opp1.AccountId = acc.Id;
        opp1.Amount = 500000;
        opp1.StageName = 'Receipt Issued';
        //opp1.CRC_Assigned__c = oppListToUpdate.get(0).CRC_Assigned__c;
        //opp1.CM_Assigned__c = oppListToUpdate.get(0).CM_Assigned__c;
        opp1.Name = 'New Transferred';
        opp1.CloseDate = System.today();
        //opp1.ownerId = oppListToUpdate.get(0).ownerId;
        opp1.Opportunity_Type__c = 'Transferor';
        //opp1.Old_Transferred_Opportunity__c = oppListToUpdate.get(0).Id;
        insert opp1;
        
        PricebookEntry PBE = new PricebookEntry();
        PBE.IsActive = true;
        PBE.UnitPrice = 1;
        PBE.UseStandardPrice = true;
        //PBE.Pricebook2Id = ;
        //PBE.Product2Id = ;
        //insert PBE;
        
        OpportunityLineItem OLI2 = new OpportunityLineItem();
        OLI2.OpportunityId = opp1.Id;
        OLI2.Quantity = 500000;
        OLI2.PricebookEntryId = PBE.Id;
        OLI2.Description = 'Test';
        OLI2.TotalPrice = 500;//OLIList.get(0).TotalPrice;
        //insert OLI2;

        Date dateOfApplication = System.today();
        dateOfApplication = dateOfApplication.addDays(10);
        
        TransferingAmountOppController.fetchLookUpValues('test');
        TransferingAmountOppController.createNewAccounts(opp1.Id, newAccObj, 'VC Business Account', 10000, dateOfApplication);
        TransferingAmountOppController.createOpps(opp1.Id, acc, 100000, dateOfApplication);
    }
}