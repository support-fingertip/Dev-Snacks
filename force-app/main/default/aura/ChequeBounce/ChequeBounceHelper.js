({
    sendDetails : function(component, event, helper) {
        var action = component.get("c.SendToSAP_ReceiptCancel_call");
          action.setParams({
                'recordId' :component.get('v.recordId'),
              'bouncingCharge' :component.get('v.boCharge')
              
            });
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
             var result = response.getReturnValue();
                    helper.showToast('Success!!!!','Reciept Cancellation request sent to SAP successfully','SUCCESS');   
              
                  $A.get("e.force:closeQuickAction").fire();   
            } else if(state === 'ERROR') {
        $A.get("e.force:closeQuickAction").fire(); 
             helper.showToast('Error..!','Something went wrong... please contact your admin','error');
            }
        });
        $A.enqueueAction(action);
	
	},
     updateRecdDetails : function(component, event, helper) {
 
        var action = component.get("c.update_Receipt");
          action.setParams({
                'recordId' :component.get('v.recordId'),
              'bouncingCharge' :component.get('v.boCharge'),
               'docDate' :component.get('v.docDate')
          });
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
             var result = response.getReturnValue();
               if(result == 0){
                  helper.showToast('Warning..!','This record not sent to SAP','error');      
               }else{
                   helper.sendDetails(component, event, helper);
               }
            } else if(state === 'ERROR') {
        $A.get("e.force:closeQuickAction").fire(); 
             helper.showToast('Error..!','Something went wrong... please contact your admin','error');
            }
        });
        $A.enqueueAction(action);	
	},
  showToast : function(title,message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    }
})