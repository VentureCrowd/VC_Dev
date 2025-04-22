public without sharing class EOI_Service {
/**
     * Retrieves EOI offer information and returns it as a serialized JSON string.
     *
     * @return String - A JSON string representing a list of EOIsData.
     * @throws AuraHandledException if no EOIs are found or if an error occurs during processing.
     */
    public String getEoiOfferInformation() {
            // Create an instance of the factory to retrieve EOI information
            EOI_Factory factory = new EOI_Factory();

            // Get the list of EOIs from the factory
            List<EOI__c> eoiRecords = factory.getEoiOfferInformation();

            // Check if the list of EOIs is empty
            if (eoiRecords.isEmpty()) {
                // Log a message indicating no EOI records were found
                Logger.logMessage('EOIApp', 'EOI_Service', 'getEoiOfferInformation', 'No EOI records found.');

                // Throw an exception indicating no EOI records were found
                throw new AuraHandledException('No EOIs found for publication on the community site.');
            } else {
                // Initialize a list to hold the EOIsData objects
                List<EoiOfferData> eoiRecordsList = new List<EoiOfferData>();

                // Loop through the EOIs and map them to the EOIsData class
                for (EOI__c eoi : eoiRecords) {
                    EoiOfferData data = new EoiOfferData();
                    data.tileHeading = eoi.EOI_Title__c;
                    data.companyOneLiner = eoi.One_liner_about_business__c;
                    data.imagesUrl = eoi.URL_Files_Img__c;
                    data.investmentType = eoi.Company_Stage__c;
                    data.dealPageLink = eoi.Published_EOI_URL__c;
                    eoiRecordsList.add(data);
                }

                // Log a success message indicating records were successfully retrieved and processed
                Logger.logMessage('EOIApp', 'EOI_Service', 'getEoiOfferInformation', 'Successfully retrieved and processed EOI records.');

                // Serialize the list of EOIsData to JSON and return it
                return JSON.serialize(eoiRecordsList);
            }
  
    }

    /**
     * Retrieves EOI offer information and returns it as a serialized JSON string for SXSW finalists.
     *
     * @return String - A JSON string representing a list of EOIsData.
     * @throws AuraHandledException if no EOIs are found or if an error occurs during processing.
     */
    public String getSXSWEoiOfferInformation(String searchTerm) {
            // Create an instance of the factory to retrieve EOI information
            EOI_Factory factory = new EOI_Factory();

            // Get the list of EOIs from the factory
            List<EOI__c> eoiRecords = factory.getEoiSXSWFinalist(searchTerm);

            // Check if the list of EOIs is empty
            if (eoiRecords.isEmpty()) {
                // Log a message indicating no EOI records were found
                Logger.logMessage('EOIApp', 'EOI_Service', 'getEoiOfferInformation', 'No EOI SXSW records found.');

                // Throw an exception indicating no EOI records were found
                throw new AuraHandledException('No SXSW EOIs found for publication on the community site.');
            } else {
                // Initialize a list to hold the EOIsData objects
                List<EoiOfferData> eoiRecordsList = new List<EoiOfferData>();

                // Loop through the EOIs and map them to the EOIsData class
                for (EOI__c eoi : eoiRecords) {
                    EoiOfferData data = new EoiOfferData();
                    data.tileHeading = eoi.EOI_Title__c;
                    data.companyOneLiner = eoi.One_liner_about_business__c;
                    data.imagesUrl = eoi.URL_Files_Img__c;
                    data.investmentType = eoi.Company_Stage__c;
                    data.dealPageLink = eoi.Published_EOI_URL__c;
                    eoiRecordsList.add(data);
                }

                // Log a success message indicating records were successfully retrieved and processed
                Logger.logMessage('EOIApp', 'EOI_Service', 'getEoiOfferInformation', 'Successfully retrieved and processed EOI SXSW records.');

                // Serialize the list of EOIsData to JSON and return it
                return JSON.serialize(eoiRecordsList);
            }
  
    }

    /**
     * Inner class representing the EOI data structure that will be serialized into JSON.
     */
    public class EoiOfferData {
        public String tileHeading;
        public String companyOneLiner;
        public String imagesUrl;
        public String investmentType;
        public String dealPageLink;
    }

    public List<EOI__c> getEoiInformation(Id eoiId) {
        EOI_Factory factory = new EOI_Factory();
        List<EOI__c> eoiRecords = factory.getEoiInformation(eoiId);
        return eoiRecords;
    }

    public Map<String,Object> getLiveRaiseFromEOI(Id eoiId) {
        EOI_Factory factory = new EOI_Factory();

        List<Raise__c> returnResults = factory.getRaiseForEOI(eoiId);

        Map<String,Object> returnValue = new Map<String,Object>();

        for(Raise__c raiseRecord : returnResults){
            
            Map<String,Object> raiseReturnMap = new Map<String,Object>();

            if(raiseRecord.Status__c == 'Live'){
                    raiseReturnMap.put('raiseId', raiseRecord.Id);
                    raiseReturnMap.put('raiseName' , raiseRecord.Name);
                    raiseReturnMap.put('raiseStatus' , raiseRecord.Status__c);
                    raiseReturnMap.put('raiseUrl' , raiseRecord.Published_Raise_URL__c);
                    raiseReturnMap.put('raiseIsApproved' , raiseRecord.Final_Approval__c);
                    raiseReturnMap.put('raiseIsPublic' , raiseRecord.Publish_on_Community_Site__c);


                    returnValue.put(raiseRecord.Id, raiseReturnMap);
            }
        
        }

        if(returnValue.isEmpty()){
            throw new AuraHandledException('No Live Raises Found for EOI: ' + eoiId);
        }

        return returnValue;
    }

    public Map<String,Object> getEOIByID(Id eoiId){

         EOI_Factory factory = new EOI_Factory();

         EOI__c eoiRecord = factory.getEOIByID(eoiId);

         Map<String,Object> returnMap  = new Map<String,Object>();

         returnMap.put('name', eoiRecord.Name);
         returnMap.put('status', eoiRecord.EOI_Status__c);
         returnMap.put('minimumInvestmentAmt', eoiRecord.Minimum_Investment_amount__c);
         

         return returnMap;
    }
}