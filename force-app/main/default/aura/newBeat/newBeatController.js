({
    doInit : function(component, event, helper) {
        var actions = [
            { label: 'Show details', name: 'show_details' }
            
            
        ];
        component.set('v.mycolumns', [
            {label: 'Store Name', fieldName: 'Name', type: 'text'},
            {label: 'Store category', fieldName: 'Store_Category__c', type: 'text'},
             {label: 'Warehouse', fieldName: 'WarehouseName__c', type: 'text'},
            {label: 'Route', fieldName: 'RouteName__c', type: 'text'},
            { type: 'action', typeAttributes: { rowActions: actions } }
        ]);
        
        var actions1 = [
            { label: 'Show details', name: 'show_details1' }
            
            
        ];
        component.set('v.mycolumns1', [
            {label: 'Beat Id', fieldName: 'Name', type: 'text'},
            {label: 'Beat Date', fieldName: 'Beat_Date__c', type: 'text'},
            {label: 'Warehouse', fieldName: 'WarehouseName__c', type: 'text'},
            {label: 'Route', fieldName: 'RouteName__c', type: 'text'},
            { type: 'action', typeAttributes: { rowActions: actions1 } }
        ]);
        
        component.set('v.mycolumns2', [
            {label: 'Store Name', fieldName: 'Account_Name__c', type: 'text'},
            {label: 'Status', fieldName: 'Status__c', type: 'text'}
           
        ]);
         var actions3 = [
            { label: 'Show details', name: 'show_details3' }
        ];
         component.set('v.mycolumns3', [
          	{label: 'Beat Id', fieldName: 'Name', type: 'text'},
            {label: 'Beat Date', fieldName: 'Beat_Date__c', type: 'text'},
           {label: 'Warehouse', fieldName: 'WarehouseName__c', type: 'text'},
            {label: 'Route', fieldName: 'RouteName__c', type: 'text'},
          	{ type: 'action', typeAttributes: { rowActions: actions3 } }
           
        ]);
        component.set('v.mycolumns4', [
            {label: 'VisitId', fieldName: 'Name', type: 'text'},
            {label: 'Store Name', fieldName: 'Account_Name__c', type: 'text'},
            {label: 'Status', fieldName: 'Status__c', type: 'text'}
           
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
    },
    getRoutes : function(component, event, helper) {
         component.set('v.spinner',true);
        component.set('v.mydata',{});
         component.set('v.searchText','');
        var action = component.get("c.getRouteList");
        action.setParams({'uId':  component.get('v.userId')})
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.allroutes', response.getReturnValue());
                component.set('v.spinner',false);
                
            }
        });
        $A.enqueueAction(action);
    },
   
    updateSelectedText: function (component, event) {
        var selectedRows = event.getParam('selectedRows');
        component.set('v.selectedRowsCount', selectedRows.length);
        component.set('v.selectedstores', selectedRows);
        
    },
    
    runBeat: function (component, event,helper) {
      
         var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        var dateValue = $A.localizationService.formatDate(component.get('v.startdate'), "YYYY-MM-DD");
      
        if(dateValue >= today){
           
         window.scroll(0,0);
          
        component.set('v.spinner',true);
           console.log('start');
        var action = component.get("c.createBeat");
        action.setParams({'uId':  component.get('v.userId'),
                          'stores': component.get('v.selectedstores'),
                          'sdate' : component.get('v.startdate'),
                          'route' : component.get('v.routeId')
                         })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // alert(6);
                 component.set("v.mydata1", response.getReturnValue());
                var data =  component.get('v.mydata');
                component.set('v.mydata', '');
                component.set('v.mydata', data);
                component.set('v.selectedRowsCount', 0);
                 component.set('v.spinner',false);
                 helper.showToast("Beat created succesfully","Success");
            }
        });
        $A.enqueueAction(action);
        }else{
            //alert(4);
            helper.showToast("Please select Today's date or future date","error");
        }
    },
    handleRowAction: function (component, event, helper) {
        var bse =  window.location.hostname;
        var row = event.getParam('row');
        var ful = bse+'/' + row.Id;
        window.open('https://'+ful);  
    },
    handleRowAction1: function (component, event, helper) {
         component.set('v.spinner',true);
        component.set('v.showBeats',false);
        var row = event.getParam('row');
        var action = component.get("c.getvisitList");
        action.setParams({'BeatId':  row.Id})
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.mydata2', response.getReturnValue());
                component.set('v.showvisits',true);
                component.set('v.spinner',false);
                
            }
        });
        $A.enqueueAction(action);
    },
    docancel: function (component, event, helper) {
        component.set('v.showvisits',false);
        component.set('v.showBeats',true);
        
    },
    updateSelectedText2: function (component, event) {
        var selectedRows = event.getParam('selectedRows');
        component.set('v.selectedRowsCount2', selectedRows.length);
        component.set('v.selectedstores2', selectedRows);
       
    },
     runagainBeat: function (component, event,helper) {
        component.set('v.spinner',true);
        var action = component.get("c.createnewBeat");
        action.setParams({'uId':  component.get('v.userId'),
                          'stores': component.get('v.selectedstores2'),
                          'sdate' : component.get('v.startdate'),
                          'route' : component.get('v.routeId')
                         })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 component.set("v.mydata1", response.getReturnValue());
                component.set('v.showvisits',false);
                component.set('v.spinner',false);
                 component.set('v.showBeats',true);
                 helper.showToast("Beat created succesfully","Success");
       
            }
        });
        $A.enqueueAction(action);
        
    },
 
     fetchbeats : function(component, event, helper) {
        component.set('v.showupcoming',false);
        if(component.get('v.SEId') != null && component.get('v.SEId') != ''){
             component.set('v.spinner',true);
                    var action = component.get("c.getupcominbeats");
                    action.setParams({'uId':  component.get('v.SEId') })
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            var result = response.getReturnValue();
                            component.set("v.mydata3", response.getReturnValue());
                            component.set('v.showupcoming',true);
                             component.set('v.spinner',false);
                        }
                    });
                    $A.enqueueAction(action);
        }
    },
     handleRowAction3: function (component, event, helper) {
         component.set('v.spinner',true);
        component.set('v.showupcoming',false);
        var row = event.getParam('row');
         component.set('v.beatId',row.Id);
        var action = component.get("c.getvisitList");
        action.setParams({'BeatId':  row.Id})
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.mydata4', response.getReturnValue());
                component.set('v.showrecent',true);
                component.set('v.spinner',false);
                
            }
        });
        $A.enqueueAction(action);
    },
     docancel2: function (component, event, helper) {
        component.set('v.showrecent',false);
        component.set('v.showupcoming',true);
         component.set('v.beatId','');
    },
     updateSelectedText4: function (component, event) {
        var selectedRows = event.getParam('selectedRows');
        component.set('v.selectedRowsCount4', selectedRows.length);
        component.set('v.selectedstores4', selectedRows);
       
    },
    changeBeatOwner: function (component, event,helper) {
      
        if(component.get('v.NextUserId') != null && component.get('v.NextUserId') !='' && component.get('v.NextUserId') !=undefined){
           
             component.set('v.spinner',true);
        var action = component.get("c.changeVisitOwner");
        action.setParams({'uId':  component.get('v.SEId'),
                          'stores': component.get('v.selectedstores4'),
                          'assId' : component.get('v.NextUserId'),
                          'beId' : component.get('v.beatId')
                         })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                  component.set('v.mydata3', response.getReturnValue());
                component.set('v.showrecent',false);
                 component.set('v.showupcoming',true);
                component.set('v.spinner',false);
            
                 helper.showToast("Beat owner changed succesfully","Success");
       
            }
        });
        $A.enqueueAction(action);
            
        }else{
          
           helper.showToast("Plaese Select Assigning user","warning");
        }
        
        
    },
    
     searchText : function(component, event, helper) {
        var routes= component.get('v.allroutes');
        var searchText= component.get('v.searchText');
        var matchroutes=[];
        if(searchText !=''){
        for(var i=0;i<routes.length; i++){ 
            if(routes[i].Name.toLowerCase().indexOf(searchText.toLowerCase())  != -1  ){
               matchroutes.push( routes[i] )
            } 
         } 
            if(matchroutes.length >0){
		 component.set('v.matchRoutes',matchroutes);
            }
        }else{
            component.set('v.matchRoutes',[]);
        }
    },update: function(component, event, helper) {
        component.set('v.routeId', event.currentTarget.dataset.id);
        var rdi = component.get('v.routeId');
         var routes= component.get('v.matchRoutes');
        for(var i=0;i<routes.length; i++){ 
            if(routes[i].Id ===  rdi ){
               component.set('v.searchText', routes[i].Name);
                break;
            } 
         } 
         component.set('v.matchRoutes',[]);
         if(component.get('v.routeId') != null && component.get('v.routeId') != ''){
             component.set('v.spinner',true);
            var action = component.get("c.getStoreList");
            action.setParams({'uId':  component.get('v.userId'),
                              'route': component.get('v.routeId')
                             })
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    component.set("v.mydata", response.getReturnValue());
                    var action = component.get("c.getbeatList");
                    action.setParams({'uId':  component.get('v.userId'),
                                      'route': component.get('v.routeId')
                                     })
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            var result = response.getReturnValue();
                            component.set("v.mydata1", response.getReturnValue());
                            component.set('v.showBeats',true);
                             component.set('v.spinner',false);
                        }
                    });
                    $A.enqueueAction(action);
                    
                }
            });
            $A.enqueueAction(action);
            
        }
        
    },
     getStores : function(component, event, helper) {
        
       
    },
})