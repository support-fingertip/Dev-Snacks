({
	getProducts : function(component, event) {
		component.set('v.spinner', true);
        var action = component.get("c.getProducts");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var db = response.getReturnValue();
                //alert('db=== '+db);
                if(db){
                    for (var i = 0; i < db.length; i++) {
                        db[i].check = false;
                    }
                    component.set('v.Products', db);
                    component.set('v.spinner', false);
                }else{
                    helper.showToast('Stock is not available.', 'Information');
                    component.set('v.spinner', false);
                }
            }
        });
        $A.enqueueAction(action);
        
	},
     addReplaceRecord: function(component, event) {
         var items = component.get('v.replaceItems');
        items.push({
            'sObjectType': 'Replaced_Item__c',
            'Name':'',
            'Product__c':'',
            'Damaged_Stock__c':'',
            'New_Stock__c':'',
            'Quantity__c': '',
            'MRP__c':'',
            'searchIndexPrd':'',
            'searchIndexNewStock':'',
             'searchIndexDmgStock':'',
            'matchproducts':[],
            'matchDmgStocks':[],
            'matchNewStocks':[],
            'newStockList':[],
            'stockList':[]
        });
        component.set("v.replaceItems", items);
        //alert(JSON.stringify(items))
    },
    saveRecord : function(component, event, helper) {
         component.set('v.spinner', true);
       
        var action1=component.get("c.saveReplacement");
        action1.setParams({'parentRec':  component.get('v.Replacement'),
                           'items':component.get('v.replaceItems'),
                           'type':'Replacement'
                          });
        action1.setCallback(this,function(response){ 
          
            if(response.getState() == "SUCCESS"){
                
                helper.showToast('Item Replacement Records has been created Successfully!','Success');
                component.set('v.spinner', false);
                var evt = $A.get("e.force:navigateToComponent");
                evt.setParams({
                    componentDef : "c:MobileVisit",
                });
                evt.fire();               
                
                
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
      validate: function (component, event, helper) {
        var isValid = true;
        var replList = component.get("v.replaceItems");
          var type = component.get('v.type');
            for (var i = 0; i < replList.length; i++) {
                if(replList[i].Quantity__c > replList[i].Available_Quantity__c ){
                    isValid = false;
                    // alert('please enter quantity on row number ' + (i + 1));
                    helper.showToast('Available Quantity exceeds at row ' + (i + 1) + '.','error');
                    break;
                }
                if(replList[i].Damaged_Stock__c == null || replList[i].Damaged_Stock__c == ''){
                    isValid = false;
                    // alert('please enter quantity on row number ' + (i + 1));
                    helper.showToast('Enter Damaged stock at row ' + (i + 1) + '.','error');
                     break;
                }
                 if((replList[i].New_Stock__c == null || replList[i].New_Stock__c == '')){
                    isValid = false;
                    // alert('please enter quantity on row number ' + (i + 1));
                    helper.showToast('Enter New stock at row ' + (i + 1) + '.','error');
                      break;
                }
            }
    
        return isValid;
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