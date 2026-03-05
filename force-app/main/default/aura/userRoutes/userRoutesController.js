({
    doInit : function(component, event, helper) {
        
       
          component.set('v.storeColumns', [
            {label: 'Store Name', fieldName: 'Name', type: 'text'},
            {label: 'Contact Person', fieldName: 'Contact_Person__c', type: 'text'},
            {label: 'Mobile', fieldName: 'Phone', type: 'text'},
            {label: 'Street Name', fieldName: 'Street_Name__c', type: 'text'},
            {label: 'State', fieldName: 'State__c', type: 'text'},
            {label: 'District', fieldName: 'District__c', type: 'text'},
            {label: 'Route Name', fieldName: 'RouteName__c', type: 'text'},
            {label: 'Warehouse Name', fieldName: 'WarehouseName__c', type: 'text'},
            {label: 'Owner', fieldName: 'OwnerName__c', type: 'text'},
           
        ]);
         var actions3 = [
            { label: 'Show Stores', name: 'show_details3' }
        ];
         component.set('v.mycolumns3', [
          
              {label: 'Route Name', fieldName: 'Name', type: 'text'},
           {label: 'Warehouse Name', fieldName: 'warehouse_Name__c', type: 'text'},
          	{ type: 'action', typeAttributes: { rowActions: actions3 } }
           
        ]);
         component.set('v.mycolumns5', [
          
              {label: 'Route Name', fieldName: 'Name', type: 'text'},
           {label: 'Warehouse Name', fieldName: 'warehouse_Name__c', type: 'text'},
          	 {label: 'Owner Name', fieldName: 'OwnerName__c', type: 'text'},
           
        ]);
        component.set('v.mycolumns4', [
            {label: 'Store Name', fieldName: 'Name', type: 'text'},
            {label: 'Street Name', fieldName: 'Street_Name__c', type: 'text'},
            {label: 'State', fieldName: 'State__c', type: 'text'},
            {label: 'District', fieldName: 'District__c', type: 'text'},
            {label: 'Route Name', fieldName: 'RouteName__c', type: 'text'},
            {label: 'Warehouse Name', fieldName: 'WarehouseName__c', type: 'text'}
           
        ]);
        component.set('v.deleteStoreColumns', [
            {label: 'Store Name', fieldName: 'Name', type: 'text'},
            {label: 'State', fieldName: 'State__c', type: 'text'},
            {label: 'District', fieldName: 'District__c', type: 'text'},
            {label: 'Route Name', fieldName: 'RouteName__c', type: 'text'},
            {label: 'Warehouse Name', fieldName: 'WarehouseName__c', type: 'text'},
            {label: 'Owner', fieldName: 'OwnerName__c', type: 'text'}
           
        ]);
        var action = component.get("c.getUserList");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.users', result);
            }
        });
        $A.enqueueAction(action);
         var action2 = component.get("c.fetchaAllStore");
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.storesData', result);
               component.set('v.allStores', result);
            }
        });
        $A.enqueueAction(action2);
        var action3 = component.get("c.fetchaWarehouses");
        action3.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
               component.set('v.warehouses', result);
            }
        });
        $A.enqueueAction(action3);
    },
  
     fetchWarehouseRoutes : function(component, event, helper) {
        component.set('v.showWarehouseRoutes',false);
            component.set('v.mydata5',{});
           component.set('v.selectedRoutesCount',0);
          component.set('v.NextUserId','');
        if(component.get('v.warehouseId') != null && component.get('v.warehouseId') != ''){
             component.set('v.spinner',true);
                    var action = component.get("c.fetchRouteNames");
                    action.setParams({'whId':  component.get('v.warehouseId') })
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                          
                            var result = response.getReturnValue();
                            component.set("v.mydata5", response.getReturnValue());
                            component.set('v.showWarehouseRoutes',true);
                             component.set('v.spinner',false);
                        }
                    });
                    $A.enqueueAction(action);
        }
    },
   
     handleRowAction3: function (component, event, helper) {
         component.set('v.spinner',true);
        var row = event.getParam('row');
         component.set('v.routeName',row.Name);
         component.set('v.routeId',row.Id);
        var action = component.get("c.getStoreList");
        action.setParams({'routeId':  row.Id})
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.mydata4', response.getReturnValue());
                var  my4= component.get('v.mydata4');
                component.set('v.TotalStores', my4.length);
                component.set('v.showStores',true);
                component.set('v.spinner',false);
            }
        });
        $A.enqueueAction(action);
    },
    fetchRoutes : function(component, event, helper) {
        component.set('v.showRoutes',false);
        if(component.get('v.SEId') != null && component.get('v.SEId') != ''){
             component.set('v.spinner',true);
                    var action = component.get("c.getRouteList");
                    action.setParams({'uId':  component.get('v.SEId') })
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            var result = response.getReturnValue();
                            component.set("v.mydata3", response.getReturnValue());
                            component.set('v.showRoutes',true);
                             component.set('v.spinner',false);
                        }
                    });
                    $A.enqueueAction(action);
        }
    }, 
 updateSelectedStores: function (component, event, helper) {
         var selectedRows = event.getParam('selectedRows');
        component.set('v.selectedRowsCount', selectedRows.length);
        component.set('v.selectedstores', selectedRows);
        
    },
    updateSelectedRoutes:function (component, event, helper) {
         var selectedRows = event.getParam('selectedRows');
        component.set('v.selectedRoutesCount', selectedRows.length);
        component.set('v.selectedRoutes', selectedRows);
    },
showDeleteWarning: function (component, event, helper) {
         component.set('v.showDelete',true);
    },
 closeDeleteWarning: function (component, event, helper) {
         component.set('v.showDelete',false);
        
    },
doDelete: function (component, event, helper) {
            component.set('v.showDelete',false);
        component.set('v.spinner',true);
 var action = component.get("c.deleteStores");
        action.setParams({'stores': component.get('v.selectedstores')})
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.storesData',{});
                 component.set('v.storesData', response.getReturnValue());
                 component.set('v.searchText','')
                /*component.set('v.selectedstores','');
                alert(component.get('v.selectedstores'));
                component.set('v.selectedRowsCount',0);
                alert( component.get('v.selectedRowsCount'));*/
                 component.set('v.spinner',false);
                 helper.showToast("Selected Stores Deleted","warning");
            }
        });
        $A.enqueueAction(action);
        
    },
    
    doSearch : function(component, event, helper) {
        var stores= component.get('v.allStores');
        var searchText= component.get('v.searchText');
             var matchstores=[];
        if(searchText !=''){
        for(var i=0;i<stores.length; i++){ 
            if(stores[i].Name.toLowerCase().indexOf(searchText.toLowerCase())  != -1  ){
               matchstores.push( stores[i] )
            } 
         } 
            if(matchstores.length >0){
		 component.set('v.storesData',matchstores);
            }else{
                component.set('v.storesData',{});
            }
        }else{
            component.set('v.storesData',stores);
        }
       
       
    },
  changeRouteUser : function (component, event, helper) {
    if(component.get('v.NextUserId') != null && component.get('v.NextUserId') != ''){
        component.set('v.spinner',true);
 var action = component.get("c.changeRouteOwner");
        action.setParams({'routes': component.get('v.selectedRoutes'),
                          'whId': component.get('v.warehouseId'),
                          'nextuId':component.get('v.NextUserId')})
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 component.set('v.mydata5',{});
                component.set('v.mydata5',response.getReturnValue());
                 component.set('v.spinner',false);
                 helper.showToast("Routes owner changed","Success");
            }
        });
        $A.enqueueAction(action);
    }else{
         helper.showToast("Please select Assigning To","error");
    }
    },
})