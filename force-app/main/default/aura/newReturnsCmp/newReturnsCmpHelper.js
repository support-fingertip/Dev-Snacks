({
    saveReturns: function (component, event, helper) {
        component.set('v.spinner', true);
        var action1=component.get("c.saveNewReturn");
        action1.setParams({'returnrec':  component.get('v.Return'),
                           'items':component.get('v.returnItems')
                          });
        action1.setCallback(this,function(response){ 
            //alert(response.getState());
            if(response.getState() == "SUCCESS"){
                
                helper.showToast('Credit note has been created Successfully!','Success');
                component.set('v.spinner', false);
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
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                }
            }
        });
        $A.enqueueAction(action1); 
        
    },
    validateOrderList: function (component, event, helper) {
        var isValid = true;
        var order = component.get('v.Return');
        var orderList = component.get("v.returnItems");
        
        //alert(JSON.stringify(order))
        if (order.Return_Type__c == '' || order.Return_Type__c == null ) {
            isValid = false;
            helper.showToast('Please select Return Type.','error')
            
        }
        else if (order.Return_Date__c == '' || order.Return_Date__c == null ) {
            isValid = false;
            helper.showToast('Please select Return Date.','error')
            
        }
        else if(order.Type__c == 'Against Customer' && (order.Debit_Note_Number__c == '' || order.Debit_Note_Number__c == null)){
            isValid = false;
            helper.showToast('Please enter Debit Note Number.','error')
        }
        else if(order.Type__c == 'Against Customer' && (order.Debit_Note_Date__c == '' || order.Debit_Note_Date__c == null)){
            isValid = false;
            helper.showToast('Please select Debit Note Date.','error')
        } else if(order.Type__c == 'Against Customer' && (order.Sales_Invoice__c == '' || order.Sales_Invoice__c == null)){
            isValid = false;
            helper.showToast('Please select SalesInvoice.','error')
        }
        else if(order.Type__c == 'Against Invoice'){
               for (var i = 0; i < orderList.length; i++) {
                
                if(orderList[i].Quantity__c > orderList[i].Inv_Quantity){
                    isValid = false;
                    // alert('please enter quantity on row number ' + (i + 1));
                    helper.showToast('Returns Quantity cannot be more than Invoice Quantity at row ' + (i + 1) + '.','error')
                    
                } 
            }
        }else if(order.Type__c == 'Against Customer'){
            for (var i = 0; i < orderList.length; i++) {
                if(orderList[i].Product__c == null || orderList[i].Product__c == '' ){
                    isValid = false;
                    helper.showToast('Choose Product  at row ' + (i + 1) + '.','error')
                    
                }
                    if(orderList[i].Quantity__c <= 0 || orderList[i].Quantity__c == null || orderList[i].Quantity__c == '' ){
                    isValid = false;
                    helper.showToast('Enter valid Quantity  at row ' + (i + 1) + '.','error')
                    
                }
            }
            }
        
      
        return isValid;
    },
     addReturnRecord: function(component, event) {
         var items = component.get('v.returnItems');
        items.push({
            'sObjectType': 'Return_Item__c',
            'Name':'',
            'Batch_No__c':'',
            'Product__c':'',
            'Quantity__c': '',
            'Rate__c': '',
            'Unit_Price__c': '',
            'GST_Percentage__c': '',
            'Total__c':''            
        });
        component.set("v.returnItems", items);
        //alert(JSON.stringify(items))
    },
     helperclickInvoice : function(component, event, helper) {
        component.set('v.spinner', true);
        var invid = component.get('v.Return.Sales_Invoice__c').toString();
        var items = component.get('v.returnItems');
        items = [];
        var action=component.get("c.getItems");
        action.setParams({ invId:invid});
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == "SUCCESS" ){ 
                var db = response.getReturnValue();
                
                for (var i = 0; i < db.length; i++){
                    
                    items.push({
                        'Invoice_Item__c':db[i].Id,
                        //'Stock__c': db[i].Stock__c,
                        'Batch_No__c':db[i].Batch_No__c,
                        'Product__c':db[i].Product__c,
                        'Stock__c':db[i].Stock__c,
                        'Item_Name__c': db[i].Item_Name__c,
                        'GST_Percentage__c': db[i].Sales_Tax__c,
                        'GST_Value__c': db[i].GST_Value__c,
                        'Name': db[i].Item_Name__c,
                        'Type__c':'',
                        'Remarks__c' : '',
                        'Quantity__c':0.00,
                        'Inv_Quantity':db[i].Quantity__c,
                        'Rate__c':db[i].Rate__c,
                        'Unit_Price__c':db[i].Unit_Price__c,
                        'Cash_Discount__c':db[i].Cash_Discount__c,
                        'Customer_Discount__c':db[i].Customer_Discount__c,
                        'UnitPriceWithDiscount__c':db[i].UnitPriceWithDiscount__c,
                        'Total__c':0
                    });
                    component.set('v.cashDiscount', db[i].Cash_Discount__c);
                    component.set('v.Return.Customer__c', db[i].Sales_Invoice__r.Customer__c);
                    component.set('v.customerName', db[i].Sales_Invoice__r.Customer__r.Name);
                }
                
                component.set('v.showItems', true);
                component.set('v.returnItems', items);
                component.set('v.spinner', false);
                component.set('v.GrandTotal', 0);
                component.set('v.disableSave', true);
            }
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