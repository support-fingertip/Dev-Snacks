({

    doInit: function (component, event, helper) {
        //var userId = $A.get("$SObjectType.CurrentUser.Id");
        component.set('v.spinner', true);
        component.set('v.visit', { 'Status__c': '', 'Planned_Start_Time__c': '', 'EId__c': '', 'Revisit__c': '', 'AccountName__c': '' });
        component.set('v.account', { 'Name': '', 'Phone': '', 'EId__c': '', 'Approval_Status__c': '', 'Email__c': '', 'Alternate_Mobile__c': '', 'Store_Category__c': '', 'Grade__c': '', 'Distributor_Name__c': '', 'State__c': '', 'GST__c': '', 'District__c': '', 'Panchayath__c': '', 'City__c': '', 'Description': '', 'GeoLocation__Latitude__s': '', 'GeoLocation__Longitude__s': '' });
        component.set('v.Order', { 'Customer__c': '' });
        component.set('v.Receipt', { 'Customer__c': '', 'Daily_Log__c': '', 'Payment_Type__c:': '' });
        component.set('v.OrderLineItem', { 'Name': '', 'Product__c': '', 'Quantity__c': '', 'Unit_Price__c': '', 'Total__c': '', 'GST_Percentage__c': '', 'GST_Value__c': '' });

        console.log('data = ' + component.get("v.data"));
        console.log('showNewInvoice = ' + component.get("v.showNewInvoice"));
        var usedid = $A.get("$SObjectType.CurrentUser.Id");
        var res = usedid.substr(10, 8);
        var d = new Date();
        var EIdFormat = res + d.getFullYear() + d.getMonth() + d.getDate()
        component.set('v.EIdFormat', EIdFormat);
        component.set('v.lcHost', window.location.hostname);
        window.addEventListener("message", function (event) {
            if (event.data.state == 'LOADED') {
                component.set('v.vfHost', event.data.vfHost);
                helper.sendToVF(component, helper);
            }
        }, false);

        var action2 = component.get("c.getBanks");

        action2.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                var banks = response.getReturnValue();
                component.set("v.banks", banks);
            }
        });
        $A.enqueueAction(action2);

        helper.doInitHelper(component, event, helper);
        helper.fetchStatePicklist(component);

        
        var action4 = component.get("c.getCurrentButtonValue");
        action4.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var buttons = response.getReturnValue();
                if(buttons){
                    // component.set("v.userMultiPicklistValue", value);
                    console.log('Button to visible=== '+buttons);
                    console.log('Button to visible type === '+typeof buttons);
                    if(buttons.includes("New Order")){
                        component.set('v.orderBtn',true);
                    }
                    if(buttons.includes("New Invoice")){
                        component.set('v.invBtn',true);
                    }
                     if(buttons.includes("Unsealed")){
                        component.set('v.unsealedBtn',true);
                    }
                    if(buttons.includes("Convert To Invoice")){
                        component.set('v.convertInvBtn',true);
                    }
                }
               
            }
        });
        $A.enqueueAction(action4);

    },
    newStockRequest: function (component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            //componentDef: "c:NewStockRequestCmp",
            componentDef: "c:UpdatedStockRequestCmp",
        });
        evt.fire();
    },
    showDayWarning: function (component, event, helper) {
        var action = component.get("c.getTripData");
        action.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                var trip = response.getReturnValue();
                component.set('v.tripData', trip);
                // var trip = component.get('v.tripData');
                if (trip != null) {
                    component.set('v.showDayWarning', true);
                } else {
                    helper.showToast("Please Start the Trip first!", "Error");
                }

            } else if (response.getState() == "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                }
            }
            component.set('v.spinner', false);
        });
        $A.enqueueAction(action);
    },
    startDayNo: function (component, event, helper) {
        component.set('v.showDayWarning', false);
        component.set('v.searchDriver', '');
        component.set('v.searchSM', '');
        component.set('v.searchASM', '');
        component.set('v.searchSMgr', '');
    },
    showEndDayWarning: function (component, event, helper) {
        component.set('v.showEndDay', true);
    },
    EndDayNo: function (component, event, helper) {
        component.set('v.showEndDay', false);
    },
    getclockIn: function (component, event, helper) {
        if (component.get('v.data.dailyLog') == null) {
            component.set('v.data.dailyLog', { 'Clock_In_Location__Latitude__s': '', 'Clock_In_Location__Longitude__s': '' });
        }
        var dlog = component.get('v.data.dailyLog');
        var val = false;
        if (dlog.Driver__c == null) {
            helper.showToast("Please select Driver. ", "Error");
            val = false;
            component.set('v.spinner', false);
        }
        /*else if (dlog.Sales_Man__c == null) {
            helper.showToast("Please select Salesman. ", "Error");
            val = false;
            component.set('v.spinner', false);
        }*/
        /*else if (dlog.Assistant_SalesMan__c == null) {
            helper.showToast("Please select Assistant Salesman. ", "Error");
            val = false;
            component.set('v.spinner', false);
        }*/
        /*else if (dlog.Sales_Manager__c == null) {
            helper.showToast("Please select Sales Manager. ", "Error");
            val = false;
            component.set('v.spinner', false);
        }*/
        else if (dlog.Start_KM__c == null || dlog.Start_KM__c == undefined) {
            helper.showToast("Please enter Start KM. ", "Error");
            val = false;
            component.set('v.spinner', false);
        }
        else {
            val = true;
        }

        if (val) {
            component.set('v.showDayWarning', false);
            component.set('v.spinner', true);
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(function (positionIn) {
                    component.set('v.clockIn', positionIn);
                },
                    function (err) {
                        component.set('v.spinner', false);
                        helper.catchError(err, helper);
                    }, { enableHighAccuracy: true, maximumAge: Infinity, timeout: 60000 });
            }
            else {
                helper.showToast("Geo Location is not supported", "Error");
            }
        }
    },
    startDayClick: function (component, event, helper) {

        if (component.get('v.data.dailyLog') == null) {
            component.set('v.data.dailyLog', { 'Clock_In_Location__Latitude__s': '', 'Clock_In_Location__Longitude__s': '' });
        }

        var position = component.get('v.clockIn');

        component.set('v.data.dailyLog.Clock_In_Location__Latitude__s', position.coords.latitude);
        component.set('v.data.dailyLog.Clock_In_Location__Longitude__s', position.coords.longitude);
        component.set('v.data.dailyLog.Clock_In__c', new Date());

        helper.dailylogHandler(component, event, helper);
      //  helper.checkOnline(component, event, helper);


    },
    getclockOut: function (component, event, helper) {
        var dlog = component.get('v.data.dailyLog');
        if (dlog.End_KM__c == null || dlog.End_KM__c == undefined) {
            helper.showToast("Please enter End KM. ", "Error");

        }
        else {
            component.set('v.showEndDay', false);
            var visits = component.get('v.data.visits');
            component.set('v.noPending', true);
            for (var i = 0; i < visits.length; i++) {
                if (visits[i].Status__c == 'Planned' || visits[i].Status__c == 'In Progress') {
                    component.set('v.noPending', 'flase');
                    helper.showToast("Act on planned Visits", "Warning");

                    return;
                }
            }
            if (component.get('v.noPending') === true) {
                component.set('v.spinner', true);
                if (navigator.geolocation) {
                    navigator.geolocation.getCurrentPosition(function (positionIn) {
                        component.set('v.clockOut', positionIn);

                    }, function (err) {
                        component.set('v.spinner', false);
                        helper.catchError(err, helper);
                    }, { enableHighAccuracy: true, maximumAge: Infinity, timeout: 60000 });

                }
            }
        }


    },
    endDayClick: function (component, event, helper) {

        var position = component.get('v.clockOut');
        component.set('v.data.dailyLog.Clock_Out_Location__Latitude__s', position.coords.latitude);
        component.set('v.data.dailyLog.Clock_Out_Location__Longitude__s', position.coords.longitude);
        component.set('v.data.dailyLog.Clock_Out__c', new Date());

        console.log(component.get('v.data.dailyLog'));

        helper.dailylogHandler(component, event, helper);
       // helper.checkOnline(component, event, helper);


    },
    /*syncNow : function(component, event, helper) {
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
        
    },*/
    navigatetovisit: function (component, event, helper) {

        var target = event.currentTarget;
        var dataIndex = target.dataset.index;
        var record = target.dataset.id;

        var currentvisit = {};
        var visits = component.get('v.data.visits');
        for (var i = 0; i < visits.length; i++) {
            if (visits[i].EId__c == record) {
                currentvisit = visits[i];
            }
        }
        component.set('v.data.currentvisit', currentvisit);
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        var dateValue = $A.localizationService.formatDate(component.get('v.data.currentvisit.Planned_Start_Time__c'), "YYYY-MM-DD");
        if (dateValue != today) {
            component.set('v.todayVisit', false);

        }
        component.set('v.showall', false);
    },
    getCheckin: function (component, event, helper) {

        //Account1__r.GeoLocation__Latitude__s,Account1__r.GeoLocation__Longitude__s
        /*var storelat = component.get('v.data.currentvisit.Account1__r.GeoLocation__Latitude__s');
        var storelon = component.get('v.data.currentvisit.Account1__r.GeoLocation__Longitude__s');
         if (navigator.geolocation){
        navigator.geolocation.getCurrentPosition(function(positionIn){
            var currentlat = positionIn.coords.latitude;
            var currentlon = positionIn.coords.longitude;
            var d = helper.distance(storelon,storelat,currentlon,currentlat);
        },function(err){  
                    helper.catchError(err,helper); 
                },{enableHighAccuracy:true,maximumAge:Infinity, timeout:60000} );
         }*/

        var visits = component.get('v.data.visits');

        var count = 0;
        for (var i = 0; i < visits.length; i++) {
            if (visits[i].Status__c === 'In Progress') {
                count = count + 1;
            }
        }



        if (count == 0) {
            var storelat = component.get('v.data.currentvisit.Account1__r.GeoLocation__Latitude__s');
            var storelon = component.get('v.data.currentvisit.Account1__r.GeoLocation__Longitude__s');
            component.set('v.spinner', true);
            if (navigator.geolocation) {

                navigator.geolocation.getCurrentPosition(function (positionIn) {
                    // component.set('v.checkedIn',positionIn);

                    var currentlat = positionIn.coords.latitude;
                    var currentlon = positionIn.coords.longitude;
                    console.log('currentlat:' + currentlat);
                    console.log('currentlon:' + currentlon);
                    /*//Getting the distance in KM
                    var d = helper.distance(storelon, storelat, currentlon, currentlat);
                    console.log('distance in km:' + d + ' km');
                    var distInMet = d * 1000;
                    console.log('distance in met:' + distInMet + ' mt');
                    if (distInMet > 600) {
                        helper.showToast("Please go to the store and try to check-in again.", "Error");
                        component.set('v.spinner', false);
                    }
                    else {
                        component.set('v.checkedIn', positionIn);
                        component.set('v.spinner', false);
                    }*/
                    
                    component.set('v.checkedIn', positionIn);
                    component.set('v.spinner', false);

                }, function (err) {
                    component.set('v.spinner', false);
                    helper.catchError(err, helper);
                }, { enableHighAccuracy: true, maximumAge: Infinity, timeout: 60000 });

            } else {

            }
        }
        else {
            helper.showToast("You can't checkIn when other visist in progress.", "Warning");
        }

    },
    checkinClick: function (component, event, helper) {

        var visits = component.get('v.data.visits');
        var position = component.get('v.checkedIn');
        if (visits) {
            for (var i = 0; i < visits.length; i++) {

                if (visits[i].EId__c == component.get('v.data.currentvisit.EId__c')) {
                    visits[i].Actual_Start_Time__c = new Date();
                    visits[i].Status__c = 'In Progress';
                    visits[i].Daily_log__c = component.get('v.data.dailyLog.Id');
                    visits[i].ClockIn_Latitude__c = position.coords.latitude;
                    visits[i].Clockin_Longitude__c = position.coords.longitude;
                    visits[i].Check_In_location__Latitude__s = position.coords.latitude;
                    visits[i].Check_In_location__Longitude__s = position.coords.longitude;
                    break;
                }
            }
            //helper.handleShowNewInvoice(component, helper, message);
        }

        component.set('v.data.currentvisit.Actual_Start_Time__c', new Date());
        component.set('v.data.currentvisit.Status__c', 'In Progress');
        component.set('v.data.currentvisit.Daily_log__c', component.get('v.data.dailyLog.Id'));
        component.set('v.checkin', 'true');
        component.set('v.data.summaryCount.plannedVisits', component.get('v.data.summaryCount.plannedVisits') - 1);
        component.set('v.data.summaryCount.InProgress', component.get('v.data.summaryCount.InProgress') + 1);
        helper.checkHandler(component, event, helper);
       // helper.checkOnline(component, event, helper);

    },
    getCheckout: function (component, event, helper) {
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

        let isAllValid = component.find('field').reduce(function (isValidSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return isValidSoFar && inputCmp.checkValidity();
        }, true);

        if (isAllValid == true) {

            component.set('v.spinner', true);
            window.scroll(0, 0);
            if (navigator.geolocation) {

                navigator.geolocation.getCurrentPosition(function (positionIn) {
                    component.set('v.checkedOut', positionIn);

                }, function (err) {
                    component.set('v.spinner', false);
                    window.scroll(0, 1800);
                    helper.catchError(err, helper);
                }, { enableHighAccuracy: true, maximumAge: Infinity, timeout: 60000 });

            }
            else {
                helper.showToast("Geo Location is not supported", "Error");

            }
        } else {
            helper.showToast("Please fill all mandatory fields", "Warning");
        }

    },
    checkoutClick: function (component, event, helper) {


        var visits = component.get('v.data.visits');
        var cv = component.get('v.data.currentvisit');
        var position = component.get('v.checkedOut');
        if (visits) {
            for (var i = 0; i < visits.length; i++) {

                if (visits[i].EId__c == component.get('v.data.currentvisit.EId__c')) {
                    visits[i].Actual_End_Time__c = new Date();
                    visits[i].Status__c = 'Completed';
                    visits[i].Daily_log__c = component.get('v.data.dailyLog.Id');
                    visits[i].TA_DA_Applicable__c = cv.TA_DA_Applicable__c;
                    visits[i].Clockout_Latitude__c = position.coords.latitude;
                    visits[i].Clockout_Longitude__c = position.coords.longitude;
                    visits[i].Check_out_location__Latitude__s = position.coords.latitude;
                    visits[i].Check_out_location__Longitude__s = position.coords.longitude;
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
        component.set('v.checkout', 'true');
        component.set('v.showPhotos', false);
        component.set('v.data.currentvisit.Actual_End_Time__c', new Date());
        component.set('v.data.currentvisit.Status__c', 'Completed');
        component.set('v.data.currentvisit.Daily_log__c', component.get('v.data.dailyLog.Id'));
        component.set('v.data.summaryCount.InProgress', component.get('v.data.summaryCount.InProgress') - 1);
        component.set('v.data.summaryCount.completedVisits', component.get('v.data.summaryCount.completedVisits') + 1);

        helper.checkHandler(component, event, helper);
      //  helper.checkOnline(component, event, helper);


    },

    doPostpone: function (component, event, helper) {
        let isAllValid = component.find('field').reduce(function (isValidSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return isValidSoFar && inputCmp.checkValidity();
        }, true);

        if (isAllValid == true) {
            var currentvisit = component.get('v.data.currentvisit');
            currentvisit.Status__c = 'Missed';
            console.log(currentvisit);
            component.set('v.data.currentvisit', currentvisit);
            component.set("v.showPostpone", false);
            component.set("v.isPopup3", false);
            component.set('v.data.summaryCount.InProgress', component.get('v.data.summaryCount.plannedVisits') - 1);
            component.set('v.data.summaryCount.completedVisits', component.get('v.data.summaryCount.Postponed') + 1);
            helper.checkHandler(component, event, helper);
          //  helper.checkOnline(component, event, helper);
        }

    },
    CreateStore: function (component, event, helper) {
        let isAllValid = component.find('field1').reduce(function (isValidSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return isValidSoFar && inputCmp.checkValidity();
        }, true);

        if (isAllValid == true) {

            var acc = component.get('v.account');
            var accounts = component.get('v.data.accounts');
            acc.Approval_Status__c = '';
            var d = new Date();
            //var eid = 'S'+component.get('v.EIdFormat')+d.getMilliseconds()+'T';
            //acc.EId__c = eid;

            accounts.push(acc);
            component.set('v.data.accounts', accounts);
            component.set('v.account', {});
            component.set('v.visitsView', true);
            component.set('v.showStore', false);
            helper.storeHandler(component, event, helper);
           // helper.checkOnline(component, event, helper);
        }
    },
    createVisit: function (component, event, helper) {
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        var dateValue = $A.localizationService.formatDate(component.get('v.visit.Planned_Start_Time__c'), "YYYY-MM-DD");
        var name = component.get('v.visit.Account1__c');
        console.log('user == '+JSON.stringify(component.get("v.CurrentUser")));
        var allowMultipleVisits = component.get("v.CurrentUser").Allow_Multiple_Visits__c;
        console.log('allowMultipleVisits == '+allowMultipleVisits);
        if (name != null && name != '') {
            var visits = component.get('v.data.visits');
            var vistExist = false;
            for (var i = 0; i < visits.length; i++) {
                console.log('name== '+name);
                console.log('visits[i].Account1__c== '+visits[i].Account1__c);
                if (visits[i].Account1__c == name) {
                    vistExist = true;
                    break;
                }
            }
        }
        if (name == null || name == '') {
            helper.showToast("Please Select Customer", "Warning");

        } else if (component.get('v.approvalStatus') != 'Approved') {
            helper.showToast("This store is not approved \n Please contact your manager", "Error");
        } else if (vistExist == true && dateValue == today && allowMultipleVisits == false) {
            helper.showToast("This store visit already exist", "Warning");
        } else if (dateValue < today) {
            helper.showToast("Please Select Future date", "Warning");
        } else {

            var commentForm = component.find('field1'), valid;
            commentForm.showHelpMessageIfInvalid();
            valid = commentForm.get("v.validity").valid;
            if (valid == true) {
                component.set('v.visit.Status__c', 'Planned');
                var d = new Date();
                //var eid = 'V'+component.get('v.EIdFormat')+d.getMilliseconds()+'T';
                //component.set('v.visit.EId__c', eid);
                var visits = component.get('v.data.visits');
                visits.push(component.get('v.visit'));

                component.set('v.data.visits', visits)
                component.set('v.visit', {});
                component.set('v.searchText', '');
                component.set('v.showVisit', false);
                if (dateValue == today) {
                    component.set('v.data.summaryCount.plannedVisits', component.get('v.data.summaryCount.plannedVisits') + 1);
                    component.set('v.data.summaryCount.visitCount', component.get('v.data.summaryCount.visitCount') + 1);
                }
                component.set('v.newvisit', 'true');
                helper.checkHandler(component, event, helper);
                //helper.checkOnline(component, event, helper);

            }
        }
    },
    createReVisit: function (component, event, helper) {
        var d = new Date();
        var eid = 'V' + component.get('v.EIdFormat') + d.getMilliseconds() + 'T';

        component.set('v.visit.Planned_Start_Time__c', d);
        component.set('v.visit.Account1__r.EId__c', component.get('v.data.currentvisit.Account1__r.EId__c'));
        component.set('v.visit.EId__c', eid);
        component.set('v.RevisitEID', eid);
        component.set('v.visit.Revisit__c', true);
        component.set('v.visit.Revisit__c', true);
        component.set('v.visit.Status__c', 'Planned');
        var visits = component.get('v.data.visits');
        visits.push(component.get('v.visit'));
        component.set('v.data.visits', visits)
        component.set('v.visit', {});
        component.set('v.data.summaryCount.plannedVisits', component.get('v.data.summaryCount.plannedVisits') + 1);
        component.set('v.data.summaryCount.visitCount', component.get('v.data.summaryCount.visitCount') + 1);
        component.set('v.newvisit', 'true');
        helper.checkHandler(component, event, helper);
        //helper.checkOnline(component, event, helper);

    },
    openCamera: function (component, event, helper) {

        if (!window.navigator.onLine) {
            helper.showToast("Currently Offilne", "Info");
        } else {

            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": "https://fit-fls-dev-ed.my.salesforce-sites.com/upload?id=" + component.get('v.data.currentvisit.Id')
            });
            urlEvent.fire();
            if (component.get("v.showPhotos") == true) {
                component.set("v.showPhotosButtonLable", 'Show Photos');
                component.set("v.showPhotos", false);
            }
        }
    },

    /*getdisricts: function (component, event, helper) {
        helper.districtPickList(component, event, helper);
    },*/
    selectChange: function (component, event, helper) {

        if (component.get('v.showall')) {

        } else {
            component.set('v.showall', false);
        }
    },
    /* Popup open close methods */

    PostPoneClick: function (component, event, helper) {
        const today = new Date()
        today.setDate(today.getDate() + 1)
        var tomorrow = $A.localizationService.formatDate(today, "YYYY-MM-DD");
        component.set('v.Today', tomorrow);
        component.set("v.showPostpone", true);
        component.set("v.isPopup3", true);

    },
    closePostpone: function (component, event, helper) {
        component.set('v.data.currentvisit.PostPoned_Start_Time__c', null);
        component.set('v.data.currentvisit.Missed_PostPone_Reason__c', null);
        component.set("v.showPostpone", false);
        component.set("v.isPopup3", false);
    },
    newVisit: function (component, event, helper) {
        var d = new Date(); var date; var month; var hour; var min; var sec;
        d.setHours(d.getHours() - 5);
        d.setMinutes(d.getMinutes() - 29);

        if (d.getMonth() < 10) { month = "0" + d.getMonth(); } else { month = d.getMonth(); }
        if (d.getDate() < 10) { date = "0" + d.getDate(); } else { date = d.getDate(); }
        if (d.getHours() < 10) { hour = "0" + d.getHours(); } else { hour = d.getHours(); }
        if (d.getMinutes() < 10) { min = "0" + d.getMinutes(); } else { min = d.getMinutes(); }
        if (d.getSeconds() < 10) { sec = "0" + d.getSeconds(); } else { sec = d.getSeconds(); }

        var fulldate = d.getFullYear() + "-" + month + "-" + date + "T" + hour + ":" + min + ":" + sec + "Z";

        //component.set('v.visit.Planned_Start_Time__c',fulldate);
        component.set('v.Today', fulldate);

        component.set("v.showVisit", true);
        component.set("v.isPopup", true);
    },
    closePopUp: function (component, event, helper) {
        component.set('v.visit', {});
        component.set('v.searchText', '');
        component.set("v.show", false);
        component.set("v.isPopup", false);
    },
    newStore: function (component, event, helper) {
        //component.set("v.showStore",true);
        //component.set("v.isPopup2",true);
        //component.set("v.visitsView",false);
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:newStore",
            componentAttributes: {
                fromMyVisit : true
            } 
        });

        evt.fire();
    },
    closeStore: function (component, event, helper) {
        component.set("v.visitsView", true);
        component.set("v.showStore", false);
        component.set("v.isPopup2", false);
    },
    showPhotos: function (component, event, helper) {
        if (component.get("v.showPhotos") == false) {
            if (!window.navigator.onLine) {
                helper.showToast("Currently Offilne", "info");
            } else {
                component.set("v.showPhotos", true);
                component.set("v.showPhotosButtonLable", 'Hide Photos');
            }
        } else {
            component.set("v.showPhotosButtonLable", 'Show Photos');
            component.set("v.showPhotos", false);
        }

    },
    showMap: function (component, event, helper) {
        if (component.get('v.showMap') === true) {
            component.set('v.showMap', false);
        }
        else {
            var visits = component.get('v.data.visits');
            var mapData = Array();
            if (visits.length > 0) {
                for (var i = 0; i < visits.length; i++) {
                    if (visits[i].Account1__r.GeoLocation__Latitude__s != null && visits[i].Account1__r.GeoLocation__Longitude__s != null) {
                        mapData.push({
                            "lat": parseFloat(visits[i].Account1__r.GeoLocation__Latitude__s), "lng": parseFloat(visits[i].Account1__r.GeoLocation__Longitude__s),
                            "markerText": i + ') ' + visits[i].Account_Name__c, "status": visits[i].Status__c,
                            "checkIn": visits[i].Actual_Start_Time__c, "checkOut": visits[i].Actual_End_Time__c

                        });

                    }
                }
            }
            var mapOptionsCenter = { "lat": parseFloat(mapData[0].lat), "lng": parseFloat(mapData[0].lng) };
            component.set('v.mapOptionsCenter', mapOptionsCenter);
            component.set('v.mapData', mapData);
            //(mapData);
            component.set('v.showMap', true);
        }

        if (component.get('v.showMapButton') === true) {
            component.set('v.showMapButton', false);
        }
        else {
            component.set('v.showMapButton', true);
        }
    },
    searchText: function (component, event, helper) {
        var accounts = component.get('v.data.accounts');
        var searchText = component.get('v.searchText');
        var matchaccounts = [];
        if (searchText != '') {
            for (var i = 0; i < accounts.length; i++) {
                if (accounts[i].Name.toLowerCase().indexOf(searchText.toLowerCase()) != -1) {

                    if (matchaccounts.length < 50) {
                        matchaccounts.push(accounts[i]);
                    } else {
                        break;
                    }

                }
            }
            if (matchaccounts.length > 0) {
                component.set('v.matchaccounts', matchaccounts);
            }
        } else {
            component.set('v.matchaccounts', []);
        }
    },
    update: function (component, event, helper) {

        component.set('v.visit.Account1__c', event.currentTarget.dataset.id);
        var edi = component.get('v.visit.Account1__c');
        var accounts = component.get('v.matchaccounts');
        for (var i = 0; i < accounts.length; i++) {
            if (accounts[i].Id === edi) {
                component.set('v.searchText', accounts[i].Name);
                component.set('v.visit.AccountName__c', accounts[i].Name);
                component.set('v.approvalStatus', accounts[i].Approval_Status__c)
                break;
            }
        }

        component.set('v.matchaccounts', []);

    },
	// When clicked on New Order Button
    createOrder: function (component, event, helper) {
        
       // var oldui = component.get('v.data.currentvisit.Account1__r.Don_t_Apply_FIFO__c');
        var oldui = true;
        console.log(oldui);
        if(!oldui){
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:MyOrderCmp",
            });
            evt.fire();
        }
        else{
            
            
            var d = new Date();
            var eid = 'O' + component.get('v.EIdFormat') + d.getMilliseconds() + 'T';
            
            var today = $A.localizationService.formatDate(new Date(), "DD-MM-YYYY");
            component.set('v.Today', today);
            var invDate = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
            var storeId = component.get('v.data.currentvisit.Account1__c');
            var visitId = component.get('v.data.currentvisit.Id');
            
            component.set('v.Order.Customer__c', storeId);
            component.set('v.Order.Visit__c', visitId);
            component.set('v.Order.EID__c', eid);
            component.set('v.Order.Invoice_Date__c', invDate);
            // component.set('v.Order.Grand_Total_Edit__c',0.00);
            
            component.set("v.buttonsToCreateOrder", 'NewOrder');
            //component.set("v.showproductlst",true);
            component.set("v.showproductCardViewOrder", true);
            component.set('v.spinner', true);
            var action = component.get("c.getProductsOrder");
            action.setParams({
                            "accountID": storeId
                        });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state == "SUCCESS") {
                    
                    var db = response.getReturnValue();
                    console.log('db=== '+JSON.stringify(db));
                    if(db){
                        for (var i = 0; i < db.length; i++) {
                            db[i].check = false;
                        }
                        component.set('v.stockList', db);
                        component.set('v.searchList', db);
                        component.set('v.spinner', false);
                    }else{
                        helper.showToast('Stock is not available.', 'Information');
                        component.set('v.spinner', false);
                        component.set("v.showproductCardViewOrder", false);
                        component.set("v.visitsView", true);
                    }
                }
            });
            $A.enqueueAction(action);
            
            var action1 = component.get("c.getDiscounts");
            action1.setParams({ 'accId': storeId })
            action1.setCallback(this, function (response) {
                var state = response.getState();
                if (state == "SUCCESS") {
                    var db = response.getReturnValue();
                    component.set('v.discounts', db);
                    component.set('v.spinner', false);
                }
            });
            $A.enqueueAction(action1);
            
            helper.addProductRecord(component, event, visitId, storeId);
            component.set("v.visitsView", false);
        }

    },
	// When Clicked on Convert Invoice Button
    ordersList: function (component, event, helper) {
        var accountID = component.get("v.data.currentvisit.Account1__r.Id");
        var action1 = component.get("c.checkCreditPeriod");
        action1.setParams({
            "accountID": accountID
        });
        action1.setCallback(this, function (response) {
            var State1 = response.getState();
            if (State1 === "SUCCESS") {
                var result1 = response.getReturnValue();
                console.log('credit period exceed===' + result1);
                if (result1) {
                    component.set('v.showNewInvoice', false);
                    helper.showToast('Sales invoice can not be created or converted.Customer credit period is exceeded to create Sales invoice.', 'Information');
                } else {
                    console.log('Show sales Invoice===');
                    var d = new Date();
                    var eid = 'O' + component.get('v.EIdFormat') + d.getMilliseconds() + 'T';
                    var today = $A.localizationService.formatDate(new Date(), "DD-MM-YYYY");
                    component.set('v.Today', today);
                    var invDate = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
                    var storeId = component.get('v.data.currentvisit.Account1__c');
                    var visitId = component.get('v.data.currentvisit.Id');

                    component.set('v.Order.Customer__c', storeId);
                    component.set('v.Order.Visit__c', visitId);
                    component.set('v.Order.EID__c', eid);
                    component.set('v.Order.Invoice_Date__c', invDate);
                    
                    // component.set('v.Order.Grand_Total_Edit__c',0.00);


                    component.set('v.spinner', true);
                    component.set('v.showorderslst', true);
                    var name = component.get('v.data.currentvisit.Account1__c');
                    var action = component.get("c.getOders");
                    action.setParams({ 'cusName': name })
                    action.setCallback(this, function (response) {
                        var state = response.getState();
                        if (state == "SUCCESS") {
                            var db = response.getReturnValue();
                            /*for(var i=0;i<db.length;i++){
                             db[i].check = false;
                             }*/
                            component.set('v.stockList', db);
                            component.set('v.searchList', db);
                            component.set('v.spinner', false);
                            console.log(db);
                        }
                    });
                    $A.enqueueAction(action);
                    component.set("v.visitsView", false);
                }
            } else if (State1 === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert("Error message: " +
                            errors[0].message);
                    }
                }
            }
        });
        $A.enqueueAction(action1);
    },
    // When clicked on New Unsealed Button
    unsealedClick: function (component, event, helper) {
        var accountID = component.get("v.data.currentvisit.Account1__r.Id");
                    var d = new Date();
                    var eid = 'O' + component.get('v.EIdFormat') + d.getMilliseconds() + 'T';

                    var today = $A.localizationService.formatDate(new Date(), "DD-MM-YYYY");
                    component.set('v.Today', today);
                    var invDate = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
                    var storeId = component.get('v.data.currentvisit.Account1__c');
                    var visitId = component.get('v.data.currentvisit.Id');
                    component.set("v.buttonsToCreateOrder", 'unsealed');
                    component.set('v.Order.Customer__c', storeId);
                    component.set('v.Order.Visit__c', visitId);
                    component.set('v.Order.EID__c', eid);
                    component.set('v.Order.Invoice_Date__c', invDate);
                    component.set("v.showproductCardView", true);
                    component.set('v.spinner', true);
                    var action = component.get("c.getProduct");
                    action.setCallback(this, function (response) {
                        var state = response.getState();
                        if (state == "SUCCESS") {
                            var db = response.getReturnValue();
                            //alert('db=== '+db);
                            if(db){
                                for (var i = 0; i < db.length; i++) {
                                    db[i].check = false;
                                }
                                component.set('v.stockList', db);
                                component.set('v.searchList', db);
                                component.set('v.spinner', false);
                            }
                            else{
                                helper.showToast('Stock is not available.', 'Information');
                                component.set('v.spinner', false);
                                component.set("v.showproductCardView", false);
                                component.set("v.visitsView", true);
                            }
                        }
                    });
                    $A.enqueueAction(action);
                    helper.addProductRecord(component, event, visitId, storeId);
                    component.set("v.visitsView", false);
    },
	// When clicked on New Invoice Button
    orderClick: function (component, event, helper) {
        
       // var oldui = component.get('v.data.currentvisit.Account1__r.Don_t_Apply_FIFO__c');
        var oldui = true;
        if(!oldui){
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:NewInvoiceCmp",
            });
            evt.fire();
        }
        else{
            var accountID = component.get("v.data.currentvisit.Account1__r.Id");
            var action1 = component.get("c.checkCreditPeriod");
            action1.setParams({
                "accountID": accountID
            });
            action1.setCallback(this, function (response) {
                var State1 = response.getState();
                if (State1 === "SUCCESS") {
                    var result1 = response.getReturnValue();
                    console.log('credit period exceed===' + result1);
                    if (result1) {
                        component.set('v.showNewInvoice', false);
                        helper.showToast('Sales invoice can not be created or converted.Customer credit period is exceeded to create Sales invoice.', 'Information');
                    } else {
                        console.log('Show sales Invoice===');
                        var d = new Date();
                        var eid = 'O' + component.get('v.EIdFormat') + d.getMilliseconds() + 'T';
                        
                        var today = $A.localizationService.formatDate(new Date(), "DD-MM-YYYY");
                        component.set('v.Today', today);
                        var invDate = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
                        var storeId = component.get('v.data.currentvisit.Account1__c');
                        var visitId = component.get('v.data.currentvisit.Id');
                        component.set("v.buttonsToCreateOrder", 'NewInvoice');
                        component.set('v.Order.Customer__c', storeId);
                        component.set('v.Order.Visit__c', visitId);
                        component.set('v.Order.EID__c', eid);
                        component.set('v.Order.Invoice_Date__c', invDate);
                        // component.set('v.Order.Grand_Total_Edit__c',0.00);
                        component.set("v.showproductCardView", true);
                        //component.set("v.showproductlst",true);
                        component.set('v.spinner', true);
                        var action = component.get("c.getProducts");
                         action.setParams({
                            "accountID": accountID
                        });
                        action.setCallback(this, function (response) {
                            var state = response.getState();
                            if (state == "SUCCESS") {
                                var db = response.getReturnValue();
                                //alert('db=== '+db);
                                if(db){
                                    for (var i = 0; i < db.length; i++) {
                                        db[i].check = false;
                                    }
                                    component.set('v.stockList', db);
                                    component.set('v.searchList', db);
                                    component.set('v.spinner', false);
                                }else{
                                    helper.showToast('Stock is not available.', 'Information');
                                    component.set('v.spinner', false);
                                    component.set("v.showproductCardView", false);
                                    component.set("v.visitsView", true);
                                }
                            }
                        });
                        $A.enqueueAction(action);
                        
                        
                        var action1 = component.get("c.getDiscounts");
                        action1.setParams({ 'accId': storeId })
                        action1.setCallback(this, function (response) {
                            var state = response.getState();
                            if (state == "SUCCESS") {
                                var db = response.getReturnValue();
                                component.set('v.discounts', db);
                                component.set('v.spinner', false);
                            }
                        });
                        $A.enqueueAction(action1);
                        
                        helper.addProductRecord(component, event, visitId, storeId);
                        component.set("v.visitsView", false);
                    }
                } else if (State1 === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            alert("Error message: " +
                                  errors[0].message);
                        }
                    }
                }
            });
            $A.enqueueAction(action1);
        }
    },
    handleChange1: function (component, event) {
        var stlist = component.get('v.stockList');
        var capturedCheckboxName = event.getSource().get("v.value");
        var selectedCheckBoxes = component.get("v.selectedCheckBoxes");
        if (selectedCheckBoxes.indexOf(capturedCheckboxName) > -1) {
            selectedCheckBoxes.splice(selectedCheckBoxes.indexOf(capturedCheckboxName), 1);
            for (var i = 0; i < stlist.length; i++) {
                if (stlist[i].productObj.Id == capturedCheckboxName) {
                    stlist[i].productObj.check = false;
                    break;
                }
            }
        }
        else {
            selectedCheckBoxes.push(capturedCheckboxName);
            for (var i = 0; i < stlist.length; i++) {
                if (stlist[i].productObj.Id == capturedCheckboxName) {
                    stlist[i].productObj.check = true;
                    break;
                }
            }
        }
        component.set("v.selectedCheckBoxes", selectedCheckBoxes);
    },
    search: function (component, event) {
        var searchtext = component.get('v.searchProd');
        var stlist = component.get('v.stockList');

        var searchRes = [];
        if (searchtext != '' && searchtext != null) {
            for (var i = 0; i < stlist.length; i++) {

                if (stlist[i].productObj.Product_Name__c.toLowerCase().includes(searchtext.toLowerCase())) {
                    searchRes.push(stlist[i]);
                }
            }
            component.set('v.searchList', searchRes);

        }
        else {
            component.set('v.searchList', stlist);
        }



    },
    searchProducts: function (component, event) {
        var searchtext = component.get('v.searchProd');
        var stlist = component.get('v.searchList');
        var searchRes = [];
        if (searchtext != '' && searchtext != null) {
            for (var i = 0; i < stlist.length; i++) {
                if (stlist[i].productObj.Name.toLowerCase().includes(searchtext.toLowerCase())) {
                    searchRes.push(stlist[i]);
                }
            }
            component.set('v.searchList', searchRes);
        }
        else {
            component.set('v.searchList', component.get('v.stockList'));
        }
    },
    
    searchProductCodes: function (component, event) {
        var searchtext = component.get('v.searchProdCode');
        var stlist = component.get('v.stockList');
        var searchRes = [];
        if (searchtext != '' && searchtext != null) {
            for (var i = 0; i < stlist.length; i++) {
                console.log('searched product== '+JSON.stringify(stlist[i].productObj));
                if (stlist[i].productObj.Product_Code__c.toLowerCase().includes(searchtext.toLowerCase())) {
                    searchRes.push(stlist[i]);
                }
            }
            component.set('v.searchList', searchRes);
        }
        else {
            component.set('v.searchList', component.get('v.stockList'));
        }
    },
    
    // When product is added to cart
    addToCart : function (component, event,helper){
        var targetVal = event.currentTarget;
        var productId = targetVal.dataset.value;
        console.log('Prod ID=== '+productId);
        var cartProductIds = component.get('v.cartProductIds');
        if(cartProductIds.includes(productId)){
            helper.showToast('Selected product is already added in cart.','Information');
        }else{
            cartProductIds.push(productId);
            component.set('v.cartItems',cartProductIds.length);
            if(cartProductIds.length > 0){
                component.set('v.disableCart',false);
            }
             console.log('Cart Prod IDs=== '+cartProductIds);
                        console.log('Cart Prod IDs=== '+cartProductIds.length);
            /*var action = component.get('c.checkStockForPrpduct');
            action.setParams({
                productId :  productId
            });
            action.setCallback(this,function(response){
                var state = response.getState();
                if(state == "SUCCESS" ){ 
                    var result = response.getReturnValue();
                    console.log('Add Item To Cart== '+result);
                    if(result){
                        
                        cartProductIds.push(productId);
                        component.set('v.cartItems',cartProductIds.length);
                        if(cartProductIds.length > 0){
                            component.set('v.disableCart',false);
                        }
                        console.log('Cart Prod IDs=== '+cartProductIds);
                        console.log('Cart Prod IDs=== '+cartProductIds.length);
                        
                    }else{
                        console.log('No stock available.');
                        helper.showToast('Selected product has no stock available, manufacturing date is missing or stock is returned.','Warning');
                    }
                }
            });
            $A.enqueueAction(action);*/
        }
    }, 

    repeatProduct: function (component, event,helper) {
        var targetVal = event.currentTarget;
        var productId = targetVal.dataset.value;
        console.log('Prod ID=== ' + productId);
        var cartProductIds = component.get('v.cartProductIds');
        cartProductIds.push(productId);
        component.set('v.cartItems', cartProductIds.length);
        if (cartProductIds.length > 0) {
            component.set('v.disableCart', false);
        }
        var action = component.get("c.getCartProducts");
        action.setParams({
            cartProductIds: productId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var result = response.getReturnValue();

                console.log('cart products=== ' + JSON.stringify(result));
                if (result) {
                    //component.set("v.orderItemList",result);
                    var orderItemList = component.get('v.orderItemList');
                    orderItemList.push(result[0]);
                    component.set("v.orderItemList", orderItemList);
                    console.log("orderItemList== " + JSON.stringify(orderItemList));
                }
            }
        });
        $A.enqueueAction(action);
    },
    removeProduct: function (component, event,helper) {
        event.stopPropagation();
        var targetVal = event.currentTarget;
        var productId = targetVal.dataset.value;
        var index = event.currentTarget.dataset.record;
        var orderItemList = component.get('v.orderItemList');
        //var oitems = component.get('v.orderItemList');
        console.log('index=== '+index);
        console.log('Prod ID=== ' + productId);
        var cartProductIds = component.get('v.cartProductIds');
        cartProductIds.filter(item => item !== productId);
        cartProductIds.pop(productId);
        component.set('v.cartItems', cartProductIds.length);
        if (cartProductIds.length > 0) {
            component.set('v.disableCart', false);
        }
        console.log('Cart Prod IDs=== ' + cartProductIds);
        console.log('Cart Prod IDs=== ' + cartProductIds.length);
        //$A.get("e.force:refreshView").fire();
        var action = component.get("c.getCartProducts");
        action.setParams({
            cartProductIds: cartProductIds
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var result = response.getReturnValue();

                console.log('cart products=== ' + JSON.stringify(result));
                if (result) {
                    if(orderItemList[index].Total__c == 'undefined' || orderItemList[index].Total__c == null){
                        orderItemList[index].Total__c = 0.00;
                    }
                    //component.set("v.orderItemList",result);
                    console.log("orderItemList== " + JSON.stringify(orderItemList));
                    var grandtotaldisc1;
                    //var grandTotal = component.get('v.GrandTotal')
                    var InitialTotal = component.get('v.InitialTotal');
                    var cashDis= component.get('v.data.currentvisit.Account1__r.Cash_Discount__c');
                    var updatedGrandTotal = InitialTotal - orderItemList[index].Total__c;
                    component.set('v.InitialTotal',updatedGrandTotal);
                     grandtotaldisc1 = component.get('v.GrandTotalDisc');
                   /* if (component.get('v.Receipt').Payment_Type__c == 'Immediate' ) {
                        grandtotaldisc1 = component.get('v.GrandTotalDisc');
                        var disApplied = component.get('v.disApplied');
                        console.log('disApplied== ' + disApplied);
                        
                        if (cashDis != null && cashDis != "undefined") {
                            grandtotaldisc1 = updatedGrandTotal - ((updatedGrandTotal * cashDis) / 100);
                        }
                        component.set('v.disApplied', true);
                    } else {
                        component.set('v.disApplied', false);
                        console.log('else ==== ');
                        grandtotaldisc1 = updatedGrandTotal;
                    }*/
                    grandtotaldisc1 = updatedGrandTotal;
                    component.set('v.GrandTotalDisc',Number(grandtotaldisc1).toFixed(2));
                    component.set('v.GrandTotal',Number(grandtotaldisc1).toFixed(2));
                    orderItemList.splice(index,1);
                    component.set("v.orderItemList", orderItemList);
                    //var action1 = component.get('c.onSelectPay');
                    //$A.enqueueAction(action1);
                    //console.log("orderItemList== " + JSON.stringify(orderItemList));
                    if(orderItemList.length == 0){
                        component.set('v.showOrderWithItems',false);
                        component.set('v.showUnsealed',false);
                        component.set('v.showorder',false);
                        component.set('v.showproductCardView',true);
                        component.set('v.cartItems','');
                        component.set('v.cartProductIds',[]);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    

	// When Cart is clicked after selecting Products for Order
    cartClickOrder: function (component, event, helper) {
        component.set('v.spinner', true);
          var stocks = component.get('v.stocks');
         
        var cartProductIds = component.get('v.cartProductIds');
        console.log('cartProductIds== ' + cartProductIds);
        if (cartProductIds.length > 0) {
            var action = component.get("c.getCartProducts");
            action.setParams({
                cartProductIds: cartProductIds
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state == "SUCCESS") {
                    var result = response.getReturnValue();
					component.set('v.stocks', []);
                    console.log('cart products=== ' + JSON.stringify(result));
                    if (result) {
                        component.set("v.orderItemList", result);
                        
                        console.log("orderItemList== " + JSON.stringify(result));
                         console.log("stocks== " + JSON.stringify(result));


                        var mapOfProductStockMfgMap = component.get('v.mapOfProductStockMfgMap');
                        var mapOfProductStockMfgArr = [];

                        var recordId = '';
                        for (var i = 0; i < result.length; i++) {
                            console.log('result[i].Id=== ' + result[i].Id)
                            recordId = result[i].Id;
                            helper.getManuFacturingDatesOrder(component, event, helper, result[i].Id)
                                .then(function (result2) {
                                     component.set('v.spinner', true); 
                                    console.log('result 11=== ' + JSON.stringify(result2));
                                     
                                    if (result2.length > 0) {
                                        for (var i = 0; i < result2.length; i++) {
                                            if(!mapOfProductStockMfgMap.includes({ key: result2[i].value.Product__c, value: result2[i] })){
                                                stocks.push(result2[i].value);
                                                mapOfProductStockMfgArr.push({ key: result2[i].value.Product__c, value: result2[i] });
                                                console.log('mapOfProductStockMfgMap=== ' + JSON.stringify(mapOfProductStockMfgMap));
                                            }
                                        }
                                        component.set('v.mapOfProductStockMfgMap', mapOfProductStockMfgArr);
                                    	component.set('v.spinner', false);
                                    } else {
                                        helper.showToast(recordId + 'product has no stock available.', 'warning');
                                        component.set('v.spinner', false);
                                    }
                                      component.set("v.stocks", stocks);
                                });
                        }
                    }
                }
            });
            $A.enqueueAction(action);
            window.setTimeout(
                $A.getCallback(function () {
                   // component.set('v.spinner', false);
                    component.set("v.showproductCardViewOrder", false);
                    component.set("v.showproductCartListOrder", true);
                    if (component.get('v.buttonsToCreateOrder') == 'NewOrder') {
                        component.set("v.showOrderWithItems", true);
                    } else if(component.get('v.buttonsToCreateOrder') == 'NewInvoice'){
                        component.set("v.showorder", true);
                    }else if(component.get('v.buttonsToCreateOrder') == 'unsealed'){
                        component.set("v.showUnsealed", true);
                    }

                }), 2000
            );
        } else {
            helper.showToast('Cart is empty.', 'Error');
        }

    },
    // When Cart is clicked after selecting Products for Invoice
      cartClick: function (component, event, helper) {
        component.set('v.spinner', true);
            var stocks = component.get('v.stocks');
          
        var cartProductIds = component.get('v.cartProductIds');
        console.log('cartProductIds== ' + cartProductIds);
        if (cartProductIds.length > 0) {
            var action = component.get("c.getCartProducts");
            action.setParams({
                cartProductIds: cartProductIds
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state == "SUCCESS") {
                    var result = response.getReturnValue();
                    component.set('v.stocks', []);
                    console.log('cart products=== ' + JSON.stringify(result));
                    if (result) {
                        component.set("v.orderItemList", result);
                        
                        console.log("orderItemList== " + JSON.stringify(result));
                         console.log("stocks== " + JSON.stringify(result));


                        var mapOfProductStockMfgMap = component.get('v.mapOfProductStockMfgMap');
                        var mapOfProductStockMfgArr = [];

                        var recordId = '';
                        for (var i = 0; i < result.length; i++) {
                            console.log('result[i].Id=== ' + result[i].Id)
                            recordId = result[i].Id;
                            helper.getManuFacturingDates(component, event, helper, result[i].Id)
                                .then(function (result2) {
                                    console.log('result 11=== ' + JSON.stringify(result2));
                                     
                                    if (result2.length > 0) {
                                        for (var i = 0; i < result2.length; i++) {
                                            if(!mapOfProductStockMfgMap.includes({ key: result2[i].value.Product__c, value: result2[i] })){
                                                  stocks.push(result2[i].value);
                                                mapOfProductStockMfgArr.push({ key: result2[i].value.Product__c, value: result2[i] });
                                                console.log('mapOfProductStockMfgMap=== ' + JSON.stringify(mapOfProductStockMfgMap));
                                            }
                                        }
                                        component.set('v.mapOfProductStockMfgMap', mapOfProductStockMfgArr);
                                    	component.set('v.spinner', false);
                                    } else {
                                        helper.showToast(recordId + 'product has no stock available.', 'warning');
                                        component.set('v.spinner', false);
                                    }
                                      component.set("v.stocks", stocks);
                                });
                        }
                    }
                }
            });
            $A.enqueueAction(action);
            window.setTimeout(
                $A.getCallback(function () {
                  //  component.set('v.spinner', false);
                    component.set("v.showproductCardView", false);
                    component.set("v.showproductCartListOrder", true);
                    if (component.get('v.buttonsToCreateOrder') == 'NewOrder') {
                        component.set("v.showOrderWithItems", true);
                    } else if(component.get('v.buttonsToCreateOrder') == 'NewInvoice'){
                        component.set("v.showorder", true);
                    }else if(component.get('v.buttonsToCreateOrder') == 'unsealed'){
                        component.set("v.showUnsealed", true);
                    }

                }), 2000
            );
        } else {
            helper.showToast('Cart is empty.', 'Error');
        }

    },

    navigateToMyComponent: function (component, event, helper) {
        

        var recId = event.currentTarget.dataset.id;
        component.set('v.selectedRecordId', recId);
        component.set("v.showorderitems", true);
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:SalesOrderItemList",
            componentAttributes: {
                recordId: recId,
                cashDiscount: component.get('v.data.currentvisit.Account1__r.Cash_Discount__c')
            }
        });
        evt.fire();
    },
    salesOrderItems: function (component, event) {
        //var itm = component.get('v.selectedCheckBoxes');
        var recId = event.currentTarget.dataset.id;
        //console.log(recId);
        component.set("v.showorderslst", false);
        //component.set("v.buttonsToCreateOrder",'');
        component.set("v.showorderitems", true);
        //var ot=component.get('v.data.currentvisit.Account1__r.Id');
        //var discounts = component.get('v.discounts');
        var action = component.get("c.getOdersItems");

        action.setParams({ 'ordName': recId })
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var db = response.getReturnValue();
                /*for(var i=0;i<db.length;i++){
                    db[i].check = false;
                }*/
                //component.set('v.stockList',db);
                component.set('v.OrderLineLists', db);
                component.set('v.spinner', false);
            }
        });
        $A.enqueueAction(action);;
    },

    /*NextClick: function (component, event) {
        var itm = component.get('v.selectedCheckBoxes');
        component.set("v.showproductlst", false);
        component.set("v.buttonsToCreateOrder", '');
        component.set("v.showorder", true);
        var ot = component.get('v.data.currentvisit.Account1__r.Id');
        var discounts = component.get('v.discounts');
        //alert('discounts-'+discounts);
        var action = component.get("c.getProduct");
        action.setParams({ 'ProductList': itm })
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var prds = response.getReturnValue();
                var oitems = component.get('v.orderItemList');

                //alert('Stock : '+JSON.stringify(prds));
                for (var i = 0; i < prds.length; i++) {
                    var dis = 0;
                    for (var d = 0; d < discounts.length; d++) {
                        if (prds[i].Product_GST__c == discounts[d].GST_Percentage__c) {
                            dis = discounts[d].Discount_Percent__c;
                        }
                    }
                    if (i == 0) {
                        oitems[i].Name = prds[i].Product_Name__c;
                        oitems[i].Product__c = prds[i].Product__c;
                        oitems[i].Stock__c = prds[i].Id;
                        oitems[i].Unit_Price__c = prds[i].Price__c;
                        oitems[i].GST_Percentage__c = prds[i].Product_GST__c;
                        oitems[i].Discount_Percent__c = dis;
                        oitems[i].Available_Quantity__c = prds[i].Available_Quantity__c;
                    }
                    else {
                        oitems.push({
                            'sobjectType': 'Sales_Invoice_Item__c',
                            'Name': prds[i].Product_Name__c,
                            'Product__c': prds[i].Product__c,
                            'Stock__c': prds[i].Id,
                            'Available_Quantity__c': prds[i].Available_Quantity__c,
                            'Quantity__c': '',
                            'Unit_Price__c': prds[i].Price__c,
                            'GST_Percentage__c': prds[i].Product_GST__c,
                            'Discount_Percent__c': dis,
                            'Total__c': '',
                            'Total_after_discount__c': '',

                        });
                    }
                }
                //alert(JSON.stringify(oitems))
                component.set('v.orderItemList', oitems);

            }
        });
        $A.enqueueAction(action);

    },*/
    /*update2: function (component, event, helper) {
        component.set('v.spinner', true);
        var index = event.currentTarget.dataset.record;
        // alert(index)
        var pid = event.currentTarget.dataset.id;
        var prds = component.get('v.matchproducts');
        var oitems = component.get('v.orderItemList');

        for (var i = 0; i < prds.length; i++) {
            if (prds[i].Id === pid) {
                //oitems[index].Product__c = prds[i].Id;
                oitems[index].Name = prds[i].Product_Name__c;
                oitems[index].Product__c = prds[i].Product__c;
                oitems[index].Stock__c = prds[i].Id;
                oitems[index].Unit_Price__c = prds[i].Price__c;
                //oitems[index].Minimum_Stock__c = prds[i].Total_Available_Stock__c;
                oitems[index].GST_Percentage__c = prds[i].GST__c;
                // oitems[index].Product_Name__c = prds[i].Name;
                component.set('v.searchText2', '');
                break;
            }

        }
        component.set('v.orderItemList', oitems);
        component.set('v.matchproducts', []);
        component.set('v.spinner', false);
    },*/

    CancelClickOrder: function (component, event) {

        component.set("v.showproductlst", false);
        component.set("v.showorderslst", false);
        component.set("v.showorderitems", false);
        component.set("v.showorder", false);
        component.set("v.buttonsToCreateOrder", '');
        component.set("v.visitsView", true);
        component.set("v.selectedCheckBoxes", []);
        component.set("v.orderItemList", []);
        component.set("v.showproductCardViewOrder", false);
        component.set("v.cartItems", '');
        component.set("v.cartProductIds", []);
        component.set("v.disableCart", true);
        component.set("v.mapOfProductStockMfgMap", []);
        component.set("v.stocks", []);
        component.set("v.productStockMfgMap", []);
        component.set("v.productStockMfgMap", []);
        component.set("v.confirmOrderWithItems", false);
        component.set('v.showConfirmInvoiceWithItem',false);
        component.set("v.originalStockQuantities", {});
    },
    CancelClick: function (component, event) {

        component.set("v.showproductlst", false);
        component.set("v.showorderslst", false);
        component.set("v.showorderitems", false);
        component.set("v.showorder", false);
        component.set("v.buttonsToCreateOrder", '');
        component.set("v.visitsView", true);
        component.set("v.selectedCheckBoxes", []);
        component.set("v.orderItemList", []);
        component.set("v.showproductCardView", false);
        component.set("v.cartItems", '');
        component.set("v.cartProductIds", []);
        component.set("v.disableCart", true);
        component.set("v.mapOfProductStockMfgMap", []);
        component.set("v.stocks", []);
        component.set("v.productStockMfgMap", []);
        component.set("v.productStockMfgMap", []);
        component.set("v.confirmOrderWithItems", false);
        component.set('v.showConfirmInvoiceWithItem',false);
        component.set("v.originalStockQuantities", {});
    },
    addRow: function (component, event, helper) {
        var storeId = component.get('v.data.currentvisit.Account1__r.EId__c');
        var visitId = component.get('v.data.currentvisit.EId__c');
        helper.addProductRecord(component, event, visitId, storeId);

    },
    removeRow: function (component, event, helper) {

        var orderList = component.get("v.orderItemList");
        var cartProductIds = component.get('v.cartProductIds');
        var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.record;
        var oitems = component.get('v.orderItemList');
        var total = (((oitems[index].Unit_Price__c * oitems[index].Quantity__c) * oitems[index].TAX_Per_GST__c) / 100) + (oitems[index].Unit_Price__c * oitems[index].Quantity__c);
        var grandtotal = (component.get('v.GrandTotal') - total);
        component.set('v.GrandTotal', grandtotal);
        orderList.splice(index, 1);
        component.set("v.orderItemList", orderList);
        if (orderList.length < 1) {
            helper.addProductRecord(component, event);
        }
        
       
    },
    searchText2: function (component, event, helper) {

        var products = component.get('v.data.products');
        var searchText = component.get('v.searchText2');

        var matchprds = [];
        if (searchText != '') {
            for (var i = 0; i < products.length; i++) {
                if (products[i].Name.toLowerCase().indexOf(searchText.toLowerCase()) != -1) {
                    matchprds.push(products[i]);
                }
            }
            if (matchprds.length > 0) {
                component.set('v.matchproducts', matchprds);
            }
        } else {
            component.set('v.matchproducts', []);
        }
    },

    // Save Invoice after confirmation
    save: function (component, event, helper) {
        component.set('v.disableInvoice',true);
        if (helper.validateOrderList(component, event)) {
            var oitems = component.get('v.orderItemList');
            var order = component.get('v.Order');
            var dataOrderItems = component.get('v.data.orderitems');
            var dataOrder = component.get('v.data.orders');
            component.set('v.Order.Payment_Type__c', component.get('v.Receipt.Payment_Type__c'));
            dataOrderItems.push(oitems);

            dataOrder.push(order);

            component.set('v.data.orderitems', dataOrderItems);
            component.set('v.data.orders', dataOrder);


            helper.saveOrderNew(component, event, helper);
          //  helper.checkOnline(component, event, helper);
        }
    },
    
    validateUnsealed: function (component, event, helper) {
        component.set('v.disableUnsealButton',true);
        component.set('v.spinner',true);
            var oitems = component.get('v.orderItemList');
            var order = component.get('v.Order');
            var dataOrderItems = [];
            var dataOrder = component.get('v.data.orders');
            component.set('v.Order.Payment_Type__c', component.get('v.Receipt.Payment_Type__c'));
            dataOrderItems.push(oitems);
            
            dataOrder.push(order);
            
            component.set('v.data.orderitems', dataOrderItems);
            component.set('v.data.orders', dataOrder);
            
            helper.saveUnsealed(component, event, helper);
            //helper.checkOnline(component, event, helper);
    },
    
    // Save Order after confirmation
    saveOrderWithItem: function (component, event, helper) {
        component.set('v.disableOrder',true);
      //  alert('Sales order submitted');
        //try {
            if (helper.validateOrderList(component, event)) {
                var oitems = component.get('v.orderItemList');
                var order = component.get('v.Order');
                var dataOrderItems = component.get('v.data.orderitems');
                var dataOrder = component.get('v.data.orders');

                dataOrderItems.push(oitems);

                dataOrder.push(order);

                component.set('v.data.orderitems', dataOrderItems);
                component.set('v.data.orders', dataOrder);

                helper.saveOrderWithItems(component, event, helper);
                //helper.checkOnline(component, event, helper);
                
            }
        /*} catch (e) {
            console.log('Error msg : ' + e.message());
        }*/

    },
    
    //Confirm Order
    confirmOrderWithItem : function (component, event, helper) {
        component.set('v.confirmOrderWithItems',true);
    },
     //Confirm Invoice
    confirmInvoiceWithItem : function (component, event, helper) {
        component.set('v.showConfirmInvoiceWithItem',true);
    },

    cancel: function (component, event, helper) {
        component.set("v.orderItemList", []);
        component.set('v.GrandTotal', 0.00);
        component.set("v.Products", []);
        component.set("v.Order", {});
        component.set("v.matchproducts", []);
        component.set("v.visitsView", true);
        component.set("v.showorder", false);
        component.set("v.showOrderWithItems", false);
        component.set("v.showUnsealed", false);
        component.set("v.Receipt", {});
        component.set("v.showPayment", false);
        component.set('v.disApplied', false);
        component.set("v.selectedCheckBoxes", []);
        component.set('v.GrandTotalDisc', 0.00);
        component.set("v.showproductCardView", false);
        component.set("v.cartItems", '');
        component.set("v.cartProductIds", []);
        component.set("v.disableCart", true);
         component.set("v.mapOfProductStockMfgMap", []);
        component.set("v.stocks", []);
        component.set("v.productStockMfgMap", []);
        component.set("v.confirmOrderWithItems", false);
        component.set("v.showConfirmInvoiceWithItem",false);
    },
    
    goBack : function (component, event, helper) {
        component.set("v.confirmOrderWithItems", false);
        component.set('v.showConfirmInvoiceWithItem',false);
        component.set('v.disableOrder',false);
        component.set('v.disableInvoice',false);
    },

    Back: function (component, event, helper) {
        
        if(component.get('v.showorder')){
            component.set("v.showproductCardView", true);
            component.set("v.showorder", false);
        }
        if(component.get('v.showOrderWithItems')){
            component.set("v.showproductCardViewOrder", true);
            component.set("v.showOrderWithItems", false);
        }
        if(component.get('v.showUnsealed')){
            component.set("v.showproductCardView", true);
            component.set("v.showUnsealed", false);
        }
        
        component.set('v.disableOrder',false);
        component.set('v.disableInvoice',false);
         component.set("v.orderItemList", []);
        component.set('v.GrandTotal', 0.00);
       // component.set("v.Order", {});
        component.set("v.selectedCheckBoxes", []);
        component.set('v.GrandTotalDisc', 0.00);
         component.set("v.mapOfProductStockMfgMap", []);
        component.set("v.stocks", []);
        component.set("v.productStockMfgMap", []);
    },

	// This function is called when manufacturing date is selected. To fetch the Available qty and price of the selected stock
    getSelectedStock: function (component, event, helper) {
        let selectedStock = event.currentTarget.dataset.value;
        var index = event.currentTarget.dataset.record;
        console.log('selectedStock== ' + selectedStock);
        var products = component.get('v.orderItemList');
        var stocks = component.get('v.stocks');
        var originalStockQuantities = component.get("v.originalStockQuantities");
        var storeId = component.get('v.data.currentvisit.Account1__c');
        var cashDis = component.get('v.data.currentvisit.Account1__r.Cash_Discount__c');
        var discounts = component.get('v.discounts');
        var gst ='';
        console.log('products== ' + JSON.stringify(products));
        console.log('storeId== ' + storeId);
        
       
        
      //  console.log('products[index]=== ' + JSON.stringify(products[index]));
       // console.log('stocks=== ' + JSON.stringify(stocks));
        for(var i=0;i<stocks.length;i++){
            console.log('products[index]=== ' + JSON.stringify(products[index]));
            console.log('stocks[i]=== ' + JSON.stringify(stocks[i]));
            if(stocks[i].Id == products[index].Stock__c){
                // products[index].Stock__c = stocks[i].Id;
                products[index].MRP__c = stocks[i].Price__c;                      
                products[index].Available_Quantity__c = stocks[i].Available_Quantity__c;
                // Store original quantity if not already stored
                var stockId = stocks[i].Id;
                if (!originalStockQuantities[stockId]) {
                    originalStockQuantities[stockId] = stocks[i].Available_Quantity__c;
                    component.set("v.originalStockQuantities", originalStockQuantities);
                }
                //  component.set('v.orderItemList', products);
                console.log('products : ' + products);
                var unitPriceAfterDiscount = 0.0,productDiscount=0,productDiscountAmt=0;
                
                var dis = 0;
                if(stocks[i].Fixed_Price_Item__c){
                    dis = stocks[i].Margin__c; 
                }
                else{
                    for (var d = 0; d < discounts.length; d++) {
                        if (stocks[i].Product__r.GST__c  == discounts[d].GST_Percentage__c) {
                            /*added*/
                             if(stocks[i].Product__r.Brand__c == 'Eva Traders'){
                                 dis = discounts[d].Eva_Discount_Percent__c;
                            }else{
                            dis = discounts[d].Discount_Percent__c;
                            }
                            gst =stocks[i].Product__r.GST__c;
                            /*added*/
                        }
                    }
                }
                  dis = dis || 0;
                products[index].Fixed_Price_Item__c = stocks[i].Fixed_Price_Item__c;
                cashDis = component.get('v.data.currentvisit.Account1__r.Cash_Discount__c');
                console.log(products[index].Fixed_Price_Item__c)
                if(cashDis == null || stocks[i].Fixed_Price_Item__c){
                    cashDis = 0;
                }
                if(dis){
                    products[index].Discount_Percent__c = dis;
                }else{
                    products[index].Discount_Percent__c  = 0;
                }
                   /*added*/
                  if(gst){
                    
                     products[index].GST_Percentage__c  = gst;
                }   /*added*/
                console.log('dis:' + dis);
                console.log('cashDis:' + cashDis);
                if(stocks[i].Price__c){
                    productDiscount = products[index].Discount__c || 0;
                    unitPriceAfterDiscount = (stocks[i].Price__c - ((stocks[i].Price__c * dis) / 100));
                   productDiscountAmt =((unitPriceAfterDiscount * productDiscount) / 100);
                    products[index].Rate__c = Number(unitPriceAfterDiscount).toFixed(2);
                    unitPriceAfterDiscount = (unitPriceAfterDiscount - ((unitPriceAfterDiscount * cashDis) / 100));
         
                    unitPriceAfterDiscount = unitPriceAfterDiscount - productDiscountAmt;
                    products[index].Unit_Price__c = Number(unitPriceAfterDiscount).toFixed(2);
                    products[index].Product_Discount_Amount__c = Number(productDiscountAmt).toFixed(2); 
     
                }else{
                    products[index].Unit_Price__c = 0;
                }

                console.log('products end===' + JSON.stringify(products)); 
                console.log('products[index].Unit_Price__c== ' + products[index].Unit_Price__c); 
                   products[index].Product_Discount__c = Number(productDiscount).toFixed(2);
                
                var SalesTaxPrice = '';
                
                if(!products[index].Sales_Tax__c){
                    products[index].Sales_Tax__c = 0
                }
                
                if(products[index].Unit_Price__c && products[index].Sales_Tax__c){
                    SalesTaxPrice  = (products[index].Unit_Price__c * products[index].Sales_Tax__c) / 100;
                }else{
                    SalesTaxPrice = 0;
                }
                
                console.log('SalesTaxPrice:' + SalesTaxPrice)
                if(SalesTaxPrice){
                    products[index].Sales_Tax_Value__c = Number(SalesTaxPrice).toFixed(2);
                }else{
                    products[index].Sales_Tax_Value__c = 0;
                }
                if(products[index].Sales_Tax__c){
                    products[index].Sales_Tax_PercentValue__c = Number(SalesTaxPrice).toFixed(2) + '(' + products[index].Sales_Tax__c + '%)';
                }else{
                    products[index].Sales_Tax_PercentValue__c = 0 + '(' + 0 + ')';
                }
                
                console.log('products[index].Sales_Tax_Value__c:' + products[index].Sales_Tax_Value__c)
                component.set('v.orderItemList', products);
                console.log('products end===' + JSON.stringify(products));
            }
        }
        
     /*   var action1 = component.get("c.getSelectedStockRec");
        action1.setParams({ stockId: selectedStock })
        action1.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var stock = response.getReturnValue();
                console.log('stock === ' + stock);
                if (stock) {
                    //for(var i=0; i < products.length; i++){
                    console.log('products[index]=== ' + JSON.stringify(products[index]));
                    console.log('stock.Product__c=== ' + stock.Product__c);
                    console.log('stock.Product__c=== ' + stock.Product__c);
                    if (products[index].Id == stock.Product__c) {
                         products[index].Stock__c = stock.Id;
                                               
                        products[index].Available_Quantity__c = stock.Available_Quantity__c;
                        component.set('v.orderItemList', products);
                        console.log('products : ' + products);
                        var unitPriceAfterDiscount = '';
                        
                        var dis = 0;
                        for (var d = 0; d < discounts.length; d++) {
                            if (stock.Product__r.GST__c  == discounts[d].GST_Percentage__c) {
                                dis = discounts[d].Discount_Percent__c;
                            }
                        }
                        if(dis){
                            products[index].Discount_Percent__c = dis;
                        }else{
                            products[index].Discount_Percent__c  = 0;
                        }
                        
                        if(stock.Price__c){
                            //unitPriceAfterDiscount = (stock.Price__c - ((stock.Price__c * discount) / 100)) - products[index].Sales_Tax_Value__c;
                            unitPriceAfterDiscount = (stock.Price__c - ((stock.Price__c * dis) / 100));
                            console.log('unitPriceAfterDiscount=== ' + unitPriceAfterDiscount);
                            //alert(unitPriceAfterDiscount)
                            //unitPriceAfterDiscount = (unitPriceAfterDiscount - ((unitPriceAfterDiscount * cashDis) / 100));
                            products[index].Unit_Price__c = Number(unitPriceAfterDiscount).toFixed(2);
                            // alert(products[index].Unit_Price__c)
                            console.log('products[index].Unit_Price__c== ' + products[index].Unit_Price__c);
                        }else{
                            products[index].Unit_Price__c = 0;
                        }
                        component.set('v.orderItemList', products);
                        console.log('products end===' + JSON.stringify(products));
                        
                      /*  if(stock.Price__c){
                            console.log('unitPriceAfterDiscount=== ' + unitPriceAfterDiscount);
                            //products[index].Unit_Price__c = stock.Price__c - products[index].Sales_Tax_Value__c;
                            //products[index].Unit_Price__c = stock.Price__c;
                            products[index].Unit_Price__c = (stock.Price__c - ((stock.Price__c * cashDis) / 100));;
                        }else{
                            products[index].Unit_Price__c = 0;
                        }*/
                   /*     console.log('products[index].Unit_Price__c== ' + products[index].Unit_Price__c); 
                        
                        
                    var SalesTaxPrice = '';
                    
                    if(!products[index].Sales_Tax__c){
                        products[index].Sales_Tax__c = 0
                    }
                    
                    if(products[index].Unit_Price__c && products[index].Sales_Tax__c){
                        SalesTaxPrice  = (products[index].Unit_Price__c * products[index].Sales_Tax__c) / 100;
                    }else{
                        SalesTaxPrice = 0;
                    }
                    
                    console.log('SalesTaxPrice:' + SalesTaxPrice)
                    if(SalesTaxPrice){
                        products[index].Sales_Tax_Value__c = Number(SalesTaxPrice).toFixed(2);
                    }else{
                        products[index].Sales_Tax_Value__c = 0;
                    }
                    if(products[index].Sales_Tax__c){
                        products[index].Sales_Tax_PercentValue__c = Number(SalesTaxPrice).toFixed(2) + '(' + products[index].Sales_Tax__c + '%)';
                    }else{
                        products[index].Sales_Tax_PercentValue__c = 0 + '(' + 0 + ')';
                    }
                    console.log('products[index].Sales_Tax_Value__c:' + products[index].Sales_Tax_Value__c)
                    component.set('v.orderItemList', products);
                    console.log('products end===' + JSON.stringify(products));

                       /* var action2 = component.get("c.getDiscounts");
                        action2.setParams({ 'accId': storeId })
                        action2.setCallback(this, function (response) {
                            var martchGST = false;
                            var state = response.getState();
                            if (state == "SUCCESS") {
                                var db = response.getReturnValue();
                                var discount = 0;
                                
                                console.log('db== ' + JSON.stringify(db));
                                if(db.length > 0){
                                    console.log('Customer have discount=== ');
                                    for (var d = 0; d < db.length; d++) {
                                        if (stock.Product__r.GST__c == db[d].GST_Percentage__c) {
                                            console.log('Match product and account GST=== ');
                                            if (products[index].Id == stock.Product__c) {
                                                console.log('products s=== ' + JSON.stringify(products));
                                                discount = db[d].Discount_Percent__c;
                                                console.log('discount=== ' + discount);
                                                if(discount){
                                                    products[index].Discount_Percent__c = discount;
                                                }else{
                                                    products[index].Discount_Percent__c  = 0;
                                                }
                                                
                                                if(stock.Price__c){
                                                    //unitPriceAfterDiscount = (stock.Price__c - ((stock.Price__c * discount) / 100)) - products[index].Sales_Tax_Value__c;
                                                    unitPriceAfterDiscount = (stock.Price__c - ((stock.Price__c * discount) / 100));
                                                    console.log('unitPriceAfterDiscount=== ' + unitPriceAfterDiscount);
                                                    //alert(unitPriceAfterDiscount)
                                                    unitPriceAfterDiscount = (unitPriceAfterDiscount - ((unitPriceAfterDiscount * cashDis) / 100));
                                                    products[index].Unit_Price__c = Number(unitPriceAfterDiscount).toFixed(2);
                                                   // alert(products[index].Unit_Price__c)
                                                    console.log('products[index].Unit_Price__c== ' + products[index].Unit_Price__c);
                                                }else{
                                                    products[index].Unit_Price__c = 0;
                                                }
                                                component.set('v.orderItemList', products);
                                                console.log('products end===' + JSON.stringify(products));
                                                martchGST = true; 
                                            }
                                        }
                                        
                                    }
                                    console.log('martchGST== '+martchGST);
                                    if(martchGST == false){
                                        if(stock.Price__c){
                                            console.log('unitPriceAfterDiscount=== ' + unitPriceAfterDiscount);
                                            //products[index].Unit_Price__c = stock.Price__c - products[index].Sales_Tax_Value__c;
                                            //products[index].Unit_Price__c = stock.Price__c;
                                              products[index].Unit_Price__c = (stock.Price__c - ((stock.Price__c * cashDis) / 100));;
                                        }else{
                                            products[index].Unit_Price__c = 0;
                                        }
                                        console.log('products[index].Unit_Price__c== ' + products[index].Unit_Price__c); 
                                       
                                    }
                                }else{
                                    if(stock.Price__c){
                                        console.log('unitPriceAfterDiscount=== ' + unitPriceAfterDiscount);
                                       // products[index].Unit_Price__c = stock.Price__c - products[index].Sales_Tax_Value__c;
                                       //products[index].Unit_Price__c = stock.Price__c;
                                              products[index].Unit_Price__c = (stock.Price__c - ((stock.Price__c * cashDis) / 100));;
                                        }else{
                                        products[index].Unit_Price__c = 0;
                                        }
                                  
                                    console.log('products[index].Unit_Price__c== ' + products[index].Unit_Price__c);
                                    component.set('v.orderItemList', products);
                                    console.log('products end===' + JSON.stringify(products));
                                }
                                 var SalesTaxPrice = '';
                                    
                                    if(!products[index].Sales_Tax__c){
                                        products[index].Sales_Tax__c = 0
                                    }
                                    
                                    if(products[index].Unit_Price__c && products[index].Sales_Tax__c){
                                        SalesTaxPrice  = (products[index].Unit_Price__c * products[index].Sales_Tax__c) / 100;
                                    }else{
                                        SalesTaxPrice = 0;
                                    }
                                    
                                console.log('SalesTaxPrice:' + SalesTaxPrice)
                                    if(SalesTaxPrice){
                                        products[index].Sales_Tax_Value__c = Number(SalesTaxPrice).toFixed(2);
                                    }else{
                                        products[index].Sales_Tax_Value__c = 0;
                                    }
                                    if(products[index].Sales_Tax__c){
                                        products[index].Sales_Tax_PercentValue__c = Number(SalesTaxPrice).toFixed(2) + '(' + products[index].Sales_Tax__c + '%)';
                                    }else{
                                        products[index].Sales_Tax_PercentValue__c = 0 + '(' + 0 + ')';
                                    }
                                 console.log('products[index].Sales_Tax_Value__c:' + products[index].Sales_Tax_Value__c)
                                 component.set('v.orderItemList', products);
                                console.log('products end===' + JSON.stringify(products));
                            }
                        });
                        $A.enqueueAction(action2);*/
                        
                        
                /*    }
                    //}
                }
            }
        });
        $A.enqueueAction(action1);*/

    },
   
	//This function is called when Quantity is entered in order/invoice. Grand Total is also calculated here
    getPrices: function (component, event, helper) {
        try{
        var quantity = event.currentTarget.dataset.value;
        console.log('quantity==' + quantity);
        var index = event.currentTarget.dataset.record;
        var oitems = component.get('v.orderItemList');
        var orderItemList = oitems;

        var originalStockQuantities = component.get("v.originalStockQuantities");
        var currentItem = orderItemList[index];
        var stockId = currentItem.Stock__c;
        var enteredQty = currentItem.Quantity__c;
        var indexNum = parseInt(index, 10);
              var newOrder = false;
             var newInvoice = false;
        if (component.get('v.buttonsToCreateOrder') == 'NewOrder') {
            newOrder = true;
        } else if(component.get('v.buttonsToCreateOrder') == 'NewInvoice'){
            newOrder = false;
            newInvoice=true;
        }else if(component.get('v.buttonsToCreateOrder') == 'unsealed'){
            newOrder = false;
        }


        // Validate stock is selected and quantity is entered
        if(stockId && enteredQty && enteredQty > 0 && newInvoice) {
            var originalQty = currentItem.Available_Quantity__c;

            // Calculate total quantity used by this stock in other items
            var totalUsedQty = 0;
            for(var i = 0; i < orderItemList.length; i++) {
                if(i !== indexNum && orderItemList[i].Stock__c === stockId && orderItemList[i].Quantity__c) {
                    totalUsedQty += parseFloat(orderItemList[i].Quantity__c);
                }
            }

            // Calculate remaining quantity
            var remainingQty =0;
           remainingQty= originalQty - totalUsedQty;
            // Validate entered quantity
            if(enteredQty > remainingQty) {
                helper.showToast("Entered quantity (" + enteredQty + ") exceeds available quantity (" + remainingQty + ") for " + currentItem.Name, "error");
                currentItem.Quantity__c = null;
                component.set("v.orderItemList", orderItemList);
                return;
            }

          
        }

        // Continue with existing price calculation logic below...
        var storeId = component.get('v.data.currentvisit.Account1__c');
        var cashDis = component.get('v.data.currentvisit.Account1__r.Cash_Discount__c');
        var salesTaxPercent= 0;
        var price= 0;
        var salesTaxPrice = 0;
        var gstPercent= 0;
        component.set('v.disableOrder',false);
        component.set('v.disableInvoice',false);
        if(oitems[index].GST__c){
            gstPercent = oitems[index].GST__c;
        }
        if(oitems[index].Sales_Tax__c){
            salesTaxPercent = oitems[index].Sales_Tax__c;
        }
        console.log('oitems[index]=== '+oitems[index]);
        if(oitems[index].Unit_Price__c){
            price = oitems[index].Unit_Price__c; 
        }        
        if (quantity) {
            salesTaxPrice = oitems[index].Sales_Tax_Value__c;
            console.log('salesTaxPrice== ' + salesTaxPrice);
        }
        
      
        if(newOrder == false && quantity > oitems[index].Available_Quantity__c){
            helper.showToast("Added quantity is exceeding then available quantity for "+'"'+oitems[index].Name+'"',"error");
        }
        console.log('Available qty=== '+oitems[index].Available_Quantity__c);
        //component.set('oitems[index].Available_Quantity__c',oitems[index].Available_Quantity__c);
        
        console.log('oitems== ' + JSON.stringify(oitems));
        console.log('storeId== ' + storeId);
        console.log('salesTaxPercent== ' + salesTaxPercent);
        console.log('price== ' + price);
        var totalPriceAfterDiscount = price;
        var totalWithGST = totalPriceAfterDiscount * quantity;
        //alert(totalWithGST)
        //totalWithGST =  Number(totalWithGST).toFixed(2);
        //alert(totalWithGST)
        cashDis = component.get('v.data.currentvisit.Account1__r.Cash_Discount__c');
        if(cashDis == null  || oitems[index].Fixed_Price_Item__c){
            cashDis = 0;
        }
      //  var totalcashdis = totalWithGST - ((totalWithGST * cashDis) / 100);
        var totalcashdis =totalWithGST;
        oitems[index].Cash_Discount__c = Number(cashDis).toFixed(2);
		 oitems[index].Customer_Discount__c = Number(totalcashdis).toFixed(2);
        
        var ttl = totalcashdis + (totalcashdis * salesTaxPercent/100 );
        oitems[index].Total__c = Number(ttl).toFixed(2);
        oitems[index].Total_Before_Tax__c = Number(totalWithGST).toFixed(2);
       // alert(oitems[index].Total__c)
        //alert(oitems[index].Total_Before_Tax__c)
        
        console.log('oitems[index].Total__c=== '+oitems[index].Total__c);
        component.set('v.orderItemList', oitems);
        console.log('oitems== ' + JSON.stringify(oitems));
        
       
        console.log('cashDis== ' + cashDis);
        if (oitems[index].GST_Percentage__c == '') {
            oitems[index].GST_Percentage__c = 1;
        }
        //oitems[index].Total__c  = (((oitems[index].Unit_Price__c * oitems[index].Quantity__c)*oitems[index].GST_Percentage__c)/100)+(oitems[index].Unit_Price__c * oitems[index].Quantity__c);
        oitems[index].Total_after_discount__c = oitems[index].Total__c;
        
        var grandtotal = 0.0;
        var grandtotaldisc = 0.0;
        var initialTotal = 0.0;
        for (var i = 0; i < oitems.length; i++) {
            if (oitems[i].Total__c != '') {
                if(oitems[i].Total__c == 'undefined' || oitems[i].Total__c == null){
                    oitems[i].Total__c = 0.00;
                }
                grandtotal = grandtotal + Number(oitems[i].Total__c);
                //console.log('grandtotal = '+grandtotal);
            }else{
                grandtotal;
            }
        }
        component.set('v.InitialTotal',grandtotal);
        //console.log('pay type=== '+component.get('v.Receipt').Payment_Type__c);
       /* if (component.get('v.Receipt').Payment_Type__c == 'Immediate') {
            grandtotaldisc = component.get('v.GrandTotalDisc');
            var disApplied = component.get('v.disApplied');
            console.log('disApplied== ' + disApplied);
            
            if (cashDis != null && cashDis != "undefined") {
                grandtotaldisc = grandtotal - ((grandtotal * cashDis) / 100);
            }
            else{
                 grandtotaldisc = grandtotal;
            }
            component.set('v.disApplied', true);
        } else {
            console.log('else ==== ');
            grandtotaldisc = grandtotal;
        }*/
        grandtotaldisc = grandtotal;
        console.log('grandtotaldisc-before: '+grandtotaldisc)
        console.log('Number(grandtotaldisc).toFixed(2):' + Number(grandtotaldisc).toFixed(2))
        component.set('v.GrandTotal', Number(grandtotal).toFixed(2));
        component.set('v.GrandTotalDisc', Number(grandtotaldisc).toFixed(2));
        console.log('grandtotaldisc-after:'+component.get('v.GrandTotalDisc'))
        console.log('grandtotal = ' + grandtotal);
        }catch(e){
           console.error(e.messaage);
        }
    },
   
     getRackStock: function (component, event, helper) {
        var reckStockQuantity = event.currentTarget.dataset.value;
        console.log('reckStockQuantity== ' + reckStockQuantity);
        var index = event.currentTarget.dataset.record;
        console.log('index== ' + index);
        var oitems = component.get('v.orderItemList');
        oitems[index].Rack_Stock___c = reckStockQuantity;
        component.set('v.orderItemList', oitems);
        console.log('oitems=== ' + JSON.stringify(oitems));
    },

    searchDriver: function (component, event, helper) {

        var employees = component.get('v.data.employees');
        var searchText = component.get('v.searchDriver');

        var matchemps = [];
        if (searchText != '') {
            for (var i = 0; i < employees.length; i++) {
                if (employees[i].Name.toLowerCase().indexOf(searchText.toLowerCase()) != -1 && employees[i].Role__c == 'Driver') {
                    matchemps.push(employees[i]);
                }
            }
            if (matchemps.length > 0) {
                component.set('v.matchDrivers', matchemps);
            }
        } else {
            component.set('v.matchDrivers', []);
        }
    },
    updateDriver: function (component, event, helper) {
        if (component.get('v.data.dailyLog') == null) {
            component.set('v.data.dailyLog', { 'Driver__c': '', 'Clock_In_Location__Latitude__s': '', 'Clock_In_Location__Longitude__s': '' });
        }

        component.set('v.spinner', true);
        var index = event.currentTarget.dataset.record;
        var eid = event.currentTarget.dataset.id;
        var emps = component.get('v.matchDrivers');
        // var oitems= component.get('v.orderItemList');

        for (var i = 0; i < emps.length; i++) {
            if (emps[i].Id === eid) {
                component.set('v.searchDriver', emps[i].Name);
                component.set('v.data.dailyLog.Driver__c', emps[i].Id);
                break;
            }

        }
        component.set('v.matchDrivers', []);
        component.set('v.spinner', false);


    },

    searchSM: function (component, event, helper) {

        var employees = component.get('v.data.employees');
        var searchText = component.get('v.searchSM');

        var matchemps = [];
        if (searchText != '') {
            for (var i = 0; i < employees.length; i++) {
                if (employees[i].Name.toLowerCase().indexOf(searchText.toLowerCase()) != -1 && employees[i].Role__c == 'Salesman') {
                    matchemps.push(employees[i]);
                }
            }
            if (matchemps.length > 0) {
                component.set('v.matchSMs', matchemps);
            }
        } else {
            component.set('v.matchSMs', []);
        }
    },
    updateSM: function (component, event, helper) {
        if (component.get('v.data.dailyLog') == null) {
            component.set('v.data.dailyLog', { 'Sales_Man__c': '', 'Clock_In_Location__Latitude__s': '', 'Clock_In_Location__Longitude__s': '' });
        }

        component.set('v.spinner', true);
        var index = event.currentTarget.dataset.record;
        var eid = event.currentTarget.dataset.id;
        var emps = component.get('v.matchSMs');
        // var oitems= component.get('v.orderItemList');

        for (var i = 0; i < emps.length; i++) {
            if (emps[i].Id === eid) {
                component.set('v.searchSM', emps[i].Name);
                component.set('v.data.dailyLog.Sales_Man__c', emps[i].Id);
                break;
            }

        }
        component.set('v.matchSMs', []);
        component.set('v.spinner', false);


    },

    searchASM: function (component, event, helper) {

        var employees = component.get('v.data.employees');
        var searchText = component.get('v.searchASM');

        var matchemps = [];
        if (searchText != '') {
            for (var i = 0; i < employees.length; i++) {
                if (employees[i].Name.toLowerCase().indexOf(searchText.toLowerCase()) != -1 && employees[i].Role__c == 'Assistant Salesman') {
                    matchemps.push(employees[i]);
                }
            }
            if (matchemps.length > 0) {
                component.set('v.matchASMs', matchemps);
            }
        } else {
            component.set('v.matchASMs', []);
        }
    },
    updateASM: function (component, event, helper) {
        if (component.get('v.data.dailyLog') == null) {
            component.set('v.data.dailyLog', { 'Assistant_SalesMan__c': '', 'Clock_In_Location__Latitude__s': '', 'Clock_In_Location__Longitude__s': '' });
        }

        component.set('v.spinner', true);
        var index = event.currentTarget.dataset.record;
        var eid = event.currentTarget.dataset.id;
        var emps = component.get('v.matchASMs');
        // var oitems= component.get('v.orderItemList');

        for (var i = 0; i < emps.length; i++) {
            if (emps[i].Id === eid) {
                component.set('v.searchASM', emps[i].Name);
                component.set('v.data.dailyLog.Assistant_SalesMan__c', emps[i].Id);
                break;
            }

        }
        component.set('v.matchASMs', []);
        component.set('v.spinner', false);


    },

    searchSMgr: function (component, event, helper) {

        var employees = component.get('v.data.employees');
        var searchText = component.get('v.searchSMgr');

        var matchemps = [];
        if (searchText != '') {
            for (var i = 0; i < employees.length; i++) {
                if (employees[i].Name.toLowerCase().indexOf(searchText.toLowerCase()) != -1 && employees[i].Role__c == 'Sales Manager') {
                    matchemps.push(employees[i]);
                }
            }
            if (matchemps.length > 0) {
                component.set('v.matchSMgrs', matchemps);
            }
        } else {
            component.set('v.matchSMgrs', []);
        }
    },
    updateSMgr: function (component, event, helper) {
        if (component.get('v.data.dailyLog') == null) {
            component.set('v.data.dailyLog', { 'Sales_Manager__c': '', 'Clock_In_Location__Latitude__s': '', 'Clock_In_Location__Longitude__s': '' });
        }

        component.set('v.spinner', true);
        var index = event.currentTarget.dataset.record;
        var eid = event.currentTarget.dataset.id;
        var emps = component.get('v.matchSMgrs');
        // var oitems= component.get('v.orderItemList');

        for (var i = 0; i < emps.length; i++) {
            if (emps[i].Id === eid) {
                component.set('v.searchSMgr', emps[i].Name);
                component.set('v.data.dailyLog.Sales_Manager__c', emps[i].Id);
                break;
            }

        }
        component.set('v.matchSMgrs', []);
        component.set('v.spinner', false);


    },

    onSelectPay: function (component, event, helper) {
        var rec = component.get('v.Receipt');
        var recDate = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        var storeId = component.get('v.data.currentvisit.Account1__c');
        var cashDis = component.get('v.data.currentvisit.Account1__r.Cash_Discount__c');
        var grandtotaldisc = component.get('v.GrandTotalDisc');
        var initialTotal = component.get('v.InitialTotal');
        console.log('grandtotaldisc' + grandtotaldisc);
        var disApplied = component.get('v.disApplied');
        console.log('disApplied' + disApplied);

        component.set('v.Receipt.Customer__c', storeId);
        component.set('v.Receipt.Daily_Log__c', component.get('v.data.dailyLog.Id'));
        component.set('v.Receipt.Receipt_Date__c', recDate);
        component.set('v.Receipt.Trip__c', component.get('v.data.dailyLog.Trip__c'));
        var grandtotal = component.get('v.GrandTotal');

        var oitems = component.get('v.orderItemList');

        if (rec.Payment_Type__c == 'Immediate') {

            component.set('v.showPayment', true);

            console.log('grandtotaldisc before=== ' + grandtotaldisc);
            /*if (grandtotaldisc != 0 && disApplied == false) {
                if (cashDis != null && cashDis != "undefined") {
                    grandtotaldisc = initialTotal - ((initialTotal * cashDis) / 100);
                    console.log('grandtotaldisc === ' + grandtotaldisc);
                }
                component.set('v.disApplied', true);
                console.log('grandtotaldisc type== '+ typeof grandtotaldisc);
                component.set('v.GrandTotalDisc', Number(grandtotaldisc).toFixed(2));
            }*/
        }else {
        //    component.set('v.disApplied', false);
            component.set('v.showPayment', false);
            
           // component.set('v.GrandTotalDisc', Number(initialTotal).toFixed(2));
        }
        component.set('v.disableOrder',false);
        component.set('v.disableInvoice',false);
    },
    onSelectPayMode: function (component, event, helper) {
        var rec = component.get('v.Receipt');
        rec.Bank_Name__c = '';
        rec.Cheque_Trasaction_Number__c = '';
        rec.Cheque_Date__c = '';

        component.set('v.Receipt', rec);
        component.set('v.disableOrder',false);
        component.set('v.disableInvoice',false);
    },
	// When clicked on New Returns Button
    returnClick : function (component, event, helper) {
       
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:newReturnsCmp",
            componentAttributes: {
                customerId: component.get('v.data.currentvisit.Account1__c')
            }
        });
        evt.fire();
    },
    // When clicked on Item Replacement Button
    replacementClick : function (component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ItemReplacementCmp",
            componentAttributes: {
                customerId: component.get('v.data.currentvisit.Account1__c')
            }
        });
        evt.fire();
    },
    
    createComplaint: function (component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Ticket__c"

        });
        createRecordEvent.fire();
    },
    createCompetition: function (component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Competition__c"

        });
        createRecordEvent.fire();
    },
    // When clicked on New Receipt Button
    createPayment: function (component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Receipt__c"

        });
        createRecordEvent.fire();
    },
    createStoreStock: function (component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Stock__c"

        });
        createRecordEvent.fire();
    }, 
    
    Close : function (component, event, helper) {
        component.set('v.showImageUpload',false);
        component.set("v.visitsView",true);
    },
      refresh : function(component, event, helper)
    {
        $A.enqueueAction(component.get('c.doInit'));
        $A.get("e.force:refreshView").fire();
    }
    
    
})