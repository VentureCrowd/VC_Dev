({
	doInit : function(component, event, helper) {
        
	},
    confirmConversion : function(component, event, helper) {
        
        $A.get("e.force:closeQuickAction").fire();
        
        var action = component.get("c.convertToPerson");
        action.setParams({
            accId : component.get("v.recordId")
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                
                console.log(state);
                $A.get('e.force:refreshView').fire();
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "SUCCESS",
                    "type": "Success",
                    "message": "The Account is converted to Person Account."
                });
                toastEvent.fire();
            }
            else{
                console.log(state);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "type": "Error",
                    "message": "The Account can not be converted to Person Account."
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
        
        
    }
})