/*********************************************************************************************************************************************
Author		 :	 Prakash Borade
Description	 :   This class is specifically created to manage my companies.
History      :   -
Test Class   :   MyCompaniesControllerTest.cls
----------------------------------------------------------------------------------------------------------------------------------------------
Version      Date                 Author               Details
1            06/21/2023           Prakash Borade       Initial Development
2            12/02/2024           Prakash Borade       Commented code of creating AccountContactRelation
**********************************************************************************************************************************************/

public without sharing class MyCompaniesController {

    /*
        createNewCompany - Method is used to create new company record which created new account record with record type Ventures Company Account.
        Additionaly this method create AccountContactRelation record.
    */
    @AuraEnabled
    public static string createNewCompany(Map<string,object> datamap){
        try{
            Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Ventures Company Account').getRecordTypeId();
            User currentuser = [SELECT Id,ContactId,Contact.Account.OwnerId,AccountId FROM User WHERE Id =:Userinfo.getuserId()];
            User owner = [SELECT Id FROM USER WHERE Name = 'The VentureCrowd Team'];
            if(owner == NULL ){
                owner = [SELECT ID,Name FROM User WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE Group.name='CM') AND IsActive = TRUE LIMIT 1];
            }
            Account a = new Account();
            a.RecordTypeId = devRecordTypeId;
            a.Related_Person_Account__c = currentuser.AccountId;
            for(string s : datamap.keyset()){
                system.debug(s);
                a.put(s,datamap.get(s));
            }
            a.Account_Created_via_Portal__c = true;
            a.ownerId = owner.Id;
            insert a;            
            // if(currentuser.ContactId <> NULL){
            //     AccountContactRelation acr = new AccountContactRelation();
            //     acr.AccountId = a.Id;
            //     acr.ContactId = currentuser.ContactId;
            //     insert acr;
            // }
            return 'Success';
        }catch(exception e){
            return e.getMessage();
        }
    }

    @AuraEnabled
    public static string editCompany(Map<string,object> datamap){
        try{
            Account company = new Account();
            for(string s : datamap.keyset()){
                company.put(s,datamap.get(s));
            }
            update company;            
            return 'Success';
        }catch(exception e){
            return e.getMessage();
        }
    }

    /*
        getMyCompanies - Method is used to get all companies associated  with current user (Current logged in user on commiunity site)
    */
    @AuraEnabled
    public static List<Account> getMyCompanies(Id loggedInUserId) {


        try {
            User currentuser = [SELECT Id,AccountId FROM User WHERE Id =:loggedInUserId];
            List<Account> lstCompanies = [Select Id, Name,Sector__c,Website,ACN__c,(SELECT Id,EOI_Status__c From EOI_s__r) From Account  Where RecordType.DeveloperName = 'Ventures_Company_Account' and Related_Person_Account__c=:currentuser.AccountId];
            if(!lstCompanies.isEmpty() && lstCompanies.size() >0) { 
                return lstCompanies;
            } else { 
                return null;
            }
        }catch (Exception ex) {
            throw new AuraHandledException('An error occurred in get companies. Please contact your administrator.');
        } 
    }

    /**
     * Adds or updates a team member record based on the provided data map and uploads a file associated with the team member.
     * parameter - datamap A map containing the data for the team member and file upload.
     * @parameter - String A message indicating the success or failure of the operation.
     */
    @AuraEnabled
    public static string addUpdateTeamMember(Map<string,object> datamap){
        String base64 = '';
        String filename=  '';
        String recordId ='';
        try{
            EOI_team_and_advisors__c teamMember = new EOI_team_and_advisors__c();
            // Extract base64 content and filename from the datamap.
            for(string s : datamap.keyset()){
                if(s == 'base64'){
                    base64 = datamap.get(s).toString();
                }else if(s=='filename'){
                    filename= datamap.get(s).toString();
                }
                else{
                    teamMember.put(EoiTeamMemberMap.get(s),datamap.get(s));
                }
            }
            upsert teamMember;
            // Upload the file associated with the team member if filename is not blank.
            if(!String.isBlank(filename)) { 
                uploadFile(base64,filename,teamMember.Id);      
            }
             // Return success message.
            return 'Success';
        }catch(exception e){
             // Return error message if an exception occurs.
            System.debug(e.getMessage());
            return e.getMessage();
        }
    }

    /**
     * Retrieves a list of team members associated with a specific category and EOI (Expression of Interest) record.
     * parameter category The category of team members to retrieve.
     * parameter eoiId The Id of the EOI record to retrieve team members for.
     */
    @AuraEnabled
    public static String getTeamMembers(String category, Id eoiId) {	
        // Query for EOI_team_and_advisors__c records related to the specified category and EOI record.
        List<EOI_team_and_advisors__c> eoimemberLst = [Select Id,Name, Category__c, Member_Role__c, Team_Member_Description__c,Team_Related_EOI__c, Team_member_Linkedin__c, Order__c From EOI_team_and_advisors__c Where Category__c=:category and Team_Related_EOI__c=:eoiId ORDER BY Order__c ASC];
        
        List<EoiTeamMember> retList = new List<EoiTeamMember>();

        for(EOI_team_and_advisors__c teamMember : eoimemberLst){
            EoiTeamMember tempTeamMember = new EoiTeamMember();

            tempTeamMember.Id = (Id)teamMember.get('Id');
            tempTeamMember.Name = (String)teamMember.get('Name');
            tempTeamMember.Category = (String)teamMember.get('Category__c');
            tempTeamMember.Member_Role = (String)teamMember.get('Member_Role__c');
            tempTeamMember.Team_Member_Description = (String)teamMember.get('Team_Member_Description__c');
            tempTeamMember.Team_Related_EOI = (Id)teamMember.get('Team_Related_EOI__c');
            tempTeamMember.Team_member_Linkedin = (String)teamMember.get('Team_member_Linkedin__c');
            tempTeamMember.Order = (String)teamMember.get('Order__c');

            
            String urlLink = getFounderImage((String)teamMember.get('Id'));
            tempTeamMember.urLink = urlLink;
            retList.add(tempTeamMember);
        }
        // Return the list of team members.
        //return eoimemberLst;
        return Json.serialize(retList);
    }
    
    // get contentDocLinks to retrieve the image URL connected to the team member
    public static string getFounderImage(String eoiTeamAdvisorId){
        List<ContentDocumentLink> cdLink = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:eoiTeamAdvisorId];
        if(cdLink.size()>0){
            Id cdId = cdLink[0].ContentDocumentId;
            List<ContentDocument> cd = [SELECT LatestPublishedVersionId FROM ContentDocument WHERE Id=:cdId];
            if(cd.size() > 0){
                Id cvId = cd[0].LatestPublishedVersionId;
                String urlLink = URL.getOrgDomainURL().toExternalForm()+'/sfc/servlet.shepherd/version/download/'+cvId;
                return urlLink;
            }
        }
        return '';
    }

    // //? New method to get the founders - Speak to prakash about this
    @AuraEnabled
    public static void upsertFounderImage(Id eoiId) {  
        List<EOI_team_and_advisors__c> founderList = [
            SELECT Id, Name, Category__c, Member_Role__c, Team_Member_Description__c, Team_Related_EOI__c, Team_member_Linkedin__c, Founder_Picture__c
            FROM EOI_team_and_advisors__c 
            WHERE Category__c = 'Founder' AND Team_Related_EOI__c = :eoiId 
            ORDER BY Id
        ];
        
        // ! Test later with new version
        for (EOI_team_and_advisors__c founder : founderList) {
            List<ContentDownloadURL.FileDownloadUrl> fileDownloadUrls = ContentDownloadURL.getSalesforceFilesDownloadUrls(founder.Id);
            if (!fileDownloadUrls.isEmpty()) {
                // Assuming you want to set the first URL found for the founder's picture
                founder.Founder_Picture__c = fileDownloadUrls[0].contentDownloadURL;
                update founder; // Make sure to persist the change

            }
        }
        
        // return founderList;
    }
    

    /**
     * Uploads a file to Salesforce as a ContentVersion and associates it with a record.
     * parameter - base64 The base64-encoded file content.
     * parameter - filename The name of the file.
     * parameter - recordId The Id of the record to associate the file with.
     * return String The Id of the ContentDocumentLink created or updated.
     */
    @AuraEnabled
    public static String uploadFile(String base64, String filename, String recordId) {
        Set < Id > reordIdSet = new Set < Id > { recordId };
        List < ContentDocumentLink > contentDocumentLinkList = new List < ContentDocumentLink > ([SELECT Id, ContentDocumentId FROM ContentDocumentLink where LinkedEntityId IN: reordIdSet and ContentDocument.Title =: filename]);

        // Create a new ContentVersion instance and set its properties.
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename + '.png';
        cv.ContentDocumentId = contentDocumentLinkList != NULL && !contentDocumentLinkList.isEmpty() ? contentDocumentLinkList[0].ContentDocumentId : NULL;
        insert cv;
        if (!(contentDocumentLinkList != NULL && !contentDocumentLinkList.isEmpty())) {
            // If no ContentDocumentLink exists, create a new one and insert it.
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
            cdl.LinkedEntityId = recordId;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';

            insert cdl;
            // Return the Id of the newly created ContentDocumentLink.
            return cdl.Id;
        }
         // If a ContentDocumentLink already exists, return its Id.
        return contentDocumentLinkList[0].Id;
    }
    
    /**
    * Returns a map of picklist field values and their corresponding labels for the 'EOI_Status__c' field on the 'EOI__c' object.
    * return Map<String, String> A map containing picklist field values as keys and their labels as values.
    */
    @AuraEnabled(cacheable=true)
    public static Map<String,string> getPicklistvalues(){
        Map<String,string> pickliastValueToLabelMap=new Map<String,string>();

        // Iterate through the picklist values and populate the map with active picklist values and labels.
        Schema.DescribeFieldResult fieldDescResult = EOI__c.EOI_Status__c.getDescribe();
        for(schema.PicklistEntry picklistValueObj: fieldDescResult.getPicklistValues()){
            if(picklistValueObj.isActive()){
                pickliastValueToLabelMap.put(picklistValueObj.getValue(),picklistValueObj.getLabel());
            }
        }
        // Return the map containing picklist values and labels.
       return pickliastValueToLabelMap;
    }

    @AuraEnabled
    public static string createEoiLead(Map<string,object> datamap){
        try{
            Id venturesRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Ventures').getRecordTypeId();
            Lead a = new Lead();
            a.RecordTypeId = venturesRecordTypeId;
            a.LeadSource = 'Organic';
            for(string s : datamap.keyset()){
                system.debug(s);
                a.put(s,datamap.get(s));
            }
            insert a;            
            return 'Success';
        }catch(exception e){
            logMsgUtility.logMessage(e,'MyCompaniesController','createEoiLead','createEoiLead',datamap);
            return e.getMessage();
        }
    }
    
    // Map structure - used to convert EoiTeamMember structure to internal form
    private static Map<String,String> EoiTeamMemberMap = new Map<String,String> {
        	'Id' => 'Id',
            'Name' => 'Name',
            'Category' => 'Category__c',
            'Member_Role' => 'Member_Role__c',
            'Team_Member_Description' => 'Team_Member_Description__c',
            'Team_Related_EOI' => 'Team_Related_EOI__c',
            'Team_member_Linkedin' => 'Team_member_Linkedin__c',
            'Order' => 'Order__c'
            };
    
    // class structure - used in getTeamMembers as the return structure
    private class EoiTeamMember{
        Id Id;
        String Name;
        String Category;
        String Member_Role;
        String Team_Member_Description;
        Id Team_Related_EOI;
        String Team_member_Linkedin;
        String Order;
        String urLink;

    }
    

  
}