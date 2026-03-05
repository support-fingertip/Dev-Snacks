({
	doInit : function(component, event, helper) {
       // alert(component.get('v.recordId'));
		 var action=component.get("c.imagesMethod");
		 action.setParams({'accId': component.get('v.recordId')});
        action.setCallback(this,function(a){
            component.set("v.visitPhotos",a.getReturnValue());
           //alert(a.getReturnValue());
           // alert(component.get('v.visitPhotos'));
            console.log('rtn value >>>>'+a.getReturnValue());

        });
        $A.enqueueAction(action);
	}
})