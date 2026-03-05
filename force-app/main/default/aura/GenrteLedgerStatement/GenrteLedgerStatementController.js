({
    doInit : function(component, event, helper) {
        // 
        var rc=component.get('v.recordId');
        //alert(rc);
    },
    send: function(component,event,helper){
        var action = component.get("c.sendEmailtoCustomer");
        action.setParams({"recId":component.get("v.recordId")});
        action.setCallback(this,function(response){
            if(response.getState() == 'SUCCESS' ) {
                var res_string= response.getReturnValue();
                event.stopPropagation();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                var type;
                if(res_string == 'Receipt sent to customer'){
                    type = 'success';
                }else{
                    type = 'error';
                }
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type":type,
                    "title": type,
                    "message":res_string,
                    "duration":10000
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            }
            else
            {
                (state === 'ERROR')
                {
                    console.log('failed');
                }
            }
        });
        $A.enqueueAction(action);
    },
    close : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    onPicklistChange : function(component, event, helper) {
        var LedgerOf=component.get('v.LedgerOf');
        if(LedgerOf =='Custom'){
            component.set("v.ShowDate",false);
        }
        else if(LedgerOf =='Today'){
            var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
            component.set("v.FromDate",today);
            component.set("v.ToDate",today);
            
        }
        else if(LedgerOf =='This Week'){
            var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
            var endDate = new Date(today);
            endDate.setDate(endDate.getDate() - 7);
            var End = endDate.toISOString().split('T')[0];
            component.set("v.FromDate",End);
            component.set("v.ToDate",today);
            
        }
        else if(LedgerOf =='This Month'){
            var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
            var endDate = new Date(today);
            endDate.setDate(endDate.getDate() - 30);
            var End = endDate.toISOString().split('T')[0];
            component.set("v.FromDate",End);
            component.set("v.ToDate",today);
            
        }
        else if(LedgerOf =='Last 3 Month'){
            var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
            var endDate = new Date(today);
            endDate.setDate(endDate.getDate() - 90);
            var End = endDate.toISOString().split('T')[0];
            component.set("v.FromDate",End);
            component.set("v.ToDate",today);
            
        }
        else if(LedgerOf =='Last 6 Month'){
            var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
           var endDate = new Date(today);
            endDate.setDate(endDate.getDate() - 180);
            var End = endDate.toISOString().split('T')[0];
            component.set("v.FromDate",End);
            component.set("v.ToDate",today);
            
        }
        else if(LedgerOf =='This Year'){
            var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
            var endDate = new Date(today);
            endDate.setDate(endDate.getDate() - 365);
            var End = endDate.toISOString().split('T')[0];
            component.set("v.FromDate",End);
            component.set("v.ToDate",today);
            
        }
        else{
            component.set("v.ShowDate",true);
        }
    },
    ShowPdf : function(component, event, helper) {
        var LedgerOf=component.get('v.LedgerOf');
        var rc=component.get('v.recordId');
        var fd=component.get('v.FromDate');
        var td=component.get('v.ToDate');
        if(LedgerOf !='Custom'){
            var action=component.get("c.GetCustomLedger");
            action.setParams({'recId': rc ,
                              'd1':fd,
                              'd2':td
                             })
            action.setCallback(this,function(response){
                var state = response.getState();
                if(state == "SUCCESS" ){ 
                    var db = response.getReturnValue();
                    if(db=='pass'){
                        component.set("v.SelectDate",false);
                        component.set("v.Openpdf",true);
                    }
                }
            });
            $A.enqueueAction(action);
            
        }
        else{
            var fd=component.get('v.FromDate');
            var td=component.get('v.ToDate');
            if(fd==null || td ==null){
                if(fd==null){
                    helper.showToast("Please Select From Date.","Warning");
                }
                if(td==null){
                    helper.showToast("Please Select To Date.","Warning");
                }
            }
            else{
                var action=component.get("c.GetCustomLedger");
                action.setParams({'recId': rc ,
                                  'd1':fd,
                                  'd2':td
                                 })
                action.setCallback(this,function(response){
                    var state = response.getState();
                    if(state == "SUCCESS" ){ 
                        var db = response.getReturnValue();
                        if(db=='pass'){
                            component.set("v.SelectDate",false);
                            component.set("v.Openpdf",true);
                        }
                    }
                });
                $A.enqueueAction(action);
                
            }
        }
    },
})