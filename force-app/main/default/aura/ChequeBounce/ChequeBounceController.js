({
       doInit : function(component, event, helper) {
        var action = component.get("c.getReceipt");
          action.setParams({
                'recordId' :component.get('v.recordId')
            });
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
             var result = response.getReturnValue();
                component.set('v.boCharge',result);
            }
        });
        $A.enqueueAction(action);			
	},
	updateDetails : function(component, event, helper) {
                 var commentForm = component.find('rec'), valid;
                commentForm.showHelpMessageIfInvalid();
                valid = commentForm.get("v.validity").valid;
        if(valid == true){
         helper.updateRecdDetails(component, event, helper);
	   $A.get('e.force:refreshView').fire();
        }
	},
    closeModel: function(component, event, helper) {
         component.set('v.isModalOpen',false);
          $A.get("e.force:closeQuickAction").fire();     
         $A.get('e.force:refreshView').fire();   
    }
})