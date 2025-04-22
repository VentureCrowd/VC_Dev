({
	invoke : function (component,event,helper) {
        console.log('Came here!!');
        try{
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
              "url": "/"
            });
            urlEvent.fire();
        } catch (e){
            console.log(e);
        }
    }
})