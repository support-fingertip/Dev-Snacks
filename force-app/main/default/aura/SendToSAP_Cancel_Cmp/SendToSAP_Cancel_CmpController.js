({
doInit : function(component, event, helper) {
        var action = component.get("c.getObjectName");
          action.setParams({
                'recordId' :component.get('v.recordId')
            });
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
             var result = response.getReturnValue();
                if(result == 'Sales_Invoice__c'){
                    helper.sendToSapReceipt(component, event, helper); 
                }
                if(result != ''){
                    helper.SendToSAP(component, event, helper); 
                }
                helper.showToast('Success!!!!','Data sent to SAP successfully','SUCCESS');   
                } else if(state === 'ERROR') {
        $A.get("e.force:closeQuickAction").fire(); 
                     
             helper.showToast('Error..!','Something went wrong... please contact your admin','error');
            }
        });
        $A.enqueueAction(action);	
       $A.get('e.force:refreshView').fire();
		
	},
})