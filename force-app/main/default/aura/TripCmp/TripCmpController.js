({
    doInit : function(component, event, helper) {
        component.set('v.spinner',true);
        var action=component.get("c.getTripData");
        
        action.setCallback(this,function(response){ 
            if(response.getState() == "SUCCESS"){ 
                var trip = response.getReturnValue();
                
                component.set('v.tripData',trip);
                if(trip != null){
                    component.set('v.showTripData',true);
                }
                
            }else if (response.getState() === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }
                }
            }
            component.set('v.spinner',false);
        });
        $A.enqueueAction(action); 
        
        var action2=component.get("c.getTodaysVisits");
        action2.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){ 
                component.set('v.spinner',false);
                var visits = response.getReturnValue();
                component.set('v.visits',  visits)
                
            }
        });
        $A.enqueueAction(action2); 
        
        var action3=component.get("c.getDailyLog");
        action3.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){ 
                component.set('v.spinner',false);
                var logs = response.getReturnValue();
                component.set('v.logData',  logs)
                
            }
        });
        $A.enqueueAction(action3); 
        
        
    },
    getclockIn : function(component, event, helper){
        
        
        component.set('v.spinner',true);
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(function(positionIn){
                component.set('v.clockIn',positionIn);
            },
                                                     function(err){  
                                                         component.set('v.spinner',false);
                                                         helper.catchError(err,helper); 
                                                     },{enableHighAccuracy:true,maximumAge:Infinity, timeout:60000});
        }
        else {
            helper.showToast("Geo Location is not supported","Error");
        }
        
    },
    startDayClick : function(component, event, helper){
        
        if( component.get('v.tripData') == null){
            component.set('v.tripData', {'Start_Location__Latitude__s':'','Start_Location__Longitude__s':''});
        }
        if(component.get('v.tripData').Start_KM__c == null || component.get('v.tripData').Start_KM__c == undefined){
            //alert('Please enter Start KM');
            helper.showToast("Please enter Start KM.","error");
            component.set('v.showTripData',false);
            component.set('v.spinner',false);
            // component.set('v.startTripWarning',true);
        }
        else{
            component.set('v.startTripWarning',false);
            var position = component.get('v.clockIn');
            
            component.set('v.tripData.Start_Location__Latitude__s',position.coords.latitude);
            component.set('v.tripData.Start_Location__Longitude__s',position.coords.longitude);
            component.set('v.tripData.Start_Date__c', new Date());
            component.set('v.tripData.Status__c','Started');
            
            helper.tripHandler(component, event, helper);
        }
        
        
    },
    getclockOut : function(component, event, helper) {
        
        
        component.set('v.spinner',true);
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(function(positionIn){
                component.set('v.clockOut',positionIn);
                 component.set('v.showTripData',false);
            },function(err){  
                component.set('v.spinner',false);
                helper.catchError(err,helper); 
            },{enableHighAccuracy:true,maximumAge:Infinity, timeout:60000} );
            
        }
        
    }, 
    endDayClick : function(component, event, helper) {
        
        var position = component.get('v.clockOut');
        var visits =  component.get('v.visits');
        component.set('v.noPending',true);
        for(var i = 0 ; i < visits.length ; i++){
            if(visits[i].Status__c == 'Planned' || visits[i].Status__c == 'In Progress'){
                component.set('v.noPending','false');
                component.set('v.spinner',false);
                helper.showToast("Act on planned Visits","Warning");
                
                return;
            }
        } 
        if( component.get('v.noPending')===true){
            
            if((component.get('v.tripData').Cash_In_Hand__c != null && component.get('v.tripData').Cash_In_Hand__c != undefined) && component.get('v.tripData').Cash_In_Hand__c > 0){
                helper.showToast("Please Clear the Balance before ending the trip.","error");                
            	component.set('v.spinner',false);
            }else{
                if(component.get('v.tripData').End_KM__c == null || component.get('v.tripData').End_KM__c == undefined){
                    // alert('Please enter End KM');
                    helper.showToast("Please enter End KM.","error");
                    component.set('v.spinner',false);
                    // component.set('v.endTripWarning',true);
                }
                else{
                    component.set('v.endTripWarning',false);
                    component.set('v.tripData.End_Location__Latitude__s',position.coords.latitude);
                    component.set('v.tripData.End_Location__Longitude__s',position.coords.longitude);
                    component.set('v.tripData.End_Date__c', new Date());
                    component.set('v.tripData.Status__c','Ended');
                    helper.tripHandler(component, event, helper);
                }
            }
            
            
        }
    }, 
    showStartTripWarning : function(component, event, helper) {
        if( component.get('v.tripData') == null){
            component.set('v.tripData', {'Start_KM__c':''});
        }
        component.set('v.startTripWarning', true); 
    },
    showEndTripWarning : function(component, event, helper) {
        component.set('v.endTripWarning', true); 
    },
    startTripNo : function(component, event, helper) {
        component.set('v.startTripWarning',false);
    },
    EndTripNo : function(component, event, helper) {
        component.set('v.endTripWarning',false);
    },
})