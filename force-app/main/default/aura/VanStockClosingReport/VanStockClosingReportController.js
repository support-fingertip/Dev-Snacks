({
	myAction : function(component, event, helper) {
		  var date = new Date();
        var firstDay = new Date(date.getFullYear(), date.getMonth(), 2).toISOString();
        var lastDay = new Date(date.getFullYear(), date.getMonth() + 1, 1).toISOString();
        
        //alert(firstDay + '----' + lastDay)
        component.set('v.fromdate',firstDay);
        component.set('v.todate',lastDay);
        
        var action = component.get("c.getRoutes"); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               component.set('v.routes', response.getReturnValue());
             }
        });
        $A.enqueueAction(action);
	}
})