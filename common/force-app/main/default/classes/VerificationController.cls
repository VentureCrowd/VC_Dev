/**

**/
public without sharing class VerificationController {
    @AuraEnabled
    public static Account checkVerificationNeeded(){
        try {
            User user = [SELECT Id, Contact.AccountId FROM User WHERE Id =: Userinfo.getUserId()];
            return [SELECT Id, ID_Checked__pc,GreenId_Status__c FROM Account WHERE Id =: user.Contact.AccountId];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String updateAccountVerificationDetails(String dataToBeUpdated){
        try {
            List<DataToBeUpdatedWrapper> result = (List<DataToBeUpdatedWrapper>) System.JSON.deserialize(dataToBeUpdated, List<DataToBeUpdatedWrapper>.class);
            User user = [SELECT Id, contactId, contact.AccountId,Account.ispersonaccount FROM User WHERE Id =: Userinfo.getUserId()];
        if(user.contact.AccountId != null) {
            Account acc = new Account();
            acc.Id = user.contact.AccountId;
            for(DataToBeUpdatedWrapper data : result) { 
                if(data.label == 'verificationId') {
                    acc.GreenID_USerID__c = data.value;
                }else if(data.label == 'verificationToken') {
                    acc.GreenID_TransID__c = data.value;
                }else if(data.label == 'verificationResult') {
                    acc.GreenId_Status__c  = data.value;
                }else if(data.label == 'givenName') {
                    acc.GreenID_First_Name__c  = data.value;
                }else if(data.label == 'middleNames') {
                    acc.GreenID_Middle_Name__c  = data.value;
                }else if(data.label == 'surname') {
                    acc.GreenID_Last_Name__c  = data.value;
                }else if(data.label == 'dob') {
                    acc.GreenID_DOB__c  = date.valueOf(data.value);
                }
            }
            if((acc.GreenId_Status__c == 'VERIFIED' || acc.GreenId_Status__c == 'VERIFIED_ADMINS'
               || acc.GreenId_Status__c == 'VERIFIED_WITH_CHANGES') && !test.isRunningTest()){
                  acc.ID_Checked__pc = true; 
            }
            update acc;
            return 'Success';
        }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return '';
    }

    public class DataToBeUpdatedWrapper{
        public String label;
        public String value;
    }
    @AuraEnabled
    public static string getverificationresult(string accountId,string webServicePassword,string verificationToken){
        dynamicformServicesRegistrationsEdent.DynamicFormsServiceV3Port parentclass1 = new dynamicformServicesRegistrationsEdent.DynamicFormsServiceV3Port();
        dynamicformServicesRegistrationsEdent.currentStatusV3 response = parentclass1.getVerificationResult(accountId,webServicePassword,null,verificationToken,null);
        system.debug(response);
        dynamicformServicesRegistrationsEdent.registrationDetailsV3 registrationDetails = response.registrationDetails;
        dynamicformServicesRegistrationsEdent.address currentResidentialAddress = registrationDetails.currentResidentialAddress;
        dynamicformServicesRegistrationsEdent.dateOfBirth dob = registrationDetails.dob;
        dynamicformServicesRegistrationsEdent.name name = registrationDetails.name;
        dynamicformServicesRegistrationsEdent.sourceFieldsV3 sourceFields = response.sourceFields;
        dynamicformServicesRegistrationsEdent.sourceListV3 sourceList = response.sourceList;
        dynamicformServicesRegistrationsEdent.verificationResultV3 verificationResult = response.verificationResult;
        dynamicformServicesRegistrationsEdent.checkResultV3[] individualResult = verificationResult.individualResult;
        string overallVerificationStatus = verificationResult.overallVerificationStatus;
        string verificationId = verificationResult.verificationId;
        User user = [SELECT Id, contactId, contact.AccountId,Account.ispersonaccount FROM User WHERE Id =: Userinfo.getUserId()];
        if(user.contact.AccountId != null) {
            Account acc = new Account();
            acc.Id = user.contact.AccountId;
            acc.GreenID_USerID__c = verificationId;
            acc.GreenID_TransID__c = verificationToken;
            acc.GreenId_Status__c  = overallVerificationStatus;
            acc.GreenID_First_Name__c  = name.givenName;
            acc.GreenID_Middle_Name__c  = name.middleNames;
            acc.GreenID_Last_Name__c  = name.surname;
            acc.GreenID_DOB__c  = date.newinstance(Integer.valueOf(dob.year),Integer.valueOf(dob.month),Integer.valueOf(dob.day));
            if((acc.GreenId_Status__c == 'VERIFIED' || acc.GreenId_Status__c == 'VERIFIED_ADMINS'|| acc.GreenId_Status__c == 'VERIFIED_WITH_CHANGES') && !test.isRunningTest()){
                acc.ID_Checked__pc = true; 
            }
            acc.GID_Address_Country__c = currentResidentialAddress.country;
            acc.GID_Address_Flat_Number__c = currentResidentialAddress.flatNumber;
            acc.GID_Address_Postal_Code__c = currentResidentialAddress.postcode;
            acc.GID_Address_State__c = currentResidentialAddress.state;
            acc.GID_Address_Street__c = currentResidentialAddress.streetName;
            acc.GID_Address_street_Number__c = currentResidentialAddress.streetNumber;
            acc.GID_Address_Street_Type__c = currentResidentialAddress.streetType;
            acc.GID_Address_Suburb__c = currentResidentialAddress.suburb;
            for(dynamicformServicesRegistrationsEdent.checkResultV3 inv : individualResult){
                if(inv.fieldResult <> null)
                for(dynamicformServicesRegistrationsEdent.fieldResultV3 flr : inv.fieldResult){
                    if(flr.status == 'CHANGED' && inv.state == 'VERIFIED_WITH_CHANGES'){
                        if(flr.name == 'state'){
                            acc.GID_Changed_Address_State__c = flr.changedValue;
                        }else if(flr.name == 'postcode'){
                            acc.GID_Changed_Address_Postal_Code__c = flr.changedValue;
                        }else if(flr.name == 'suburb'){
                            acc.GID_Changed_Address_Suburb__c = flr.changedValue;
                        }else if(flr.name == 'streetType'){
                            acc.GID_Changed_Address_Street_Type__c = flr.changedValue;
                        }else if(flr.name == 'street'){
                            acc.GID_Changed_Address_Street__c = flr.changedValue;
                        }else if(flr.name == 'streetNumber'){
                            acc.GID_Changed_Street_Number__c = flr.changedValue;
                        }else if(flr.name == 'flatNumber'){
                            acc.GID_Changed_Address_Flat_Number__c = flr.changedValue;
                        }else if(flr.name == 'surname'){
                            acc.GID_Changed_Last_Name__c = flr.changedValue;
                        }else if(flr.name == 'givenName'){
                            acc.GID_Changed_First_Name__c = flr.changedValue;
                        }else if(flr.name == 'dob'){
                            acc.GID_Chnaged_DOB__c = Date.valueof(flr.changedValue);
                        }
                    }
                }
            }
            update acc;
        }
        return overallVerificationStatus;
    }
}