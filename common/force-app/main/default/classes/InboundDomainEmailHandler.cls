global with sharing class InboundDomainEmailHandler  implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        try{
            string RecordTypeID = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('VCPP').getRecordTypeId();
            Lead l = new Lead();
            string name = email.plainTextBody.split('\n *>* *\\*From:\\*')[1].split('\n')[0].trim();
            l.LastName = name.contains(' ') ? name.split(' ')[1]: 'ULN';
            l.FirstName = name.split(' ')[0] ;
            string email1 = email.plainTextBody.split('\\**Email:\\**')[1].split('\n')[0];
            email1 = email1.contains('mailto:') ? email1.split('mailto:')[1]: email1;
            l.Email = email1;
            string projectinfo = email.plainTextBody.split('View the details of the project at').size() > 1 ? email.plainTextBody.split('View the details of the project at')[1].split('\n')[0] : '';
            string propertyinfo = email.plainTextBody.split('View the details of the property at').size() > 1 ? email.plainTextBody.split('View the details of the property at')[1].split('\n')[0] : '';
            string info = string.isempty(projectinfo) ? propertyinfo : projectinfo;
            l.MobilePhone = email.plainTextBody.split('\\**Phone:\\**')[1].split('\n')[0];
            l.Additional_Info__c = email.subject + '\nprojectinfo -->'+info + '\nmessageId -->'+email.messageId;
            l.Additional_Info__c = l.Additional_Info__c.length() > 255 ?  l.Additional_Info__c.substring(0,254) : l.Additional_Info__c;
            l.Web_Source__c = 'VCPP-SWE';
            l.LeadSource = 'Domain';
            l.RecordTypeID = RecordTypeID;
            l.Background_information__c = email.plainTextBody.split('\\*Message:\\*')[1].split('\\* Security Policy \\*')[0];
            Database.DMLOptions leadAssignmentRuleOptions = new Database.DMLOptions();
            leadAssignmentRuleOptions.assignmentRuleHeader.useDefaultRule = true;
            // leadAssignmentRuleOptions.assignmentRuleHeader.assignmentRuleID  = '';
            l.setOptions(leadAssignmentRuleOptions);
            insert l;
        }catch(exception e){
            logMsgUtility.logMessage(e,'InboundDomainEmailHandler','handleInboundEmail','handleInboundEmail',new Map<string,object>{'emailbody' => email.plainTextBody});
        }        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        return result;
    }
}