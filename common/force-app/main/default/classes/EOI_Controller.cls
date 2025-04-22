public without sharing class EOI_Controller {
    // Test-visible instance of the EOI_Service class, 
    // allowing it to be mocked or manipulated in test methods.
    @TestVisible 
    private static EOI_Service eoiService = new EOI_Service();

    /**
     * Retrieves EOI offer information from the service layer.
     * Exposed to Aura and LWC components via @AuraEnabled.
     *
     * @return A JSON string containing EOI offer information.
     * @throws DmlException If there is an issue while retrieving the EOI information.
     */
    @AuraEnabled
    public static String getEoiOfferInformation() {
        try {
            // Retrieve EOI offer information from the service layer
            return eoiService.getEoiOfferInformation();
        } catch (DmlException e) {
            // Log error details and rethrow the exception
            Logger.logError('EOIApp', 'EOI_Controller', 'getEoiOfferInformation', 
                            null, null, null, null, e, 
                            'Failed to retrieve EOI offer information');
            throw e;
        }
    }

    /**
     * Retrieves SXSW finalists' EOI offer information based on the provided search term.
     * Exposed to Aura and LWC components via @AuraEnabled.
     *
     * @param searchTerm The search term used to filter the SXSW finalists' EOI offers.
     * @return A JSON string containing SXSW finalist EOI offer information.
     * @throws DmlException If there is an issue while retrieving the EOI information.
     */
    @AuraEnabled
    public static String getEoiSXSWOfferInformation(String searchTerm) {
        try {
            // Retrieve SXSW finalists' EOI offer information based on the search term
            return eoiService.getSXSWEoiOfferInformation(searchTerm);
        } catch (DmlException e) {
            // Log error details and rethrow the exception
            Logger.logError('EOIApp', 'EOI_Controller', 'getEoiSXSWOfferInformation', 
                            null, null, null, null, e, 
                            'Failed to retrieve SXSW EOI offer information');
            throw e;
        }
    }

    /**
     * Retrieves detailed EOI information based on the provided EOI record ID.
     * Exposed to Aura and LWC components via @AuraEnabled.
     *
     * @param eoiId The ID of the EOI record to retrieve.
     * @return A list of EOI__c records containing detailed EOI information.
     * @throws Exception If there is an issue while retrieving the information.
     */
    @AuraEnabled
    public static List<EOI__c> getEoiInformation(Id eoiId) {
        try {
            // Retrieve detailed EOI information from the service layer
            return eoiService.getEoiInformation(eoiId);
        } catch (Exception e) {
            // Rethrow the exception for handling at a higher level
            throw e;
        }
    }
    

    /**
     * Retrieves live raise information for the given EOI ID.
     *
     * @param eoiId The EOI ID for which live raise information is retrieved.
     * @return A map containing live raise information for the specified EOI ID.
     * @throws Exception If there is an issue while retrieving the information.
     */
    public static Map<String, Object> getLiveRaiseFromEOI(String eoiId) {
        try {
            // Retrieve live raise information from the service layer
            return eoiService.getLiveRaiseFromEOI(eoiId);
        } catch (Exception e) {
            // Rethrow the exception for handling at a higher level
            throw e;
        }
    }

    /**
     * Retrieves EOI information based on the provided EOI record ID.
     * Exposed to Aura and LWC components via @AuraEnabled.
     *
     * @param eoiId The ID of the EOI record to retrieve.
     * @return A map containing EOI information for the specified EOI ID.
     * @throws AuraHandledException If an issue occurs while retrieving the information.
     */
    @AuraEnabled
    public static Map<String, Object> getEOIByID(Id eoiId) {
        try {
            // Retrieve EOI information by ID from the service layer
            return eoiService.getEOIByID(eoiId);
        } catch (Exception e) {
            // Wrap the exception in an AuraHandledException and throw it
            throw new AuraHandledException(e.getMessage());
        }
    }
}