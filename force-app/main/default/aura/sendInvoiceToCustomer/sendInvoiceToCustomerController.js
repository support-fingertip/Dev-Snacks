({
     doInit : function(component, event, helper) {   
        component.set('v.isMainPopupOpen',true);
        helper.getEmailAddress(component, event, helper);
    },
    openSendEmail : function(component, event, helper) {
        component.set('v.isInnerPopupOpen',true);
    },
    closeInnerPop : function(component, event, helper) {
        component.set('v.isInnerPopupOpen',false);
    },
    closeOuterPopup : function(component, event, helper) {
        component.set('v.isMainPopupOpen',false);
        component.set('v.isInnerPopupOpen',false);
        
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId" : component.get("v.recordId"),
            "slideDevName" : "related"
        });
        navEvt.fire(); 
        //  event.stopPropagation();
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        $A.get('e.force:refreshView').fire();
    },
    handleSend : function(component,event,helper){
        var action = component.get("c.sendEmailToCustomer");
        action.setParams({ body : component.get("v.emailBody"),
                          email : component.get("v.email"),
                          invoiceId : component.get("v.recordId")});
        action.setCallback(this,function(response){
            if(response.getState() == 'SUCCESS' ) { 
                 helper.showToast('Success!!!!','Email sent successfully','SUCCESS');   
                 $A.get("e.force:closeQuickAction").fire(); 
                 $A.get('e.force:refreshView').fire();
            }else{ 
                var errorMsg = JSON.stringify(response.getError());
                 helper.showToast('Error..!',errorMsg,'error');
                 $A.get("e.force:closeQuickAction").fire(); 
                // $A.get('e.force:refreshView').fire();
            }
           
        });
        $A.enqueueAction(action);
    }
})