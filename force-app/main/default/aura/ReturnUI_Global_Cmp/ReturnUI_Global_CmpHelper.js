({
    clearValues : function(component, event, helper) {
        
    },
    helperclickInvoice : function(component, event, helper) {
        component.set('v.spinner', true);
        var invid = component.get('v.salesInvoiceId')
        var items = component.get('v.returnItems');
        items = [];
        var action=component.get("c.getInvoiceItems");
        action.setParams({ invId:invid});
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == "SUCCESS" ){ 
                var db = response.getReturnValue();
                
                for (var i = 0; i < db.length; i++){
                    
                    items.push({
                        'Invoice_Item__c':db[i].Id,
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
                }
                
                component.set('v.showItems', true);
                component.set('v.returnItems', items);
                component.set('v.spinner', false);
                component.set('v.GrandTotal', 0);
                //  component.set('v.disableSave', true);
            }
        });
        $A.enqueueAction(action);
    },
    saveReturns: function (component, event, helper) {
        component.set('v.spinner', true);
        var action1=component.get("c.saveNewReturn");
        action1.setParams({'returnId':  component.get('v.recordId').toString(),
                           'routeId':component.get('v.routeId').toString(),
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
                var errors = response.getError();
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
        try{
        var isValid = true;

        var orderList = component.get("v.returnItems");
        var returnType =component.get("v.returnType");
        var salesinvoiceId =component.get('v.agSalesInvoiceId');
        
       if(returnType == 'Against Customer' && (salesinvoiceId == '' || salesinvoiceId == null)){
            isValid = false;
            helper.showToast('Please select SalesInvoice.','error')
        }
            else if(returnType == 'Against Invoice'){
                for (var i = 0; i < orderList.length; i++) {
                    
                    if(orderList[i].Quantity__c > orderList[i].Inv_Quantity){
                        isValid = false;
                        // alert('please enter quantity on row number ' + (i + 1));
                        helper.showToast('Returns Quantity cannot be more than Invoice Quantity at row ' + (i + 1) + '.','error')
                        
                    } 
                }
            }else if(returnType == 'Against Customer'){
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
             }catch(error){
                console.error(error.message);
            }
    },
     addReturnRecord: function(component, event,helper) {
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