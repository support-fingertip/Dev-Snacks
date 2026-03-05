({
	doInit : function(component, event, helper) {
		      var action = component.get("c.createVisits");
                action.setParams({
                                  
                                  'beatId': component.get('v.recordId')
                                                                    
                                 })
                action.setCallback(this, function(response) { 
                var state = response.getState();
                if (state === "SUCCESS") {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type":'success',
                            "message":  'Visit Plan added succefully' 
                        });
                        toastEvent.fire();
                        $A.get("e.force:closeQuickAction").fire();
                        $A.get('e.force:refreshView').fire();
                  }
             });
            $A.enqueueAction(action); 
	}
})