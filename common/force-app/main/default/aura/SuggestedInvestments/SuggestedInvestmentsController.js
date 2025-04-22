({
	doInit : function(component, event, helper) {
        if(window.screen.width < 490 || $A.get("$Browser.isPhone")){
            component.set('v.isMobile',true);
        }
		var action = component.get("c.getRecentInvestments");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //console.log('Investment success');
                console.log(JSON.parse(response.getReturnValue()));
                component.set("v.successfulDealList",JSON.parse(response.getReturnValue()));
            } else if (state == "ERROR"){
                //console.log('Fetching Investment failure');
            }
        });
        $A.enqueueAction(action);
	},
    handleClickInvestMents:function(cmp,event,helper){
        window.location.href = 'https://www.venturecrowd.com.au/invest/';
    },
    onSuggestedPClick:function (cmp,event,helper){
                window.location.href = cmp.get("v.successfulDealList")[event.currentTarget.id]['Deal_Page_Link__c'];
        /*
        console.log(event);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          	"url": '/detail/'+event.currentTarget.id
        });
        urlEvent.fire();*/
	}
})