({
  showToast : function(title,message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    },
    SendEinvoice : function(component, event, helper) {
         helper.showToast('Success!!!!','Requesting Einvoice cancellation','info');
          var action = component.get("c.SendPortal_call");
          action.setParams({
                'recordId' :component.get('v.recordId')
            });
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
             var result = response.getReturnValue();
                  helper.showToast('Success!!!!','Data sent to GST portal successfully','SUCCESS');   
                } else if(state === 'ERROR') {
        $A.get("e.force:closeQuickAction").fire(); 
             helper.showToast('Error..!','Something went wrong... please contact your admin','error');
            }
        });
        $A.enqueueAction(action);  
    },
       sendToSapReceipt : function(component, event, helper) {
            helper.showToast('Success!!!!','Requesting related receipt cancellation','info');
        var action = component.get("c.SendSAPInvoiceReceipt");
          action.setParams({
                'recordId' :component.get('v.recordId')
            });
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
             var result = response.getReturnValue();
                  helper.showToast('Success!!!!','Receipt cancellation sent successfully','SUCCESS'); 
            } else if(state === 'ERROR') {
        $A.get("e.force:closeQuickAction").fire(); 
             helper.showToast('Error..!','Something went wrong... please contact your admin','error');
            }
        });
        $A.enqueueAction(action);	
		
	},
           SendToSAP : function(component, event, helper) {
                helper.showToast('Success!!!!','Requesting salesinvoice cancellation','info');
        var action = component.get("c.SendToSAP_Cancel_call");
          action.setParams({
                'recordId' :component.get('v.recordId')
            });
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
             var result = response.getReturnValue();
                  helper.showToast('Success!!!!','Salesinvoice cancellation sent successfully to SAP','SUCCESS'); 
                  $A.get("e.force:closeQuickAction").fire(); 
            } else if(state === 'ERROR') {
        $A.get("e.force:closeQuickAction").fire(); 
             helper.showToast('Error..!','Something went wrong... please contact your admin','error');
            }
        });
        $A.enqueueAction(action);	
		
	},

})