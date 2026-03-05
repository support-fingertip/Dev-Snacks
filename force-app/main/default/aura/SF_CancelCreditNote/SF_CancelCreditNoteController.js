({
    doInit : function(component, event, helper) {

        var action = component.get("c.cancelCreditNoteSF");
        action.setParams({
            returnId : component.get("v.recordId")
        });

        action.setCallback(this, function(resp) {

            if(resp.getState() === "SUCCESS") {
                helper.showToast('Success', 'Credit Note Cancelled Successfully', 'success');
            }
            else {
                var err = resp.getError();
                helper.showToast('Error', err[0].message, 'error');
            }

            $A.get("e.force:closeQuickAction").fire();
            $A.get("e.force:refreshView").fire();
        });

        $A.enqueueAction(action);
    }
})