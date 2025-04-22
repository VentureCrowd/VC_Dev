public interface ICompaniesFactory {
    Boolean checkRaiseExists(String companyId);
    Boolean checkEoiExists(String companyId);
    EOI__c getEOIDetailsFromCompanyId(String companyId);
    Raise__c getRaiseRecordCompanyId(String companyId);
    Account getCompanyDetails(String companyId);
    List<Account> getCompanyId(String userId);
}