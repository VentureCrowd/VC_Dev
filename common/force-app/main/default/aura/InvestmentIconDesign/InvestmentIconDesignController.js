({
	retrivePrdFeedbackCategory : function(component, event, helper) {
        component.set('v.showcmp',(component.get('v.recordId').startsWith('a3u')));
        var action = component.get("c.retrivePdtCategory");
         action.setParams({'recordId':component.get("v.recordId")});
        action.setCallback(this,function(data){           
            //component.set('v.category',data.getReturnValue());
            component.set('v.sector',data.getReturnValue());
        });
        $A.enqueueAction(action);
	}  
})