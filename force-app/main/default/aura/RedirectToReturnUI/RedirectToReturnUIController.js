({
	doInit : function(component, event, helper) {

           component.find("navigationService").navigate({
                type: "standard__component",
                attributes: {
                    componentName: "c__ReturnUI_Global_Cmp" // Correct format for the component name
                },
                state: {
                    c__customerId: component.get("v.recordId") // Pass the current record ID
                }
            }, true);// replace = true 
           /*const navigateEvent = $A.get("e.force:navigateToComponent");
            if (navigateEvent) {
                navigateEvent.setParams({
                    componentDef: "c:ReturnUI_Global_Cmp", // Target component
                    componentAttributes: {
                        customerId: component.get("v.recordId") // Pass the current record ID
                    }
                });
                navigateEvent.fire();*/
            
        // Close the Quick Action panel
        
    },
})