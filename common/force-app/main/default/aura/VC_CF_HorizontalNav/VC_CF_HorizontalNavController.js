({
   onClick : function(component, event, helper) {
       var id = event.target.dataset.menuItemId;
       if (id) {
           component.getSuper().navigate(id);
        }
  },
    
   /*************Intilializing component with user details*******************/

   doInit:function(cmp, event, helper) {
    // create a one-time use instance of the serverEcho action
     // in the server-side controller
     var action = cmp.get("c.getCurrentUser");
    
     action.setCallback(this, function(response) {
         var state = response.getState();
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
    
    handleClickLogout:function(cmp,event,helper){
        window.location.replace("https://"+window.location.hostname+"/portal/secur/logout.jsp?retURL=/s/login");
    }
})