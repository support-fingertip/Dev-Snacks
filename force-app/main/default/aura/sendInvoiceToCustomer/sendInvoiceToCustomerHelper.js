({
    showToast : function(title,message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    },
    getEmailAddress :function(component,event,helper){
        var action = component.get("c.fetchEmailAddressInvoice");
        action.setParams({ invoiceId : component.get("v.recordId")});
        action.setCallback(this,function(response){
            if(response.getState() == 'SUCCESS' ) {
                var result =response.getReturnValue();
                component.set('v.email',result.email);
                component.set('v.emailBody',result.emailBody);
            }else{
                var errorMsg = JSON.stringify(response.getError());
                helper.showToast('Error..!',errorMsg,'error');  
            }
        });
        $A.enqueueAction(action);
    }
})