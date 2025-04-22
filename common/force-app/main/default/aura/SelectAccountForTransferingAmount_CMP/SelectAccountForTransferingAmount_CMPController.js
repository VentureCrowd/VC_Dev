({
    doInit : function(component, event, helper) 
    {
        var oppObj =  component.get("v.oppId");
        console.log(oppObj);
        //var today = $A.localizationService.formatDate(new Date(), "DD-MM-YYYY");
        //component.set('v.today', today);
    },
    itemsChange : function(component, event, helper) 
    {
        var selectedOption =  component.get("v.selectedValue");
        console.log(selectedOption);
        if(selectedOption == 'Existing Account')
        {
            console.log('if');
            component.set("v.showHideLookup",false);
        }
        else
        {
            console.log('else');            
            component.set("v.showHideLookup",true);
        }
    },
    AccountChanged : function(component, event, helper)
    {
        var selectedAccObj =  component.get("v.selectedAccObj");
        console.log('selectedAccObj: '+selectedAccObj);
        
        if(selectedAccObj != null)
        {
            component.set("v.selectedAccId",selectedAccObj.Id);
            console.log('if selectedAccObj.Id : '+selectedAccObj.Id);
        }
        else
        {
            component.set("v.selectedAccId",'');
            console.log('else ');
        }
    },
    Submit : function(component, event, helper)
    {
        var accObj = component.get("v.newAccObj");
        var selectedAccType = component.get("v.selectedAccType");
        console.log('--->  ',selectedAccType);
		if(accObj.Name != '')
        {
            if(accObj.Phone !='')
            {
                helper.CreateNewAccountH(component, event, helper);
            }
            else
            {
                var msg = 'Account Phone is required';
                helper.showErrorToast(component, event, helper, msg);
            }
        }
        else
        {
            var msg = 'Account Name is required';
            helper.showErrorToast(component, event, helper, msg);
        }
    },
    cancel : function(component, event, helper){
        var navEvt = $A.get("e.force:navigateToSObject");
		navEvt.setParams({
	  	"recordId": component.get("v.oppId")
		});
		navEvt.fire();
    },
    Next : function(component, event, helper)
    {
        var oppAmount = component.get("v.OppAmount");
        var transferAmount = component.get("v.TransferAmount");
        var dateOfApplication = component.get("v.DateOfApplication");
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        if(transferAmount == null)
        {
            console.log('transferAmount:'+transferAmount);
            var msg = 'The transfer amount is required.';
            helper.showErrorToast(component, event, helper, msg);
            return;
        }
        if(dateOfApplication == null)
        {
            console.log('dateOfApplication:'+dateOfApplication);
            var msg = 'The Date of Application is required.';
            helper.showErrorToast(component, event, helper, msg);
            return;
        }
        if(oppAmount < transferAmount)
        {
            var msg = 'The transfer amount exceeds the limit.';
            helper.showErrorToast(component, event, helper, msg);
        }
        /*
        else if(dateOfApplication < today)
        {
            console.log('inside date check..');
            var msg = 'The Date of Application greter than or equal today date';
            helper.showErrorToast(component, event, helper, msg);
        }
        */
        else 
        {
            console.log('inside 59...');
            var selectedOption =  component.get("v.selectedValue");
            if(selectedOption == 'Existing Account')
            {
                var selectedAccObj =  component.get("v.selectedAccObj");
                console.log('inside existing acc: '+JSON.stringify(selectedAccObj));
                if(selectedAccObj != null)
                {
                    //component.set("v.showHideScreen",false);
                    //Create Opp with transferred amount for transferee account
                    //create new Opp with balance amount for tranferor
                    helper.createNewOppH(component, event, helper);
                }
                else
                {
                    var msg = 'Select Any Account';
                    helper.showErrorToast(component, event, helper, msg);
                }
            }
            else
            {
                component.set("v.showHideScreen",false);
            }
        }
            
    }, 
    Back : function(component, event, helper){
        component.set("v.showHideScreen",true);   
    }

})