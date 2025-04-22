/*********************************************************************************************************************************************
Author		 :	 Prakash Borade
Description	 :   This class is specifically created to manage EOI.
History      :   -
Test Class   :   MyEOIControllerTest.cls
Uses         :   Till the date 6/Feb/2024 this class is used by following LWC- ManageEOI, EOI_Preview, CreateUpdateEOi, AddEditAdvisor, AddEditLeadInvestor, AddEditMediaLinks, AddEditWiderTeam
----------------------------------------------------------------------------------------------------------------------------------------------
Version      Date                 Author               Details
1            01/01/2024           Prakash Borade       Initial Development
**********************************************************************************************************************************************/
public without sharing class MyEOIController {
    /*
        updateEoi - Method is used updated eoi record
    */
    @AuraEnabled
    public static string updateEoi(Map<string, object> datamap, Id eoiId) {
        try {
            EOI__c eoi = new EOI__c();
            eoi.Id = eoiId;
            for (string s : datamap.keyset()) {
                eoi.put(s, datamap.get(s));
            }
            update eoi;
            return 'Success';
        } catch (exception e) {
            return e.getMessage();
        }
    }

    // Base method to get EOI details (Used in LWC - ManageEoi, EOI_Preview, CreateUpdateEoi), this method also return Documents(Supporting images , logo and banner) linked with EOI.
    // KEN PREVUP-53 added the Minimum_Investment_amount__c field to the method
    @AuraEnabled(cacheable=true)
    public static EOI__c getEoiDetails(Id eoiId) {
        try {
            EOI__c eoiRecord = [
                SELECT Account__r.Name,Account__r.Id, Id, Name,Minimum_Investment_amount__c, EOI_Title__c, One_liner_about_business__c, Offer_Overview__c, Problem_or_opportunity__c, Youtube_Video_Link__c, EOI_Subtitle__c, Solution__c, Differentiation__c, Intellectual_Property__c, Total_addressable_market__c, Progress__c, Growth_plan__c, EOI_Published_Date__c, URL_Files_Img__c, Instagram_link__c, Youtube_link__c, Facebook_link__c, Linkedin_link__c, Twitter_X_link__c, Company_Website_Link__c, Website_link__c, Company_Stage__c, Target_Raise_Amount__c, Raise_Contact_email__c, Leads_Expressed_Interest__c, Value_of_investment_interest__c, EOI_Progress__c, End_Date__c, Published_EOI_URL__c, EOI_Status__c, Planned_used_of_funds__c, (SELECT ContentDocument.Title, ContentDocument.LatestPublishedVersion.VersionDataUrl FROM ContentDocumentLinks),
                Is_Fund__c ,Fund_Structure__c, Investment_Strategy__c, Tax_Concessions__c, Portfolio_Size__c, Investment_Objective__c, Investment_Period__c, Fund_Term__c, First_Close_Amount__c
                FROM EOI__c
                WHERE Id = :eoiId
            ];
            return eoiRecord;
        } catch (Exception ex) {
            // throw error on bad request
            throw new AuraHandledException('An error occurred in geting EOI details. Please contact your administrator.');
        }
    }

    /*
        addUpdateTeamMember - used to add/update team member in EOI - founder , advisor etc.
    */
    @AuraEnabled
    public static string addUpdateTeamMember(Map<string, object> datamap) {
        try {
            // we get team member data from lwc in datamap and if Id is present then we update the existing record else we create a new record for team member.
            EOI_team_and_advisors__c teamMember = new EOI_team_and_advisors__c();
            for (string s : datamap.keyset()) {
                teamMember.put(s, datamap.get(s));
            }
            upsert teamMember;
            return 'Success';
        } catch (exception e) {
            return e.getMessage();
        }
    }

    /*
        getTeamMembers - used to fetch all team members list.
    */
    @AuraEnabled(cacheable=true)
    public static List<EOI_team_and_advisors__c> getTeamMembers(String category, Id eoiId) {
        try {
            List<EOI_team_and_advisors__c> lstTeamMember = [SELECT Id, Name, Category__c, Member_Role__c, Founder_Picture__c, Team_Member_Description__c, Team_Related_EOI__c, Team_member_Linkedin__c, Order__c FROM EOI_team_and_advisors__c WHERE Category__c = :category AND Team_Related_EOI__c = :eoiId];

            if (!lstTeamMember.isEmpty() && lstTeamMember.size() > 0) {
                // return list of all team member record
                return lstTeamMember;
            } else {
                // return null when no team member
                return null;
            }
        } catch (Exception ex) {
            throw new AuraHandledException('An error occurred in getTeamMember. Please contact your administrator.');
        }
    }

    /*
        addUpdateLeadInvestor - create update entry on EOI_Lead_Investor__c object.
    */
    @AuraEnabled
    public static string addUpdateLeadInvestor(Map<string, object> datamap) {
        try {
            EOI_Lead_Investor__c leadInvestor = new EOI_Lead_Investor__c();
            for (string s : datamap.keyset()) {
                leadInvestor.put(s, datamap.get(s));
            }
            upsert leadInvestor;
            return 'Success';
        } catch (exception e) {
            return e.getMessage();
        }
    }

    /*
        getLeadInvestor - get list of all availabel EOI_Lead_Investor__c.
    */
    @AuraEnabled(cacheable=true)
    public static List<EOI_Lead_Investor__c> getLeadInvestor(Id eoiId) {
        try {
            List<EOI_Lead_Investor__c> lstLeadInvestor = [SELECT Id, Name, Lead_Investor_Amount__c, Related_EOI__c, Lead_Investor_Bio__c FROM EOI_Lead_Investor__c WHERE Related_EOI__c = :eoiId];

            if (!lstLeadInvestor.isEmpty() && lstLeadInvestor.size() > 0) {
                return lstLeadInvestor;
            } else {
                // return null on no lead investor
                return null;
            }
        } catch (Exception ex) {
            throw new AuraHandledException('An error occurred in getLeadInvestor. Please contact your administrator.');
        }
    }

    /*
        addUpdateMediaLinks - create/update record of EOI_Media_Links__c.
    */
    @AuraEnabled
    public static string addUpdateMediaLinks(Map<string, object> datamap) {
        try {
            EOI_Media_Links__c mediaLink = new EOI_Media_Links__c();
            for (string s : datamap.keyset()) {
                mediaLink.put(s, datamap.get(s));
            }
            upsert mediaLink;
            return 'Success';
        } catch (exception e) {
            return e.getMessage();
        }
    }

    /*
        getMediaLinks - get list of all EOI_Media_Links__c.
        UPDATED ON 12/11/2024 to include Min Investment amt
    */
    @AuraEnabled(cacheable=true)
    public static List<EOI_Media_Links__c> getMediaLinks(Id eoiId) {
        try {
            List<EOI_Media_Links__c> lstMediaLinks = [SELECT Id, Name, Media_URL__c, EOI__c FROM EOI_Media_Links__c WHERE EOI__c = :eoiId];

            if (!lstMediaLinks.isEmpty() && lstMediaLinks.size() > 0) {
                return lstMediaLinks;
            } else {
                // return null if no media links found
                return null;
            }
        } catch (Exception ex) {
            throw new AuraHandledException('An error occurred in getMediaLinks. Please contact your administrator.');
        }
    }

    // Here getting leads related to EOI, showing this on EOI management page
    @AuraEnabled
    public static List<Lead> getInterestesLeads(Id eoiId) {
        return [SELECT Name, Email, MobilePhone, Investment_Range__c, Investment_Amount__c,Status, CreatedDate, Investment_Amount_Currency__c, Min_Investment__c FROM Lead WHERE Related_EOI__c = :eoiId];
    }

}