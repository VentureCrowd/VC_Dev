({
	doInit : function(component, event, helper) 
    {
        if(component.get("v.displayErrorMessage"))
            helper.showErrorToast(component, event, helper);
	}
})