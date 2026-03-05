({
    data:{'currentvisit':{},
          'stocks':[]
         },
    addProductRecord: function(component, event) {
        var productList = component.get("v.orderItemList");
        productList.push({
            'sObjectType': 'Sales_order_item__c',
            'Stock__c':'',
            'Product__c':'',
            'Quantity__c': '',
            'Rate__c': '',
            'Unit_Price__c': '',
            'GST_Percentage__c': '',
            'Total__c':'',
            'Sales_Tax__c':'',
            'Discount_Percent__c':'',
            'Cash_Discount__c':component.get('v.cashDiscount')
            
        });
        component.set("v.orderItemList", productList);
        //alert(5)
    },
    validateOrderList: function(component, event) {
        var isValid = true;
        var orderList = component.get("v.orderItemList");
        var rec = component.get("v.Receipt");
        for (var i = 0; i < orderList.length; i++) {
            
            if (orderList[i].Product__c == '') {
                isValid = false;
                alert('Product Name cannot be blank on row number ' + (i + 1));
            }else if(orderList[i].Quantity__c == '' || orderList[i].Quantity__c == null){
                isValid = false;
                alert('please enter quantity on row number ' + (i + 1));
            }
        }
        
        return isValid;
    },
    saveOrder : function(component,event,helper) {  
        
        if(window.navigator.onLine){
            var oitems= component.get('v.orderItemList');
            var stockAvailable;
            
            console.log('oitems-162:==='+JSON.stringify(oitems));
            
            /*for(var i=0; i<oitems.length; i++){
            
            console.log('oitems[i]-166:==='+JSON.stringify(oitems[i]));
          
            if(oitems[i].Available_Quantity__c != undefined){
                console.log(oitems[i].Quantity__c + '----' + oitems[i].Available_Quantity__c);
                if(oitems[i].Quantity__c > oitems[i].Available_Quantity__c){
                    stockAvailable = false;
                    helper.showToast("Added quantity is exceeding then available quantity for "+'"'+oitems[i].Product_Name__c+'"'+"","error");
                    component.set('v.disableBtn',false);
                    break;
                }else{
                    stockAvailable = true; 
                }
            }
        }*/
            stockAvailable = true; 
            console.log(stockAvailable)
            
            if(stockAvailable == true){
                component.set('v.spinner', true);
                var action=component.get("c.createOrder");
                action.setParams({'orderItemList': JSON.stringify(oitems),
                                  'order':component.get('v.Order')
                                 });
                action.setCallback(this,function(response){ 
                    if(response.getState() == "SUCCESS"){ 
                        var invId = response.getReturnValue();
                        
                        component.set("v.Stocks", []);
                        component.set("v.matchstocks", []);
                        component.set("v.orderItemList", []);
                        component.set("v.Order", {});
                        component.set('v.GrandTotalDisc',0.00);
                        component.set('v.GrandTotal',0.00);
                        
                        component.set('v.spinner', false);
                        
                        helper.showToast("Order created successfully","success");
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": invId,
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
                $A.enqueueAction(action); 
            }
        }
        else{
            helper.showToast("You are offline!","info");
        }
        
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