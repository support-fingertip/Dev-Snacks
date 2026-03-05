({
	convertSalesOrder : function(component, event, helper, recordId) {
		//alert('convert sales order');
        var action = component.get("c.createInvoice");
        action.setParams({
            'recordId' : recordId
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                
                var result = response.getReturnValue();
                if(result){
                    //alert('Sales Inv=== '+ JSON.stringify(result.Id));
                    var salesInvoiceId = result.Id;
                    helper.convertSalesInvoiceItems(component, event, helper, recordId, salesInvoiceId);
                }
                //helper.showToast('success','Sales order is converted!!','Sales order converted and created new sales invoice.');
            }else if (state === "ERROR") {
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
	},
    
    convertSalesInvoiceItems: function(component, event, helper, salesOrderId, salesInvoiceId){
        //alert('create sales Invoice Items.');
        console.log('Sales order Id=== '+salesOrderId);
        console.log('sales Invoice Id=== '+salesInvoiceId);
        var action = component.get("c.createInvoiceItems");
        action.setParams({
            salesOrderId : salesOrderId,
            salesInvoiceId : salesInvoiceId
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            //alert('state=== '+state);
            if(state === "SUCCESS"){
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                var salesInvoiceName = response.getReturnValue();
                if(salesInvoiceName){
                    helper.showToast('success','Sales invoice items are created!!','Sales invoices items for sales invoice are created successfully. Sales Invoice '+'"'+salesInvoiceName+'"'+' is Converted.');
                }
            }else if(state === "ERROR"){
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
    },
    
    showToast : function(type,title,message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            title : title,
            message: message,
        });
        toastEvent.fire();
    }
})