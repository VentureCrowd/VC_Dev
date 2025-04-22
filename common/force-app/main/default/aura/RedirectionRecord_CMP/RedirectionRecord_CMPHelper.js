({
    gotoURL : function (component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": '/'+component.get("v.recordId")
        });
        setTimeout(function(){ 
            urlEvent.fire();
        }, 1000);
    }
})