({
    onClick : function(component, event, helper) {
       //document.getElementById('my-portfolio').classList.remove('active-anchor');
       //document.getElementById('profile').classList.remove('active-anchor');
       //document.getElementById('my-entities').classList.remove('active-anchor');
      let portal='';
      if((window.location.href.indexOf('portal') > -1)){
          portal = '/portal/';
      }
       var iden = event.target.id;
       if(iden == 'profile'){///portal/profile/:recordId
           iden = iden+'/'+$A.get("$SObjectType.CurrentUser.Id");
       }
       //document.getElementById(event.target.id).classList.add('active-anchor'); 
       var urlEvent = $A.get("e.force:navigateToURL");

        if (iden == 'my-portfolio') {
            urlEvent.setParams({
                "url": portal + 'my-portfolio'
            });
        } else if (iden == 'my-companies') {
            urlEvent.setParams({
                "url": portal + 'my-companies'
            });
        } else {
            urlEvent.setParams({
                "url": portal + iden
            });
        }

        urlEvent.fire();
  },
  doneRendering: function(cmp, event, helper) {
        //console.log('Done rendering');
        
        if(document.getElementById('my-portfolio') == null || 
            document.getElementById('profile') == null ||
            document.getElementById('my-entities') == null ||
            document.getElementById('my-companies') == null
            ){
            return;
        }
        
        document.getElementById('my-portfolio').classList.remove('active-anchor');
        document.getElementById('profile').classList.remove('active-anchor');
        document.getElementById('my-entities').classList.remove('active-anchor');
        document.getElementById('my-companies').classList.remove('active-anchor');
        var itemActive;
        if(window.location.pathname.toString().includes('my-entities') 
            || window.location.pathname.toString().includes('account')){
            itemActive = 'my-entities';
        } else if(window.location.pathname.toString().includes('profile') 
                    || window.location.pathname.toString().includes('settings')){
            itemActive = 'profile';
        }  else if(window.location.pathname.toString().includes('my-companies') 
                    || window.location.pathname.toString().includes('account')){
            itemActive = 'my-companies';
        } else{
            itemActive = 'my-portfolio';
        }
        document.getElementById(itemActive).classList.add('active-anchor'); 
        
    },
    onHover : function(cmp,event,helper){
        var targetId = event.target.id;
        document.getElementById('my-portfolio').classList.remove('active-anchor-hover');
      document.getElementById('profile').classList.remove('active-anchor-hover');
      document.getElementById('my-entities').classList.remove('active-anchor-hover');
      // this is dodgy, so we will redo this in LWC but for now...
      document.getElementById('my-companies').classList.remove('active-anchor-hover');
         ['my-portfolio','profile','my-entities','my-companies'].forEach(function(item){
          if(targetId.includes(item)){
             document.getElementById(item).classList.add('active-anchor-hover'); 
          }
      });
    },
    onHoverOut : function(cmp,event,helper){
        document.getElementById('my-portfolio').classList.remove('active-anchor-hover');
      document.getElementById('profile').classList.remove('active-anchor-hover');
      document.getElementById('my-entities').classList.remove('active-anchor-hover');
      document.getElementById('my-companies').classList.remove('active-anchor-hover');
    },
    logout:function(cmp,event,helper){
        console.log("logout ");
       // $A.get("e.force:logout").fire();
       window.open("https://"+window.location.hostname+"/secur/logout.jsp?retURL=/s/login",'_top');
    }
})