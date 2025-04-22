public inherited sharing class InvestmentFactory implements IInvestmentFactory  {
    /**
     * Retrieves a list of Investment__c records for a given accountId.
     * The records contain information such as Stage, Opportunity, Amount, and Product Name.
     * 
     * @param accountId The Id of the account for which investments are being retrieved.
     * @return A List of Investment__c records, or null if no investments are found.
     */
    public List<Investment__c> getInvestments (List<Id> accountId, Integer limitSize, Integer offsetValue) {
            // Fetch Investments
            if (accountId.isEmpty()) {
                return new List<Investment__c>();
            }
            List<Investment__c> investment = [SELECT Id, Account__c, Related_Product__c, Stage__c, Opportunity__c, Investment_Amount__c, Amount__c, Investment_Product_Name__c, Investment_Status__c, Investment_Stages__c, Current_Holding_Value__c, Closed_Date__c,Investment_Date__c
                FROM Investment__c WHERE Account__c =:accountId AND (Stage__c = 'Closed Won') AND (Investment_Stages__c = 'Active' OR Investment_Stages__c = null OR Investment_Stages__c = 'Closing') ORDER BY Investment_Date__c DESC LIMIT :limitSize OFFSET :offsetValue];
            Logger.logMessage('InvestmentApp', 'InvestmentFactory', 'getInvestments', 'Successfully retrieved full investment record for accountId: ' + accountId);
            return investment;
    }

    /**
     * Retrieves a list of Investment Ids records for a given accountId.
     * 
         * @param accountId The Id of the account for which investments are being retrieved.
         * @return A List of Investment__c Ids
     */
    public List<Investment__c> getInvestmentsIds (Id accountId) {
        // Fetch Investments
        List<Investment__c> investment = [SELECT Id FROM Investment__c WHERE Account__c =:accountId];
        Logger.logMessage('InvestmentApp', 'InvestmentFactory', 'getInvestments', 'Successfully retrieved full investment record for accountId: ' + accountId);
        return investment;
    }

    /**
     * Retrieves a list of Investment__c records for a given investment Id.
     * 
     * @param investmentId The Id of the account for which investments are being retrieved.
     * @return A List of Investment__c records, or null if no investments are found.
     */
    public List<Investment__c> getInvestmentDetails (Id investmentId) {
        // Fetch Investments
        List<Investment__c> investment = [SELECT Amount__c, Investment_Amount__c, Investment_Opp_ID__c, Current_Holding_Value__c, Investment_Date__c, Term_Expiry__c, Securities_Held__c, Related_Product__c, Funds_Received_in_Bank__c, Reason_Refund__c, Refund_Requested__c, Date_Refund_Requested__c  FROM Investment__c WHERE Id =:investmentId];
        Logger.logMessage('InvestmentApp', 'InvestmentFactory', 'getInvestments', 'Successfully retrieved full investment record for investmentId: ' + investmentId);
        return investment;
    }

    /**
     * Retrieves investment records for a given account ID that are in the 
     * 'Closed Won' stage and either 'Active' or have no defined investment stage.
     * 
     * @param accountId The ID of the account for which investments are retrieved.
     * @return A list of Investment__c records matching the criteria.
     */
    public List<Investment__c> getInvestmentSpotlightData (Id accountId) {
        // Fetch Investments
        List<Investment__c> investment = [SELECT Amount__c, Investment_Amount__c, Investment_Status__c, Current_Holding_Value__c FROM Investment__c
        WHERE Account__c =:accountId AND Stage__c = 'Closed Won' AND (Investment_Stages__c = 'Active' OR Investment_Stages__c = null OR Investment_Stages__c = 'Closing')];
        Logger.logMessage('InvestmentApp', 'InvestmentFactory', 'getInvestmentSpotlightData', 'Successfully retrieved full investment record for accountId: ' + accountId);
        return investment;
    }

    /**
     * Retrieves pending and closed investment records for a given list of account IDs.
     * This method filters investments that are linked to an opportunity and have a positive amount.
     * 
     * @param accountId A list of account IDs for which investments are retrieved.
     * @return A list of Investment__c records that are either in 'Closed Won' (with stage 'Closed') 
     *         or in 'Application Received' stage.
     */
    public List<Investment__c> getPendingAndClosedInvestments (List<Id> accountId) {
        // Fetch Investments
        if (accountId.isEmpty()) {
            return new List<Investment__c>();
        }
        List<Investment__c> investment = [
            SELECT Id, Related_Product__c, Investment_Product_Name__c, Account__c, Amount__c, Investment_Amount__c, Investment_Stages__c, Stage__c 
            FROM Investment__c 
            WHERE Account__c = :accountId 
            AND Opportunity__c != null 
            AND Amount__c > 0 
            AND ( 
                (Stage__c = 'Closed Won' AND Investment_Stages__c = 'Closed') 
                OR Stage__c IN ('Application Received', 'Receipt Issued')
            )
        ];
        Logger.logMessage('InvestmentApp', 'InvestmentFactory', 'getInvestmentSpotlightData', 'Successfully retrieved full investment record for accountId: ' + accountId);
        return investment;
        }

    /**
     * Determines whether the CSF Product banner should be displayed for a given account.
     * The banner is displayed if there is at least one investment related to a CSF Product.
     * 
     * @param accountId The ID of the account for which the CSF banner check is performed.
     * @return Boolean value indicating whether the CSF banner should be shown.
     */
    public Boolean showCSFBanner (Id accountId) {
        Integer investments = [SELECT Count() FROM Investment__c WHERE Related_product__r.Type__c = 'CSF Product' AND Stage__c = 'Closed Won' AND Account__c =: accountId];
        return investments > 0;
    }   
}