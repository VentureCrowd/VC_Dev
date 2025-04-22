public interface IRaiseFactory {
	Raise__c createRaise(String companyId, String investType);
    Boolean checkRaiseExists(String companyId);
    Raise__c getRaiseRecord(String raiseId);
    Raise__c getRaiseRecordCompanyId(String companyId);
    Raise__c getRaisePageRecordRaiseId(String raiseId);
    Raise__c getFullRaiseRecord(String raiseId);
    Map<String,Object> updateRaiseRecord(Id raiseId, Map<String, Object> fieldsToUpdate);
    Raise__c getRaiseRecordDetailsForm(Id raiseId);
    Raise__c updateRaiseStatus(Id raiseId, String status);
    Raise__c getRaiseStatuses(String raiseId);
    Raise__c unlockRaiseCourse(String raiseId);
    Map<String,Object> getSummaryStatistics(Id raiseId,Id eoiId);
}