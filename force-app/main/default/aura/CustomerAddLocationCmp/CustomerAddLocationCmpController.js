({
	doInit : function(component, event, helper) {
        helper.getObject(component, event, helper);
        
        if(navigator.geoLocation){
            console.log("capabsility is there");
        }else{
            console.log("No Capability");
        }
        navigator.geolocation.getCurrentPosition(function(position) {
            var latit = position.coords.latitude;
            var longit = position.coords.longitude;
            component.set("v.latitude",latit);
            component.set("v.longitude",longit);
            console.log("The latitude is:"+ latit);
            console.log("The longitude is:"+longit); 
            component.set('v.mapMarkers', [
                {
                    location: {
                        Latitude : latit,
                        Longitude : longit
                    },
                     
                    title: name
                }
            ]);
            component.set('v.center', {
                location: {
                    Latitude : latit,
                        Longitude : longit
                }
            });
            component.set('v.zoomLevel', 17);
          component.set('v.markersTitle', 'Capture Location Marker');
          component.set('v.showFooter', true);
            
            console.log("The mapMarkers is:" +component.get("v.mapMarkers"));
        });
       
		
	},
    
    handleLongitude : function(component, event, helper) {
        console.log('handleLongitude=== ')
        var Latitude = component.get("v.latitude");  
        var Longitude = component.get("v.longitude");
            console.log('Latitude=== '+Latitude);
            //component.set("v.latitude",Latitude);
            component.set('v.mapMarkers', [
                {
                    location: {
                        Latitude : Latitude,
                        Longitude : Longitude
                    },
                    
                    title: name
                }
            ]);
            component.set('v.center', {
                location: {
                    Latitude : Latitude,
                    Longitude : Longitude
                }
            });
            //component.set('v.zoomLevel', 17);
            component.set('v.markersTitle', 'Capture Location Marker');
            component.set('v.showFooter', true);
    },
    
    handleLatitude : function(component, event, helper) {

            var Latitude = component.get("v.latitude");  
            var Longitude = component.get("v.longitude");
            console.log('Latitude=== '+Latitude);
            component.set("v.latitude",Latitude);
            component.set('v.mapMarkers', [
                {
                    location: {
                        Latitude : Latitude,
                        Longitude : Longitude
                    },
                    
                    title: name
                }
            ]);
            component.set('v.center', {
                location: {
                    Latitude : Latitude,
                    Longitude : Longitude
                }
            });
            //component.set('v.zoomLevel', 17);
            component.set('v.markersTitle', 'Capture Location Marker');
            component.set('v.showFooter', true);
    },
    
    captureLocation : function(component, event, helper){
        var status = component.get("v.status");
        var locationApproveStatus = component.get("v.locationApproveStatus");
        console.log('status=== '+status);
        if(status != 'Pending' && locationApproveStatus != 'Pending'){
            helper.captureLoc(component, event, helper);
        }else{
            helper.showToast('Customer is not approved!!','In order to update location, customer record must be approved.','ERROR');
        }
        
    }
})