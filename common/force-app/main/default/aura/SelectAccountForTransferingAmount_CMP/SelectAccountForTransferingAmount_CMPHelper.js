({
    showErrorToast : function(component, event, helper, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error',
            message:msg,
            messageTemplate: '',
            duration:' 5000',
            key: 'info_alt',
            type: 'error',
            mode: 'pester'
        });
        toastEvent.fire();
    },
    CreateNewAccountH : function(component, event, helper)
    {
        var oppId = component.get("v.oppId");
        var newAccObj = component.get("v.newAccObj");
        var selectedAccType = component.get("v.selectedAccType");
        var transferAmount = component.get("v.TransferAmount");
        var dateOfApplication = component.get("v.DateOfApplication");
        console.log( '->>>>>> ---- Neext');
        var action = component.get("c.createNewAccounts");
        action.setParams({
            'oppId': oppId,
            'newAccObj': newAccObj,
            'selectedAccType': selectedAccType,
            'transferAmount': transferAmount,
            'dateOfApplication': dateOfApplication,            
        });
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {   
                var retValue = response.getReturnValue();
                if(retValue.indexOf('exception') !== -1){
                    var errMsg = retValue.substring(retValue.indexOf(";") + 1, retValue.lastIndexOf(":") - 1);
                    console.log( '->>>>>> ---- ',errMsg);
					component.set("v.errorNewAcc",errMsg);
                }else{
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": '/'+response.getReturnValue()
                    });
                    setTimeout(function(){ 
                        urlEvent.fire();
                    }, 1000);
                }
                //var storeResponse = response.getReturnValue();
                // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                //component.set("v.listOfSearchRecords", storeResponse);
            }
            
        });
        $A.enqueueAction(action);

    },
    createNewOppH : function(component, event, helper)
    {
        var oppId = component.get("v.oppId");
        var selectedAccObj = component.get("v.selectedAccObj");
        var transferAmount = component.get("v.TransferAmount");
        var dateOfApplication = component.get("v.DateOfApplication");

        var action = component.get("c.createOpps");
        action.setParams({
            'oppId': oppId,
            'selectedAccObj': selectedAccObj,
            'transferAmount': transferAmount,
            'dateOfApplication': dateOfApplication,            
        });
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var retValue = response.getReturnValue();
                if(retValue.indexOf('exception') !== -1){
                    var errMsg = retValue.substring(retValue.indexOf(";") + 1, retValue.lastIndexOf(":") - 1);
                    component.set("v.error",errMsg);
                }
                else{
                    var urlEvent = $A.get("e.force:navigateToURL");
                	urlEvent.setParams({
                    "url": '/'+response.getReturnValue()
                	});
                	setTimeout(function(){ 
                    urlEvent.fire();
                	}, 1000);
                
                }
                //var storeResponse = response.getReturnValue();
                // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                //component.set("v.listOfSearchRecords", storeResponse);
            }
            
        });
        $A.enqueueAction(action);
        
    }
})