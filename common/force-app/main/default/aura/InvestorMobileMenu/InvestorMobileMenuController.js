({
    doInit:function(cmp, event, helper) {
        // create a one-time use instance of the serverEcho action
        // in the server-side controller
        let menus=[ 
            {id: 0, label: "Invest", active: false,url:'/invest'},
            {id: 1, label: "Learn", active: false, url:'/blog'},
            {id: 2, label: "Raise", active: false, url:'/raise'},
            {id: 3, label: "Property", active: false, url:'/property'},
            {id: 4, label: "About", active: false, url:'/about'},
            {id: 5, label: "Login", active: false, url:'Login'},
            {id: 6, label: "Register", active: false, url:'Register'}
        ];
        cmp.set("v.menus",menus);
        helper.getUserInfo(cmp, event, helper);
    },
    
    navigate : function(component, event, helper) {
        //Find the text value of the component with aura:id set to "address"
        component.set('v.showDropDown',false);
        console.log("clicked....");
        var url =event.target.dataset.url;
        console.log("The url is created", url);

        console.log('===component.get("v.usedInVF")===>', component.get("v.usedInVF"));
        if(url=='Login'){

            window.open(
                $A.get("$Label.c.vc_cf_login_sy"),
                '_top' // <- This is what makes it open in a new window.
              );
          
        }
        else if(url=='Register'){
            window.open(
                $A.get("$Label.c.VC_CF_Register_Symphony"),
                '_top' // <- This is what makes it open in a new window.
              );
        }
        else if(url=='logout'){
            console.log('===Inside logout 111===>');
            //window.location.replace("https://"+window.location.hostname+"/s/portal/secur/logout.jsp?retURL=%2Flogin");
           // window.location.replace("https://www.venturecrowd.com.au/secur/logout.jsp?retUrl=/s/login");
           window.open("https://"+window.location.hostname+"/secur/logout.jsp?retURL=/s/login",'_top');
        }
        else if(url=='portfolio'){
            console.log('===Inside portfolio===>');
            window.location.replace("https://www.venturecrowd.com.au/s/portal/portfolio");
        }
        else if(url=='profile'){
            console.log('===Inside profile===>', 'https://www.venturecrowd.com.au/s/portal' + 
                                                    '/profile/'+$A.get("$SObjectType.CurrentUser.Id"));
                                                    // window.location.replace("https://"+window.location.hostname+"/portal/secur/logout.jsp?retURL=/s/login");
            window.location.replace('https://www.venturecrowd.com.au/s/portal' + 
                                    '/profile/'+$A.get("$SObjectType.CurrentUser.Id"));
        }
        else if(url=='entities'){
            console.log('===Inside entities===>');
            window.location.replace("https://www.venturecrowd.com.au/s/portal/my-entities");
        }
        else  if(component.get("v.usedInVF")){
            console.log('===Inside usedInVF 111===>');
            var vfMethod=component.get("v.vfpageMethod");
            // Calling Vf page method
            vfMethod(url,function() {}); 
        }
        else{
                     helper.navigateToPartialUrl(url);
        }
    },
    
    onHamburgerClick:function(component, event, helper){
        // console.log('menuItems=',component.get("v.menuItems"));
        component.set('v.showDropDown',!component.get('v.showDropDown'));
    },
    
    
})