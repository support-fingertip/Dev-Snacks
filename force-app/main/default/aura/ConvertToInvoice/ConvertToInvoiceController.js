({
    doinIt : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.getSalesOrderRecord");
        action.setParams({
            "recordId" : recordId
        });
        action.setCallback(this,function(response){
            var State = response.getState();
            if(State === "SUCCESS"){
                var result = response.getReturnValue();
                //alert('Sales Order=== '+ JSON.stringify(result));
                component.set('v.salesOrder',result);
                alert('Sales Order Status=== '+ JSON.stringify(result.Status__c));
                if(result.Status__c === "Approved"){
                    var action1 = component.get("c.checkCreditPeriod");
                    action1.setParams({
                        "recordId" : recordId
                    });
                    action1.setCallback(this,function(response){
                        var State1 = response.getState();
                        if(State1 === "SUCCESS"){
                            var result1 = response.getReturnValue();
                            console.log('credit period exceed==='+result1);
                            if(result1){
                                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                                dismissActionPanel.fire();
                                helper.showToast('error','Customer credit period exceeded!!','Customer credit period is exceeded to convert this order into invoice.');
                            }else{
                                alert('Create sales invoice===');
                                helper.convertSalesOrder(component, event,helper,recordId);
                            }
                        }else if (State1 === "ERROR") {
                            var errors = response.getError();
                            if (errors) {
                                if (errors[0] && errors[0].message) {
                                    alert("Error message: " + 
                                          errors[0].message);
                                }
                            }
                        }
                    });
                    $A.enqueueAction(action1);
                    //helper.convertSalesOrder(component, event,helper,recordId);
                }else{
                    //alert('Sales order status is not approved');
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                    helper.showToast('error','Sales order Can not be converted!!','In order to convert sales order record, sales order status must be Approved.');
                }
            }else if (State === "ERROR") {
                var errors = response.getError();
                //alert(JSON.stringify(errors));
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert("Error message: " + 
                                    errors[0].message);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    }
})