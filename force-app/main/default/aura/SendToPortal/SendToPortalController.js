({
doInit : function(component, event, helper) {
       $A.get("e.force:closeQuickAction").fire(); 
        var action = component.get("c.SendToPortal_call");
          action.setParams({
                'recordId' :component.get('v.recordId'),
                   'type' :'Generate'
            });
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
             var result = response.getReturnValue();
                //alert(result)
               if(result == 2){
                     helper.showToast('Warning..!','This record is not approved','error');     
                }else if(result == 3){
                     helper.showToast('Warning..!','This customer is not GST applicable customer /Einvoice already generated','error');     
                }else{
                   helper.showToast('Success!!!!','Data sent to Portal successfully','SUCCESS');      
                }
                 
            } else if(state === 'ERROR') {
        $A.get("e.force:closeQuickAction").fire(); 
             helper.showToast('Error..!','Something went wrong... please contact your admin','error');
            }
        });
        $A.enqueueAction(action);	
		
	},
})