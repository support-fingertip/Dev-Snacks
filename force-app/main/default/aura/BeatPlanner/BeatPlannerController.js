({
    doInit : function(component, event, helper) {
        component.set('v.userId', component.get('v.beatRecord.Executive__c'));
        // helper.getRoutes(component, event, helper);
        helper.setColumn(component, event, helper);
        var DistrictList = [];
        DistrictList.push({'label':'Alappuzha', 'value': 'Alappuzha'});
        DistrictList.push({'label':'Ernakulam', 'value': 'Ernakulam'});
        DistrictList.push({'label':'Idukki', 'value': 'Idukki'});
        DistrictList.push({'label':'Kannur', 'value': 'Kannur'});
        DistrictList.push({'label':'Kasargod', 'value': 'Kasargod'});
        DistrictList.push({'label':'Kollam', 'value': 'Kollam'});
        DistrictList.push({'label':'Kottayam', 'value': 'Kottayam'});
        DistrictList.push({'label':'Kozhikode', 'value': 'Kozhikode'});
        DistrictList.push({'label':'Malappuram', 'value': 'Malappuram'});
        DistrictList.push({'label':'Palakkad', 'value': 'Palakkad'});
        DistrictList.push({'label':'Pathanamthitta', 'value': 'Pathanamthitta'});
        DistrictList.push({'label':'Thiruvananthapuram', 'value': 'Thiruvananthapuram'});
        DistrictList.push({'label':'Thrissur', 'value': 'Thrissur'});
        DistrictList.push({'label':'Wayanad', 'value': 'Wayanad'});
        
        
        
        component.set("v.DistrictList", DistrictList);
    },  
    updateUserId: function(component, event, helper) {
        component.set('v.userId', component.get('v.beatRecord.Executive__c'));
        
    },
    updateSelectedText: function (component, event) {
        var selectedRows = event.getParam('selectedRows');
        component.set('v.selectedRowsCount', selectedRows.length);
        component.set('v.selectedaccounts', selectedRows);
        
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
    }, 
    
    handleDistrictChange: function (component, event, helper) {
        //Get the Selected values 
        var district= event.getParam("value");
        if(district != null){
            component.set('v.spinner',true);
            var action = component.get("c.getAccountList");
            action.setParams({'uId':  component.get('v.userId'),
                              'District': JSON.stringify(district),
                              'beatId': component.get('v.beatRecord.Id')
                             })
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    component.set("v.mydata", response.getReturnValue());
                }
            });
            $A.enqueueAction(action);
        } 
    },
    
    update: function(component, event, helper) {
        
        /*component.set('v.routeId', event.currentTarget.dataset.id);
        var rdi = component.get('v.routeId');
        var routes= component.get('v.matchRoutes');
        for(var i=0;i<routes.length; i++){ 
            if(routes[i].Id ===  rdi ){
                component.set('v.searchText', routes[i].Name);
                break;
            } 
        } 
        component.set('v.matchRoutes',[]);*/
        var district= component.get('v.districtSelected');
        if(district != null){
            component.set('v.spinner',true);
            var action = component.get("c.getAccountList");
            action.setParams({'uId':  component.get('v.userId'),
                              'District': component.get('v.districtSelected'),
                              'beatId': component.get('v.beatRecord.Id')
                             })
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    component.set("v.mydata", response.getReturnValue());
                }
            });
            $A.enqueueAction(action);
            
        } 
    },addItems: function(component, event, helper) {  
        
        if(component.get('v.daySelected') == ""){
            helper.showToast('Please select Day','error');
            
        }
        var action = component.get("c.createBeatLines");
        action.setParams({
            'uId':  component.get('v.userId'),
            'beatId': component.get('v.recordId'),
            'day': component.get('v.daySelected'),
            'lines': component.get('v.selectedaccounts')                                     
        })
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                helper.showToast('Visit Plan added succefully','success');
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action); 
    },closePopup : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
        
    }
    
})