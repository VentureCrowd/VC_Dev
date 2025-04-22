({
	onbuttonClick : function(component, event, helper) {
		var scrollOptions = {
            left: 0,
            top: 0,
            behavior: 'smooth'
        };
    	window.scrollTo(scrollOptions);
	},
      onClick : function(component, event, helper) {
       //document.getElementById('my-portfolio').classList.remove('active-anchor');
       //document.getElementById('profile').classList.remove('active-anchor');
       //document.getElementById('my-entities').classList.remove('active-anchor');
       var iden = event.target.id;
       if(iden == 'profile'){
           iden = iden+'/'+$A.get("$SObjectType.CurrentUser.Id");
       }
       //document.getElementById(event.target.id).classList.add('active-anchor'); 
       var urlEvent = $A.get("e.force:navigateToURL");
       if( iden == 'my-portfolio'){
           urlEvent.setParams({
          	"url": '/'
        	});
       } else {
        urlEvent.setParams({
          "url": '/'+iden
        });
       }
        urlEvent.fire();
  },
  doneRendering: function(cmp, event, helper) {
      //console.log('Done rendering');
      document.getElementById('my-portfolio').classList.remove('active-anchor');
      document.getElementById('profile').classList.remove('active-anchor');
      document.getElementById('my-entities').classList.remove('active-anchor');
      //console.log(window.location.href);
      var isProf = false;
      ['my-portfolio','profile','my-entities'].forEach(function(item){
          if(window.location.href.toString().includes(item)){
              isProf = true;
             document.getElementById(item).classList.add('active-anchor'); 
          }
      });
      if(window.location.href.toString() == "https://www.venturecrowd.com.au/portal/s/" || !isProf){
          document.getElementById('my-portfolio').classList.add('active-anchor'); 
      }
  },
    onHover : function(cmp,event,helper){
        var targetId = event.target.id;
        document.getElementById('my-portfolio').classList.remove('active-anchor-hover');
      document.getElementById('profile').classList.remove('active-anchor-hover');
      document.getElementById('my-entities').classList.remove('active-anchor-hover');
         ['my-portfolio','profile','my-entities'].forEach(function(item){
          if(targetId.includes(item)){
             document.getElementById(item).classList.add('active-anchor-hover'); 
          }
      });
    },
    onHoverOut : function(cmp,event,helper){
        document.getElementById('my-portfolio').classList.remove('active-anchor-hover');
      document.getElementById('profile').classList.remove('active-anchor-hover');
      document.getElementById('my-entities').classList.remove('active-anchor-hover');
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