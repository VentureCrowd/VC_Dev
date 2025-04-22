({
    doInit : function(cmp, event, helper) {
        console.log('Hello');
        var totalInvestments=0;
        var personalInvestments=0;
        var entitiesInvestments =0;
        if(window.screen.width < 490 || $A.get("$Browser.isPhone")){
            cmp.set('v.isMobile',true);
        }
        var checkProcessingNeeded = cmp.get("v.isHomePage");
        if(checkProcessingNeeded){
            var currGreeting ="";
            var currentdate = new Date(); 
            if(currentdate.getHours() <= 12){
                currGreeting ='Good morning';
            } else if (currentdate.getHours() > 12 && currentdate.getHours() <= 16){
                currGreeting ='Good afternoon';
            } else {
                currGreeting ='Good evening';
            }
            cmp.set('v.currentTimeGreeting',currGreeting);
            
            var userAction = cmp.get("c.getCurrentUser");
            
            userAction.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    // Alert the user with the value returned 
                    // from the server
                    
                    let users=response.getReturnValue();
                    if(users.length>0){
                        cmp.set("v.currentUser",users[0]);  
                        if(users[0]['Contact'] && users[0]['Contact']['ID_Checked__c']){
                            var idInfo = users[0]['Contact']['ID_Checked__c'];
                            if (idInfo == 'true' || idInfo == true){
                                cmp.set('v.isIdVerified',true);
                                cmp.set('v.cssstring','slds-col slds-size_12-of-12');
                            }
                        }else{
                            cmp.set('v.cssstring','slds-col slds-size_8-of-12');
                        }
                    }
                    
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
            
            $A.enqueueAction(userAction);
            
            var action = cmp.get('c.getInvestments'); 
            action.setCallback(this, function(a){
                var state = a.getState(); // get the response state
                if(state == 'SUCCESS') {
                    // console.log(JSON.parse(a.getReturnValue()));
                    var investmentList = JSON.parse(a.getReturnValue());
                    for(let i=0;i<investmentList.length;i++){
                        if(investmentList[i].Name == "Business Account" || investmentList[i].Name == "VC Business Account" || investmentList[i].RecordTypeId=='0122v000001bzCzAAI' ){
                            entitiesInvestments = investmentList[i].Investments;
                            cmp.set("v.numberOfEntitiesInvestments",investmentList[i].NumberOfInvestments);
                        } else if(investmentList[i].Name == "Person Account" || investmentList[i].Name == "VC Person Account" || investmentList[i].RecordTypeId=='0122v000001bzMaAAI'){
                            personalInvestments =investmentList[i].Investments;
                            cmp.set("v.numberOfPersonalInvestments",investmentList[i].NumberOfInvestments);
                        }
                    }
                    //console.log(personalInvestments.toLocaleString('en-US', { style: 'currency', currency: 'AUD' }));
                    cmp.set('v.personalInvestments',personalInvestments.toLocaleString('en-US', { style: 'currency', currency: 'USD',minimumFractionDigits: 0,maximumFractionDigits:0 }));
                    cmp.set('v.entitiesInvestments',entitiesInvestments.toLocaleString('en-US', { style: 'currency', currency: 'USD',minimumFractionDigits: 0,maximumFractionDigits:0 }));
                    cmp.set('v.totalInvestments',(personalInvestments+entitiesInvestments).toLocaleString('en-US', { style: 'currency', currency: 'USD',minimumFractionDigits: 0,maximumFractionDigits:0 }));
                    
                } else if(state == 'Error' || state == 'ERROR'){
                    //console.error('Error');
                     console.error(JSON.stringify(a.getError()));
                }
            });
            $A.enqueueAction(action);
            
            
        } else {
            if(cmp.get("v.recordId") == null ||cmp.get("v.recordId") == ''){
                cmp.set("v.dataExists",false);
            }
            var actionFromRecordPage = cmp.get('c.getInvestmentFromInvestmentObject'); 
            actionFromRecordPage.setParams({
            	"recordId" : cmp.get("v.recordId") 
        	});
            actionFromRecordPage.setCallback(this, function(a){
                var state = a.getState();
                if(state == 'SUCCESS') {
                    cmp.set("v.totalInvestments",a.getReturnValue().Investment_Amount__c.toLocaleString('en-US', { style: 'currency', currency: 'USD',minimumFractionDigits: 0 }));
                    cmp.set("v.stage",a.getReturnValue().Stage__c);
                } else if(state =='ERROR'){
                    cmp.set("v.dataExists",false);
                }
            });
            $A.enqueueAction(actionFromRecordPage);
        }
        let getinvestcount = cmp.get('c.getInvestmentFromInvestmentObject'); 
        getinvestcount.setCallback(this, function(a){
            var state = a.getState();
            if(state == 'SUCCESS') {
                cmp.set("v.INVESTMENTCOUNT",a.getReturnValue());
            } else if(state =='ERROR'){
                cmp.set("v.INVESTMENTCOUNT",0);
            }
        });
        $A.enqueueAction(getinvestcount);
    }
})