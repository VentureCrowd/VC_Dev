({
    onHamburgerClick:function(component, event, helper){
        console.log('menuItems=',component.get("v.menuItems"));
        component.set('v.showDropDown',!component.get('v.showDropDown'));
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
      var itemActive;
      if(window.location.pathname.toString().includes('my-entities') 
         || window.location.pathname.toString().includes('account')){
          itemActive = 'my-entities';
      } else if(window.location.pathname.toString().includes('profile') 
				|| window.location.pathname.toString().includes('settings')){
          itemActive = 'profile';
      } else{
          itemActive = 'my-portfolio';
      }
      document.getElementById(itemActive).classList.add('active-anchor'); 
      /*let isProf=false;
      //console.log(window.location.href);
      ['my-portfolio','profile','my-entities'].forEach(function(item){
          if(window.location.href.toString().includes(item)){
              isProf = true;
             document.getElementById(item).classList.add('active-anchor'); 
          }
      });
     if(window.location.href.toString() == "https://cm-vc-internal.cs74.force.com/InvestorLogin/s/" || !isProf){
          document.getElementById('my-portfolio').classList.add('active-anchor'); 
      }*/
  },
  /*Submenu code for the component */
  doInit:function(cmp, event, helper){
      let menus=[ {id: 0, label: "Home", active: true},
       {id: 1, label: "Invest", active: false,
       subMenus:[{id: 1, label: "High Growth Property Fund ", active: false},{id: 1, label: "Super High Yield", active: false}]},
      {id: 2, label: "Learn", active: false,subMenus:[{id: 1, label: "What Are Early Stage Securities? ", active: false},{id: 1, label: "Why Include Early Stage Securities?", active: false},{id: 1, label: "How To Choose", active: false}]},
      {id: 3, label: "Raise", active: false},
      {id: 4, label: "Property", active: false,subMenus:[{id: 1, label: "High Growth Property Fund", active: false},{id: 1, label: "Super High Yield", active: false},{id: 1, label: "VC Mortgage Fund", active: false}]},
      {id: 5, label: "About", active: false,subMenus:[{id: 1, label: "About Us", active: false},{id: 1, label: "How It Works", active: false},{id: 1, label: "Syndicates", active: false},{id: 1, label: "Partners", active: false}]},
      {id: 6, label: "News", active: false}];
      cmp.set("v.menus",menus);

  }
})