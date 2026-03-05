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
        }else{
            component.set("v.ShowDate",true);
        }
    },
    ShowPdf : function(component, event, helper) {
        var LedgerOf=component.get('v.LedgerOf');
        var rc=component.get('v.recordId');
        if(LedgerOf !='Custom'){
            var action=component.get("c.GetStock");
            action.setParams({'recId': rc ,
                              'LedgerOf':LedgerOf
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
                var action=component.get("c.GetCustomStock");
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
    searchText : function(component, event, helper) {
        var accounts= component.get('v.data.accounts');
        var searchText= component.get('v.searchText');
        var matchaccounts=[];
        if(searchText !=''){
            for(var i=0;i<accounts.length; i++){ 
                if(accounts[i].Name.toLowerCase().indexOf(searchText.toLowerCase())  != -1  ){
                    
                    if(matchaccounts.length <50){
                        matchaccounts.push( accounts[i] );
                    }else{
                        break;
                    }
                    
                } 
            } 
            if(matchaccounts.length >0){
                component.set('v.matchaccounts',matchaccounts);
            }
        }else{
            component.set('v.matchaccounts',[]);
        }
    },
    update: function(component, event, helper) {
        
        component.set('v.SelectedId', event.currentTarget.dataset.id);
        var edi = component.get('v.SelectedId');
        var accounts= component.get('v.matchaccounts');
        for(var i=0;i<accounts.length; i++){ 
            if(accounts[i].Id ===  edi ){
                component.set('v.searchText', accounts[i].Name);
               // component.set('v.visit.AccountName__c', accounts[i].Name);
               // component.set('v.approvalStatus', accounts[i].Approval_Status__c )
                break;
            } 
        } 
        
        component.set('v.matchaccounts',[]);
        
    },
    
})