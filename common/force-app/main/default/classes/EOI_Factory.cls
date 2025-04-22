public class EOI_Factory implements IEOI_Factory {
    /**
     * Retrieves a list of EOI records that are marked for publishing on the community site.
     *
     * @return List<EOI> - A list of EOI records.
     * @throws AuraHandledException if no EOIs are found or if an error occurs during retrieval.
     */
    public List<EOI__c> getEoiOfferInformation() {
        // Query to retrieve the relevant EOI records
        List<EOI__c> eoiRecords = [
            SELECT URL_Files_Img__c, Published_EOI_URL__c, One_liner_about_business__c, Company_Stage__c, EOI_Title__c FROM EOI__c 
            WHERE EOI_Status__c = 'Published' AND Publish_on_Community_Site__c = True
            ORDER BY CreatedDate DESC
            ];

        // Check if the query returned any records
        if (eoiRecords.isEmpty()) {
            // Log a message indicating no records were found
            Logger.logMessage('EOIApp', 'EOI_Factory', 'getEoiOfferInformation', 'No EOI records found');
            
            // Throw an exception indicating no EOIs are available
            throw new DmlException('No EOIs found for publication on the community site.');
        } else {
            // Log a success message indicating records were retrieved
            Logger.logMessage('EOIApp', 'EOI_Factory', 'getEoiOfferInformation', 'Successfully retrieved EOI records.');
            
            // Return the list of EOI records
            return eoiRecords;
        }
    }

    /**
     * Retrieves a list of EOI records that are marked for publishing on the community site.
     *
     * @return List<EOI> - A list of EOI records.
     * @throws AuraHandledException if no EOIs are found or if an error occurs during retrieval.
     */
    public List<EOI__c> getEoiSXSWFinalist(String searchTerm) {
        // Query to retrieve the relevant EOI records

        List<EOI__c> eoiRecords = new List<EOI__c>();

        if(!String.isBlank(searchTerm)){
            String searchKeyword = '%'+searchTerm+'%';

            eoiRecords = [
            SELECT URL_Files_Img__c, Published_EOI_URL__c, One_liner_about_business__c, Company_Stage__c, EOI_Title__c FROM EOI__c 
            WHERE EOI_Status__c = 'Published' AND Publish_on_Community_Site__c = True AND SXSW_Finalist__c = True AND Name LIKE :searchKeyword
            ORDER BY CreatedDate DESC
            ];
        }else{
            eoiRecords = [
            SELECT URL_Files_Img__c, Published_EOI_URL__c, One_liner_about_business__c, Company_Stage__c, EOI_Title__c FROM EOI__c 
            WHERE EOI_Status__c = 'Published' AND Publish_on_Community_Site__c = True AND SXSW_Finalist__c = True
            ORDER BY CreatedDate DESC
            ];
        }

        

        // Check if the query returned any records
        if (eoiRecords.isEmpty()) {
            // Log a message indicating no records were found
            Logger.logMessage('EOIApp', 'EOI_Factory', 'getEoiOfferInformation', 'No EOI records found');
            
            // Throw an exception indicating no EOIs are available
            throw new DmlException('No EOIs found for publication on the community site.');
        } else {
            // Log a success message indicating records were retrieved
            Logger.logMessage('EOIApp', 'EOI_Factory', 'getEoiOfferInformation', 'Successfully retrieved EOI records.');
            
            // Return the list of EOI records
            return eoiRecords;
        }

    }
    
    public List<EOI__c> getEoiInformation(Id eoiId) {
        List<EOI__c> eoiRecords = [SELECT URL_Files_Img__c, EOI_Title__c, EOI_Status__c FROM EOI__c WHERE Id = :eoiId];
            Logger.logMessage('EOIApp', 'EOI_Factory', 'getEoiInformation', 'No EOI record found for Id: ' + eoiId);
            return eoiRecords;
    }

    
    public List<Raise__c> getRaiseForEOI(Id eoiId){
        List<Raise__c> raisesForEOI = [SELECT Id, Name, Status__c, Published_Raise_URL__c, Final_Approval__c, Publish_on_Community_Site__c FROM Raise__c WHERE EOI__c=:eoiId];

        if(raisesForEOI.isEmpty()){
            throw new DmlException('No Raises Found for EOI ID: ' + eoiId );
        }else{
            return raisesForEOI;
        }
    }

    public EOI__c getEOIByID(Id eoiId){
        List<EOI__c> returnRecord = [SELECT Id, Name, EOI_Status__c, Minimum_Investment_amount__c FROM EOI__c WHERE Id=:eoiId];

        if(returnRecord.isEmpty()){
            throw new DmlException('No EOI Found for EOI ID: ' + eoiId );
        }else{
            return returnRecord[0];
        }
    }
}