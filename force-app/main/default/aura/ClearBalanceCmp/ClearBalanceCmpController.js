({
    doinIt : function(component, event, helper) {
        component.set('v.spinner',true);
        var recordId = component.get("v.recordId");
        var action = component.get("c.checkBalance");
        action.setParams({
            "recId" : recordId
        });
        action.setCallback(this,function(response){
            var State = response.getState();
            if(State === "SUCCESS"){
                var result = response.getReturnValue();
                //alert(result)
                if(result <= 0){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        type: 'error',
                        title : 'Error',
                        message: 'Not enough Balance to transfer.',
                    });
                    toastEvent.fire();
                    component.set('v.spinner',false);
                    component.set('v.showMsg',false);
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                }
                else{
                    component.set('v.showMsg',true);
                     component.set('v.spinner',false);
                }
               
                
                
            }else if (State === "ERROR") {
                var errors = response.getError();
                //alert(JSON.stringify(errors));
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert("Error message: " + 
                              errors[0].message);
                    }
                }
            }
        });
        $A.enqueueAction(action);
       /* var recordId = component.get("v.recordId");
        var action = component.get("c.clearBalance");
        action.setParams({
            "recId" : recordId
        });
        action.setCallback(this,function(response){
            var State = response.getState();
            if(State === "SUCCESS"){
                var result = response.getReturnValue();
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    type: 'success',
                    title : 'Success',
                    message: 'Balance transferred to Branch.',
                });
                toastEvent.fire();
                
                 var dismissActionPanel = $A.get("e.force:closeQuickAction");
                                dismissActionPanel.fire();
                
                
            }else if (State === "ERROR") {
                var errors = response.getError();
                //alert(JSON.stringify(errors));
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert("Error message: " + 
                              errors[0].message);
                    }
                }
            }
        });
        $A.enqueueAction(action);*/
    },
    handleConfirmDialogNo: function(component, event, helper) {
         var dismissActionPanel = $A.get("e.force:closeQuickAction");
                                dismissActionPanel.fire();
    },
     handleConfirmDialogYes: function(component, event, helper) {
         component.set('v.spinner',true);
         var recordId = component.get("v.recordId");
        var action = component.get("c.clearBalance");
        action.setParams({
            "recId" : recordId
        });
        action.setCallback(this,function(response){
            var State = response.getState();
            if(State === "SUCCESS"){
                var result = response.getReturnValue();
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    type: 'success',
                    title : 'Success',
                    message: 'Balance transferred to Branch.',
                });
                toastEvent.fire();
                component.set('v.spinner',false);
                
                 var dismissActionPanel = $A.get("e.force:closeQuickAction");
                                dismissActionPanel.fire();
                
                
            }else if (State === "ERROR") {
                var errors = response.getError();
                //alert(JSON.stringify(errors));
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert("Error message: " + 
                              errors[0].message);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
})