({
	addProduct: function(component, event,helper) {
        var items = component.get('v.ItemList');
        items.push({
            'sobjectType':'PO_Item__c',
            'Product__c': '',
            'Ordered_Quantity__c': '',
            'Unit_Price__c': '',
            'Total_Price__c':'',
            'Product_Name__c':'',
            'Tax__c':''
        });
        component.set("v.ItemList", items);
    },
     getExistingData : function(component, event,helper) {
        var action=component.get("c.getdata");
        action.setParams({'recId':  component.get('v.recordId')  })
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){ 
                var db = response.getReturnValue();
                component.set('v.GrandTotal',db.grandTotal);
                component.set('v.vendorId',db.vendorId);
                component.set('v.vendorName',db.vendorName);
                component.set('v.poDate',db.poDate);
                component.set('v.Products',db.productList);
                component.set('v.vendors',db.vendorList);
                component.set('v.showRecord',true);
                console.log(db.recList);
                if(db.recList !='' && db.recList !=undefined){
                component.set('v.ItemList', db.recList );
                }else{
                    console.log('no list');
                    helper.addProduct(component, event,helper);
                   
                }
            }
        });
        $A.enqueueAction(action); 
    },
    validateItemList: function(component, event) {
        var isValid = true;
        var itemList = component.get("v.ItemList");
        for (var i = 0; i < itemList.length; i++) {
            if (itemList[i].Product__c == '') {
                isValid = false;
                alert('Product Name cannot be blank on row number ' + (i + 1));
            }else if(itemList[i].Ordered_Quantity__c == '' || itemList[i].Ordered_Quantity__c == null){
                isValid = false;
                alert('please enter quantity on row number ' + (i + 1));
            }
        }
        return isValid;
    },
    saveRecord : function(component,event,helper) {
      console.log(JSON.stringify(component.get('v.itemList')));
        var action=component.get("c.insertItemList");
        action.setParams({'ItemList': component.get('v.itemList'),
                          'parentId':component.get('v.recordId'),
                          'objName' : component.get("v.sObjectName"),
                          'vendorId': component.get("v.vendorId"),
                          'poDate': component.get("v.poDate")
                         });
        action.setCallback(this,function(response){ 
            if(response.getState() == "SUCCESS"){ 
                var qId = response.getReturnValue();
                component.set("v.POId",qId);
                 component.set("v.vendorId",'');
                 component.set("v.poDate",'');
                 component.set("v.vendorName",'');
                component.set('v.showRecord',false);
                component.set('v.showPdf',true);
                component.set("v.Products", []);
                component.set("v.matchproducts", []);
                 component.set("v.vendors", []);
                component.set("v.matchVendors", []);
                component.set("v.itemList", []);
                component.set('v.GrandTotal',0.00);
                /*  var navEvt = $A.get("e.force:navigateToSObject");
    navEvt.setParams({
         "recordId": component.get('v.recordId'),
      "slideDevName": "detail"
    });
    navEvt.fire();*/
                
                helper.showToast("Record created successfully","success");
            }
        });
        $A.enqueueAction(action); 
        
    }, 
     sendEmail:function(component, event, helper) {
      //  alert(component.get('v.quoteId'))
        var action=component.get("c.sendEmailtoCustomer");
        action.setParams({'quoteId':  component.get('v.quoteId'),
                          'storeId':component.get('v.recordId'),
                          'objName' : component.get("v.sObjectName")
                         });
        action.setCallback(this,function(response){ 
            if(response.getState() == "SUCCESS"){ 
               //alert(response.getResponseValue());
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": component.get('v.recordId'),
                    "slideDevName": "detail"
                });
                navEvt.fire();
                
                helper.showToast("Quote sent to your email successfully.","success");
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