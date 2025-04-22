global without sharing class InboundEmailHandler implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        try{
            string RecordTypeID = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('VCPP').getRecordTypeId();
            Lead l = new Lead();
            string name = email.plainTextBody.split('\n *>* *\\**Name:\\**')[1].split('\n')[0].trim();
            string ProjectId = email.plainTextBody.split('\\**Project ID:\\**').size() > 1 ? email.plainTextBody.split('\\**Project ID:\\**')[1].split('\n')[0] : '';
            string ProjectName = email.plainTextBody.split('\\**Project Name:\\**').size() > 1 ? email.plainTextBody.split('\\**Project Name:\\**')[1].split('\n')[0] : '';
            string ProjectAdress = email.plainTextBody.split('\\**Project Address:\\**').size() > 1 ? email.plainTextBody.split('\\**Project Address:\\**')[1].split('\n')[0] : '';
            string surname = email.plainTextBody.split('\\**Surname:\\**').size() > 1 ? email.plainTextBody.split('\\**Surname:\\**')[1].split('\n')[0] : '';
            if(string.isEmpty(surname)){
                l.LastName = name.contains(' ') ? name.split(' ')[1]: 'ULN';
                l.FirstName = name.split(' ')[0] ;
            }else{
                l.LastName = surname;
                l.FirstName = name;
            }
            string email1 = email.plainTextBody.split('\\**Email:\\**')[1].split('\n')[0];
            email1 = email1.contains('mailto:') ? email1.split('mailto:')[1]: email1;
            l.Email = email1;
            l.MobilePhone = email.plainTextBody.split('\\**Phone:\\**')[1].split('\n')[0];
            l.Additional_Info__c = email.subject + '\nProject ID -->'+ProjectId +  '\nProject Name -->'+ProjectName + '\nmessageId -->'+email.messageId;
            l.Additional_Info__c = l.Additional_Info__c.length() > 255 ?  l.Additional_Info__c.substring(0,254) : l.Additional_Info__c;
            l.Web_Source__c = 'VCPP-SWE';
            l.LeadSource = 'REA';
            l.RecordTypeID = RecordTypeID;
            l.Background_information__c = email.plainTextBody.split('\\**About me:\\**')[1];
            Database.DMLOptions leadAssignmentRuleOptions = new Database.DMLOptions();
            leadAssignmentRuleOptions.assignmentRuleHeader.useDefaultRule = true;
            // leadAssignmentRuleOptions.assignmentRuleHeader.assignmentRuleID  = '';
            l.setOptions(leadAssignmentRuleOptions);
            insert l;
        }catch(exception e){
            logMsgUtility.logMessage(e,'InboundEmailHandler','handleInboundEmail','handleInboundEmail',new Map<string,object>{'emailbody' => email.plainTextBody});
        }        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        return result;
    }
}