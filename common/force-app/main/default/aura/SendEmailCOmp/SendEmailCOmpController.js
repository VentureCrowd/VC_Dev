({
    doInit:function(component, event, helper){
        
    },
    sendEmail : function(cmp, event, helper) {   
        try{
            var allValid = cmp.find('filed').reduce(function (validSoFar, inputCmp) {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true); 
            
          /*  let name=cmp.get("v.name");
            console.log("Allvalid=",allValid);
            let nameinput=name.get('v.value');
            if($A.util.isEmpty(nameinput)){
             name.setCustomValidity('Complete this field.');   
            }else{
             name.setCustomValidity(''); //do not get any message
            }
            name.reportValidity(); */
            if(allValid){
                cmp.set("v.showError",false);
                helper.sendEmailhelper(cmp, event, helper); 
            }else{
                cmp.set("v.showError",true);
            }
        }catch(error){
            console.log("error occured while email sending=",error);
        }
        
    },
    verifycapthca : function(component, event, helper) {
        console.log("verifycapthca done");
        component.set("v.buttondisabled",false);
    },
    
})