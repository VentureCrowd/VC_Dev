({
	doInit : function(component, event, helper) {
        if(window.screen.width < 490 || $A.get("$Browser.isPhone")){
            component.set('v.isMobile',true);
        }
        //document.getElementsByName('head').append('<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0">');
        if(window.location.href == 'https://www.venturecrowd.com.au/portal/s/'){
            
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
              "url": "/my-portfolio"
            });
            urlEvent.fire();
        }
	}
})