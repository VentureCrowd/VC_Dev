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
      if(window.location.href.toString() == "https://cm-vc-internal.cs74.force.com/portal/s/" || !isProf){
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
    console.log('In the do init method');
     action.setCallback(this, function(response) {
         var state = response.getState();
         if (state === "SUCCESS") {
             // Alert the user with the value returned 
             // from the server
             console.log("This is a Footer " );
             
             let users=response.getReturnValue();
             console.log('USers are:: '+users);
             if(users.length>0){
               cmp.set("v.currentUser",users[0]); 
               cmp.set("v.isUserAvailable",true);  
                 console.log("current user=",cmp.get("v.currentUser"))
             }
             else
             {
                 //added to make My Account options visible when user is not loggedIn
                // cmp.set("v.currentUser",users[0]);
                 // cmp.set("v.isUserAvailable",false); 
                  console.log('In else ='+users);
             }
         }
         else if (state === "INCOMPLETE") {
             // do something
             //added to make My Account options visible when user is not loggedIn
                 // cmp.set("v.isUserAvailable",false); 
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
    },
    
   /*************Set the Navigation URL here*******************/
   navigate : function(component, event, helper) {
    //Find the text value of the component with aura:id set to "address"
    var address =event.target.dataset.url;
   console.log("navigating to address",address);
     var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
      "url": address,
      "isredirect" :false
    });
    urlEvent.fire();
  },

    /*************Set the Navigation Public webiste URL here*******************/
   navigatetopublic : function(component, event, helper) {
    //Find the text value of the component with aura:id set to "address"
    var address =event.target.dataset.url;
   console.log("navigating to address",address);
     var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
        "url":"https://"+window.location.hostname+"/s"+address,
      "isredirect" :false
    });
    urlEvent.fire();
  }
    
})