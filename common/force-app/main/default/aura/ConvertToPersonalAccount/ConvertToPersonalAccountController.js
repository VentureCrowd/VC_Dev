({
	convertToPersonAccount : function(component, event, helper) {
        var action = component.get("c.convertToPersonalAccount");
        action.setParams({ 
            contactId : component.get("v.recordId") 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var statusCode = response.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": statusCode
                });
                toastEvent.fire();
                window.location.reload();
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                var toastEvent = $A.get("e.force:showToast");
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": errors[0].message
                        });
                    }
                } else {
                    toastEvent.setParams({
                            "title": "Unknown Error",
                            "message": "Something went wrong.Please Contact your System administrator."
                        });
                }
            }
        });
         $A.enqueueAction(action);
	}
   
})