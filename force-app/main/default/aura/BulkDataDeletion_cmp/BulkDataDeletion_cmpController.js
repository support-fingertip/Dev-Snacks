({
    handleDeleteAlert : function(component, event, helper) {
        var isAllValid = component.find('rec').reduce(function(isValidSoFar, inputCmp){
            inputCmp.showHelpMessageIfInvalid();
            return isValidSoFar && inputCmp.checkValidity();
        },true);
        if(isAllValid == true){
            component.set('v.showAlert',true);
        }
    },
    handleDelete : function(component, event, helper) {
        component.set('v.showAlert',false);
        var action = component.get("c.callDeleteBatch");
        action.setParams({
            startDate: component.get("v.startDate"),
            endDate: component.get("v.endDate"),
            objectName: component.get("v.objectName")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var records = response.getReturnValue();
                
                component.find('notifLib').showToast({
                    "variant": "success",
                    "title": "Your request to delete "+records+" records successfully submited"
                });
                 $A.get('e.force:refreshView').fire();

            } else {
                // Handle errors here
                var errors = response.getError();
                console.error(errors);
                component.find('notifLib').showToast({
                    "variant": "Error",
                    "title": JSON.stringify(errors)
                });
            }
        });
        
        $A.enqueueAction(action);	
    },
    handlePreview : function(component, event, helper) {
        var isAllValid = component.find('rec').reduce(function(isValidSoFar, inputCmp){
            inputCmp.showHelpMessageIfInvalid();
            return isValidSoFar && inputCmp.checkValidity();
        },true);
        if(isAllValid == true){
             component.set('v.showRecords',true);
            var actions = [
                { label: 'Show details', name: 'show_details' } ]; 
            component.set('v.columns', [
                  {label: 'Name', fieldName: 'linkName', type: 'url', typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}, },
                { label: "Created Date", fieldName: "CreatedDate", type: "date", typeAttributes: {
                year: "numeric",
                month: "short",
                day: "2-digit"
            }},
                { type: 'action', typeAttributes: { rowActions: actions } }
            ]); 
            var pageNumber = component.get("v.PageNumber");  
            var pageSize = component.find("pageSize").get("v.value");
            helper.getData(component, pageNumber, pageSize);
           
        }
    },
    handleNext: function(component, event, helper) {
        component.set('v.showSpinner',true);
        var pageNumber = component.get("v.PageNumber");  
        var pageSize = component.find("pageSize").get("v.value");
        pageNumber++;
        component.set("v.selectedRowsCount",0);  
        component.set("v.selectedRows",[]);  
        helper.getData(component, pageNumber, pageSize);
        
        component.set('v.showSpinner',false);
    },
    
    handlePrev: function(component, event, helper) {
        component.set('v.showSpinner',true);
        var pageNumber = component.get("v.PageNumber");  
        var pageSize = component.find("pageSize").get("v.value");
        pageNumber--;
        helper.getData(component, pageNumber, pageSize);       
        component.set('v.showSpinner',false);  
    },
    handleRowAction: function (cmp, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'show_details':
                {
                    var bse =  window.location.hostname;
                    var ful = bse+'/' + row.Id;
                    window.open('https://'+ful);  
                    break;
                }
                
        }
    },
    closeDeteAlert : function(component, event, helper) {
        component.set('v.showAlert',false);
    },
    onSelectChange: function(component, event, helper) {
        var isAllValid = component.find('rec').reduce(function(isValidSoFar, inputCmp){
            inputCmp.showHelpMessageIfInvalid();
            return isValidSoFar && inputCmp.checkValidity();
        },true);
        if(isAllValid == true){
            component.set('v.showSpinner',true);
            var page = 1
            var pageNumber = component.get("v.PageNumber");  
            var pageSize = component.find("pageSize").get("v.value");
            helper.getData(component, pageNumber, pageSize);
            component.set('v.showSpinner',false);
        }
    },
    updateSelectedData: function (component, event) {
        var selectedRows = event.getParam('selectedRows');
        component.set('v.selectedRowsCount', selectedRows.length);
        component.set('v.selectedRows', selectedRows);
        
    },
    handleDeleteSelectedAlert : function(component, event, helper) {
        component.set('v.showAlertSelected',true);
        
    },
    closeSelectedDeteAlert : function(component, event, helper) {
        component.set('v.showAlertSelected',false);
        
    },
      handleDeleteSelected : function(component, event, helper) {
        component.set('v.showAlertSelected',false);
        var action = component.get("c.callDeleteSelected");
        action.setParams({
            deletedata: component.get("v.selectedRows")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var records = response.getReturnValue();
                
                component.find('notifLib').showToast({
                    "variant": "success",
                    "title": "Selected records successfully deleted"
                });
                 $A.get('e.force:refreshView').fire();

            } else {
                // Handle errors here
                var errors = response.getError();
                console.error(errors);
                component.find('notifLib').showToast({
                    "variant": "Error",
                    "title": JSON.stringify(errors)
                });
            }
        });
        
        $A.enqueueAction(action);	
    },
    
})