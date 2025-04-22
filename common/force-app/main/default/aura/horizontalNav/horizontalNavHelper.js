({
    navigateToPage : function(iden) {
        var urlEvent = $A.get("e.force:navigateToURL");
        if(iden == 'profile'){
            iden = iden+'/'+$A.get("$SObjectType.CurrentUser.Id");
            urlEvent.setParams({
                "url": '/'+iden
            });
        }
        else if( iden == 'my-portfolio'){
            urlEvent.setParams({
                "url": '/'
            });
        } else if(iden =="my-entities") {
            urlEvent.setParams({
                "url": '/'+iden
            });
        }else{
            window.location.replace("https://"+window.location.hostname+"/portal/secur/logout.jsp?retURL=/s/login");
        }
        urlEvent.fire();	
    },
    navigateToPartialUrl:function(partialurl){
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": partialurl,
            "isredirect" :false
        });
        urlEvent.fire();
    }
})