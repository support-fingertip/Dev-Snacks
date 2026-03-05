({
doInit : function(component, event, helper) {
       $A.get("e.force:closeQuickAction").fire(); 
        var action = component.get("c.getOutstandingData");
          action.setParams({
                'recordId' :component.get('v.recordId'),
              'type':'OutStandingInv'
            });
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
             var result = response.getReturnValue();
                   helper.showToast('Success!!!!','Data synchronized successfully','SUCCESS');      
                } else if(state === 'ERROR') {
        $A.get("e.force:closeQuickAction").fire(); 
             helper.showToast('Error..!','Something went wrong... please contact your admin','error');
            }
        });
        $A.enqueueAction(action);	
	   $A.get('e.force:refreshView').fire();	
	},
})