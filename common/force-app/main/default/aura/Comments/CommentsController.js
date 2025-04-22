({
	doPost : function(component, event, helper) {
        component.set('v.displayLoading',true);
		var action = component.get("c.createComment");
        var commentsList = component.get("v.commentsList");
        let toBePostedComment = component.get('v.commentObj');
        let prodRecId = component.get("v.prodId");
        toBePostedComment.Post_Comments__c = $A.get("$SObjectType.CurrentUser.Id");
        action.setParams({'comObj':toBePostedComment,'productId':prodRecId});
        action.setCallback(this,function(data){           
            component.set('v.commentId',data.getReturnValue())
            // commentsList.splice(0,0,component.get('v.commentObj'));
            // component.set("v.commentsList",commentsList);
            let commentObj = component.get("v.commentObj");
            commentObj.comments__c = '';
            component.set("v.commentObj",commentObj);
            component.set('v.displayLoading',false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Success!",
                "message": "Thank you. Your comment will be reviewed by the VentureCrowd team.",
                "type": 'success',
                "duration":"2000",
            });
            toastEvent.fire();
        });
        
        $A.enqueueAction(action);
	},
    
       showComments : function(component, event, helper) {    

            if ($A.get("$SObjectType.CurrentUser.Id")) {
                let prodRecId = component.get("v.prodId");
                component.set("v.displayComment",true);
                let action = component.get("c.retriveComments");
                action.setParams({'productId':prodRecId});
                action.setCallback(this,function(data){
                     component.set('v.tempCommentsList',data.getReturnValue());	
                    component.set('v.commentsList',data.getReturnValue());	
                    
                });   
                $A.enqueueAction(action);
            }
            component.set('v.displayLoading',false);

    },

    loadMore : function(component, event, helper) { 
        component.set("v.hideLoadMore", false);
        var pageNumber = component.get("v.pageNumber");
        var action = component.get("c.retriveNextThreeComments");
        let prodRecId = component.get("v.prodId");
        action.setParams({ nextLimit : pageNumber+3,'productId':prodRecId});                
        action.setCallback(this,function(data){
            component.set('v.commentsList',data.getReturnValue());	
            if(data.getReturnValue().length > 0) {
                component.set("v.pageNumber", pageNumber+3);
            }else {
                component.set("v.hideLoadMore", true);
            }
            
        });   
        $A.enqueueAction(action);
        
    },

    joinVentureCrowd : function(component, event, helper) { 
        let windoworigin = window.location.origin;
        window.location.assign(`${windoworigin}/s/login/SelfRegister`);
    },

    handleLoginClick:function(component, event, helper) { 
        let windoworigin = window.location.origin,
            refererUrl = window.location.href;
        window.location.assign(`${windoworigin}/s/login/?startURL=${refererUrl}`);
    },
})