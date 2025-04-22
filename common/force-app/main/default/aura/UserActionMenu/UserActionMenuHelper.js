({
	 navigateToPartialUrl:function(partialurl){
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            
            "url": partialurl,
            "isredirect" :false
            
        });
        urlEvent.fire();
    }
})