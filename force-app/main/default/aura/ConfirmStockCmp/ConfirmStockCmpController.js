({
	doInit : function(component, event, helper) {
          var action = component.get("c.getUIThemeDescription");
         action.setCallback(this, function(a) {
            if(a.getReturnValue()=='Theme4d'){
                component.set("v.isDesktop",true);
                component.set("v.isMobile1",false);
               
            }else if(a.getReturnValue()=='Theme4t'){
                component.set("v.isMobile1",true);
                component.set("v.isDesktop",false);
            }
                    });
        $A.enqueueAction(action);
		helper.getStockItems(component, event, helper);
	},
     save: function(component,event,helper) {
          component.set('v.spinner',true);
          component.set('v.disableBtn',true);
        if (helper.validateReqList(component, event)) {
           	helper.saveOrder(component,event,helper);
        }
         else{
              component.set('v.spinner',false);
          component.set('v.disableBtn',false);
         }
    },
    reject: function(component,event,helper) {
         component.set('v.disableBtn',true);
         component.set('v.spinner',true);
        if (helper.validateReqList(component, event)) {
            console.log('Request is valid=== ');
           	helper.rejectStock(component,event,helper);
        }
    },
    cancel:function(component, event, helper) {
      var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get('v.recordId'),
                        "slideDevName": "detail"
                    });
                    navEvt.fire();
        
    },
})