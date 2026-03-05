({
    dohelper : function(component,event,helper) {  
 
    },
	 showToast : function(message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type":type,
            "message":  message 
        });
        toastEvent.fire();
    },
    getRoutes : function(component, event, helper) {
        component.set('v.spinner',true);
        component.set('v.mydata',{});
        component.set('v.searchText','');
        var action = component.get("c.getRouteList");
        action.setParams({'uId':  component.get('v.userId')})
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.allroutes', response.getReturnValue());
                component.set('v.spinner',false);
                
            }
        });
        $A.enqueueAction(action);
    },
    setColumn : function (component, event,helper) {
         var actions = [  { label: 'Show details', name: 'show_details' } ]; //LEAD
          component.set('v.mycolumns', [
            {label: 'Account Name', fieldName: 'Name', type: 'text'},
            {label: 'Municipality', fieldName: 'RouteName__c', type: 'text'},
            {label: 'Product Type', fieldName: 'Product_Type__c', type: 'text'},
            {label: 'Division', fieldName: 'Division__c', type: 'text'},
            { type: 'action', typeAttributes: { rowActions: actions } }
        ]);  
   
    },
})