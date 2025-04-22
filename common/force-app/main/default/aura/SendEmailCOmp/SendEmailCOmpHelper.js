({
    sendEmailhelper : function(cmp, event, helper) {
        console.log("sending email");
        cmp.set("v.showspinner",true);
        cmp.set("v.showSuccess",false);
        let emailinfo={
            name:cmp.get("v.name"),
            email:cmp.get("v.email"),
            helptext:cmp.get("v.helptext"),
            message:cmp.get("v.message"),
        }
        console.log("sending email emailinfo=",emailinfo);        
        var action = cmp.get("c.notifyEmail");
        action.setParams(emailinfo);
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Alert the user with the value returned 
                // from the server
               // console.log("Success! Thanks for your enquiry, we’ll be in touch with you soon.");
                
                cmp.set("v.emailinfo",{});
                cmp.set("v.showspinner",false);
                cmp.set("v.showSuccess",true);
                
                cmp.set("v.name",'');
                cmp.set("v.email",'');
                cmp.set("v.helptext",'');
                cmp.set("v.message",'');
                
                
                
            }
            else if (state === "INCOMPLETE") {
                // do something
                console.log('Not logged in');
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
        
        
    }
    ,
})