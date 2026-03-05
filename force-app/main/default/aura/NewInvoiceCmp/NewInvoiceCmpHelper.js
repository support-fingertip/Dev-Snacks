({
    data:{'currentvisit':{},
          'stocks':[],
          'wrapper':[]
         },
   
    validateInvoiceList: function(component, event) {
        var isValid = true;
        var invoiceList = component.get("v.invoiceItemList");
        var rec = component.get("v.Receipt");
        for (var i = 0; i < invoiceList.length; i++) {
            
            if (invoiceList[i].Product__c == '') {
                isValid = false;
                alert('Product Name cannot be blank on row number ' + (i + 1));
            }else if(invoiceList[i].Quantity__c == '' || invoiceList[i].Quantity__c == null){
                isValid = false;
                alert('please enter quantity on row number ' + (i + 1));
            }
        }
        
        return isValid;
    },
    saveInvoice : function(component,event,helper) {  
        
        if(window.navigator.onLine){
            var oitems= component.get('v.invoiceItemList');
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
                var action=component.get("c.createInvoice");
                action.setParams({'invoiceItemList': JSON.stringify(oitems),
                                  'invoice':component.get('v.Invoice')
                                 });
                action.setCallback(this,function(response){ 
                    if(response.getState() == "SUCCESS"){ 
                        var invId = response.getReturnValue();
                        
                        component.set("v.Stocks", []);
                        component.set("v.matchstocks", []);
                        component.set("v.invoiceItemList", []);
                        component.set("v.Invoice", {});
                        component.set('v.GrandTotalDisc',0.00);
                        component.set('v.GrandTotal',0.00);
                        component.set('v.cartProductIds',[]);
                        component.set('v.cartItems','');
                        
                        component.set('v.spinner', false);
                        
                        helper.showToast("Invoice created successfully","success");
                        $A.enqueueAction(component.get('c.doInit'));
                        $A.get("e.force:refreshView").fire();
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