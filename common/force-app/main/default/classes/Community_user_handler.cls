public class Community_user_handler {

    @AuraEnabled
	public static User getCurrentUser(){
	User usr = [SELECT Id, Name, profile.Name FROM User WHERE Id =: Userinfo.getUserId()];

	return usr;
}
}