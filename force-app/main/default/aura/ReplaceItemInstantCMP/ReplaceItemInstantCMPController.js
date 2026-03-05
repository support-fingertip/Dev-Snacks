({
	 
	closeModal : function(component, event, helper) {
		component.destroy();
	},

	// action to execute when Proceed button is clicked
	handleProceed : function(component, event, helper) {
		 var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ItemReplacementCmp",
            componentAttributes: {
                customerId: component.get('v.customerId'),
                type :component.get('v.type')
            }
        });
        evt.fire();
		component.destroy();
	}
})