({
    getObject :function(component,event,helper){
        
        var recordId = component.get("v.recordId");
        console.log('recordId=== '+recordId);
        var action=component.get("c.gettingOutlet");
        action.setParams({
            recordId : recordId
        });
        action.setCallback(this,function(response){
            var status = response.getState();
            var error = response.getError();
            //console.log('status: 1st'+error[0].message);
            if(status==="SUCCESS"){
                console.log('response.getReturnValue(): '+JSON.stringify(response.getReturnValue()));
                var accRecord = response.getReturnValue();
                console.log('status: '+accRecord.Approval_Status__c);
                component.set("v.outletObj",accRecord); 
                component.set("v.status",accRecord.Approval_Status__c);
                component.set("v.locationApproveStatus",accRecord.Geolocation_Approval__c);
                //component.set("v.latitude",accRecord.GeoLocation__Latitude__s);  
                //component.set("v.longitude",accRecord.GeoLocation__Longitude__s);  
            }
        });
        $A.enqueueAction(action);  
    },
    
    captureLoc : function(component,event,helper){
        var Id = component.get("v.recordId");
        var action = component.get("c.updateOutlet");
        action.setParams({
            "outId":component.get("v.recordId"),
            "lat":component.get("v.latitude"),
            "longi":component.get("v.longitude")
        });
        action.setCallback(this,function(response){
            var status = response.getState();
            
            var type;
            var msg;
            var title;
            if(status==="SUCCESS"){
                console.log('status: '+status);
                msg = 'Customer Location for '+'"'+response.getReturnValue()+'"'+' Successfully Updated.';
                helper.showToast('Location Captured Successfully!!!!',msg,'SUCCESS');
                $A.get("e.force:refreshView").fire();
            }
             else if(state==="ERROR"){
                let err = response.getError();
                 helper.showToast('Error occurred!!',err,'ERROR');
            }
            
            var ttu=response.getReturnValue();
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": "/"+Id
            });
            urlEvent.fire();
            
        //$A.get('e.force:refreshView').fire();    
        });
       $A.enqueueAction(action);   
    },
    
    showToast : function(title,message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    }
})