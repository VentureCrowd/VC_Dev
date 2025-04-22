public interface IEOI_Factory {
    List<EOI__c> getEoiOfferInformation();
    List<EOI__c> getEoiSXSWFinalist(String searchTerm);
}