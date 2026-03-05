({
    doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId");
       // alert(recordId)
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
                    helper.showToast('error','Customer credit period exceeded!!','Customer credit period is exceeded to convert this order into invoice.');
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                    
                }else{
                    
                    var action1 = component.get("c.getOrderStatus");
                    action1.setParams({
                        "ordId" : recordId
                    });
                    action1.setCallback(this,function(response){
                        var State1 = response.getState();
                        if(State1 === "SUCCESS"){
                            var status = response.getReturnValue();
                            console.log('credit period exceed==='+result1);
                            if(status == 'Converted'){
                                helper.showToast('error','Sales Order is already Converted.');
                                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                                dismissActionPanel.fire();
                                
                            }else{
                                
                                var evt = $A.get("e.force:navigateToComponent");
                                evt.setParams({
                                    componentDef : "c:SalesOrderItemList",
                                    componentAttributes: {
                                        recordId : component.get("v.recordId"),
                                        sObjectName : component.get("v.sObjectName"),
                                        redirect : true
                                    }
                                });
                                evt.fire();
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
                    
                    
                    /*  var evt = $A.get("e.force:navigateToComponent");
                    evt.setParams({
                        componentDef : "c:SalesOrderItemList",
                        componentAttributes: {
                            recordId : component.get("v.recordId"),
                            sObjectName : component.get("v.sObjectName"),
                            redirect : true
                        }
                    });
                    evt.fire();*/
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
        
        
        
        
        
    }
})