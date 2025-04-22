({
    init : function(cmp, event, helper) {
        //console.log(cmp.get('v.recordId').startsWith('001'));
        cmp.set('v.showcmp',(cmp.get('v.recordId').startsWith('001')));
    }
    
})