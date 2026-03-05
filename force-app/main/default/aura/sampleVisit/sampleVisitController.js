({
    
    doInit : function(component, event, helper) {
     
        component.set('v.visit',{'Status__c':'','Planned_Start_Time__c':'','EId__c':'','AccountName__c':'','Account1__r':{"attributes":{"type":"Account"},"EId__c": ''}});
        component.set('v.account',{'Name':'','Phone':'' ,'EId__c':'','Approval_Status__c':'','Email__c':'','Alternate_Mobile__c':'','Store_Category__c':'','Grade__c':'','Distributor_Name__c':'','State__c':'','GST__c':'','District__c':'','Panchayath__c':'','City__c':'','Description':'','GeoLocation__Latitude__s':'','GeoLocation__Longitude__s':''});
        var usedid = $A.get("$SObjectType.CurrentUser.Id");
        var res = usedid.substr(10, 8);
        var d = new Date();
        var EIdFormat = res+d.getFullYear()+d.getMonth()+d.getDate()
        component.set('v.EIdFormat',EIdFormat);
         component.set('v.lcHost', window.location.hostname);
        window.addEventListener("message", function(event) {
            if(event.data.state == 'LOADED'){
                component.set('v.vfHost', event.data.vfHost);
                helper.sendToVF(component, helper);
            }
        }, false);
       

        helper.doInitHelper(component,event,helper); 
        helper.fetchStatePicklist(component);
        
    },
    showDayWarning : function(component, event, helper) {
        component.set('v.showDayWarning', true); 
    },
    startDayNo : function(component, event, helper) {
        component.set('v.showDayWarning',false);
    },
    showEndDayWarning : function(component, event, helper) {
      
            component.set('v.showEndDay', true); 
      
    },
    EndDayNo : function(component, event, helper) {
        component.set('v.showEndDay',false);
    },
     getclockIn : function(component, event, helper){
       
            component.set('v.showDayWarning',false);
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
        if( component.get('v.data.dailyLog') == null){
            component.set('v.data.dailyLog', {'Clock_In_Location__Latitude__s':'','Clock_In_Location__Longitude__s':''});
        }
      
       var position = component.get('v.clockIn');
            
            component.set('v.data.dailyLog.Clock_In_Location__Latitude__s',position.coords.latitude);
            component.set('v.data.dailyLog.Clock_In_Location__Longitude__s',position.coords.longitude);
            component.set('v.data.dailyLog.Clock_In__c', new Date());
            
           		 helper.dailylogHandler(component, event, helper);
                helper.checkOnline(component, event, helper);
           
    },
     getclockOut : function(component, event, helper) {
       
            component.set('v.showEndDay',false);
            var visits =  component.get('v.data.visits');
            component.set('v.noPending',true);
            for(var i = 0 ; i < visits.length ; i++){
                if(visits[i].Status__c == 'Planned' || visits[i].Status__c == 'In Progress'){
                    component.set('v.noPending','flase');
                    helper.showToast("Act on planned Visits","Warning");
                    
                    return;
                }
            } 
            if( component.get('v.noPending')===true){
                component.set('v.spinner',true);
                if (navigator.geolocation) {
                    navigator.geolocation.getCurrentPosition(function(positionIn){
                        component.set('v.clockOut',positionIn);
                        
                    },function(err){  
                        component.set('v.spinner',false);
                        helper.catchError(err,helper); 
                    },{enableHighAccuracy:true,maximumAge:Infinity, timeout:60000} );
                    
                }
            } 
        
    }, 
    endDayClick : function(component, event, helper) {
        
                    var position = component.get('v.clockOut');
            component.set('v.data.dailyLog.Clock_Out_Location__Latitude__s',position.coords.latitude);
            component.set('v.data.dailyLog.Clock_Out_Location__Longitude__s',position.coords.longitude);
            component.set('v.data.dailyLog.Clock_Out__c', new Date());
            
            console.log(  component.get('v.data.dailyLog'));
                    
                    helper.dailylogHandler(component, event, helper);
                    helper.checkOnline(component, event, helper);
                    
              
    }, 
    syncNow : function(component, event, helper) {
        if(!window.navigator.onLine){
            helper.showToast("Currently Offilne","info");
        }else{
           
            if(component.get('v.data.offlineRecords') == 0){
                helper.showToast("No offline data to sync","info");
            }else{
                 component.set('v.spinner',true);
                helper.dataHandler(component, event, helper); 
            }
            
        }     
        
    },    
    navigatetovisit : function(component, event, helper) { 
        
        var target = event.currentTarget;
        var dataIndex = target.dataset.index;
        var record = target.dataset.id ; 
        
        var currentvisit = {};
        var visits = component.get('v.data.visits');
        for(var i=0;i<visits.length; i++){ 
            if(visits[i].EId__c  ==  record ){
                currentvisit = visits[i];
            } 
        }
        component.set('v.data.currentvisit', currentvisit);
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        var dateValue = $A.localizationService.formatDate(component.get('v.data.currentvisit.Planned_Start_Time__c'), "YYYY-MM-DD");
        if(dateValue != today){
            component.set('v.todayVisit', false);
            //alert(component.get('v.todayVisit'));
            
        }
        component.set('v.showall',false); 
    },
     getCheckin : function(component, event, helper) {
         
          //Account1__r.GeoLocation__Latitude__s,Account1__r.GeoLocation__Longitude__s
        /*var storelat = component.get('v.data.currentvisit.Account1__r.GeoLocation__Latitude__s');
        var storelon = component.get('v.data.currentvisit.Account1__r.GeoLocation__Longitude__s');
         if (navigator.geolocation){
        navigator.geolocation.getCurrentPosition(function(positionIn){
            var currentlat = positionIn.coords.latitude;
            var currentlon = positionIn.coords.longitude;
              //alert('store: '+storelat+' '+storelon);
            //alert('current: '+currentlat+' '+currentlon);
            var d = helper.distance(storelon,storelat,currentlon,currentlat);
            //alert(d);
        },function(err){  
                    helper.catchError(err,helper); 
                },{enableHighAccuracy:true,maximumAge:Infinity, timeout:60000} );
         }*/
      
            var visits = component.get('v.data.visits');
        
            var count =0;
            for(var i=0;i<visits.length; i++){ 
                if(visits[i].Status__c ==='In Progress'){
                    count = count+1;
                } 
            }
        
            if(count==0){
               
                component.set('v.spinner',true);
                if (navigator.geolocation){
                    
                    navigator.geolocation.getCurrentPosition(function(positionIn){
                        component.set('v.checkedIn',positionIn);
                    },function(err){  
                         component.set('v.spinner',false);
                        helper.catchError(err,helper); 
                    },{enableHighAccuracy:true,maximumAge:Infinity, timeout:60000} );
                    
                }else{
                    
                }   
            }
            else {
                helper.showToast("You can't checkIn when other visist in progress.","Warning");
            }
        
    },
    checkinClick : function(component, event, helper) {
     
                    var visits = component.get('v.data.visits');
        var position = component.get('v.checkedIn');
                    if(visits){
                        for(var i = 0; i < visits.length; i++){
                            
                            if(visits[i].EId__c == component.get('v.data.currentvisit.EId__c')){
                                visits[i].Actual_Start_Time__c = new Date();
                                visits[i].Status__c = 'In Progress';
                                visits[i].ClockIn_Latitude__c = position.coords.latitude;
                                visits[i].Clockin_Longitude__c = position.coords.longitude;
                                break;
                            }
                        }
                    }
                   component.set('v.data.currentvisit.Actual_Start_Time__c',new Date());
                    component.set('v.data.currentvisit.Status__c','In Progress');
         			component.set('v.checkin','true');
                    component.set('v.data.summaryCount.plannedVisits',component.get('v.data.summaryCount.plannedVisits')-1);
                    component.set('v.data.summaryCount.InProgress',component.get('v.data.summaryCount.InProgress')+1);
              
                    helper.checkHandler(component,event,helper);
                    helper.checkOnline(component, event, helper);
               
    },
     getCheckout : function(component, event, helper) {
          /* var storelat = component.get('v.data.currentvisit.Account1__r.GeoLocation__Latitude__s');
        var storelon = component.get('v.data.currentvisit.Account1__r.GeoLocation__Longitude__s');
        navigator.geolocation.getCurrentPosition(function(positionIn){
            var currentlat = positionIn.coords.latitude;
            var currentlon = positionIn.coords.longitude;
            var d = helper.distance(storelon,storelat,currentlon,currentlat);
        },function(err){  
                    helper.catchError(err,helper); 
                },{enableHighAccuracy:true,maximumAge:Infinity, timeout:60000} );
        */
       
          let isAllValid = component.find('field').reduce(function(isValidSoFar, inputCmp){
            inputCmp.showHelpMessageIfInvalid();
            return isValidSoFar && inputCmp.checkValidity();
        },true);
        
        if(isAllValid == true){
            
                     component.set('v.spinner',true);
            			window.scroll(0,0);
                    if (navigator.geolocation) {
                        
                        navigator.geolocation.getCurrentPosition(function(positionIn){  
                            component.set('v.checkedOut',positionIn);
                            
                        },function(err){
                            component.set('v.spinner',false);
                            window.scroll(0,1800);
                            helper.catchError(err,helper); 
                        },{enableHighAccuracy:true,maximumAge:Infinity, timeout:60000});
                        
                    }
                    else {
                        helper.showToast("Geo Location is not supported","Error");
                        
                    }
        }else{
              helper.showToast("Please fill all mandatory fields","Warning");
        }
        
    },
    checkoutClick : function(component, event, helper) {
       
      
                    var visits = component.get('v.data.visits');
         var cv = component.get('v.data.currentvisit');
         var position = component.get('v.checkedOut');
                    if(visits){
                        for(var i = 0; i < visits.length; i++){
                            
                            if(visits[i].EId__c == component.get('v.data.currentvisit.EId__c')){
                                visits[i].Actual_End_Time__c = new Date();
                                visits[i].Status__c = 'Completed';
                                visits[i].CheckedOutLatitude__c = position.coords.latitude;
                                visits[i].CheckedOutLongitude__c = position.coords.longitude;
                                visits[i].Meet_and_greet__c = cv.Meet_and_greet__c;
                                visits[i].Placements__c = cv.Placements__c;
                                visits[i].Checked_expiry__c = cv.Checked_expiry__c;
                                visits[i].Product_introduction__c = cv.Product_introduction__c;
                                visits[i].presentation__c = cv.presentation__c;
                                visits[i].marketing_material__c = cv.marketing_material__c;
                                 visits[i].Comments__c = cv.Comments__c;
                                break;
                            }
                        }
                    }
                    //component.set('v.spinner',true);
                    component.set('v.checkout','true');
                    component.set('v.showPhotos',false);
                    component.set('v.data.currentvisit.Actual_End_Time__c',new Date());
                    component.set('v.data.currentvisit.Status__c','Completed');
                    component.set('v.data.summaryCount.InProgress',component.get('v.data.summaryCount.InProgress')-1);
                    component.set('v.data.summaryCount.completedVisits',component.get('v.data.summaryCount.completedVisits')+1);
                   
                    helper.checkHandler(component,event,helper);
                    helper.checkOnline(component, event, helper);
                    
              
    },
    
    doPostpone :function (component, event, helper) {
        let isAllValid = component.find('field').reduce(function(isValidSoFar, inputCmp){
            inputCmp.showHelpMessageIfInvalid();
            return isValidSoFar && inputCmp.checkValidity();
        },true);
        
        if(isAllValid == true){
            var currentvisit = component.get('v.data.currentvisit');
            currentvisit.Status__c =  'Missed';
            console.log(currentvisit);
            component.set('v.data.currentvisit', currentvisit );
            component.set("v.showPostpone",false);
            component.set("v.isPopup3",false);
            component.set('v.data.summaryCount.InProgress',component.get('v.data.summaryCount.plannedVisits')-1);
            component.set('v.data.summaryCount.completedVisits',component.get('v.data.summaryCount.Postponed')+1);
            helper.checkHandler(component,event,helper);
            helper.checkOnline(component, event, helper);
        }
        
    },
    CreateStore : function (component, event, helper) {
        let isAllValid = component.find('field1').reduce(function(isValidSoFar, inputCmp){
            inputCmp.showHelpMessageIfInvalid();
            return isValidSoFar && inputCmp.checkValidity();
        },true);
        
        if(isAllValid == true){
            
            var acc = component.get('v.account'); 
            var accounts = component.get('v.data.accounts');
            acc.Approval_Status__c = '';
            var d = new Date();
            var eid = 'S'+component.get('v.EIdFormat')+d.getMilliseconds()+'T';
            acc.EId__c = eid;
            alert(acc.EId__c);
             alert(JSON.stringify(acc));
            accounts.push(acc); 
            component.set('v.data.accounts',accounts);
            component.set('v.account',{});
            component.set('v.visitsView',true);
            component.set('v.showStore',false);
            helper.storeHandler(component, event, helper);
            helper.checkOnline(component, event, helper);
        }
    },
    createVisit: function (component, event, helper) {
        
        var name = component.get('v.visit.Account1__r.EId__c');
        
        if(name ==null || name ==''){
            helper.showToast("Please Select Store","Warning");
            
        }else if(component.get('v.approvalStatus') !='Approved'){
            helper.showToast("This store is not approved \n Please contact your manager","Error");
        }else{
            var commentForm = component.find('field1'), valid;
            commentForm.showHelpMessageIfInvalid();
            valid = commentForm.get("v.validity").valid;
            if(valid == true){
                component.set('v.visit.Status__c','Planned');
                var d = new Date();
                var eid = 'V'+component.get('v.EIdFormat')+d.getMilliseconds()+'T';
                component.set('v.visit.EId__c', eid);
                var visits = component.get('v.data.visits');
                visits.push(component.get('v.visit')); 
                
                component.set('v.data.visits',visits)
                component.set('v.visit',{});
                 component.set('v.searchText','');
                component.set('v.showVisit',false);
                component.set('v.data.summaryCount.plannedVisits',component.get('v.data.summaryCount.plannedVisits')+1);
                component.set('v.data.summaryCount.visitCount',component.get('v.data.summaryCount.visitCount')+1);
                component.set('v.newvisit','true');  
                helper.checkHandler(component, event, helper);
                helper.checkOnline(component, event, helper);
                
            }
        }
    },
    openCamera:function (component, event, helper) {
        
        if(!window.navigator.onLine){
            helper.showToast("Currently Offilne","Info");
        }else{ 
            
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": "http://sbox1-brahminsgroup.cs73.force.com/upload?id="+component.get('v.data.currentvisit.Id')
            });
            urlEvent.fire();
            if( component.get("v.showPhotos")==true){
                component.set("v.showPhotosButtonLable",'Show Photos');
                component.set("v.showPhotos",false);
            } 
        }
    },
    
    getdisricts: function(component, event, helper) {
        helper.districtPickList(component, event, helper);
    },
    selectChange : function(component, event, helper) { 
        
        if(component.get('v.showall')){
            
        }else{
            component.set('v.showall', false); 
        } 
    }, 
    /* Popup open close methods */
    
    PostPoneClick : function(component, event, helper) {
        const today = new Date()
        today.setDate(today.getDate() + 1)
        var tomorrow = $A.localizationService.formatDate(today, "YYYY-MM-DD");
        component.set('v.Today',tomorrow);
        component.set("v.showPostpone",true);
        component.set("v.isPopup3",true);
        
    },
    closePostpone: function (component, event, helper) {
        component.set('v.data.currentvisit.PostPoned_Start_Time__c',null);
        component.set('v.data.currentvisit.Missed_PostPone_Reason__c',null);
        component.set("v.showPostpone",false);
        component.set("v.isPopup3",false);
    },
    newVisit : function (component, event, helper) {
        var d= new Date();var date;var month;var hour;var min;var sec;
        d.setHours(d.getHours() -5);
        d.setMinutes(d.getMinutes() -29);
        if(d.getMonth()<10){month = "0"+d.getMonth();}else{ month = d.getMonth(); }
        if(d.getDate()<10){date = "0"+d.getDate();}else{ date = d.getDate(); }    
        if(d.getHours()<10){hour = "0"+d.getHours();}else{ hour = d.getHours(); }
        if(d.getMinutes()<10){min = "0"+d.getMinutes();}else{ min = d.getMinutes(); }  
        if(d.getSeconds()<10){sec = "0"+d.getSeconds();}else{ sec = d.getSeconds(); }  
        
        var fulldate = d.getFullYear()+"-"+month+"-"+date+"T"+hour+":"+min+":"+sec+"Z";
        //component.set('v.visit.Planned_Start_Time__c',fulldate);
        component.set('v.Today',fulldate);
        
        component.set("v.showVisit",true);
        component.set("v.isPopup",true);
    },
    closePopUp: function (component, event, helper) {
         component.set('v.visit',{});
         component.set('v.searchText','');
        component.set("v.show",false);
        component.set("v.isPopup",false);
    },
    newStore : function (component, event, helper) {
        component.set("v.showStore",true);
        component.set("v.isPopup2",true);
        component.set("v.visitsView",false);
    },
    closeStore: function (component, event, helper) {
        component.set("v.visitsView",true);
        component.set("v.showStore",false);
        component.set("v.isPopup2",false);
    },
    showPhotos: function (component, event, helper) {
        if( component.get("v.showPhotos")==false){
            
            if(!window.navigator.onLine){
                helper.showToast("Currently Offilne","info");
            }else{
                component.set("v.showPhotos",true);
                component.set("v.showPhotosButtonLable",'Hide Photos');
            }     
        }else{
            component.set("v.showPhotosButtonLable",'Show Photos');
            component.set("v.showPhotos",false);
        } 
        
    },
     showMap : function(component, event, helper) {
        if(component.get('v.showMap')===true){
            component.set('v.showMap', false);
        }
        else{
            var visits = component.get('v.data.visits');
           // alert(visits);
             var mapData = Array();
            if(visits.length > 0){
                        for(var i=0; i<visits.length; i++){
                            //alert(i);
                            if(visits[i].Account1__r.GeoLocation__Latitude__s != null && visits[i].Account1__r.GeoLocation__Longitude__s != null){
                             // alert(i);
                                    mapData.push({"lat":parseFloat(visits[i].Account1__r.GeoLocation__Latitude__s), "lng":parseFloat(visits[i].Account1__r.GeoLocation__Longitude__s), 
                                                  "markerText":i+') '+visits[i].Account_Name__c,"status":visits[i].Status__c,
                                                  "checkIn":visits[i].Actual_Start_Time__c,"checkOut":visits[i].Actual_End_Time__c
                                                  
                                                 });
                              
                            }
                        }
            }
             var mapOptionsCenter = {"lat":parseFloat(mapData[0].lat), "lng":parseFloat(mapData[0].lng)};
                    component.set('v.mapOptionsCenter', mapOptionsCenter);
                    component.set('v.mapData', mapData);
            //(mapData);
            component.set('v.showMap', true);
        }
        
        if(component.get('v.showMapButton')===true){
            component.set('v.showMapButton', false);
        }
        else{
            component.set('v.showMapButton', true);
        }
    },
   searchText : function(component, event, helper) {
        var accounts= component.get('v.data.accounts');
        var searchText= component.get('v.searchText');
        var matchaccounts=[];
        if(searchText !=''){
        for(var i=0;i<accounts.length; i++){ 
            if(accounts[i].Name.toLowerCase().indexOf(searchText.toLowerCase())  != -1  ){
               matchaccounts.push( accounts[i] )
            } 
         } 
            if(matchaccounts.length >0){
		 component.set('v.matchaccounts',matchaccounts);
            }
        }else{
            component.set('v.matchaccounts',[]);
        }
    },update: function(component, event, helper) {
        
        component.set('v.visit.Account1__r.EId__c', event.currentTarget.dataset.id);
        var edi = component.get('v.visit.Account1__r.EId__c');
         var accounts= component.get('v.matchaccounts');
        for(var i=0;i<accounts.length; i++){ 
            if(accounts[i].EId__c ===  edi ){
               component.set('v.searchText', accounts[i].Name);
                component.set('v.visit.AccountName__c', accounts[i].Name);
                component.set('v.approvalStatus', accounts[i].Approval_Status__c )
                break;
            } 
         } 
       
         component.set('v.matchaccounts',[]);
       
    },
})