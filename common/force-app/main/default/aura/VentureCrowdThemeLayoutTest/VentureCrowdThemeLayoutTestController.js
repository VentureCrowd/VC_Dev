({
	doInit : function(component, event, helper) {
    helper.loadcurrentUser(component, event, helper);
    // Ven - 127 4/11
        if(window.screen.width < 490 || $A.get("$Browser.isPhone" || $A.get("$Browser.isTablet") )){
            component.set('v.isMobile',true);
        }
        //document.getElementsByName('head').append('<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0">');
        /*if(window.location.href == 'https://cm-vc-internal.cs74.force.com/InvestorLogin/s/'){
            
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
              "url": "/my-portfolio"
            });
            urlEvent.fire();
        }*/
	}
})