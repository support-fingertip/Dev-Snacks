({
    doInit : function(component, event, helper) {
        var action = component.get("c.getSalesInv");
          action.setParams({
                'recordId' :component.get('v.recordId')
            });
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
             var result = response.getReturnValue();
                component.set('v.po',result);
            }
        });
        $A.enqueueAction(action);			
	},
	updateDetails : function(component, event, helper) {
         var commentForm = component.find('sales'), valid;
                commentForm.showHelpMessageIfInvalid();
               var valid = commentForm.get("v.validity").valid;
        if(valid == true){
        var po =component.get('v.po');
		var action = component.get("c.salesInvoicePO");
          action.setParams({
                'recordId' :component.get('v.recordId'),
                 'po' :po
            });
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
             var result = response.getReturnValue();
                helper.showToast('Success!!!!','SalesInvoice Updated successfully','SUCCESS');  
                   component.set('v.isModalOpen',false);
                  $A.get("e.force:closeQuickAction").fire();     
                 $A.get('e.force:refreshView').fire();
                } else if(state === 'ERROR') {
        $A.get("e.force:closeQuickAction").fire();     
             helper.showToast('Error..!','Something went wrong... please contact your admin','error');
            }
        });
        $A.enqueueAction(action);	
            
       $A.get('e.force:refreshView').fire();
        }
	},
    closeModel: function(component, event, helper) {
         component.set('v.isModalOpen',false);
          $A.get("e.force:closeQuickAction").fire();     
         $A.get('e.force:refreshView').fire();   
    }
})