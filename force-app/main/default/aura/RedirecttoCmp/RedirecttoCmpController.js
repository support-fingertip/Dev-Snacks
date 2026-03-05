({
	doInit : function(component, event, helper) {
          var objectc= component.get("v.sObjectName"); 
        
        if(objectc == 'Account'){
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:ReturnUI_Global_Cmp",
                componentAttributes: {
                    customerId : component.get("v.recordId")
                }
            });
            evt.fire();
        }else{
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:GenrteLedgerStatement",
                componentAttributes: {
                    recordId : component.get("v.recordId"),
                    sObjectName : component.get("v.sObjectName")
                }
            });
            evt.fire();
        }
        },

})