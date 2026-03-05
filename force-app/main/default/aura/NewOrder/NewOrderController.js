({
    doInit : function(component, event, helper) {
        var action=component.get("c.getStock");
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == "SUCCESS" ){ 
                var db = response.getReturnValue();
                //  alert(db)
                component.set('v.stockList',db);
            }
        });
        $A.enqueueAction(action);
    }
})