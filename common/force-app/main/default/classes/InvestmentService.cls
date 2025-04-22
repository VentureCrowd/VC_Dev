/**
 * The InvestmentService class provides functionality to retrieve investment information for a specific account.
 * This class does not enforce sharing rules ("without sharing"), so it will run in system context.
 */
public inherited sharing class InvestmentService {

    /**
     * Retrieves a list of Investment__c records associated with a given account ID.
     * This method utilizes the InvestmentFactory to fetch data.
     * 
     * @param accountId The ID of the account for which investments are being retrieved.
     * @return A list of Investment__c records if investments exist, or null if none are found.
     * @throws AuraHandledException If an error occurs during the process.
     */
    public List<Investment__c> getInvestmentInfo(List<Id> accountId ,Integer limitSize, Integer offsetValue) {
        // Create an instance of InvestmentFactory to handle the retrieval of investment data
        InvestmentFactory factory = new InvestmentFactory();

        // Retrieve the list of Investment__c records associated with the provided accountId
        List<Investment__c> investmentRecord = factory.getInvestments(accountId, limitSize, offsetValue);

        // Return the list of retrieved investments
        return investmentRecord;
    }

    /**
     * Retrieves a list of Investment__c records' IDs associated with a given account ID.
     * This method calls the InvestmentFactory to retrieve the data.
     * 
     * @param accountId The ID of the account for which investment IDs are being retrieved.
     * @return A list of Investment__c records containing the IDs of investments.
     */
    public List<Investment__c> getInvestmentIds(Id accountId) {
        // Create an instance of InvestmentFactory to handle the retrieval of investment IDs
        InvestmentFactory factory = new InvestmentFactory();

        // Retrieve the list of Investment__c IDs associated with the provided accountId
        List<Investment__c> investmentRecord = factory.getInvestmentsIds(accountId);

        // Return the list of investment IDs
        return investmentRecord;
    }

    /**
     * Retrieves detailed information about a specific Investment__c record.
     * 
     * @param investmentId The ID of the specific investment for which details are being retrieved.
     * @return A list containing the details of the specified Investment__c record.
     */
    public List<Investment__c> getInvestmentDetails(Id investmentId) {
        // Create an instance of InvestmentFactory to handle the retrieval of investment details
        InvestmentFactory factory = new InvestmentFactory();
        
        // Retrieve the details of the Investment__c record associated with the given investmentId
        List<Investment__c> investmentRecord = factory.getInvestmentDetails(investmentId);
        
        if (investmentRecord.isEmpty()) {
            // If no investment details are found, throw an exception
            throw new DmlException('No investment details found for investment ID: ' + investmentId);
        }
        // Return the investment details
        return investmentRecord;
    }

    /**
     * Retrieves investment records for a given account ID that are in the 
     * 'Closed Won' stage and either 'Active' or have no defined investment stage.
     * 
     * @param accountId The ID of the account for which investments are retrieved.
     * @return A list of Investment__c records matching the criteria.
     */
    public List<Investment__c> getInvestmentSpotlightData (Id accountId) {
        // Create an instance of InvestmentFactory to handle the retrieval of investment data
        InvestmentFactory factory = new InvestmentFactory();

        // Retrieve the list of Investment__c records associated with the provided accountId
        List<Investment__c> investmentRecord = factory.getInvestmentSpotlightData(accountId);

        // Return the list of retrieved investments
        return investmentRecord;
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
        // Create an instance of InvestmentFactory to handle the retrieval of investment data
        InvestmentFactory factory = new InvestmentFactory();

        // Retrieve the list of Investment__c records associated with the provided accountId
        List<Investment__c> investmentRecord = factory.getPendingAndClosedInvestments(accountId);

        // Return the list of retrieved investments.
        return investmentRecord;
    }

    /**
     * Determines whether the CSF Product banner should be displayed for a given account.
     * The banner is displayed if there is at least one investment related to a CSF Product.
     * 
     * @param accountId The ID of the account for which the CSF banner check is performed.
     * @return Boolean value indicating whether the CSF banner should be shown.
     */
    public Boolean showCSFBanner (Id accountId) {
        // Create an instance of InvestmentFactory to handle the retrieval of investment data
        InvestmentFactory factory = new InvestmentFactory();

        // Retrieve the list of Investment__c records associated with the provided accountId
        Boolean investmentRecord = factory.showCSFBanner(accountId);

        // Return the list of retrieved investments.
        return investmentRecord;
    }
}