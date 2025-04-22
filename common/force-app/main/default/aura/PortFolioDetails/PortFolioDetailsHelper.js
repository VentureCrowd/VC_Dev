({
	doInit:function(cmp, event, helper) {
        helper.greetingcalculation(cmp, event, helper);
        window.setInterval( $A.getCallback(function(){ helper.greetingcalculation(cmp, event, helper) }),60000);
    // create a one-time use instance of the serverEcho action
     // in the server-side controller
     var action = cmp.get("c.initlializeMyportfolio");
    
     action.setCallback(this, function(response) {
         var state = response.getState();
         if (state === "SUCCESS") {
             // Alert the user with the value returned 
             // from the server
             console.log("From server: " , response.getReturnValue());
             
             let protfoliodetail=response.getReturnValue();
             if(protfoliodetail.currentUser){
               cmp.set("v.currentUser",protfoliodetail.currentUser); 
               cmp.set("v.isUserAvailable",true);  
                 console.log("current user=",cmp.get("v.currentUser"))
             }
             console.log('currentAccount=',protfoliodetail.currentAccount);
             if(protfoliodetail.currentAccount){
				cmp.set("v.currentAccount",protfoliodetail.currentAccount); 
				cmp.set("v.investments",protfoliodetail.currentAccount.Investments__r);                 
             }
             
             
         }
         else if (state === "INCOMPLETE") {
             // do something
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
    greetingcalculation:function(cmp, event, helper) {
  	let tdate=new Date();
    let currhour=tdate.getHours();
       let message="Good Morning ";
       if(currhour<12){
           message="Good Morning "; 
       }else if(currhour<18){
             message="Good Afternoon ";  
          }else{
               message="Good Evening "; 
              }
        cmp.set("v.greetingMsg",message);
 }
})