({
	doInit : function(component, event, helper) {
        
    var evt = $A.get("e.force:navigateToComponent");
    evt.setParams({
        //componentDef : "c:NewStockRequestCmp",
        componentDef : "c:UpdatedStockRequestCmp",
    });
    evt.fire();
}
})