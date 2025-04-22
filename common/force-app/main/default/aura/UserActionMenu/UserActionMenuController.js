({
	doInit : function(cmp, event, helper) {
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
						 console.log("Error message: " + 
								  errors[0].message);
					 }
				 } else {
					 console.log("Unknown error");
				 }
			 }
		 });
	
		 $A.enqueueAction(action);
	},
     /*Action on the selected option Desktop*/
    onaction:function(component, event, helper){
    console.log("showing menu");
        var a = event.getSource();
		var iden = a.getLocalId();
   
      console.log("Id= ",iden);
        console.log("v.usedInVF=",component.get("v.usedInVF"));
        if(component.get("v.usedInVF")){
            console.log("notifying vf");
           var vfMethod=component.get("v.vfpageMethod");
        // Calling Vf page method
        vfMethod(iden,function()
                           {
                             
                             

                           }); 
        }
        else{
         var urlEvent = $A.get("e.force:navigateToURL");
         console.log('This is a URLEvent Else condition===>'+urlEvent);
         console.log('This is an Clicked value===>'+iden);
       if(iden == 'profile'){
           iden = iden+'/'+$A.get("$SObjectType.CurrentUser.Id");
            urlEvent.setParams({
             
          "url": '/portal/'+iden
             
        });
       }
      else if( iden == 'my-portfolio'){
           urlEvent.setParams({
          	"url": '/portal/portfolio/'
              
        	});
       } else if(iden =="my-entities") {
        urlEvent.setParams({
          "url": '/portal/'+iden
            
        });
       }else{
           window.location.replace("https://"+window.location.hostname+"/secur/logout.jsp?retURL=/s/portal/");
       }
        urlEvent.fire();
        }
},
    handleSetActiveSectionC:function(component, event, helper){
    
		},
     navigate : function(component, event, helper) {
        //Find the text value of the component with aura:id set to "address"
        component.set('v.showDropDown',false);
        console.log("clicked....");
        var url =event.target.dataset.url;
        console.log("The url is created", url);
        if(url=='logout'){
            window.location.replace("https://"+window.location.hostname+"/portal/secur/logout.jsp?retURL=/s/login");
        }
        else  if(component.get("v.usedInVF")){
            console.log("notifying in mobile vf");
            var vfMethod=component.get("v.vfpageMethod");
            // Calling Vf page method
            vfMethod(url,function() {}); 
        }
            else{
                console.log("The url is partial URL Investor Portal", url);
                helper.navigateToPartialUrl(url);
                
            }
        
        
    }
    
    
})