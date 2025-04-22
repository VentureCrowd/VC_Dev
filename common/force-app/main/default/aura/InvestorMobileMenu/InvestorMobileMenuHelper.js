({
	navigateToPartialUrl:function(partialurl){
	   var urlEvent = $A.get("e.force:navigateToURL");
	   urlEvent.setParams({
		   
		   "url": partialurl,
		   "isredirect" :false
		   
	   });
	   urlEvent.fire();
   },
   getUserInfo : function(cmp, event, helper) {
		// in the server-side controller
		var action = cmp.get("c.getCurrentUser");
	   cmp.set("v.showspinner",true);
		action.setCallback(this, function(response) {
			var state = response.getState();
			cmp.set("v.showspinner",false);
			if (state === "SUCCESS") {
			   // Alert the user with the value returned 
			   // from the server
			   console.log("From server: " , response.getReturnValue());
			   
			   let users=response.getReturnValue();
			   if(users.length>0){
				   cmp.set("v.currentUser",users[0]); 
				   cmp.set("v.isUserAvailable",true); 
				   let menus=[ 
				   {id: 0, label: "Invest", active: false,url:'/invest'},
				   {id: 1, label: "Learn", active: false, url:'/investor-education'},
				   {id: 2, label: "Raise", active: false, url:'/raise'},
				   {id: 3, label: "Property", active: false, url:'/property'},
				   {id: 4, label: "About", active: false, url:'/about'},
				   {id: 5, label: "News", active: false, url:'/blog'},
				   // {id: 6, label: "My Portfolio", active: false, url:'/'},
				   // {id: 7, label: "My Profile", active: false, url:'/profile/'+$A.get("$SObjectType.CurrentUser.Id")},
				   // {id: 8, label: "My Entities", active: false, url:'/my-entities'},
				   {id: 6, label: "My Portfolio", active: false, url:'portfolio'},
				   {id: 7, label: "My Profile", active: false, url:'profile'},
				   {id: 8, label: "My Entities", active: false, url:'entities'},
				   {id: 9, label: "Log out", active: false, url:'logout'}];
				   cmp.set("v.menus",menus);
				   console.log("current user=",cmp.get("v.currentUser"))
			   }
		   }
		   else if (state === "INCOMPLETE") {
			   // do something
		   console.log('Not logged in');
		   }
		   else if (state === "ERROR") {
			   var errors = response.getError();
			   if (errors) {
				   if (errors[0] && errors[0].message) {
					   console.log("Error message: " + errors[0].message);
				   }
			   } else {
				   console.log("Unknown error");
			   }
		   }
		});
   
	   $A.enqueueAction(action);
   }
})