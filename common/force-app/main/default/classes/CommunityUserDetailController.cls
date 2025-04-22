public without sharing class CommunityUserDetailController {
	// *******************   Community user detail *************** 
	@AuraEnabled(cacheable=true)
	public static List<User> getCurrentUser(){
        List<User> users=new List<User>();
        if(UserInfo.getUserType()!='Guest'){
            users=  [SELECT Id, Name, profile.Name,SmallPhotourl,FullPhotoUrl FROM User WHERE Id =: Userinfo.getUserId()];   
        }
        return users;
	
   }
   @AuraEnabled
   public static Map<string,List<navheader>> getheaders(){
        Map<string,List<navheader>> retMap = new Map<string,List<navheader>>();
        for(Site_Nav_Bar__c snv : [SELECT Id, Sub_Header__c,  Display_Order__c, Display_Name__c, Display_URL__c, Active__c FROM Site_Nav_Bar__c WHERE Active__c = TRUE ORDER BY Sub_Header__c,Display_Order__c ASC]){
            if(!retMap.keyset().contains(snv.Sub_Header__c))
            retMap.put(snv.Sub_Header__c, new List<navheader>());
            retMap.get(snv.Sub_Header__c).add(new navheader(snv));
        }
        return retMap;
   }
   public class navheader{
       @AuraEnabled public string displayName {get;set;}
       @AuraEnabled public string displayUrl {get;set;}
       public navheader(Site_Nav_Bar__c sitenavbar){
           if(Site.getSiteType() == 'ChatterNetworkPicasso'){
                displayName = sitenavbar.Display_Name__c;
        		displayUrl = sitenavbar.Display_URL__c;
            }else{
                displayName = sitenavbar.Display_Name__c;
        		displayUrl = System.Label.Community_URL + sitenavbar.Display_URL__c;
            }
        
       }
   }
}