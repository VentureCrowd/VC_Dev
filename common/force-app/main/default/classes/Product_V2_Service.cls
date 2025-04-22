public without sharing class Product_V2_Service {

    /**
     * Retrieves product offer information and returns it as a serialized JSON string.
     *
     * @return String - A JSON string representing a list of ProductsData.
     * @throws AuraHandledException if no products are found or if an error occurs during processing.
     */
    public String getProductOfferInformation() {
        try {
            // Create an instance of the factory to retrieve product information
            Product_V2_Factory factory = new Product_V2_Factory();

            // Get the list of products from the factory
            List<Product2> productsRecords = factory.getProductOfferInformation();

            // Check if the list of products is empty
            if (productsRecords.isEmpty()) {
                // Log a message indicating no product records were found
                Logger.logMessage('ProductApp', 'Product_V2_Service', 'getProductOfferInformation', 'No product records found.');

                // Throw an exception indicating no product records were found
                throw new AuraHandledException('No products found for publication on the community site.');
            } else {
                // Initialize a list to hold the ProductsData objects
                List<ProductsData> productsRecordsList = new List<ProductsData>();

                // Loop through the products and map them to the ProductsData class
                for (Product2 product : productsRecords) {
                    ProductsData data = new ProductsData();
                    Id raiseId = product.Raise__c;
                    // Fetch the logo and hero Banner URLs

                    if (raiseId != null) {
                        List<Map<String, Object>> documentLogoUrl = FileUploadController.getDocumentsUrl('companyLogoId', raiseId);
                        List<Map<String, Object>> documentLogoheroBannerUrl = FileUploadController.getDocumentsUrl('heroImageId', raiseId);
                        if (!documentLogoUrl.isEmpty() && !documentLogoheroBannerUrl.isEmpty()) {
                            String logourl = (String) documentLogoUrl[0].get('publicDownloadUrl');
                            String heroBannerUrl = (String) documentLogoheroBannerUrl[0].get('publicDownloadUrl');
                            data.logoURL = logourl;
                            data.heroBannerURL = heroBannerUrl;
                        }
                    }
                    // Assign the data

                    data.tileHeading = product.Tile_Heading__c;
                    data.companyOneLiner = product.Deal_Description__c;
                    data.bannerURL = product.Tile_Banner__c;
                    data.industryType = product.Tile_Offer_Type__c;
                    data.dealPageLink = product.Deal_Page_Link__c;
                    data.investmentType = product.Family;
                    // Check if both URL's are available



                    productsRecordsList.add(data);
                }

                // Log a success message indicating records were successfully retrieved and processed
                Logger.logMessage('ProductApp', 'Product_V2_Service', 'getProductOfferInformation', 'Successfully retrieved and processed product records.');

                // Serialize the list of ProductsData to JSON and return it
                return JSON.serialize(productsRecordsList);
            }
        } catch (Exception e) {
            // Log an error message with detailed information about the exception
            Logger.logError('ProductApp', 'Product_V2_Service', 'getProductOfferInformation', null, null, null, null, e, 'Failed to retrieve and process product records.');

            // Throw an AuraHandledException with a user-friendly message
            throw new AuraHandledException('An error occurred while processing product records: ' + e.getMessage());
        }
    }

    /**
     * Inner class representing the product data structure that will be serialized into JSON.
     */
    public class ProductsData {
        public String tileHeading;
        public String companyOneLiner;
        public String bannerURL;
        public String logoURL;
        public String heroBannerURL;

        public String industryType;
        public String investmentType;
        public String dealPageLink;
    }

    /**
     * Retrieves detailed information about a specific product identified by its ID.
     * 
     * @param productId The ID of the Product2 record to retrieve.
     * @return A Product2 object containing the requested product's details.
     * @throws AuraHandledException If an error occurs during the query execution.
     */
    public Product2 getProductInformation(Id productId) {
        // Create an instance of the factory to retrieve product information
        Product_V2_Factory factory = new Product_V2_Factory();

        // Get the list of products from the factory
        Product2 productsRecords = factory.getProductInformation(productId);

        // Check if the list of products is empty
        return productsRecords;
    }

    /**
     * Retrieves the PricebookEntry associated with a specific product.
     * 
     * @param productId The ID of the Product2 record whose price book entry is to be retrieved.
     * @return A PricebookEntry object containing the price details for the given product.
     * @throws QueryException If the product does not have an associated PricebookEntry or multiple entries are found.
     */
    public PricebookEntry getProductPriceBook(Id productId) {
        // Create an instance of the factory to retrieve product information
        Product_V2_Factory factory = new Product_V2_Factory();
        // Get the list of products from the factory
        PricebookEntry productsRecords = factory.getProductPriceBook(productId);
        // Check if the list of products is empty
        return productsRecords;
    }

    public List<Map<String,Object>> getProductByType(String productTypeName, String productRTName){
        Product_V2_Factory factory = new Product_V2_Factory();

        List<Product2> prodData = factory.getProductByType(productTypeName, productRTName);

        List<Map<String,Object>> returnData = new List<Map<String,Object>>();

        if(prodData.size()>0){
            for(Product2 product : prodData){
                Map<String,Object> tempMap = new Map<String,Object>{
                    'prodName' =>  product.Name,
                    'prodDisplayName' => product.Portal_Display_Name__c,
                    'prodCode' => product.ProductCode,
                    'prodId'=>product.Id
                };

                returnData.add(tempMap);
            }
        }

        return returnData;
    }

}