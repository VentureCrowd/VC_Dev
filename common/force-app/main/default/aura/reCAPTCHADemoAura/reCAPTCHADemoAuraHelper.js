({
	isEmpty : function(val) {
		return val == null || val == '';
	},
    passwordKeyUp:function(cmp,event){
        var smallCase = /[a-z]/g;
        var capitalCase = /[A-Z]/g;
        var digit = /[\d]/g;
        var cmpFind = cmp.find("password");
        var passwordInfo =cmp.get("v.password");
        if(passwordInfo.length<8  || !smallCase.test(passwordInfo) || !capitalCase.test(passwordInfo) && !digit.test(passwordInfo) || cmp.get("v.password") == "password"){
             $A.util.addClass(cmpFind, "slds-has-error"); // remove red border
            $A.util.removeClass(cmpFind, "hide-error-message");
            cmpFind.reportValidity();
            cmpFind.setCustomValidity("Invalid password. Please ensure your password is a minimum of 8 characters, including both letters and numbers"); 
        } else {
            $A.util.removeClass(cmpFind, "slds-has-error"); // remove red border
            $A.util.addClass(cmpFind, "hide-error-message");
        }
        //if(cmp.get("v.password") != cmp.get("v.confirmPassword")){
          //  cmp.set("v.confirmPassword","")
        //}
        if(!this.isEmpty(cmp.get("v.confirmPassword")) && cmp.get("v.password") != cmp.get("v.confirmPassword")){
        	this.confirmPasswordKeyUp(cmp,event);
        }
        //$A.get('e.force:refreshView').fire(); 
        
    },
    confirmPasswordKeyUp:function(cmp,event){
        if(this.isEmpty(cmp.get("v.password")) || this.isEmpty(cmp.get("v.confirmPassword")) || (cmp.get("v.password") != cmp.get("v.confirmPassword"))){
            $A.util.addClass(cmp.find("confirmPassword"), "slds-has-error"); // remove red border
            $A.util.removeClass(cmp.find("confirmPassword"), "hide-error-message");
            cmp.find("confirmPassword").reportValidity();
            cmp.find("confirmPassword").setCustomValidity("Password and confirm-password fields must match.");
        } else {
            $A.util.removeClass(cmp.find("confirmPassword"), "slds-has-error"); // remove red border
            $A.util.addClass(cmp.find("confirmPassword"), "hide-error-message");
        }
        //$A.get('e.force:refreshView').fire(); 
    },
    closeResetModal:function(cmp,event){
        cmp.set("v.isResetModal",false);
    }
})