({
doInit : function(component, event, helper) {
       $A.get("e.force:closeQuickAction").fire(); 
        var action = component.get("c.SendToSAP_call");
          action.setParams({
                'recordId' :component.get('v.recordId')
            });
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
             var result = response.getReturnValue();
               if(result == 2){
                     helper.showToast('Warning..!','This record has not been approved.','error');     
                }else if(result == 3){
                     helper.showToast('Warning..!','The record has not been sent to the portal.','error');     
                }else if(result == 4){
                     helper.showToast('Warning..!','This record already sent to SAP','error');     
                }else{
                   helper.showToast('Success!!!!','Data sent to SAP successfully','SUCCESS');      
                }
                 
            } else if(state === 'ERROR') {
        $A.get("e.force:closeQuickAction").fire(); 
             helper.showToast('Error..!','Something went wrong... please contact your admin','error');
            }
        });
        $A.enqueueAction(action);	
	   $A.get('e.force:refreshView').fire();	
	},
})