/**
 * Apex controller for the My companies process.
 * The goal is to not have any business logic living in this layer,
 * but merely translate the callers input to match that of the service class
 */

public without sharing class CompaniesController {
    @TestVisible private static CompaniesService companiesService = new CompaniesService();

    /**
     * Checks if a raise record exists for the specified company.
     *
     * @param companyId The ID of the company to check.
     * @return Boolean indicating whether a raise record exists for the company.
     */
    @AuraEnabled()
    public static Boolean raiseExists(String companyId){
        try{
            return companiesService.raiseExists(companyId);
        }catch (Exception e) {
            Logger.logError('CompaniesApp', 'RaiseController', 'raiseExists', null, null, null, null, e, 'Failed to check if raise exists for companyId: ' + companyId);
            throw e;
        }
    }

    /**
     * Checks if an EOI (Expression of Interest) record exists for the specified company.
     *
     * @param companyId The ID of the company to check.
     * @return Boolean indicating whether an EOI record exists for the company.
     */
    @AuraEnabled()
    public static Boolean eoiExists(String companyId){
        try{
            return companiesService.eoiExists(companyId);
        }catch (Exception e) {
            Logger.logError('CompaniesApp', 'RaiseController', 'eoiExists', null, null, null, null, e, 'Failed to check if raise exists for companyId: ' + companyId);
            throw e;
        }
    }

    /**
     * Retrieves the raise details for the specified company.
     *
     * @param companyId The ID of the company to retrieve the raise details for.
     * @return A JSON string containing the raise details for the company.
     */
    @AuraEnabled()
    public static String getRaiseDetailsFromCompanyId(String companyId){
        try{
            return companiesService.getRaiseDetailsFromCompanyId(companyId);
        }catch (Exception e) {
            Logger.logError('CompaniesApp', 'RaiseController', 'getRaiseDetailsFromCompanyId', null, null, null, null, e, 'Failed to get raise details for companyId: ' + companyId);
            throw e;
        }
    }

    /**
     * Retrieves the EOI (Expression of Interest) details for the specified company.
     *
     * @param companyId The ID of the company to retrieve the EOI details for.
     * @return A JSON string containing the EOI details for the company.
     */
    @AuraEnabled()
    public static String getEoiDetailsFromCompanyId(String companyId){
        try{
            return companiesService.getEoiDetailsFromCompanyId(companyId);
        }catch (Exception e) {
            Logger.logError('CompaniesApp', 'RaiseController', 'getEoiDetailsFromCompanyId', null, null, null, null, e, 'Failed to get eoi details for companyId: ' + companyId);
            throw e;
        }
    }

    /**
     * Retrieves the card details for all companies associated with a specified user.
     *
     * @param userId The ID of the user to retrieve the company card details for.
     * @return A list of maps, each representing a company's card details with key-value pairs.
     */
    @AuraEnabled()
    public static List<Map<String,Object>> getCompaniesCardDetails(String userId){
        try{
            return companiesService.getCompaniesCardDetails(userId);
        }catch (Exception e) {
            Logger.logError('CompaniesApp', 'RaiseController', 'getCompaniesCardDetails', null, null, null, null, e, 'Failed to get eoi details for companyId: ' + userId);
            throw e;
        }
    }

}