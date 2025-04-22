({
    // Your renderer method overrides go here
    afterRender: function (cmp, helper) {
        
        this.superAfterRender();
        if(cmp.get("v.isContactUs")){
          cmp.find("name").focus();   
        }
       
    }
})