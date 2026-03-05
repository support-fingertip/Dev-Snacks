({
    
    doInit : function(component, event, helper) {
        helper.doInitHelper(component,event,helper); 
        helper.getUsers(component,event,helper); 
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
         component.set("v.TodayDate",today);
        var showSummaryCount = {'visitCount' : 0,'expectedDistance' : 0,'MissedVisits':0,'plannedVisits' : 0, 'completedVisits' : 0,'InprogressVisitCount' : 0,'IncompleteVisitCount' : 0};
        component.set('v.summaryCount',showSummaryCount);  
        
    },
     showMeetingClick : function(component, event, helper) {
        var startdate = component.get("v.startdate"); 
        console.log("##StartDate: ", startdate);  
        component.set("v.startdate",startdate);

        helper.getSummaryCount(component,event,helper);
        var userName = component.get("v.users.userName"); 
        if(userName != 'choose' && userName != '' && userName != undefined && userName != null ){
            helper.getSummaryCount(component,event, helper); 
            helper.showMeetingClick(component,event, helper); 
        }  
    },
     selectUsers:function(component, event, helper){
        var userName = component.get("v.users.userName"); 
        if(userName != 'choose' && userName != '' && userName != undefined && userName != null ){
            helper.getSummaryCount(component,event, helper); 
            helper.showMeetingClick(component,event, helper); 
        }  
    },
    showMap : function(component, event, helper) {
        if(component.get('v.showMap')===true){
            component.set('v.showMap', false);
        }
        else{
            component.set('v.showMap', true);
        }
        
        if(component.get('v.showMapButton')===true){
            component.set('v.showMapButton', false);
        }
        else{
            component.set('v.showMapButton', true);
        }
    },
   startdate : function(component, event, helper) {
        helper.startdateHelper(component,event,helper);
    },     
 
    onSelectBrand : function(component, event, helper) {
        var selected1 = component.find("brand"); 
        var selected ='';
        if(component.find("brand")){
            selected = component.find("brand").get("v.value");
        }
        console.log(selected1);
        console.log(selected);
    },
    
    getCommets : function(component, event, helper) {
        var comments = component.find("comment1").get("v.value");
        component.set("v.comments",comments);
    },
   
    getMeetingClick :  function(component, event, helper) {
        helper.showMeetingClick(component,event, helper);
        helper.getSummaryCount(component,event,helper);
    },
    EditBulkVisit : function(component, event, helper){
        component.set("v.showvisitEditModel",true);
        var target = event.target;
        var dataId = target.getAttribute("data-id");
        var dataName = target.getAttribute("data-name"); 
        console.log('----dataName----',dataName);
        component.set("v.visit",dataId);
        component.set("v.visitName",dataName);
    },
    navigatetovisit : function(component, event, helper) { 
        
        var target = event.currentTarget;
        var dataIndex = target.dataset.index;
        var record = target.dataset.id ;   
        window.open('/' + record,'_blank');
        
      /*  var position = component.get('v.getMeeting');
        var startdate = component.get("v.startdate");
        var loadedMapdata=component.get("v.mapData");
        if(loadedMapdata!=null){
            component.set("v.mapData",[]);
        }
        var action = component.get('c.movetoNext'); 
        action.setParams({
            'para1': ''+position.coords.latitude,
            'para2': ''+position.coords.longitude,
            'visitId' :  record
            
        });
        action.setCallback(this,function(result){
            var state= result.getState();
            if (result.getState() == "SUCCESS") {
                
                component.set('v.showall', false);
                var meetings = JSON.parse( result.getReturnValue());
                if(meetings != null){
                    if(meetings.currentvisit.Actual_Start_Time__c == null){
                        component.set('v.checkin', true);
                    }
                    component.set('v.lstvisit',meetings);
                    component.set('v.allmeetings',meetings.Allmeetings);
                    component.set('v.dailyLog',meetings.dailyLog);
                    
                    var mapData = Array();
                    if(meetings.Allmeetings.length > 0){
                        for(var i=0; i<meetings.Allmeetings.length; i++){
                            if(meetings.Allmeetings[i].hasOwnProperty('Account__r') && meetings.Allmeetings[i].Account__r.Geolocation__Latitude__s != null && meetings.Allmeetings[i].Account__r.Geolocation__Longitude__s != null ){
                                mapData.push({"lat":parseFloat(meetings.Allmeetings[i].Account__r.Geolocation__Latitude__s), "lng":parseFloat(meetings.Allmeetings[i].Account__r.Geolocation__Longitude__s), 
                                              "markerText":meetings.Allmeetings[i].Account_Name__c,"status":meetings.Allmeetings[i].Status__c,
                                              "checkIn":meetings.Allmeetings[i].Actual_Start_Time__c,"checkOut":meetings.Allmeetings[i].Actual_End_Time__c
                                             });
                            }
                            if(meetings.Allmeetings[i].hasOwnProperty('Lead__r') && meetings.Allmeetings[i].Lead__r.GeoLocation__Latitude__s != null && meetings.Allmeetings[i].Lead__r.GeoLocation__Longitude__s != null ){
                                mapData.push({"lat":parseFloat(meetings.Allmeetings[i].Lead__r.GeoLocation__Latitude__s), "lng":parseFloat(meetings.Allmeetings[i].Lead__r.GeoLocation__Longitude__s), 
                                              "markerText":meetings.Allmeetings[i].Account_Name__c,"status":meetings.Allmeetings[i].Status__c,
                                              "checkIn":meetings.Allmeetings[i].Actual_Start_Time__c,"checkOut":meetings.Allmeetings[i].Actual_End_Time__c
                                             });
                            }
                            if(meetings.Allmeetings[i].hasOwnProperty('Dealer__r') && meetings.Allmeetings[i].Dealer__r.GeoLocation__Latitude__s != null && meetings.Allmeetings[i].Dealer__r.GeoLocation__Longitude__s != null ){
                                mapData.push({"lat":parseFloat(meetings.Allmeetings[i].Dealer__r.GeoLocation__Latitude__s), "lng":parseFloat(meetings.Allmeetings[i].Dealer__r.GeoLocation__Longitude__s), 
                                              "markerText":meetings.Allmeetings[i].Account_Name__c,"status":meetings.Allmeetings[i].Status__c,
                                              "checkIn":meetings.Allmeetings[i].Actual_Start_Time__c,"checkOut":meetings.Allmeetings[i].Actual_End_Time__c
                                             });
                            }
                        }
                    }
                    if(meetings.dailyLogs.length > 0){
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
                    }
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
                    var summaryCount = component.get("v.summaryCount");
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
                    }
                    helper.showToast('No more meetings in selected date');                 
                }
                
            }
            helper.hideProgressWithId(component,'timeSpinner'); 
        });
        
        $A.enqueueAction(action); 
        */
    },
    
    checkinClick : function(component, event, helper) {
        if (navigator.geolocation) {
            var opts= {}
            opts.enableHighAccuracy = false;
            opts.timeout = 5000;
            opts.maximumAge = 0;
            navigator.geolocation.getCurrentPosition(function(positionIn){
                component.set('v.checkedIn',positionIn);
                
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
    checkoutClick : function(component, event, helper) {
        if (navigator.geolocation) {
            var opts= {}
            opts.enableHighAccuracy = false;
            opts.timeout = 5000;
            opts.maximumAge = 0;
            navigator.geolocation.getCurrentPosition(function(positionOut){
                component.set('v.checkedOut',positionOut);
                component.set('v.getMeeting',positionOut);
                helper.showMeetingClick(component,event, helper); 
                helper.getSummaryCount(component,event,helper);
                
            },function(err){  
                helper.catchError(err,helper); 
            });
            //navigator.geolocation.getCurrentPosition(function showPosition(positionOut) {
                //component.set('v.positionOut',positionOut);  
           // }); 
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
    
    selectChange : function(component, event, helper) {
        if(component.get('v.showall')){
            helper.showMeetingClick(component,event, helper);
        }else{
            component.set('v.showall', false); 
        } 
    }, 
    startDayClick : function(component, event, helper) {
        if (navigator.geolocation) {
            var opts= {}
            opts.enableHighAccuracy = false;
            opts.timeout = 5000;
            opts.maximumAge = 0;
            
            navigator.geolocation.getCurrentPosition(function(positionIn){
                component.set('v.positionIn',positionIn);
                
            },function(err){  
                helper.catchError(err,helper); 
            });
           // navigator.geolocation.getCurrentPosition(function showPosition(positionIn) {
                     
                     //component.set('v.positionIn',positionIn);
              //}); 
            
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
    EditVisit: function(component,event,helper){
        component.set("v.showvisitEditModel",true);
        component.set("v.visit",component.get("v.lstvisit[0].currentvisit.Id"));
        component.set("v.visitName",component.get("v.lstvisit[0].currentvisit.Account_Name__c"));
        return;
    },
    
    
    endDayClick : function(component, event, helper) {
        var currentvisit = component.get('v.lstvisit');
        var allmeetings = component.get('v.allmeetings');
        console.log('**********jjjj ',allmeetings);
        if(component.get('v.pendingVisit')){
            for(var i = 0 ; i < allmeetings.length ; i++){
                if(allmeetings[i].Status__c != 'Completed'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Act on planned Visits"
                    });
                    toastEvent.fire();                       
                    return;
                }
            } 
        }
        if(!component.get("v.distanceEntered") && component.get("v.endDayCheck")){
            component.set("v.showEndDayModel",true);
            return;
        }
        if (navigator.geolocation) {
            var opts= {}
            opts.enableHighAccuracy = false;
            opts.timeout = 5000;
            opts.maximumAge = 0;
            
            navigator.geolocation.getCurrentPosition(function(positionOut){
                component.set('v.positionOut',positionOut);
                
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
    
    previousClick : function(component, event, helper) {
        if (navigator.geolocation) {
            
            var opts= {}
            opts.enableHighAccuracy = false;
            opts.timeout = 5000;
            opts.maximumAge = 0;
            
            navigator.geolocation.getCurrentPosition(function(positionOut){
                component.set('v.previousClick',positionOut);
                
            },function(err){  
                helper.catchError(err,helper); 
            });
            
            
            //navigator.geolocation.getCurrentPosition(function showPosition(positionOut) {
                //component.set('v.positionOut',positionOut);  
          //  }); 
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
    
    
    nextClick : function(component, event, helper) {
        
        
        if (navigator.geolocation) {
            
            var opts= {}
            opts.enableHighAccuracy = false;
            opts.timeout = 5000;
            opts.maximumAge = 0;
            
            navigator.geolocation.getCurrentPosition(function(positionOut){
                component.set('v.nextClick',positionOut);
                
            },function(err){  
                helper.catchError(err,helper); 
            });
            
            
            //navigator.geolocation.getCurrentPosition(function showPosition(positionOut) {
                //component.set('v.positionOut',positionOut);  
            //}); 
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
    
    changePositionIn: function(component, event, helper) {
        helper.clockinHelper(component, event, helper);
        
    },
    changePositionOut: function(component, event, helper) {
        helper.clockoutHelper(component, event, helper);
        
    },
    
    changeCheckIn: function(component, event, helper) {
        //helper.doCheckoutPrevious(component,event,helper); 
        helper.changeCheckIn(component, event, helper);   
    },
    changeCheckOut: function(component, event, helper) {
        helper.changeCheckOut(component, event, helper);
        
    },
    
    nextClickIn: function(component, event, helper) {
        helper.nextClickIn(component, event, helper);
        
    },
    previousClickIn: function(component, event, helper) {
        helper.previousClickIn(component, event, helper);
        
    },
    showGeoModal :function(component,event,helper){
        var action=component.get("c.updateGeoLocation");
        var position = component.get('v.getMeeting');
        var visitId =  component.get('v.lstvisit')[0].currentvisit.Id;
        
        action.setParams({'visitId':visitId, 'latitude':position.coords.latitude, 'longitude':position.coords.longitude})
        action.setCallback(this,function(response){
            if(response.getState()=="SUCCESS"){
                helper.showMeetingClick(component,event,helper);
                component.set('v.updateGeoLocation',false);
            }
        });
        $A.enqueueAction(action);
    },
    showSurveyModal :function(component,event,helper){
        component.set("v.showSurveyModal",true);
        
    },
    refreshVisits :function(component,event,helper){
        var type=event.getParam("type"); 
        helper.showMeetingClick(component,event,helper);
        helper.getSummaryCount(component,event,helper);
        
    },
    CreateNewOrder : function(component,event,helper){
        component.set("v.CreateNewOpp",true);
        component.set("v.saveType",'Order');
    },
    CreateNewQuote : function(component,event,helper){
        component.set("v.CreateNewOpp",true);
        component.set("v.saveType",'Quote');
    },
    
    
    CreateNewOpportunity:function(component,event,helper){
        component.set("v.showOpportunity",true); 
        component.set("v.objectName",'Opportunity');
    },
    menuButton : function(component,event,helper){
        var selectedMenuItemValue = event.getParam("value");
        if(selectedMenuItemValue == "New Account"){
            //alert('New Account');
            helper.getCurrentLocation(component,event,helper);
            component.set("v.showNewAccModal",true); 
        }
        else if(selectedMenuItemValue == "Generic Account"){
            component.set("v.showGenericAccount",true); 
            component.set("v.objectName",'Account'); 
        }
            else if(selectedMenuItemValue == "Generic Prospect"){
                component.set("v.showGenericVisit",true); 
                component.set("v.objectName",'Prospect__c'); 
            }
                else if(selectedMenuItemValue == "New Visit"){
                    
                    component.set("v.showNewVisitModal",true);
                }
                    else if(selectedMenuItemValue == "Opportunity"){
                        component.set("v.showOpportunity",true); 
                        component.set("v.objectName",'Opportunity'); 
                    }
                        else if(selectedMenuItemValue == "New Prospect"){
                            helper.getCurrentLocation(component,event,helper);
                            component.set("v.showNewProspect",true);
                        }
                            else if(selectedMenuItemValue == "Refresh"){
                                var startdate = component.get("v.startdate"); 
                                if(startdate != null){
                                    helper.showMeetingClick(component,event, helper);  
                                    helper.getSummaryCount(component,event,helper);
                                }
                                else
                                {
                                    helper.showToast('Select date first');
                                    return;
                                }
                                
                            }
    },
    refreshSummary : function(component,event,helper){
        helper.showMeetingClick(component,event, helper);  
        helper.getSummaryCount(component,event,helper); 
    },
    createRecord : function (component, event, helper) {
        var currentvisit = component.get('v.lstvisit');
        var accountId = currentvisit[0].currentvisit.Account__r.Id;
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Payments__c",
            "defaultFieldValues": {
                'Account__c' :  accountId
            }
        });
        createRecordEvent.fire();
    },
    newVisit : function (component, event, helper) {
        component.set("v.showNewVisitModal",true);
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
  
})