({
    tripHandler : function(component,event,helper) {  
        var action = component.get("c.upsertTrip");
        action.setParams({'trip':  component.get('v.tripData')  });
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
                component.set('v.spinner',false);
                var trip = response.getReturnValue();
                component.set('v.tripData', trip);
                
                if(trip.End_Date__c==null){
                    helper.showToast("Trip Started Successfully.","Success");
                    component.set('v.showTripData',true);
                }else{
                    helper.showToast("Trip Ended Successfully.","Success");
                    component.set('v.tripData',null);
                }
                component.set('v.spinner',false);
            }
        });
        $A.enqueueAction(action);
        
    }, 
    catchError : function(error,helper) {
        
        switch(error.code)
        {
            case error.TIMEOUT:
                helper.showToast("The request to get user location has aborted as it has taken too long.");
                break;
            case error.POSITION_UNAVAILABLE:
                helper.showToast("Location information is not available.");
                break;
            case error.PERMISSION_DENIED:
                helper.showToast("Permission to share location information has been denied!");
                break;
            default:
                helper.showToast("An unknown error occurred.");
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