public with sharing class SecurityController {
    
    @TestVisible private static SecurityService securityService = new SecurityService();
    
    @AuraEnabled()
    public static String getLoggedInAccountId(){
        return securityService.getLoggedInAccountId();
    }

    @AuraEnabled
    public static Boolean checkRaiseAccess(Id raiseId){
        try {
            return securityService.checkRaiseAccess(raiseId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean checkEoiAccess(Id eoiId){
        try {
            return securityService.checkEoiAccess(eoiId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}