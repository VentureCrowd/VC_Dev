/**
 * @description
 * This class belongs to the service where we take all the factory DML operations and this class is used to the controller 
 * 
 * The following actions are available for this
 *
 * @author
 * Cesar Vaca
 *
 * @date
 * 19/11/2024
 */

public inherited sharing class PipoService {
    /**
     * Retrieves portfolio account information for a given userId.
     *
     * @param userId The Id of the user for whom the account information is being retrieved.
     * @return A Map containing account information such as Name and IdVerified.
     */
    public Map<String, Object> portfolioAccountInformation(Id userId) {
        // Initialize AccountService to access account-related methods
        AccountService accService = new AccountService();
        InvestmentService investmentService = new InvestmentService();

        // Get the AccountId associated with the provided userId
        Id accountId = accService.getAccountId(userId);

        // Get the account information as a Map using the accountId
        Map<String, Object> accountRecord = accService.getAccountInformation(accountId);

        // Initialize an empty map to store the return values
        Map<String, Object> returnMap = new Map<String, Object>();

        // Show CSF Banner based on Product Type

        Boolean showCSFBanner = investmentService.showCSFBanner(accountId);

        // Check if the accountRecord contains data (i.e., is not empty)
        if (accountRecord.isEmpty()) {
            throw new DmlException('No Account Found');
        }

        // If PreferredName exists in accountRecord, use it for the 'Name' field
        if (accountRecord.get('PreferredName') != null) {
            returnMap.put('Name', accountRecord.get('PreferredName'));
        } else {
            // Otherwise, use the regular 'Name' field
            returnMap.put('Name', accountRecord.get('Name'));
        }

        // Add the IdVerified flag and email to the return map
        returnMap.put('IdVerified', accountRecord.get('IdVerified'));
        returnMap.put('Email', accountRecord.get('Email'));
        returnMap.put('ShowCSFBanner', showCSFBanner);
        
        // This logic handles how the banner is displayed to different users and if they interact with the banner
        /*
        
            Week 1–4: Banner prominently displayed to all users on login.

            Week 4–12: Banner displayed only to users who haven’t engaged with it.

            After Week 12: Retire the banner.
        
        */

        Date startDate = Date.today();
        Date firstReleaseDate = Date.newInstance(2025, 2, 19);
        Date secondReleaseDate = Date.newInstance(2026, 4, 16);
        Integer firstRelease = startDate.daysBetween(firstReleaseDate);
        Integer secondRelease = startDate.daysBetween(secondReleaseDate);
        if (firstRelease >= 0) {
            returnMap.put('ShowBanner', true);
        } else if ((secondRelease >= 0) && (accountRecord.get('InvestorBannerInteraction') == false)) {
            returnMap.put('ShowBanner', true);
        } else {
            returnMap.put('ShowBanner', false);
        }

        // Log a message indicating successful retrieval of account information
        Logger.logMessage('PipoApp', 'PipoService', 'portfolioAccountInformation', 'Successfully retrieved Account Information details for userId: ' + userId);

        // Return the populated returnMap
        return returnMap;
    }

    public Map<String,Decimal> getSpotlightData(Id userId) {
        // Initialize services
        EntitiesService entitiesService = new EntitiesService();
        AccountService accountService = new AccountService();
        InvestmentService investmentService = new InvestmentService();
        
        // Get the Person AccountId associated with the provided userId
        Id accountId = accountService.getAccountId(userId);
    
        Map<String, Decimal> returnMap = new Map<String, Decimal>();
    
        Integer activeInvestments = 0;
        Integer personalInvestments = 0;
        Decimal holdingValue = 0;
        Decimal portfolioValue = 0;
    
    
        // Create a new list to store all the total investments
        List<Investment__c> totalInvestments = new List<Investment__c>();
    
        // Get all the person account investments
        List<Investment__c> personAccountInvestments = investmentService.getInvestmentSpotlightData(accountId);
        personalInvestments = personAccountInvestments.size();
        totalInvestments.addAll(personAccountInvestments);
    
        // Get the contact ID related to the provided userId
        Id contactId = entitiesService.getLoggedInUser();
    
    
        // Get all the entities related to the contact
        List<Map<String,Object>> entityRecordList = entitiesService.getRelatedBusinessAccounts(contactId);
        // Check if any entities were returned
        if (!entityRecordList.isEmpty()) {
            // Loop through each entity and get related investments
            for (Map<String,Object> entityRecord : entityRecordList) {
                // Extract entityId and entityName from entityRecord
                Id entityId = (Id)entityRecord.get('id');                
                try {
                    // Get investments for each entity
                    List<Investment__c> investmentRecordList = investmentService.getInvestmentSpotlightData(entityId);
    
                    //Store all the investmentRecordsList in the list
                    totalInvestments.addAll(investmentRecordList);
                } catch (Exception e) {
                    System.debug('No investments found' + e + 'for entityId' + entityId);
                }
            }
        }
    
        // Iterate through all the totalInvestments to get the data
        for (Investment__c investment : totalInvestments) {
            activeInvestments++;
            // Convert the current holding value
            String cleanValue = investment.Current_Holding_Value__c.replace('$', '').replace(',', '');
            holdingValue += Decimal.valueOf(cleanValue);
            if (investment.Investment_Amount__c == null) {
                portfolioValue += investment.Amount__c;
            } else {
                portfolioValue += investment.Investment_Amount__c;
            }      
        }
        
        // Return all the portfolio values
        returnMap.put('TotalInvestments', activeInvestments);
        returnMap.put('HoldingValue',holdingValue);
        returnMap.put('TotalInvested',portfolioValue);
        returnMap.put('ActivePersonalInvestments', personalInvestments);
        returnMap.put('ActiveEntitiesInvestments', activeInvestments - personalInvestments);

        // Log a message indicating successful retrieval of spotlight data

        return returnMap;
    } 
    
    /**
     * Retrieves investment information for a given userId.
     * This method can be use to get the investment of a person account because is 1 to 1 relationship
     *
     * @param userId The Id of the user for whom the investment information is being retrieved.
     * @return A List of Maps containing investment information such as Stage, Amount, ProductName, and ProductLogo.
     */

    public List<Map<String,Object>> getAccountInvestments(Id userId, Integer limitSize, Integer offsetValue){
        // setup return structure
        List<Map<String,Object>> returnMap = new List<Map<String,Object>>();
        AccountService accountService = new AccountService();

        // Get the accountid from UserId
        Id accountId = accountService.getAccountId(userId);

        // Create a list with the id
        List<Id> accountIdList = new List<Id>();
        accountIdList.add(accountId);

        Logger.logMessage('PipoApp', 'AccountService', 'getAccountInformation', 'Successfully retrieved account details for accountId: ' + userId);
        return getInvestmentsAccount(accountIdList, limitSize, offsetValue); 
        
    }
    /**
    * Retrieves a list of investments associated with entities linked to a given userId.
    *
    * @param userId The Id of the user whose related entities' investments are being retrieved.
    * @return A list of maps containing investment information along with the associated entity's name and Id.
     */

    public List<Map<String,Object>> getEntitiesInvestments(Integer limitSize, Integer offsetValue) {
            // Initialize the return map
            List<Map<String,Object>> returnMap = new List<Map<String,Object>>();
            
            // Invoke the services
            EntitiesService entitiesService = new EntitiesService();

            // Get the contact ID related to the provided userId
            Id contactId = entitiesService.getLoggedInUser();
            
            
            // Get all the entities related to the contact
            // List<Map<String,Object>> entityRecordList = entitiesService.getRelatedBusinessAccounts(contactId);
            
            Map<Id,String> entitiesIds = getEntitiesIds();
            
            try {
                // Get investments for each entity
                List<Map<String, Object>> investmentRecordList = getInvestmentsAccount(new List<Id>(entitiesIds.keySet()), limitSize, offsetValue);
            
                // If there are investments, get the Entity name, id, and investments
                if (!investmentRecordList.isEmpty()) {
                    for (Map<String, Object> investmentRecord : investmentRecordList) {
                        // Extract the EntityId from the investment record
                        Id entityId = (Id) investmentRecord.get('AccountId'); // Ensure this matches the field name in investmentRecord
            
                        // Retrieve the entityName from the entitiesIds map using the entityId
                        String entityName = entitiesIds.get(entityId);
            
                        // Add the entityName to the investment record
                        investmentRecord.put('AccountName', entityName);
            
                        // Add the updated investment record to the returnMap
                        returnMap.add(investmentRecord);
                    }
                }
            } catch (Exception e) {
                System.debug('No investments found: ' + e + ' for entityIds: ' + entitiesIds);
            }
            
            // Log a success message indicating the account information retrieval was successful
            Logger.logMessage('PipoApp', 'PipoService', 'getEntitiesInvestments', 'Successfully retrieved entities investments for userId: ');

            return returnMap;
    }

    /**
     * Retrieves investment data for a given accountId.
     *
     * @param accountId The Id of the account for which investment information is being retrieved.
     * @return A list of maps containing investment details such as Stage, Amount, ProductName, and ProductLogo.
     */
    private List<Map<String, Object>> getInvestmentsAccount(List<Id> accountId, Integer limitSize, Integer offsetValue) {
        // Initialize services
        InvestmentService investmentService = new InvestmentService();
        Product_V2_Service productService = new Product_V2_Service();
        TransactionsService transactionsService = new TransactionsService();

        // Initialize return list
        List<Map<String, Object>> returnMap = new List<Map<String, Object>>();
        
        // Initialize return list
        List<Investment__c> investmentRecord = investmentService.getInvestmentInfo(accountId, limitSize, offsetValue);
        
        // If there are investments, process them
        if (!investmentRecord.isEmpty()) {
            for (Investment__c investment : investmentRecord) {
                // Create a new map for each investment
                Map<String, Object> investmentDataMap = new Map<String, Object>();
                String latestTransaction;
                List<Transaction__c> transactionRecords = transactionsService.getInterestTransactions(investment.Id);

                if (transactionRecords.size() != 0) {
                    latestTransaction = transactionRecords[0].XI_Line_Items_Description__c;    
                }
                
                // Get all the investment Data
                investmentDataMap.put('investmentId', investment.Id);
                investmentDataMap.put('Stage', investment.Stage__c);
                investmentDataMap.put('AccountId', investment.Account__c);

                // If the Inv_Amount is empty grab the amount instead
                if (investment.Investment_Amount__c == null) {
                    investmentDataMap.put('Amount', investment.Amount__c);
                } else {
                    investmentDataMap.put('Amount', investment.Investment_Amount__c);
                }
                investmentDataMap.put('OpportunityId', investment.Opportunity__c);
                investmentDataMap.put('BadgeStyle', latestTransaction);

                // If something fails try the catch block
                try {
                    investmentDataMap.put('HoldingValue', investment.Current_Holding_Value__c.replace('$', ''));
                    investmentDataMap.put('InvestmentStage', investment.Investment_Stages__c);
                    investmentDataMap.put('ClosedDate', investment.Closed_Date__c);
                    investmentDataMap.put('InvestmentDate', investment.Investment_Date__c);
                } catch (Exception e) {
                    System.debug('No Records Related for this investment' + e);
                }


                if (investment.Investment_Stages__c == null) {
                    investmentDataMap.put('InvestmentStage', 'Active');
                } else {
                    investmentDataMap.put('InvestmentStage', investment.Investment_Stages__c);
                }
                
                // Get the related records from the product
                try {
                    if (investment.Related_Product__c != null) {
                        Product2 productRecord = productService.getProductInformation(investment.Related_Product__c);
                        if (productRecord!= null) {
                            investmentDataMap.put('ProductName', productRecord.Portal_Display_Name__c);
                            investmentDataMap.put('ProductLogo', productRecord.DisplayUrl);
                            investmentDataMap.put('DistributionType', productRecord.Distribution_Type__c);
                            investmentDataMap.put('ProductView', productRecord.yielding__c);
                        }
                    }
                } catch (Exception e) {
                    System.debug('No Records Related for this investment' + e);
                }
                    // Return everything in a list of object
                returnMap.add(investmentDataMap);
            }
        }
        return returnMap;
    }

    //TODO Keep this and update documentation

    // Get all the entitiesId and names
    private Map<Id,String> getEntitiesIds() {
        
        // Initialize the return set
        Map<Id,String> returnMap = new Map<Id,String>();
        
        // Invoke the services
        EntitiesService entitiesService = new EntitiesService();

        // Get the contact ID related to the provided userId
        Id contactId = entitiesService.getLoggedInUser();

        // Get all the entities related to the contact
        List<Map<String,Object>> entityRecordList = entitiesService.getRelatedBusinessAccounts(contactId);

        // Check if any entities were returned
        if (!entityRecordList.isEmpty()) {
            // Loop through each entity and get related investments
            for (Map<String, Object> entityRecord : entityRecordList) {
                // Extract entityId and entityName from entityRecord
                Id entityId = (Id)entityRecord.get('id');
                String entityName = (String)entityRecord.get('name');
                
                // Add to the map: Key = entityId, Value = entityName
                if (entityId != null && entityName != null) {
                    returnMap.put(entityId, entityName);
                }
            }
        }
        // Log a success message indicating the account information retrieval was successful
        Logger.logMessage('PipoApp', 'PipoService', 'getEntitiesIds', 'Successfully retrieved entities investments for userId: ');
        return returnMap;
    }

    // Get all the pending and other ones
    public List<Map<String, Object>> getPendingAndInactiveInvestments(Id userId) {
        // Retrieve entity IDs and names
        Map<Id, String> totalIds = getEntitiesIds();
        // Initialize the return list
        List<Map<String, Object>> returnList = new List<Map<String, Object>>();
    
        // Initialize services
        InvestmentService investmentService = new InvestmentService();
        AccountService accountService = new AccountService();
        Product_V2_Service productService = new Product_V2_Service();

        // Add the logged-in user's accountId to the totalIds map
        Id accountId = accountService.getAccountId(userId);
        
        // Get all the person account investments
        Map<String, Object> personalAccount = portfolioAccountInformation(userId);

        // Get the name of the person account
        String name = (String) personalAccount.get('Name');
        
        if (accountId != null) {
            totalIds.put(accountId, name);
        }
    
        // Bulk call to fetch all investments for all accounts | Avoid the nested loops
        List<Investment__c> allInvestments = investmentService.getPendingAndClosedInvestments(
            new List<Id>(totalIds.keySet())
        );

        // Flatten the results using a single loop
        for (Investment__c investment : allInvestments) {
            Map<String, Object> investmentMap = new Map<String, Object>();
            
            investmentMap.put('investmentId', investment.Id);

            // Add the account name by looking it up in the totalIds map
            String accountName = totalIds.get(investment.Account__c);
            investmentMap.put('AccountName', accountName);

            // Return the amount if the investment amount is empty
            if (investment.Investment_Amount__c == null) {
                investmentMap.put('Amount', investment.Amount__c);
            } else {
                investmentMap.put('Amount', investment.Investment_Amount__c);
            }
            investmentMap.put('InvestmentStage', investment.Investment_Stages__c);
            investmentMap.put('Stage', investment.Stage__c);

            // Get the productId related fields
            try {
                if (investment.Related_Product__c != null) {
                    Product2 productRecord = productService.getProductInformation(investment.Related_Product__c);
                    if (productRecord!= null) {
                        investmentMap.put('ProductName', productRecord.Portal_Display_Name__c);
                        investmentMap.put('ProductLogo', productRecord.DisplayUrl);
                        investmentMap.put('DistributionType', productRecord.Distribution_Type__c);
                        investmentMap.put('ProductView', productRecord.yielding__c);
                    }
                }
            } catch (Exception e) {
                System.debug('No Records Related for this investment' + e);
            }
            
            // Return everything in a list of object
            returnList.add(investmentMap);
        }
    
        return returnList;
    }

    /**
     * Retrieves a list of Account IDs associated with a given UserId.
     * 
     * @param userId The Id of the user whose related Account IDs are being retrieved.
     * @return A List of Account Ids, including both the user's primary account and any related business accounts.
     * 
     * This method first retrieves the AccountId associated with the user and the contactId of the logged-in user.
     * It then fetches related business accounts via the EntitiesService and compiles all relevant account Ids 
     * into a list. If no related entities are found, only the primary accountId is returned.
     */
    private List<Id> getAccountIds(Id userId) {
        // Invoke the services
        AccountService accService = new AccountService();
        EntitiesService entitiesService = new EntitiesService();

        // Get the AccountId associated with the provided userId
        
        // Get the contact ID related to the provided userId
        Id accountId = accService.getAccountId(userId);
        Id contactId = entitiesService.getLoggedInUser();
        // Get all the entities related to the contact
        List<Map<String,Object>> entityRecordList = entitiesService.getRelatedBusinessAccounts(contactId);

        // This List contains Entity and Person account business account Id
        List<Id> idList = new List<Id>();
        idList.add(accountId);

        if(!entityRecordList.isEmpty()) {
            // Add person account to the list
            // Iterate over each entity and add the Id
            for (Map<String, Object> entities : entityRecordList) {
                // Check if the map contains the "Id" key and the value is not null
                if (entities.containsKey('id') && entities.get('id') != null) {
                    idList.add((Id)entities.get('id'));
                }
            }
        }
        return idList;
    }

    /**
     * Retrieves a list of tax document URLs associated with a given userId.
     * The documents are filtered based on the file name containing "FY" (financial year).
     * The method fetches investments related to the user's accounts and retrieves the document URLs for each investment.
     * 
     * @param userId The Id of the user whose tax documents are being retrieved.
     * @return A list of maps, where each map represents a document with key-value pairs containing document details.
     */
    public List<Map<String, Object>> getTaxDocuments(Id userId, String fileName, Boolean base64) {

        List <Id> accountsIdList = getAccountIds(userId);
        // Create a list to store filtered document URLs (only those with "FY" in the fileName)
        List<Map<String, Object>> filteredDocumentUrls = new List<Map<String, Object>>();
        
        // Invoke the services
        InvestmentService investmentService = new InvestmentService();
        
        for(Id accountsId : accountsIdList) {
            // Loop over each investment and get the document URLs
            List<Investment__c> investmentRecord = investmentService.getInvestmentIds(accountsId);
            for (Investment__c investment : investmentRecord) {
                // Get the list of document maps for each investment
                // List<Map<String, Object>> documentUrls = FileUploadController.getFilesByFileName(investment.Id, 'FY_', false);
                List<Map<String, Object>> documentUrls = FileUploadController.getFilesByFileName(investment.Id, fileName, base64);
                // Null check to prevent NullPointerException if the method returns null
                if (!documentUrls.isEmpty()) {
                    // Iterate over each document map
                    for (Map<String, Object> document : documentUrls) {
                            // Add the document to the filtered list
                            filteredDocumentUrls.add(document);
                        }
                    }
                }
        }
        return filteredDocumentUrls;
    }

    /**
     * Retrieves detailed investment information for a given investment ID.
     *
     * @param investmentId The ID of the investment for which details are being retrieved.
     * @return A Map containing key investment details such as amount, term, product information, and more.
     * @throws DmlException if no investment is found for the given ID.
     */
    public Map<String, Object> getInvestmentDetails (Id investmentId) {
        Map<String, Object> returnList = new Map<String, Object>();
        Id productId;
        // Invoke all the service methods
        InvestmentService investmentService = new InvestmentService();
        Product_V2_Service productService  = new Product_V2_Service();
        // Get the investment details
        List<Investment__c> investmentRecord = investmentService.getInvestmentDetails(investmentId);
        
        // Get the products details
        if (!investmentRecord.isEmpty()) {
            Investment__c investment = investmentRecord[0];
            productId = investment.Related_Product__c;
            // If the Inv_Amount is empty grab the amount instead
            if (investment.Investment_Amount__c == null) {
                returnList.put('InvestmentAmt', investment.Amount__c);
            } else {
                returnList.put('InvestmentAmt', investment.Investment_Amount__c);
            }
            returnList.put('InvestmentDate', investment.Investment_Date__c);
            returnList.put('InvestmentID', investment.Investment_Opp_ID__c);
            returnList.put('Term', investment.Term_Expiry__c);
            returnList.put('SecuritiesHeld', investment.Securities_Held__c);
            returnList.put('HoldingValue', investment.Current_Holding_Value__c);
            returnList.put('FundsReceived', investment.Funds_Received_in_Bank__c);
            returnList.put('RefundRequested', investment.Refund_Requested__c); 

        } else {
            throw new DmlException('No Investment Found');
        }

        // Get the product details
        if (productId != null) {
            Product2 productRecord = productService.getProductInformation(productId);
            returnList.put('Series', productRecord.Stage__c);
            returnList.put('Sector', productRecord.Sector__c);
            returnList.put('Name', productRecord.Name);
            returnList.put('ProductView', productRecord.yielding__c);
            returnList.put('DistributionType', productRecord.Distribution_Type__c);
            returnList.put('ProductImage', productRecord.DisplayUrl);
            returnList.put('Family', productRecord.Family);
        }
        // Fetch pricebook details for the product
        PricebookEntry pricebookRecord = productService.getProductPriceBook(productId);
        if (pricebookRecord != null) {
            returnList.put('UnitPrice', pricebookRecord.UnitPrice);
        }
        return returnList;
    }

    /**
     * Submits a refund request for a specific investment.
     *
     * @param investmentId The ID of the investment for which the refund is requested.
     * @param reasonRefund The reason provided for the refund request.
     */
    public void requestRefund(Id investmentId, String reasonRefund) {
        InvestmentService investmentService = new InvestmentService();
        List<Investment__c> investmentRecord = InvestmentService.getInvestmentDetails(investmentId);
        
        if (!investmentRecord.isEmpty()) {
            investmentRecord[0].Refund_Requested__c = true;
            investmentRecord[0].Reason_Refund__c = reasonRefund;
            investmentRecord[0].Date_Refund_Requested__c = Date.today();
            update investmentRecord;
        }
    }

    //! This field piece of code needs to be delete it in may 2025
    /**
     * Updates the banner checkbox too see if the investor interacts with the banner
     *
     */
    public void tourTaken(Id userId) {
        AccountFactory accountFactory = new AccountFactory();

        // Get the AccountId associated with the provided userId
        Id accountId = accountFactory.getAccountId(userId);
        Account accRecord = accountFactory.getUserAccountInfo(accountId);
        
        if (accRecord != null && accRecord.Investor_Banner_Interaction__c == false) {
            accRecord.Investor_Banner_Interaction__c = true;
            update accRecord;
        }
    }

    /**
     * Retrieves all transactions related to a specific investment.
     *
     * @param investmentId The ID of the investment for which transactions are being retrieved.
     * @return A List of Maps, where each Map contains transaction details such as type, amount, date, and status.
     */
    public List<Map<String,Object>> getInvestmentTransactions(Id investmentId) {
        // Initialize the return list
        List<Map<String,Object>> returnList = new List<Map<String,Object>>();
        
        // Invoke the services
        TransactionsService transactionsService = new TransactionsService();
        
        // Get the transactions associated with the provided investmentId
        List<Transaction__c> transactionRecords = transactionsService.getInterestTransactions(investmentId);
        

        // If transactions are found, process them
        if (!transactionRecords.isEmpty()) {

            String latestTransaction = transactionRecords[0].XI_Line_Items_Description__c;

            // Create map to retrieve the transaction
            
            for (Transaction__c transactions : transactionRecords) {
                // Create a new map for each transaction
                Map<String, Object> transactionDataMap = new Map<String, Object>();
                
                // Get the transaction data from the transaction record
                transactionDataMap.put('TransactionType', transactions.Transaction_Type__c);
                transactionDataMap.put('TransactionAmount', transactions.Transaction_Amount__c);
                transactionDataMap.put('Date', transactions.CreatedDate.format('dd MMMM yyyy'));
                transactionDataMap.put('Status', transactions.Status__c);
                transactionDataMap.put('Name', transactions.Name);
                transactionDataMap.put('YieldingType', transactions.XI_Line_Items_Description__c);
                
                // Add the transactionDataMap to returnList
                returnList.add(transactionDataMap);
            }
        }
        
        // Return the populated list of transaction data maps
        return returnList;
    }
}