({
	doInit : function(component, event, helper) {
		var action = component.get("c.convertLead");
        action.setParams({
            recId : component.get('v.recordId')
        });
        action.setCallback(this, $A.getCallback(function (response){
            var state = response.getState();
            if (state ==="SUCCESS") {
               var dismissActionPanel = $A.get("e.force:closeQuickAction");
        		dismissActionPanel.fire();
                $A.get('e.force:refreshView').fire();
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
                 // component.set('v.spinner',false);
            }
        }));
        $A.enqueueAction(action);
	}
})