/**
Companies factory class that is used to retrieve data to my companies
from the EOI__c and Raise__c objects without exposing the object creation logic to the client
*/
public class CompaniesFactory implements ICompaniesFactory{
    /**
    * Checks if there is a Raise already created for a Business Account.
    * @param companyId The Id of the Business Account to create the raise.
    * @return Boolean to indicate if a raise exists or not.
    */
    public Boolean checkRaiseExists(String companyId){
        try{
            List<Raise__c> raiseList = [SELECT Id FROM Raise__c WHERE Company__c=:companyId];
            if(raiseList.size()>0){
                Logger.logMessage('CompaniesApp', 'CompaniesFactory', 'checkRaiseExists', 'Raise exists for companyId: ' + companyId);
                return true;
            }else{
                Logger.logMessage('CompaniesApp', 'CompaniesFactory', 'checkRaiseExists', 'No raise exists for companyId: ' + companyId);
                return false;
            }
        }catch(Exception e){
            Logger.logError('CompaniesApp', 'CompaniesFactory', 'checkRaiseExists', companyId, null, null, null, e, 'Failed to check if raise exists for companyId: ' + companyId);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * Checks if there is a EOI already created for a Business Account.
    * @param companyId The Id of the Business Account to create the raise.
    * @return Boolean to indicate if a EOI exists or not.
    */
    public Boolean checkEoiExists(String companyId) {
        try {
            List<EOI__c> eoiList = [SELECT Id FROM EOI__c WHERE Account__c = :companyId];
            if (eoiList.size() > 0) {
                Logger.logMessage('CompaniesApp', 'CompaniesFactory', 'checkEoiExists', 'EOI exists for companyId: ' + companyId);
                return true;
            } else {
                Logger.logMessage('CompaniesApp', 'CompaniesFactory', 'checkEoiExists', 'No EOI exists for companyId: ' + companyId);
                return false;
            }
        } catch (Exception e) {
            Logger.logError('CompaniesApp', 'CompaniesFactory', 'checkEoiExists', companyId, null, null, null, e, 'Failed to check if EOI exists for companyId: ' + companyId);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * Gets the EOI__c details for a specific Business account ID.
    * @param companyId The Id of the Business Account to be queried.
    * @return EOI__c record.
    * MODIFIED FOR PREVUP-98
    */
    public EOI__c getEOIDetailsFromCompanyId(String companyId){
        try{
            List<EOI__c> eoi = [SELECT Name, Id, EOI_Status__c, EOI_Published_Date__c, Published_EOI_URL__c, URL_Files_Img__c FROM EOI__c WHERE Account__c=:companyId ORDER BY CreatedDate DESC];        
            if (eoi.size() > 0) {
                Logger.logMessage('CompaniesApp', 'CompaniesFactory', 'getEOIDetailsFromCompanyId', 'Successfully retrieved EOI details for companyId: ' + companyId);
                return eoi[0];
            } else {
                Logger.logMessage('CompaniesApp', 'CompaniesFactory', 'getEOIDetailsFromCompanyId', 'No EOI details found for companyId: ' + companyId);
                return null;
            }
        }catch(Exception e){
            Logger.logError('CompaniesApp', 'CompaniesFactory', 'getEOIDetailsFromCompanyId', companyId, null, null, null, e, 'Failed to get EOI details for companyId: ' + companyId);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * Gets the Raise record given a company ID.
    * @param companyId The Id of the Business Account.
    * @return Raise__c record.
    */
    public Raise__c getRaiseRecordCompanyId(String companyId){
        try{
            List<Raise__c> raiseList = [SELECT Name,Account__c, Company__c, EOI__c, Status__c ,Form_Investment_type__c, Form_Offer_close_date__c,Form_Offer_launch_date__c ,Course_unlocked__c, Learning_completed__c FROM Raise__c WHERE Company__c=:companyId];
            if (raiseList.isEmpty()) {
                Logger.logMessage('CompaniesApp', 'CompaniesFactory', 'getRaiseRecordCompanyId', 'GetRaiseRecord Factory No raise record found for companyId: ' + companyId);
                throw new AuraHandledException('GetRaiseRecord Factory No raise record found for companyId: ' + companyId);
            } else {
                Logger.logMessage('CompaniesApp', 'CompaniesFactory', 'getRaiseRecordCompanyId', 'Successfully retrieved raise record for companyId: ' + companyId);
                return raiseList[0];
            }
        }catch(Exception e){
            Logger.logError('CompaniesApp', 'CompaniesFactory', 'getRaiseRecordCompanyId', companyId, null, null, null, e, 'Failed to get raise record for companyId: ' + companyId);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * Gets the Business account details for a specific account ID.
    * @param companyId The Id of the Business Account.
    * @return Account record.
    */
    public Account getCompanyDetails(String companyId){
        try{
            List<Account> company = [SELECT Id, Name FROM Account WHERE Id = :companyId];
            if(company.size() > 0){
                Logger.logMessage('RaiseApp', 'CompaniesFactory', 'getCompanyDetails', 'Successfully retrieved company details for companyId: ' + companyId);
                return company[0];
            }else{
                Logger.logMessage('RaiseApp', 'CompaniesFactory', 'getCompanyDetails', 'No company details found for companyId: ' + companyId);
                return null;
            }
        }catch(Exception e){
            Logger.logError('RaiseApp', 'CompaniesFactory', 'getCompanyDetails', companyId, null, null, null, e, 'Failed to get company details for companyId: ' + companyId);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * Gets the company Id for  a specific user ID.
    * @param userId The Id of the User.
    * @return companyId record.
    */
    public List<Account> getCompanyId(String userId){
        try {
            List<User> companyId = [SELECT AccountId FROM User WHERE Id = :userId];
            
            if (companyId.isEmpty()) {
                Logger.logMessage('CompaniesApp', 'CompaniesFactory', 'getRaiseRecordCompanyId', 'No raise record found for userId: ' + userId);
                throw new AuraHandledException('No raise record found for userId: ' + userId);
            } else {
                // List<Account> lstCompanies = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'Ventures_Company_Account' AND Related_Person_Account__c=:companyId[0].AccountId];
                List<Account> lstCompanies = [SELECT Id FROM Account WHERE Related_Person_Account__c=:companyId[0].AccountId];

                Logger.logMessage('CompaniesApp', 'CompaniesFactory', 'getRaiseRecordCompanyId', 'Successfully retrieved raise record for companyId: ' + userId);
                return lstCompanies;
            }
        } catch(Exception e){
            Logger.logError('CompaniesApp', 'CompaniesFactory', 'getRaiseRecordCompanyId', userId, null, null, null, e, 'Failed to get raise record for companyId: ' + userId);
            throw new AuraHandledException(e.getMessage());
        }
    }
}