({
    doInitHelper:function(component,event,helper){
        
        var today = new Date();
        var month=today.getMonth()+1;
        var day=today.getDate();
        if(month<10){
            month='0'+month;
        }
        if(day<10){
            day='0'+day;
        }
        helper.clockinclockouthelper(component,event,helper);
        component.set('v.startdate', today.getFullYear() +"-"+month+"-"+day); 
        component.set('v.lcHost', window.location.hostname);
        
        //Add message listener
        window.addEventListener("message", function(event) {
            
            if(event.data.state == 'LOADED'){
                //Set vfHost which will be used later to send message
                component.set('v.vfHost', event.data.vfHost);
                
                //Send data to VF page to draw map
                helper.sendToVF(component, helper);
            }
        }, false);		
    },
    getUsers : function(component,helper,event){
        var action = component.get("c.getUserList");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.users", result);
                
            }
        });
        $A.enqueueAction(action);
    },
    getSummaryCount : function (component,event,helper){
        var position = component.get('v.getMeeting');
        var action = component.get('c.showSummeryCount');
        if(position !=null){
            action.setParams({
                'mystartDate' : new Date(component.get('v.startdate')),
                'currentuserid' : component.get("v.users.userName"),
                'latitude' : position.coords.latitude,
                'longitude': position.coords.longitude
                
            });  
        }
        else{
            action.setParams({
                'mystartDate' : new Date(component.get('v.startdate')),
                'currentuserid' : component.get("v.users.userName"),
                'latitude' : null,
                'longitude': null
                
            });
        }
        
        action.setCallback(this,function(result){
            var state= result.getState();
            if (result.getState() == "SUCCESS") {
                var resultCount = result.getReturnValue();
                console.log('####resultcount####',resultCount);
                component.set("v.summaryCount",resultCount);
                
            }
        });
        $A.enqueueAction(action);           
    },     
    showMeetingClick : function(component, event, helper) {
        
        var position = component.get('v.getMeeting');
        var startdate = component.get("v.startdate");
        var loadedMapdata=component.get("v.mapData");
        
        if(loadedMapdata!=null){
            component.set("v.mapData",[]);
        }
        var action = component.get('c.showMeeting');
        var selectuser = component.get("v.users");
        
        action.setParams({
            'para1': ''+position.coords.latitude,
            'para2': ''+position.coords.longitude,
            'mystartDate' : new Date(component.get('v.startdate')),
            'currentuserid' : component.get("v.users.userName")
            
        });
        action.setCallback(this,function(result){
            var state= result.getState();
            if (result.getState() == "SUCCESS") {
                
                var meetings = JSON.parse( result.getReturnValue());
                
                if(meetings != null){
                    if(meetings.currentvisit.Actual_Start_Time__c == null){
                        component.set('v.checkin', true);
                    }
                    
                    component.set('v.lstvisit',meetings);
                    component.set('v.expenses',meetings.expenses);
                    component.set('v.allmeetings',meetings.Allmeetings);
                    component.set('v.dailyLog',meetings.dailyLog);
                    component.set('v.expecteddistace',meetings.distance);
                   
                    var checkedinVisits = Array();
                    
                    for(var i=0; i<meetings.Allmeetings.length; i++){
                        if(meetings.Allmeetings[i].ClockIn_Latitude__c != null && meetings.Allmeetings[i].Clockin_Longitude__c != null){
                            checkedinVisits.push(meetings.Allmeetings[i])
                        }
                        
                    }
                    
                    var mapData = Array();
                    if(checkedinVisits.length > 0){
                        
                        for(var i=0; i<checkedinVisits.length; i++){
                            
                            if(checkedinVisits[i].ClockIn_Latitude__c != null && checkedinVisits[i].Clockin_Longitude__c != null){
                                if(i==0){
                                    
                                    mapData.push({"lat":parseFloat(checkedinVisits[i].ClockIn_Latitude__c), "lng":parseFloat(checkedinVisits[i].Clockin_Longitude__c), 
                                                  "markerText":(i+1)+') '+checkedinVisits[i].Account_Name__c,"status":checkedinVisits[i].Status__c,
                                                  "checkIn":checkedinVisits[i].Actual_Start_Time__c,"checkOut":checkedinVisits[i].Actual_End_Time__c,
                                                  "startingPoint":true,"endingPoint":false
                                                  
                                                 });
                                    
                                }else if(i==(checkedinVisits.length-1)){
                                    
                                    mapData.push({"lat":parseFloat(checkedinVisits[i].ClockIn_Latitude__c), "lng":parseFloat(checkedinVisits[i].Clockin_Longitude__c), 
                                                  "markerText":(i+1)+')'+checkedinVisits[i].Account_Name__c,"status":checkedinVisits[i].Status__c,
                                                  "checkIn":checkedinVisits[i].Actual_Start_Time__c,"checkOut":checkedinVisits[i].Actual_End_Time__c,
                                                  "startingPoint":false,"endingPoint":true
                                                  
                                                 });
                                }else{
                                    
                                    mapData.push({"lat":parseFloat(checkedinVisits[i].ClockIn_Latitude__c), "lng":parseFloat(checkedinVisits[i].Clockin_Longitude__c), 
                                                  "markerText":(i+1)+')'+checkedinVisits[i].Account_Name__c,"status":checkedinVisits[i].Status__c,
                                                  "checkIn":checkedinVisits[i].Actual_Start_Time__c,"checkOut":checkedinVisits[i].Actual_End_Time__c
                                                  
                                                 });
                                }
                                
                                
                            }
                            
                        }
                        
                    }
                    
                    
                    
                    
                    /*  if(meetings.Allmeetings.length > 0){
                        for(var i=0; i<meetings.Allmeetings.length; i++){
                         
                            if(meetings.Allmeetings[i].hasOwnProperty('Account1__r') && meetings.Allmeetings[i].Account1__r.GeoLocation__c.latitude != null && meetings.Allmeetings[i].Account1__r.GeoLocation__c.longitude != null){
                               
                                if(meetings.Allmeetings[i].hasOwnProperty('Account1__r') && meetings.Allmeetings[i].Account1__r.GeoLocation__c.latitude != null && meetings.Allmeetings[i].Account1__r.GeoLocation__c.longitude != null ){
                                   
                                    mapData.push({"lat":parseFloat(meetings.Allmeetings[i].Account1__r.GeoLocation__c.latitude), "lng":parseFloat(meetings.Allmeetings[i].Account1__r.GeoLocation__c.longitude), 
                                                  "markerText":meetings.Allmeetings[i].Account_Name__c,"status":meetings.Allmeetings[i].Status__c,
                                                  "checkIn":meetings.Allmeetings[i].Actual_Start_Time__c,"checkOut":meetings.Allmeetings[i].Actual_End_Time__c
                                                 
                                                 });
                                }
                            }
                        }
                    }   */  
                    /*if(meetings.dailyLogs.length > 0){
                        
                        for(var i=0; i<meetings.dailyLogs.length; i++){
                           
                            if(meetings.dailyLogs[i].Clock_In_Location__Latitude__s && meetings.dailyLogs[i].Clock_In_Location__Latitude__s != null){
                                
                                mapData.push({"lat":parseFloat(meetings.dailyLogs[i].Clock_In_Location__Latitude__s), "lng":parseFloat(meetings.dailyLogs[i].Clock_In_Location__Longitude__s), 
                                              "markerText":'Started',"status":'Completed',
                                              "checkIn":meetings.dailyLogs[i].Clock_In__c,"startingPoint":true,"endingPoint":false
                                             });
                            }
                            if(meetings.dailyLogs[i].Clock_Out_Location__Latitude__s && meetings.dailyLogs[i].Clock_Out_Location__Latitude__s != null){
                               
                                mapData.push({"lat":parseFloat(meetings.dailyLogs[i].Clock_Out_Location__Latitude__s), "lng":parseFloat(meetings.dailyLogs[i].Clock_Out_Location__Longitude__s), 
                                              "markerText":'Ended',"status":'Completed',"checkOut":meetings.dailyLogs[i].Clock_Out__c,"startingPoint":false,"endingPoint":true
                                             });
                            }
                        }
                    }*/
                    //mapData.unshift({"lat":parseFloat(position.coords.latitude), "lng":parseFloat(position.coords.longitude), "markerText":'Your Current Location',"status":'New'})
                    var mapOptionsCenter = {"lat":parseFloat(mapData[0].lat), "lng":parseFloat(mapData[0].lng)};
                    component.set('v.mapOptionsCenter', mapOptionsCenter);
                    component.set('v.mapData', mapData);
                    
                    component.get("v.summaryCount");
                    
                }else {
                    
                    component.set('v.lstvisit',null);
                    component.set('v.allmeetings',null);
                    component.set("v.showall",false);
                    component.set("v.mapData",null);
                    /*var summaryCount = component.get("v.summaryCount");
                    if(summaryCount.hasOwnProperty('visitCount')){
                        component.set("v.summaryCount.visitCount",0);
                    }
                    if(summaryCount.hasOwnProperty('expectedDistance')){
                        component.set("v.summaryCount.expectedDistance",0);
                    }
                    if(summaryCount.hasOwnProperty('visitCount')){
                        component.set("v.summaryCount.plannedVisits",0);
                    }
                    if(summaryCount.hasOwnProperty('expectedDistance')){
                        component.set("v.summaryCount.completedVisits",0);
                    }*/
                    helper.showToast('No more meetings in selected date');                 
                }
                
            }
            //helper.hideProgressWithId(component,'timeSpinner');  
        });
        $A.enqueueAction(action); 
        
    },
    clockinclockouthelper : function(component,event,helper){
        var action =component.get("c.getClockInClockOut");
        action.setCallback(this,function(response){
            var state=response.getState();
            if(state=='SUCCESS'){
                component.set("v.ClockInClockOutDay",response.getReturnValue());  
            } 
        });
        $A.enqueueAction(action);
    },
    startdateHelper : function(component,event,helper){
        if (navigator.geolocation) {
            var opts= {}
            opts.enableHighAccuracy = false;
            opts.timeout = 5000;
            opts.maximumAge = 0;
            navigator.geolocation.getCurrentPosition(function(positionIn){
                component.set('v.getMeeting',positionIn);
                helper.getSummaryCount(component,event,helper);
                
            },function(err){  
                helper.catchError(err,helper); 
            });
        }
        else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Geo Location is not supported"
            });
            toastEvent.fire();                              
            
        }      
    },
    showToast : function(message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "",
            "message":  message
        });
        toastEvent.fire();
    },
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    fieldSettingsHelper : function(component,event,helper){
        var action=component.get("c.checkEnabledForCheckin");
        action.setCallback(this,function(response){
            if(response.getState()=="SUCCESS"){
                console.log(response.getReturnValue());
                component.set("v.fieldSettings",response.getReturnValue());
                console.log('----',component.get("v.fieldSettings"));
            }
        });
        $A.enqueueAction(action);
    },
    endDayDistance : function(component,event,helper){
        var action=component.get("c.checkEnabledForEndDay");
        action.setCallback(this,function(response){
            if(response.getState()=="SUCCESS"){
                component.set("v.endDayCheck",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    sendToVF : function(component, helper) {
        //Prepare message in the format required in VF page
        
        var message = {
            "loadGoogleMap" : true,
            "mapData": component.get('v.mapData'), 
            "mapOptions": component.get('v.mapOptions'),  
            'mapOptionsCenter': component.get('v.mapOptionsCenter')
        } ;
        
        //Send message to VF
        helper.sendMessage(component, helper, message);
    },
    sendMessage: function(component, helper, message){
        //Send message to VF
        message.origin = window.location.hostname;
        if(component.find("vfFrame")){
            var vfWindow = component.find("vfFrame").getElement().contentWindow;
            var obj = JSON.parse(JSON.stringify(message));
            console.log('LC ',obj,component.get("v.vfHost"));
            vfWindow.postMessage(obj, component.get("v.vfHost"));
        }
        
    },
    
    clockinHelper : function(component,event,helper) {
        var position = component.get('v.positionIn');
        console.log(position);
        var action = component.get('c.doClockIn');
        action.setParams({
            'para1': ''+position.coords.latitude,
            'para2': ''+position.coords.longitude
        });
        // helper.showProgressWithId(component,'timeSpinner');  
        action.setCallback(this,function(result){
            var response=result.getReturnValue();
            if(response.indexOf('Fail') == -1){
                helper.displayToast('success','Succesfully Clocked-In',10000); 
                helper.clockinclockouthelper(component,event,helper);
            }else{
                helper.showToast(result.getReturnValue()); 
            }
            
        });
        $A.enqueueAction(action);  
    },
    clockoutHelper:function(component,event,helper){
        var position = component.get('v.positionOut');
        var action = component.get('c.doClockOut');
        action.setParams({
            'para1': ''+position.coords.latitude,
            'para2': ''+position.coords.longitude,
            'mystartDate' : new Date(component.get('v.startdate')).toJSON()
        });
        helper.showProgressWithId(component,'timeSpinner');
        action.setCallback(this,function(result){
            console.log(result.getReturnValue()); 
            if(result.getReturnValue() == 'false'){
                helper.showToast('You have to Clock-In First!!!');                 
            }
            else if(result.getReturnValue() == 'true'){
                helper.showToast('You are already Clocked-Out');                 
            }
                else {
                    helper.displayToast('success','Successfully Clocked-Out',10000);
                    helper.startdateHelper(component,event,helper);
                    helper.clockinclockouthelper(component,event,helper);
                } 
            //helper.hideProgressWithId(component,'timeSpinner'); 
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
    
    
    changeCheckIn : function(component,event,helper) {
        var currentvisit = component.get('v.lstvisit');
        var position = component.get('v.checkedIn');
        //Dealer
        if(currentvisit[0].currentvisit.hasOwnProperty('Account__r')){
            if(currentvisit[0].currentvisit.Account__r.Geolocation__Longitude__s == null || currentvisit[0].currentvisit.Account__r.Geolocation__Latitude__s == null){
                component.set("v.updateGeoLocation",true);  
                helper.displayToast('error','Account does not have GeoLocation,Please update GeoLocation',10000);
                component.set("v.visitId",currentvisit[0].currentvisit.Id);
                component.set("v.dealername",currentvisit[0].currentvisit.Account__r.Name);
                return;
            }
            if(currentvisit[0].currentvisit.Account__r.GeoLocation__Longitude__s != undefined && currentvisit[0].currentvisit.Account__r.GeoLocation__Latitude__s != undefined ){
                var d = helper.distance(position.coords.longitude,position.coords.latitude,currentvisit[0].currentvisit.Account__r.GeoLocation__Longitude__s,currentvisit[0].currentvisit.Account__r.GeoLocation__Latitude__s);
            }
        }
        
        var action = component.get('c.doCheckIn');
        action.setParams({
            'para1': ''+position.coords.latitude,
            'para2': ''+position.coords.longitude,
            'visitId' : currentvisit[0].currentvisit.Id
            
        });
        helper.showProgressWithId(component,'timeSpinner');
        action.setCallback(this,function(result){
            var meetings =  JSON.parse( result.getReturnValue());
            if(meetings != null ){
                component.set("v.updateGeoLocation",false);
                component.set('v.comments', '');
                component.set('v.lstvisit',meetings )
                console.log(meetings);
            }else{  
                helper.displayToast('error','Please start your day first',10000);                 
            }
            //helper.hideProgressWithId(component,'timeSpinner');  
        });
        $A.enqueueAction(action);  
    },
    
    changeCheckOut : function(component,event,helper){
        var currentvisit = component.get('v.lstvisit');
        var position = component.get('v.checkedOut');
        
        //Dealer
        if(currentvisit[0].currentvisit.hasOwnProperty('Account__r') ){
            if(currentvisit[0].currentvisit.Account__r.GeoLocation__Longitude__s != undefined && currentvisit[0].currentvisit.Account__r.GeoLocation__Latitude__s != undefined ){
                var d = helper.distance(position.coords.longitude,position.coords.latitude,currentvisit[0].currentvisit.Account__r.GeoLocation__Longitude__s,currentvisit[0].currentvisit.Account__r.GeoLocation__Latitude__s);
                console.log('distance#####'+d);
                var restriction=component.get("v.EnabledKmCheckin");
                if(restriction && d>1){
                    helper.displayToast('error','Please do Checkin/Checkout with in 1 km distance',10000);
                    return;
                }
            }
        } 
        var comments = component.get('v.comments');  
        if(comments != '' && comments != undefined){
            var action = component.get('c.doCheckOut');
            action.setParams({
                'para1': ''+position.coords.latitude,
                'para2': ''+position.coords.longitude,
                'visitId' : currentvisit[0].currentvisit.Id,
                'comments' : comments
            });
            //  helper.showProgressWithId(component,'timeSpinner');
            action.setCallback(this,function(result){
                component.set('v.lstvisit', JSON.parse( result.getReturnValue()) );
                helper.showMeetingClick(component,event,helper);
                //helper.hideProgressWithId(component,'timeSpinner'); 
            });
            $A.enqueueAction(action); 
            
        }else{
            helper.showToast('Please enter Comments');
            
        }
        
        
    },
    
    previousClickIn : function(component,event,helper) {
        var currentvisit = component.get('v.lstvisit');
        console.log(currentvisit);
        var position = component.get('v.previousClick');
        console.log(position);
        var action = component.get('c.previous');
        action.setParams({
            'para1': ''+position.coords.latitude,
            'para2': ''+position.coords.longitude,
            'currentvisitId' : currentvisit[0].currentvisit.Id,
            'mystartDate' : new Date(component.get('v.startdate')).toJSON()
        });
        helper.showProgressWithId(component,'timeSpinner');
        action.setCallback(this,function(result){
            console.log(result.getReturnValue()); 
            var state= result.getState();
            if (result.getState() == "SUCCESS") {
                var meetings = result.getReturnValue();
                if(meetings != null){
                    component.set('v.lstvisit',meetings);
                    console.log(component.get('v.lstvisit'));
                    
                }else{
                    helper.showToast('No more meetings not completed');                    
                }
            }     
            //helper.hideProgressWithId(component,'timeSpinner');  
        });
        $A.enqueueAction(action);  
    }, 
    
    nextClickIn : function(component,event,helper){
        var startdate = component.get("v.startdate"); 
        var currentvisit = component.get('v.lstvisit');
        var position = component.get('v.nextClick');
        console.log(currentvisit);
        if(currentvisit[0].currentvisit.Status__c != 'In Progress' && currentvisit[0].currentvisit.Status__c != 'Planned'){
            var action = component.get('c.showMeeting');
            action.setParams({
                'para1': ''+position.coords.latitude,
                'para2': ''+position.coords.longitude,
                'currentuserid' : '',
            });
            helper.showProgressWithId(component,'timeSpinner'); 
            action.setCallback(this,function(result){
                console.log(result.getReturnValue()); 
                var state= result.getState();
                if (result.getState() == "SUCCESS") {
                    var meetings = JSON.parse( result.getReturnValue());
                    if(meetings != null){
                        component.set('v.lstvisit',meetings);
                        console.log(component.get('v.lstvisit'));
                        
                    }else{
                        helper.showToast('No more meetings to meet');                                        
                    }                
                }     
                //helper.hideProgressWithId(component,'timeSpinner');  
            });
            $A.enqueueAction(action);  
        }else{
            helper.showToast('Please do checkin and checkout for this meeting'); 
        }
    },
    
    
    
    distance:function(lon1, lat1, lon2, lat2) {
        
        var R = 6371; // Radius of the earth in km
        var dLat = (lat2 - lat1) * Math.PI / 180;  // deg2rad below
        var dLon = (lon2 - lon1) * Math.PI / 180;
        var a = 
            0.5 - Math.cos(dLat)/2 + 
            Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) * 
            (1 - Math.cos(dLon))/2;
        
        return R * 2 * Math.asin(Math.sqrt(a));
        
    },
    
    getCurrentLocation : function(component,event,helper){
        //  alert('hii');
        if (navigator.geolocation) {
            var opts= {}
            opts.enableHighAccuracy = false;
            opts.timeout = 5000;
            opts.maximumAge = 0;
            navigator.geolocation.getCurrentPosition(function(positionIn){
                //  alert('hii');
                component.set('v.CurrentLocation',positionIn);
                
            },function(err){  
                helper.catchError(err,helper); 
            });
        }else{
            helper.displayToast('error','Your location is having problem',10000);
        }
    },
    doCheckoutPrevious : function(component,event,helper){
        var action=component.get("c.CheckoutPrevious");
        action.setParams({
            'mystartDate' : component.get('v.startdate'),
        });
        action.setCallback(this,function(response){
            var state=response.getState();
            if(state=='SUCCESS'){
                console.log('returnValue ',response.getReturnValue())
                if(response.getReturnValue()==null){
                    helper.changeCheckIn(component, event, helper);
                }else{
                    helper.displayToast('error','Please do checkout for previous meeting');
                    return;
                }
            } 
        });
        $A.enqueueAction(action);
        
    },
    CheckForAdmin:function(component,event,helper){
        var action=component.get("c.getCheckAdminUser");
        action.setCallback(this, function(a) {
            var booleanResult=a.getReturnValue();
            console.log('----booleanResult----',booleanResult);
            component.set("v.isAppAdmin",booleanResult);
        });
        $A.enqueueAction(action);
    },
    
    getVisitEditSetting : function(component,event,helper) {
        var action=component.get("c.fetchEditButtonSetting");
        action.setCallback(this,function(response){
            var state=response.getState();
            if(state=="SUCCESS"){
                console.log("success..")
                var res=response.getReturnValue();
                component.set("v.visitEdit",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    transferVisitSetting : function(component,event,helper){
        var action=component.get("c.transferVisitSetting");
        action.setCallback(this,function(response){
            if(response.getState()=="SUCCESS"){
                console.log(response.getReturnValue());
                component.set("v.visitTransfer",response.getReturnValue());
                console.log('----',component.get("v.visitTransfer"));
            }
        });
        $A.enqueueAction(action);
    },
    getPlannedVisitSetting : function(component,event,helper) {
        var action=component.get("c.plannedVisitSetting");
        action.setCallback(this,function(response){
            var state=response.getState();
            if(state=="SUCCESS"){
                console.log("success..")
                var res=response.getReturnValue();
                console.log("success..",response.getReturnValue())
                component.set("v.pendingVisit",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    getAllbrand : function(component,event,helper){
        var dataIndex =  component.get('v.dataindex');
        //alert(dataIndex);
        var meeting = component.get('v.allmeetings');
        //alert(meeting[dataIndex].Dealer__c);
        // alert(meeting[dataIndex].Account_Name__c);
        var action = component.get('c.getAllbrand');
        action.setParams({
            'accid' : meeting[dataIndex].Dealer__c
        });
        
        action.setCallback(this,function(result){
            console.log(result.getReturnValue()); 
            var state= result.getState();
            if (result.getState() == "SUCCESS") {
                var arr = {}
                arr.currentvisit = meeting[dataIndex];
                arr.Brand = result.getReturnValue();
                var arrlist = [];
                arrlist.push(arr);                     
                console.log(arrlist);
                console.log(arrlist[0].Brand[0]);
                // component.find("brand").set("v.options", arrlist[0].Brand); 
                component.set('v.lstvisit', arrlist);
                console.log(component.get('v.lstvisit'));
                component.set('v.showall', false);  
                
                
            }      
            
        });
        $A.enqueueAction(action);            
        
    },
    
})