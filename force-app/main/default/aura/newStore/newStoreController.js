({
    doInit: function (component, event, helper) {
        
        component.set('v.account', {
            'Name': '', 'Phone': '', 'Approval_Status__c': '', 'Email__c': '', 'Contact_Person__c': '', 'Rating': '',
            'Alternate_Mobile__c': '', 'Warehouse__c': '', 'Routes__c': '', 'Street_Name__c': '', 'Region__c': '',
            'Store_Category__c': '', 'Grade__c': '', 'State__c': '', 'GST__c': '', 'GST_applicable__c': false, 'District__c': '', 'Panchayath__c': '',
            'City__c': '', 'Pin_code__c': '', 'Description': '', 'Pan_Number__c': '', 'Credit_Limit__c': '', 'Credit_period__c': '','CustomerType__c': '',
            'GST_Type__c': '', 'Opening_Balance__c': '', 'UPI_ID__c': '', 'Vehicle__c': '', 'Parent_Customer__c': '', 'CardType__c': 'C', 'CustomerGroupCode__c': '100', 'CompanyId__c' : '','CustomerType__c':'1'
            
        });
        //component.set('v.account.GST_applicable__c')
        //var recordTypeId = component.get("v.pageReference").state.recordTypeId;
        //console.log('recordTypeId=== ' + recordTypeId);
        //component.set("v.selectedRecordTypeId", recordTypeId);
        //helper.getRouteId(component, event, helper);	
        helper.getWarehouses(component, event, helper);
        helper.fetchStatePicklist(component, event, helper);
        helper.fecthParentAccount(component, event, helper);
        helper.fecthCompany(component, event, helper);
        helper.fecthCustomerType(component, event, helper);
          helper.fetchStatePicklist1(component, event, helper);
        /*if(component.get('v.fromMyVisit') == true){
            helper.getRecordTypes(component, event, helper);
        }*/
    },
    closeExpense: function (component, event, helper) {
        if (component.get('v.fromMyVisit') == true) {
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef: "c:MobileVisit",
                componentAttributes: {
                    fromMyVisit: true
                }
            });

            evt.fire();
        } else {
            var navEvent = $A.get("e.force:navigateToList");
            navEvent.setParams({
                "listViewId": component.get('v.listId'),
                "listViewName": null,
                "scope": "Account"
            });
            navEvent.fire();
        }
    },

    gotoRecord: function (component, event, helper) {
        if (component.get('v.fromMyVisit') == true) {
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef: "c:MobileVisit",
                componentAttributes: {
                    fromMyVisit: true
                }
            });
            evt.fire();
        } else{
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": component.get('v.account.Id'),
                "slideDevName": "detail"
            });
            navEvt.fire();
        }
    },

    getdisricts: function (component, event, helper) {
        helper.districtPickList(component, event, helper);
    },
    doUpdate: function (component, event, helper) {
        component.set('v.isUpdate', true);
        var action = component.get('c.dosave');
        $A.enqueueAction(action);
    },
    dosave: function (component, event, helper) {
        let isAllValid = component.find('field1').reduce(function (isValidSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return isValidSoFar && inputCmp.checkValidity();
        }, true);

        if (isAllValid == true) {
            //alert('valid');
            var isUpdate = component.get("v.isUpdate");
            var gstNumber = component.get("v.account.GST__c");
            var PanNumber = component.get("v.account.Pan_Number__c");
            var parentAccId = component.get("v.account.Parent_Customer__c");
            var mobileNumber = component.get("v.account.Phone");
            var email = component.get("v.account.Email__c");
            var parentAccObj = {};
            var checked = component.get("v.isChecked");
            component.set('v.spinner', true);
            //console.log('parentAccId===' + parentAccId);
            //console.log('Pan number from gst=== ' + gstNumber.substring(2, 12));
            if(checked && !PanNumber){
                helper.showToast("PAN Number is required when GST applicable is checked.", "error");
                component.set('v.spinner', false);
            } 
            else {
                var action = component.get("c.checkDuplicateAccountEmail");
                action.setParams({
                    email: email
                });
                action.setCallback(this, function (response) {
                    if (response.getState() == "SUCCESS") {
                        var validationMessage = response.getReturnValue();
                        if (validationMessage == 'Entered email adderess is already exist.' && email && !isUpdate) {
                            helper.showToast('Entered email adderess already exist.', 'Error');
                            component.set('v.spinner', false);
                        } else {
                            var gstApplicable = component.get('v.account.GST_applicable__c');
                            if(!gstApplicable){
                                //check for duplicate number
                                var action = component.get("c.getDuplicateAccount");
                                action.setParams({
                                    mobileNumber: mobileNumber,
                                });
                                action.setCallback(this, function (response) {
                                    if (response.getState() == "SUCCESS") {
                                        var duplicateRecord = response.getReturnValue();
                                        console.log('duplicateRecord=== '+JSON.stringify(duplicateRecord));
                                        if (duplicateRecord && !isUpdate) {
                                            console.log('Got duplicate value=== ');
                                            var DuplicateAccountNames = [];
                                            for (var i = 0; i < duplicateRecord.length; i++) {
                                                DuplicateAccountNames.push(duplicateRecord[i].Name);
                                            }
                                            component.set("v.account.Parent_Customer__c", duplicateRecord[0].Id);
                                            helper.showToast('Entered customer recored has duplicate Phone Number. Check Account : ' + '"' + DuplicateAccountNames + '".', 'Error');
                                        }else{
                                            helper.createStore(component, event, helper);
                                        }
                                    } else if (response.getState() === "ERROR") {
                                        var errors = response.getError();
                                        if (errors) {
                                            if (errors[0] && errors[0].message) {
                                                helper.showToast('Error message: ' + '"' + errors[0].message + '".', 'error');
                                            }
                                        }
                                    }
                                });
                                $A.enqueueAction(action);
                                component.set('v.spinner', false);
                            }else{
                                console.log('create customer===')
                                helper.createStore(component, event, helper);
                                component.set('v.spinner', false);
                            }
                            /*if(gstNumber != '' && gstNumber != null){
                                if (parentAccId == '' || parentAccId == null) {
                                //alert('Do not have parent account ==== ');
                                var action = component.get("c.getDuplicateAccount");
                                action.setParams({
                                    gstNumber: gstNumber,
                                    mobileNumber: mobileNumber,
                                    email: email
                                });
                                action.setCallback(this, function (response) {
                                    if (response.getState() == "SUCCESS") {
                                        var duplicateRecord = response.getReturnValue();
                                        console.log('duplicateRecord=== '+JSON.stringify(duplicateRecord));
                                        if (duplicateRecord) {
                                            console.log('Got duplicate value=== ');
                                            var DuplicateAccountNames = [];
                                            for (var i = 0; i < duplicateRecord.length; i++) {
                                                DuplicateAccountNames.push(duplicateRecord[i].Name);
                                            }
                                            component.set("v.account.Parent_Customer__c", duplicateRecord[0].Id);
                                            //helper.showToast('Entered customer recored has duplicate GST number, Phone Number or Email. Check Account : ' + '"' + DuplicateAccountNames + '".', 'warning');
                                            helper.showToast('Entered customer recored has duplicate Phone Number. Check Account : ' + '"' + DuplicateAccountNames + '".', 'warning');
                                            helper.createStore(component, event, helper);
                                        }else{
                                            var action1 = component.get("c.getNotApprovedDuplicateAccount");
                                            action1.setParams({
                                                gstNumber: gstNumber,
                                                mobileNumber: mobileNumber,
                                            });
                                            action1.setCallback(this, function (response) {
                                                if (response.getState() == "SUCCESS") {
                                                    var notApprovedDuplicateRecord = response.getReturnValue();
                                                    console.log('notApprovedDuplicateRecord=== '+JSON.stringify(notApprovedDuplicateRecord));
                                                    if (notApprovedDuplicateRecord) {
                                                        console.log('Got not approved duplicate value=== ');
                                                        var DuplicateAccountNames = [];
                                                        for (var i = 0; i < notApprovedDuplicateRecord.length; i++) {
                                                            DuplicateAccountNames.push(notApprovedDuplicateRecord[i].Name);
                                                        }
                                                        console.log('Got not approved duplicate value=== ');
                                                        helper.showToast(' Duplicate parent customer is not approved. Check Account : ' + '"' + DuplicateAccountNames + '".','Error');
                                                    }else{
                                                       helper.createStore(component, event, helper); 
                                                    }
                                                } else if (response.getState() === "ERROR") {
                                                    var errors = response.getError();
                                                    if (errors) {
                                                        if (errors[0] && errors[0].message) {
                                                            helper.showToast('Error message: ' + '"' + errors[0].message + '".', 'error');
                                                        }
                                                    }
                                                }
                                            });
                                            $A.enqueueAction(action1);
                                        }
                                    } else if (response.getState() === "ERROR") {
                                        var errors = response.getError();
                                        if (errors) {
                                            if (errors[0] && errors[0].message) {
                                                helper.showToast('Error message: ' + '"' + errors[0].message + '".', 'error');
                                            }
                                        }
                                    }
                                });
                                $A.enqueueAction(action);
                                component.set('v.spinner', false);
                            } 
                            else {
                                //alert('Have parent account ==== ');
                                var action = component.get("c.getParentAccount");
                                action.setParams({
                                    parentAccountId: parentAccId
                                });
                                action.setCallback(this, function (response) {
                                    if (response.getState() == "SUCCESS") {
                                        parentAccObj = response.getReturnValue();
                                        console.log('parentAccObj=== ' + JSON.stringify(parentAccObj));
                                        if (parentAccObj) {
                                            console.log('got parent object=== ');
                                            var parentAccountMobile = parentAccObj.Phone;
                                            var parentAccountStatus = parentAccObj.Approval_Status__c;
                                            console.log('Parent account Mobile=== ' + parentAccountMobile);
                                            console.log('Parent account Status=== ' + parentAccountStatus);
                                            console.log('Mobile=== ' + mobileNumber);
                                            if ( parentAccountMobile != mobileNumber || parentAccountStatus != "Approved") {
                                                console.log('Duplicate== ');
                                                helper.showToast('Selected parent customer record is not correct or not approved.', 'error');
                                            } else {
                                                helper.createStore(component, event, helper);
                                            }
                                        }
                                    } else if (response.getState() === "ERROR") {
                                        var errors = response.getError();
                                        if (errors) {
                                            if (errors[0] && errors[0].message) {
                                                helper.showToast('Error message: ' + '"' + errors[0].message + '".', 'error');
                                            }
                                        }
                                    }
                                });
                                $A.enqueueAction(action);
                                component.set('v.spinner', false);
                            }
                            }
                            else{
                                helper.createStore(component, event, helper); 
                            }*/
                        }
                    } else if (response.getState() === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                alert('Error message: ' + '"' + errors[0].message + '".');
                            }
                        }
                    }
                });
                $A.enqueueAction(action);

            }
            /*if(component.get('v.account.Warehouse__c')==''){
                helper.showToast("Please select warehouse","error");
            }else if(component.get('v.account.Routes__c')==''){
                helper.showToast("Please select route","error");
            }else{
            helper.createStore(component, event, helper);                
            }*/
        }
    },
    handleCheckboxChange: function(component, event, helper) {
        var isChecked = event.getSource().get("v.checked");
        component.set("v.isChecked", isChecked);
        //alert(component.get('v.account.GST_applicable__c'));
    },
    doPrevious: function (component, event, helper) {
        component.set('v.showAccount', true);
        component.set('v.showUpdate', true);
        component.set('v.showUpload', false);
    },
    donext: function (component, event, helper) {
        component.set('v.showUpdate', false);
        component.set('v.showAccount', false);
        component.set('v.showUpload', true);
    },
    doSubmit: function (component, event, helper) {
        helper.approvalSubmit(component, event, helper);

    },
    doSearch: function (component, event, helper) {
        var whs = component.get('v.warehouse');
        var searchText = component.get('v.searchText');
        var matchwhs = [];
        if (searchText != '') {
            for (var i = 0; i < whs.length; i++) {
                if (whs[i].Name.toLowerCase().indexOf(searchText.toLowerCase()) != -1) {
                    matchwhs.push(whs[i])
                }
            }

            if (matchwhs.length > 0) {
                component.set('v.matchWarehouse', matchwhs);
            } else {
                component.set('v.matchWarehouse', []);
            }
        } else {
            component.set('v.matchWarehouse', []);
            component.set('v.routeSearchText', '');
            component.set('v.account.Routes__c', '');
            component.set('v.account.Warehouse__c', '');
        }

    },
    update: function (component, event, helper) {
        component.set('v.account.Warehouse__c', event.currentTarget.dataset.id);
        var storeId = component.get('v.account.Warehouse__c');
        var matchwhsList = component.get('v.matchWarehouse');
        for (var i = 0; i < matchwhsList.length; i++) {
            if (matchwhsList[i].Id === storeId) {
                component.set('v.searchText', matchwhsList[i].Name);
                break;
            }
        }
        component.set('v.matchWarehouse', []);
        helper.fecthRoute(component, event, helper);

    },

    accountSearch: function (component, event, helper) {
        //alert('parentAccount== '+component.get('v.parentAccount'));
        //alert('searchText== '+component.get('v.accountSearchText'));
        //alert('call accountSearch=== ');

        var parentAccounts = component.get('v.parentAccount');
        var searchText = component.get('v.accountSearchText');
        var matchrts = [];
        if (searchText != '') {
            for (var i = 0; i < parentAccounts.length; i++) {
                if (parentAccounts[i].Name.toLowerCase().indexOf(searchText.toLowerCase()) != -1) {
                    matchrts.push(parentAccounts[i]);
                }
            }
            if (matchrts.length > 0) {
                component.set('v.matchAccounts', matchrts);
                console.log('matchrts=== ' + JSON.stringify(matchrts));
            } else {
                component.set('v.matchAccounts', []);
            }
        } else {
            component.set('v.matchAccounts', []);
            component.set('v.accountSearchText', '');
            component.set('v.account.Parent_Customer__c', '');
        }
    },
    updateAccount: function (component, event, helper) {
        component.set('v.account.Parent_Customer__c', event.currentTarget.dataset.id);
        var routeId = component.get('v.account.Parent_Customer__c');
        var matchrtsList = component.get('v.matchAccounts');
        for (var i = 0; i < matchrtsList.length; i++) {
            if (matchrtsList[i].Id === routeId) {
                component.set('v.accountSearchText', matchrtsList[i].Name);
                break;
            }
        }
        component.set('v.matchAccounts', []);
    },

    doRouteSearch: function (component, event, helper) {
        var rts = component.get('v.Routes');
        var searchText = component.get('v.routeSearchText');
        var matchrts = [];
        if (searchText != '') {
            for (var i = 0; i < rts.length; i++) {
                if (rts[i].Name.toLowerCase().indexOf(searchText.toLowerCase()) != -1) {
                    matchrts.push(rts[i]);
                }
            }
            if (matchrts.length > 0) {
                component.set('v.matchRoutes', matchrts);

            } else {
                component.set('v.matchRoutes', []);
            }
        } else {
            component.set('v.matchRoutes', []);
            component.set('v.routeSearchText', '');
            component.set('v.account.Routes__c', '');
        }

    },
    updateRoute: function (component, event, helper) {
        component.set('v.account.Routes__c', event.currentTarget.dataset.id);
        var routeId = component.get('v.account.Routes__c');
        var matchrtsList = component.get('v.matchRoutes');
        for (var i = 0; i < matchrtsList.length; i++) {
            if (matchrtsList[i].Id === routeId) {
                component.set('v.routeSearchText', matchrtsList[i].Name);
                break;
            }
        }
        component.set('v.matchRoutes', []);
    },
    reloadComponent: function (component, event, helper) {
        var loc = event.getParam("token");
        $A.get('e.force:refreshView').fire();
    }
})