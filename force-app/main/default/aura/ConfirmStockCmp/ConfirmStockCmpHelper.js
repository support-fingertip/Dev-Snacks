({
    getStockItems : function(component, event, helper) {
        component.set('v.spinner',true);
     
        var action=component.get("c.getStock");
        action.setParams({'recId':  component.get('v.recordId')
                         });
        action.setCallback(this,function(response){ 
            if(response.getState() == "SUCCESS"){
                var items = response.getReturnValue();
                
                for (var i = 0; i < items.length; i++) {
                    if(items[i].Stock_Request__r.Status__c == 'Received')
                    {
                        helper.showToast('Stock is already Converted!','Error');
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": component.get('v.recordId'),
                            "slideDevName": "detail"
                        });
                        navEvt.fire();
                        break;
                    }
                    else{
                        items[i].Received_Qunatity__c = items[i].Transfered_Quantity__c;
                    }
                    
                }
                component.set('v.stockRequests',items);
            }else if (response.getState() === "ERROR") {
                //alert(1);
                var errors = response.getError();
                //alert(JSON.stringify(errors));
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                }
            }
            component.set('v.spinner',false);
        });
        $A.enqueueAction(action); 
    },
    validateReqList: function(component, event) {
        var isValid = true;
        var prdList = component.get("v.stockRequests");
        // alert(JSON.stringify(prdList))
        for (var i = 0; i < prdList.length; i++) {
            if(prdList[i].Received_Qunatity__c == '' || prdList[i].Received_Qunatity__c == null){
                isValid = false;
                alert('please enter quantity on row number ' + (i + 1));
                component.set('v.disableBtn',false);
            }
        }
        return isValid;
    }, 
    rejectStock : function(component,event,helper) {
        console.log('Reject Stock=== ');
        var action = component.get('c.rejectNewRequest');
        action.setParams({'reqList':  component.get('v.stockRequests'),
                          'recId': component.get('v.recordId')
                         });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == "SUCCESS"){
                helper.showToast('Stock Request is rejected!','Information');
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": response.getReturnValue(),
                    "slideDevName": "detail"
                });
                navEvt.fire();
            }else if (response.getState() === "ERROR") {
                //alert(1);
                var errors = response.getError();
                //alert(JSON.stringify(errors));
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert("Error message: " + 
                              errors[0].message);
                    }
                }
            }
            component.set('v.spinner',false);
            component.set('v.disableBtn',false);
        });
        $A.enqueueAction(action); 
    },
    saveOrder : function(component,event,helper) {  
        
        
        component.set('v.spinner',true);
         component.set('v.disableBtn',true); 
        var action=component.get("c.checkStatus");
        action.setParams({'recId':  component.get('v.recordId')
                         });
        action.setCallback(this,function(response){ 
            if(response.getState() == "SUCCESS"){
                var status = response.getReturnValue();
                
                
                if(status == 'Received')
                {
                    helper.showToast('Stock is already Converted!','Error');
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get('v.recordId'),
                        "slideDevName": "detail"
                    });
                    navEvt.fire();
                 
                }
                else{
                   
                    var action1=component.get("c.saveNewRequest");
                    action1.setParams({'reqList':  component.get('v.stockRequests'),
                                       'recId': component.get('v.recordId')
                                      });
                    action1.setCallback(this,function(response){ 
                        //alert(response.getState());
                        if(response.getState() == "SUCCESS"){
                            
                            helper.showToast('Stock Request is updated Successfully!','Success');
                            
                            var navEvt = $A.get("e.force:navigateToSObject");
                            navEvt.setParams({
                                "recordId": response.getReturnValue(),
                                "slideDevName": "detail"
                            });
                            navEvt.fire();
                            
                            
                        }else if (response.getState() === "ERROR") {
                            //alert(1);
                            var errors = response.getError();
                            //alert(JSON.stringify(errors));
                            if (errors) {
                                if (errors[0] && errors[0].message) {
                                    alert("Error message: " + 
                                          errors[0].message);
                                }
                            }
                            component.set('v.disableBtn',false);
                        }
                        component.set('v.spinner',false);
                       // component.set('v.disableBtn',false);
                    });
                    $A.enqueueAction(action1); 
                }
                
            }else if (response.getState() === "ERROR") {
                //alert(1);
                var errors = response.getError();
                //alert(JSON.stringify(errors));
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                }
                component.set('v.disableBtn',false);
            }
            component.set('v.spinner',false);
            
        });
        $A.enqueueAction(action); 
        
        
        
    }, 
    showToast : function(message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type":type,
            "message":  message
        });
        toastEvent.fire();
    },
})