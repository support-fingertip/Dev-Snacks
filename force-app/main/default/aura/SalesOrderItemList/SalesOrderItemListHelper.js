({
    data:{'visits':[],
          'dailyLog': {}, 
          'accounts':[],'currentvisit':{},
          'products':[],
          'employees':[],
          'orders':[],
          'orderitems':[],
          'summaryCount':{'visitCount' : 0,'InProgress' : 0,'plannedVisits' : 0, 'completedVisits' : 0,'Postponed':0},
          'offlineRecords':0
         },
    scrollStopPropagation: function(e) {
        e.stopPropagation();
    },
    doInitHelper:function(component,event,helper){
        
        
        if(!window.navigator.onLine){
            component.set('v.data',  JSON.parse( localStorage.getItem("data") ) );
            //var data = JSON.parse( localStorage.getItem("data"));
            // alert('inside helpen dointit'+data);
            var offlinedata = 0;
            if(data == null || data == '' || data == 'null'){
                offlinedata = 0;
            }else{
                offlinedata=data.offlineRecords;
                if(offlinedata != null || offlinedata !=0 ||offlinedata !='' ){
                    component.set('v.spinner',false);
                    component.set('v.offlineCount',offlinedata);
                    component.set('v.onlineStatus',false);
                }
            }
        }else{
            var data = JSON.parse( localStorage.getItem("data"));
            var offlinedata = 0;
            if(data == null || data == '' || data == 'null'){
                offlinedata = 0;
            }else{
                offlinedata=data.offlineRecords;
            }
            if(offlinedata == null || offlinedata ==0 ||offlinedata =='' ){
                component.set('v.spinner',true);
                var action=component.get("c.getDailyLog");
                action.setCallback(this,function(response){
                    if(response.getState() == "SUCCESS"){ 
                        helper.data.dailyLog  = response.getReturnValue();
                        var action=component.get("c.getAccounts");    
                        action.setCallback(this,function(response){
                            if(response.getState()=="SUCCESS"){ 
                                helper.data.accounts = response.getReturnValue(); 
                                var action=component.get("c.getOrders");
                                action.setCallback(this,function(response){
                                    if(response.getState() == "SUCCESS"){ 
                                        
                                        // helper.data.orders = response.getReturnValue();
                                        var action=component.get("c.getOrderItems");
                                        action.setCallback(this,function(response){
                                            if(response.getState() == "SUCCESS"){ 
                                                
                                                //helper.data.orderitems = response.getReturnValue();
                                                var action=component.get("c.getproductList");
                                                action.setCallback(this,function(response){
                                                    if(response.getState() == "SUCCESS"){ 
                                                      
                                                        helper.data.products = response.getReturnValue();
                                                        var action=component.get("c.getTodaysVisits");
                                                        action.setCallback(this,function(response){
                                                            if(response.getState() == "SUCCESS"){ 
                                                                helper.data.visits = response.getReturnValue();
                                                                var action=component.get("c.getEmployees");
                                                                action.setCallback(this,function(response){ 
                                                                    if(response.getState() == "SUCCESS"){ 
                                                                        component.set('v.spinner',false);
                                                                        helper.data.employees = response.getReturnValue();
                                                                        component.set('v.data',  helper.data);
                                                                        //localStorage.setItem("data",   JSON.stringify(helper.data)   );
                                                                        helper.visitsCount(component,event,helper);
                                                                    }
                                                                    
                                                                });
                                                                $A.enqueueAction(action); 
                                                                
                                                            }
                                                        });
                                                        $A.enqueueAction(action); 
                                                    }
                                                });
                                                $A.enqueueAction(action); 
                                                
                                            }
                                        });
                                        $A.enqueueAction(action); 
                                        
                                        
                                    }
                                });
                                $A.enqueueAction(action);
                                
                            }
                        });
                        $A.enqueueAction(action);
                    }
                    
                });
                $A.enqueueAction(action);
            }else{
                helper.offlinedata(component, event, helper);
            }
            
        } 	
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
        
        if(rec.Payment_Type__c == ''){
            isValid = false;
            alert('Please select Payment Type.');
        }
        else if(rec.Payment_Type__c == 'Immediate'){
            if(rec.Mode_of_payment__c == ''){
                isValid = false;
                alert('Please select Mode of Payment.');
            }
            else if(rec.Mode_of_payment__c == 'Cheque' && (rec.Bank_Name__c == '' || rec.Bank_Name__c == undefined)){
                isValid = false;
                alert('Please select Bank Name.');
            }
                else if(rec.Mode_of_payment__c == 'Cheque' && (rec.Cheque_Trasaction_Number__c == '' || rec.Cheque_Trasaction_Number__c == undefined)){
                    isValid = false;
                    alert('Please enter Cheque Transaction Number.');
                }
                    else if(rec.Mode_of_payment__c == 'Cheque' && (rec.Cheque_Date__c == '' || rec.Cheque_Date__c == undefined)){
                        isValid = false;
                        alert('Please select Cheque Date.');
                    }
                        else if(rec.Mode_of_payment__c == 'Bank Transfer' && (rec.Bank_Name__c == '' || rec.Bank_Name__c == undefined)){
                            isValid = false;
                            alert('Please select Bank Name.');
                        }
        }
        
        
        return isValid;
    },
    
    saveOrder : function(component,event,helper) {  
        var oitems= component.get('v.orderItemList');
        var stockAvailable;
        //alert(JSON.stringify(data.orders));
        console.log('oitems-162:==='+JSON.stringify(oitems));
        
        for(var i=0; i<oitems.length; i++){
            //console.log('data.orderitems === '+JSON.stringify(data.orderitems[i]));
            console.log('oitems[i]-166:==='+JSON.stringify(oitems[i]));
            console.log('oitems[i].Stock__r-167:==='+JSON.stringify(oitems[i].Stock__r));
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
            else{
                if(oitems[i].Stock__r != undefined){
                    var qty = oitems[i].Stock__r.Available_Quantity__c +  oitems[i].Stock__r.Blocked_Quantity__c;
                    console.log('qty-181:===='+qty);
                    if(oitems[i].Quantity__c > qty){ 
                        stockAvailable = false;
                        helper.showToast("Added quantity is exceeding then available quantity for "+'"'+oitems[i].Product_Name__c+'"'+"","error");
                        component.set('v.disableBtn',false);
                        break;
                    }else{
                        stockAvailable = true; 
                    } 
                }
            }
            
            
        }
        console.log(stockAvailable)
        
        //alert(stockAvailable);
        
        if(stockAvailable == true){
            component.set('v.spinner', true);
            var action=component.get("c.createInvoice");
            action.setParams({'orderItemList': JSON.stringify(oitems),
                              'ordId':component.get('v.recordId'),
                              'paymentType':component.get('v.Receipt.Payment_Type__c')
                             });
            action.setCallback(this,function(response){ 
                if(response.getState() == "SUCCESS"){ 
                    var invId = response.getReturnValue();
                    if(component.get('v.Receipt').Payment_Type__c == 'Immediate'){
                        var action=component.get("c.saveReceipt");
                        action.setParams({'receipt': component.get('v.Receipt'),
                                          'amt':component.get('v.GrandTotalDisc'),
                                          'invId':invId
                                         });
                        action.setCallback(this,function(response){ 
                            if(response.getState() == "SUCCESS"){
                                if(response.getReturnValue() != null){
                                    component.set("v.Products", []);
                                    component.set("v.matchproducts", []);
                                    component.set("v.orderItemList", []);
                                    component.set("v.Order", {});
                                    component.set('v.GrandTotal',0.00);
                                    component.set('v.GrandTotalDisc',0.00);
                                    component.set('v.Receipt',{});
                                    
                                    component.set("v.showPayment",false);
                                    component.set('v.disApplied',false);
                                    component.set('v.spinner', false);
                                    // component.set('v.disableBtn',false);
                                    helper.showToast("Invoice created successfully","success");
                                    var navEvt = $A.get("e.force:navigateToSObject");
                                    navEvt.setParams({
                                        "recordId": invId,
                                        "slideDevName": "detail"
                                    });
                                    navEvt.fire();
                                }
                                else{
                                    helper.showToast("Error message: Some Error Occurred! Try after sometime or contact System Administrator!","error");
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
                            }
                        });
                        $A.enqueueAction(action); 
                        
                    }
                    else{
                        component.set("v.Products", []);
                        component.set("v.matchproducts", []);
                        component.set("v.orderItemList", []);
                        component.set("v.Order", {});
                        component.set('v.GrandTotalDisc',0.00);
                        
                        component.set('v.Receipt',{});
                        
                        component.set("v.showPayment",false);
                        component.set('v.disApplied',false);
                        component.set('v.spinner', false);
                        // component.set('v.disableBtn',false);
                        helper.showToast("Invoice created successfully","success");
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": invId,
                            "slideDevName": "detail"
                        });
                        navEvt.fire();
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
                }
            });
            $A.enqueueAction(action); 
        }
        
    }, 
    
    
    //-----------------------------------------------------------------------------------------------------------
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
    
    showToast : function(message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type":type,
            "message":  message
        });
        toastEvent.fire();
    },
    
    saveQuote : function(component,event,helper) {  
        var action=component.get("c.insertSalesItem");
        //alert(component.get('v.orderItemList'));
        console.log(component.get('v.orderItemList'));
        action.setParams({'quoteItemList':  JSON.stringify(component.get('v.orderItemList')),
                          'storeId':component.get('v.recordId')
                         });
        
        action.setCallback(this,function(response){ 
            //  alert(response.getState());
            
            if(response.getState() == "SUCCESS"){ 
                
                var qId = response.getReturnValue();
                component.set("v.orderItemList", []);
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": component.get('v.recordId'),
                    "slideDevName": "detail"
                });
                navEvt.fire();
                helper.showToast("Items updated successfully","success");
            }
            
            else if (response.getState() == "ERROR") {
                //    alert('1');
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action); 
        
        
    }
    
})