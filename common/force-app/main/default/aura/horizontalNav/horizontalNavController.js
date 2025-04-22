({
  onClick : function(component, event, helper) {
      var id = event.target.dataset.menuItemId;
      if (id) {
          component.getSuper().navigate(id);
      }
  },
  
  
  
  /*************Intilializing component with user details*******************/
  
  doInit:function(cmp, event, helper) {
      let action = cmp.get("c.getheaders");
      action.setCallback(this, function(response) {
          let state = response.getState();
          if (state === "SUCCESS") {
            cmp.set("v.getInvestdetails",response.getReturnValue()['INVEST']);
            cmp.set("v.getLearndetails",response.getReturnValue()['LEARN']);
            cmp.set("v.getRaisedetails",response.getReturnValue()['RAISE']);
            cmp.set("v.getPropertydetails",response.getReturnValue()['PROPERTY']);
            cmp.set("v.getAboutdetails",response.getReturnValue()['ABOUT']);
            cmp.set("v.getNewsdetails",response.getReturnValue()['NEWS']);
            cmp.set("v.getVenturesdetails",response.getReturnValue()['VENTURES']);
          }else if (state === "ERROR") {
            let errors = response.getError();
            if (errors) {
                if (errors[0] && errors[0].message){
                  console.log("Error message: " +  errors[0].message);
                }
            }else{
                console.log("Unknown error");
            }
          }
      });
      $A.enqueueAction(action);
      // create a one-time use instance of the serverEcho action
      // in the server-side controller
      let menus=[ 
          {id: 0, label: "Invest", active: false,url:'/invest'},
          {id: 1, label: "Learn", active: false, url:'/vc-cf-home/vc-cf-learn'},
          {id: 2, label: "Raise", active: false, url:'/vc-cf-home/vc-cf-raise'},
          {id: 3, label: "Property", active: false, url:'/vc-cf-home/vc-cf-property'},
          {id: 4, label: "About", active: false, url:'/vc-cf-home/vc-cf-about'},
          {id: 5, label: "News", active: false, url:'/vc-cf-home/vc-cf-news'},
          {id: 6, label: "My Portfolio", active: false, url:'/'},
          {id: 7, label: "My Profile", active: false, url:'/profile/'+$A.get("$SObjectType.CurrentUser.Id")},
          {id: 8, label: "My Entities", active: false, url:'/my-entities'},
          {id: 9, label: "Ventures", active: false, url:'/vc-cf-home/vc-cf-ventures'}, ];
          cmp.set("v.menus",menus);
          
          },
          
          handleClickLogout:function(cmp,event,helper){
          window.location.replace("https://"+window.location.hostname+"/portal/secur/logout.jsp?retURL=/s/login");
          },
          
          
          navigate : function(component, event, helper) {
          //Find the text value of the component with aura:id set to "address"
           component.set('v.showDropDown',false);
          var address =event.target.dataset.url;
          helper.navigateToPartialUrl(address);
          /*  console.log("navigating to address",address);
   var urlEvent = $A.get("e.force:navigateToURL");
  urlEvent.setParams({
    "url": address,
    "isredirect" :false
  });
  urlEvent.fire();*/
        },
        /*Action on the selected option Desktop*/
        onaction:function(component, event, helper){
        console.log("showing menu");
        var a = event.getSource();
        var iden = a.getLocalId();
        helper.navigateToPage(iden);
        
        /*  console.log("Id= ",iden);
       var urlEvent = $A.get("e.force:navigateToURL");
     if(iden == 'profile'){
         iden = iden+'/'+$A.get("$SObjectType.CurrentUser.Id");
          urlEvent.setParams({
        "url": '/'+iden
      });
     }
    else if( iden == 'my-portfolio'){
         urlEvent.setParams({
          "url": '/'
        });
     } else if(iden =="my-entities") {
      urlEvent.setParams({
        "url": '/'+iden
      });
     }else{
         window.location.replace("https://"+window.location.hostname+"/portal/secur/logout.jsp?retURL=/s/login");
     }
      urlEvent.fire();
      */
        },
        onHamburgerClick:function(component, event, helper){
        console.log('menuItems=',component.get("v.menuItems"));
        component.set('v.showDropDown',!component.get('v.showDropDown'));
        },
        
        
        handlebreadcrumbNav: function(component, event, helper){
        // let userdataNavigationList=['profile','my-portfolio','my-entities'];
           //var url =event.target.dataset.url; 
        
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