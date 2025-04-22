/**
 * This is the service layer class associated with the Raise process. 
 * All of the business logic relevant to Raise will remain in this class.
*/
public without sharing class CompaniesService {
    /**
     * Check if a Raise record exists for a Business account.
     * @param companyId The Id of the Business Account.
     * @return Boolean to indicate if the raise exists.
     * @throws AuraHandledException
     */ 
    public Boolean raiseExists(String companyId){
        try{
            CompaniesFactory factory = New CompaniesFactory();
            Boolean result = factory.checkRaiseExists(companyId);
            Logger.logMessage('CompaniesApp', 'CompaniesService', 'raiseExists', 'Checked existence of raise record for companyId: ' + companyId);
            return result;
        }catch (Exception e){
            Logger.logError('CompaniesApp', 'CompaniesService', 'raiseExists', companyId, null, null, null, e, 'Failed to check if raise exists for companyId: ' + companyId);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Check if a EOI Record exists for a Business account.
     * @param companyId The Id of the Business Account.
     * @return Boolean to indicate if the raise exists.
     * @throws AuraHandledException
     */ 
    public Boolean eoiExists(String companyId){
        try{
            CompaniesFactory factory = New CompaniesFactory();
            Boolean result = factory.checkEoiExists(companyId);
            Logger.logMessage('CompaniesApp', 'CompaniesService', 'eoiExists', 'Checked existence of raise record for companyId: ' + companyId);
            return result;
        }catch (Exception e){
            Logger.logError('CompaniesApp', 'CompaniesService', 'eoiExists', companyId, null, null, null, e, 'Failed to check if raise exists for companyId: ' + companyId);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Get the details of a raise record given the Business Account ID
     * @param companyId The Id of the Business Account record.
     * @return JSON.serialize string representation of the raise record.
     * @throws AuraHandledException
     */ 
    public String getRaiseDetailsFromCompanyId(String companyId){
        try{
            CompaniesFactory factory = New CompaniesFactory();
            Raise__c raiseRecord = factory.getRaiseRecordCompanyId(companyId);
            if(raiseRecord != null){
                RaiseData returnData = new RaiseData();
                returnData.id = raiseRecord.Id;
                returnData.name = raiseRecord.Name;
                returnData.account = raiseRecord.Account__c;
                returnData.company = raiseRecord.Company__c;
                returnData.eoi = raiseRecord.EOI__c;
                returnData.status = raiseRecord.Status__c;
                returnData.investmentType = raiseRecord.Form_Investment_type__c;
                returnData.offerCloseDate = raiseRecord.Form_Offer_close_date__c;
                returnData.launchDate = raiseRecord.Form_Offer_launch_date__c;
                returnData.courseUnlocked = raiseRecord.Course_unlocked__c;
                returnData.learningCompleted = raiseRecord.Learning_completed__c;
                Logger.logMessage('CompaniesApp', 'CompaniesService', 'getRaiseDetailsFromCompanyId', 'Successfully retrieved raise details for companyId: ' + companyId);
                return JSON.serialize(returnData);
            }else{
                Logger.logMessage('CompaniesApp', 'CompaniesService', 'getRaiseDetailsFromCompanyId', 'This is from Service No raise record found for companyId: ' + companyId);
                throw new AuraHandledException( 'No raise record found for companyId: ' + companyId);
            }
        }catch(Exception e){
            Logger.logError('CompaniesApp', 'CompaniesService', 'getRaiseDetailsFromCompanyId', companyId, null, null, null, e, 'Failed to get raise details for companyId: ' + companyId);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Get the details of a EOI record given the Business Account ID
     * @param companyId The Id of the Business Account record.
     * @return JSON.serialize string representation of the eoi record.
     * @throws AuraHandledException
     */ 
    public String getEoiDetailsFromCompanyId(String companyId){
        try{
            CompaniesFactory factory = New CompaniesFactory();
            EOI__c eoiRecord = factory.getEOIDetailsFromCompanyId(companyId);
            if(eoiRecord != null){
                EoiData returnData = new EoiData();
                returnData.id = eoiRecord.Id;
                returnData.name = eoiRecord.Name;
                returnData.status = eoiRecord.EOI_Status__c;
                returnData.publishedDate = eoiRecord.EOI_Published_Date__c;
                Logger.logMessage('CompaniesApp', 'CompaniesService', 'getEoiDetailsFromCompanyId', 'Successfully retrieved eoi details for companyId: ' + companyId);
                return JSON.serialize(returnData);
            }else{
                Logger.logMessage('CompaniesApp', 'CompaniesService', 'getEoiDetailsFromCompanyId', 'EoiDetails Method No raise record found for companyId: ' + companyId);
                throw new AuraHandledException( 'No raise record found for companyId: ' + companyId);
            }
        }catch(Exception e){
            Logger.logError('CompaniesApp', 'CompaniesService', 'getEoiDetailsFromCompanyId', companyId, null, null, null, e, 'Failed to get eoi details for companyId: ' + companyId);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Get the details of companies associated with a given user ID.
     *
     * This method retrieves company details, including their respective EOI (Expression of Interest) 
     * and Raise records, for a specified user. It gathers necessary information from the CompaniesFactory 
     * and other related entities and returns a list of maps containing the detailed information.
     *
     * @param userId The ID of the user for whom the company details are to be fetched.
     * @return A list of maps, each representing a company with its details and associated records.
     *         Each map contains key-value pairs representing different attributes of the company 
     *         and its associated records.
     * @throws AuraHandledException If there is an error while retrieving the company details.
     */ 
    public List<Map<String,Object>> getCompaniesCardDetails(String userId) {
        try {
            // Initialize the CompaniesFactory to interact with the companies data.            
            CompaniesFactory factory = New CompaniesFactory();
            List<Account> companiesId = factory.getCompanyId(userId);
            List<Map<String,Object>> finalReturnData = new List<Map<String,Object>>();
            
            // Iterate through each company ID to fetch and compile their details.
            for (Account companyId : companiesId) {                
                Account companyRecord = factory.getCompanyDetails(companyId.Id);
                Boolean eoiExist = factory.checkEoiExists(companyId.Id);
                Boolean raiseExist = factory.checkRaiseExists(companyId.Id);
                Map<String,Object> returnData = new Map<String,Object>();

                // If an EOI record exists, retrieve and add its details to the return data.
                if (eoiExist) {
                    EOI__c eoiRecord = factory.getEoiDetailsFromCompanyId(companyId.Id);
                    returnData.put('eoiId',eoiRecord.Id);
                    returnData.put('eoiStatus', eoiRecord.EOI_Status__c);

                     // Check if EOI is live
                    if(eoiRecord.EOI_Status__c == 'Published' || eoiRecord.EOI_Status__c == 'Closed'){
                        returnData.put('eoiPublishURL', eoiRecord.Published_EOI_URL__c);
                    }


                    if (eoiRecord.URL_Files_Img__c != null) {
                        List<Object> imagesURLS = (List<Object>) JSON.deserializeUntyped(eoiRecord.URL_Files_Img__c);
                        for (Object imageObj : imagesURLS) {
                            Map<String, Object> imageMap = (Map<String, Object>) imageObj;
                            if (imageMap.get('title') == 'logo') {
                                returnData.put('companyLogoEOI', (String) imageMap.get('contentDownloadURL'));
                                break;
                            }
                        }
                    }
                    // Format the date to only return date not date and time
                    if(eoiRecord.EOI_Published_Date__c != null) {
                        Date eoiDate = eoiRecord.EOI_Published_Date__c.date();
                        returnData.put('eoiLaunchDate', eoiDate);
                    }
                    returnData.put('eoiExist', eoiExist);
                }

                // If a Raise record exists, retrieve and add its details to the return data.
                if (raiseExist) {
                    Raise__c raiseRecord = factory.getRaiseRecordCompanyId(companyId.Id);
                    List<Map<String, Object>> documentsUrls = FileUploadController.getDocumentsUrl('companyLogoId', raiseRecord.Id);
                    returnData.put('raiseId', raiseRecord.Id);
                    returnData.put('raiseStatus', raiseRecord.Status__c);
                    returnData.put('raiseEndDate', raiseRecord.Form_Offer_close_date__c);
                    returnData.put('raiseLaunchDate', raiseRecord.Form_Offer_launch_date__c);
                    returnData.put('raiseExist', raiseExist);
                    returnData.put('raiseCourseUnlocked', raiseRecord.Course_unlocked__c);
                    returnData.put('learningCompleted', raiseRecord.Learning_completed__c);
                    // Extract the publicDownloadUrl;
                    if (!documentsUrls.isEmpty() && documentsUrls[0].containsKey('publicDownloadUrl')) {
                        String publicDownloadUrl = (String) documentsUrls[0].get('publicDownloadUrl');
                        returnData.put('companyLogo', publicDownloadUrl);
                    }
                }
                returnData.put('companyId', companyRecord.Id);
                returnData.put('companyName', companyRecord.Name);
                finalReturnData.add(returnData);
            }
                Logger.logMessage('CompaniesApp', 'CompaniesService', 'getCompaniesCardDetails', 'Successfully retrieved raise details for userId: ' + userId);
                return finalReturnData;
        }catch(Exception e){
            Logger.logError('CompaniesApp', 'CompaniesService', 'getCompaniesCardDetails', userId, null, null, null, e, 'Failed to get company card details for userId: ' + userId);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Class structure that abstracts the EOI record structure need for my Companies Page
     */ 
    public class EoiData {
        String name;
        Id id;
        String status;
        Datetime publishedDate;
    }

    /**
     * Class structure that abstracts the Raise record structure need for my Companies Page
     */ 
	public class RaiseData{
        String name;
        String account;
        String eoi;
        String id; 
        String status;
        String company;
        String investmentType;
        Decimal minTarget;
        Decimal maxTarget;
        Decimal minInvestAmount;
        Date offerCloseDate;
        Date launchDate;
        Boolean learningCompleted;
        Boolean courseUnlocked;
    }


}