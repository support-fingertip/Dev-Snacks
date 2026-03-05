({
    doInit : function(component, event, helper) {
        
        var actions3 = [
            { label: 'Show details', name: 'show_details3' }];
        component.set('v.mycolumns3', [
            {label: 'Customer Id', fieldName: 'CustomerId__c', type: 'text'},
            {label: 'Name', fieldName: 'Name', type: 'text'},
            {label: 'Phone', fieldName: 'Phone', type: 'text'},
            {label: 'Route', fieldName: 'RouteName__c', type: 'text'},
            {label: 'Created Date', fieldName: 'CreatedDate', type: 'date',typeAttributes: {
                day: 'numeric',
                month: 'short',
                year: 'numeric',
                hour: '2-digit',
                minute: '2-digit',
                second: '2-digit',
                hour12: true
            }}]);
        
        var action = component.get("c.getuserdetails");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.users', result);
                //alert(JSON.stringify(result))
                
            }
        });
        $A.enqueueAction(action);
        
        
        
    },
    
    handleRowAction3: function (component, event, helper) {
        component.set('v.spinner',true);
        //component.set('v.showupcoming',false);
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
        //component.set('v.showrecent',false);
        //component.set('v.showupcoming',true);
        
        component.set('v.userId','');
        component.set('v.showUsers',false);
    },
    updateSelectedText4: function (component, event) {
        var selectedRows = event.getParam('selectedRows');
        component.set('v.selectedRowsCount4', selectedRows.length);
        component.set('v.selectedUsers', selectedRows);
        
    },
    changeBeatOwner: function (component, event,helper) {
        
        if(component.get('v.NextUserId') != null && component.get('v.NextUserId') !='' && component.get('v.NextUserId') !=undefined){
            
            component.set('v.spinner',true);
            var action = component.get("c.updateOwner");
            action.setParams({'accs': component.get('v.selectedUsers'),
                              'currentUserId' : component.get('v.userId'),
                              'assignToId' : component.get('v.NextUserId')
                             })
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    if( response.getReturnValue() != null){
                        component.set('v.mydata3', response.getReturnValue());
                        var test = [];
                        var selRows = component.get('v.selectedUsers');
                        component.set('v.searchText', '');
                        component.set('v.searchText2', '');
                        //component.set('v.selectedUsers',test);
                        
                        //component.set('v.showupcoming',true);
                        component.set('v.spinner',false);
                        component.set('v.showUsers',false);
                        
                        
                        helper.showToast("Customer owner changed succesfully","Success");
                        
                    }
                    else{
                        component.set('v.spinner',false);
                        helper.showToast("Some error occured.Please try again.","Error");
                    }
                }
                
            });
            $A.enqueueAction(action);
            
        }else{
            
            helper.showToast("Plaese Select Assigning user","error");
        }
        
        
    },
    searchText : function(component, event, helper) {
        var routes= component.get('v.users');
        var searchText= component.get('v.searchText');
        
        var matchroutes=[];
        if(searchText !=''){
            for(var i=0;i<routes.length; i++){ 
                
                if(routes[i].Name.toLowerCase().indexOf(searchText.toLowerCase())  != -1  ){
                    matchroutes.push( routes[i] )
                } 
            } 
            if(matchroutes.length >0){
                component.set('v.matchUsers',matchroutes);
            }
        }else{
            component.set('v.matchUsers',[]);
        }
    },
    searchText2 : function(component, event, helper) {
        var routes= component.get('v.users');
        var searchText= component.get('v.searchText2');
        var matchroutes=[];
        if(searchText !=''){
            for(var i=0;i<routes.length; i++){ 
                if(routes[i].Name.toLowerCase().indexOf(searchText.toLowerCase())  != -1  ){
                    matchroutes.push( routes[i] )
                } 
            } 
            if(matchroutes.length >0){
                component.set('v.matchUsers2',matchroutes);
            }
        }else{
            component.set('v.matchUsers2',[]);
        }
    },
    update: function(component, event, helper) {
        component.set('v.userId', event.currentTarget.dataset.id);
        component.set('v.showUsers',true);
        var rdi = component.get('v.userId');
        var routes= component.get('v.matchUsers');
        for(var i=0;i<routes.length; i++){ 
            if(routes[i].Id ===  rdi ){
                component.set('v.searchText', routes[i].Name + ' - ' + routes[i].Username);
                break;
            } 
        } 
        component.set('v.matchUsers',[]);
        if(component.get('v.userId') != null && component.get('v.userId') != ''){
            component.set('v.spinner',true);
            var action = component.get("c.getcustomers");
            action.setParams({'currentUserId':  component.get('v.userId')
                             })
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    
                    component.set("v.mydata3", response.getReturnValue());
                    component.set('v.spinner',false);
                    
                    
                }
            });
            $A.enqueueAction(action);
            
        }
        
    },
    update2: function(component, event, helper) {
        component.set('v.NextUserId', event.currentTarget.dataset.id);
        
        var rdi = component.get('v.NextUserId');
        var routes= component.get('v.matchUsers2');
        for(var i=0;i<routes.length; i++){ 
            if(routes[i].Id ===  rdi ){
                component.set('v.searchText2', routes[i].Name + ' - ' + routes[i].Username);
                break;
            } 
        } 
        component.set('v.matchUsers2',[]);
        
        
    },
    
})