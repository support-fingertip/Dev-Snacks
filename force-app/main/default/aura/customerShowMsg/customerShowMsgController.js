({
	recordLoaded: function(component, event, helper) {
   
        var record = component.get("v.record");
        
        var action=component.get("c.checkAddresses");
        action.setParams({'recId':record.Id});
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
                var res = response.getReturnValue();
                
                if(res != ''){
                    var toastEvent = $A.get("e.force:showToast");
                   // alert(res)
                    toastEvent.setParams({
                        
                        message: res,
                        duration:'5000',
                        key: 'info_alt',
                        type: 'Error',
                        mode: 'dismissible'           
                    });
                    toastEvent.fire();
                }
       
            }
        });
        $A.enqueueAction(action);	
       
       
    
},
})