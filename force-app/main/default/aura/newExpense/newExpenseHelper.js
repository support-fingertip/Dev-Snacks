({
    getdates : function(component,event,helper) {
        var action=component.get("c.getDates");
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
                var databox = response.getReturnValue()
                if(component.get('v.yesterdayExp') ==true){
                    component.set('v.Expense.Expense_Date__c',databox.yersterdaydate);
                }else{
                    component.set('v.Expense.Expense_Date__c',databox.Todaydate);
                }
                
                component.set('v.mindate',databox.twodaydate);
                component.set('v.listId',databox.listId);
                component.set('v.inprogress',databox.inprogressCount);
               component.set('v.planned',databox.plannedCount);
             /*  if(databox.inprogressCount >0 || databox.plannedCount >0){
                     var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
        mode: 'dismissible',
        message: 'Please work on Inprogress and Planned visits!',
        type:'error',
        duration : 10000,
        messageTemplate: 'Please work on Inprogress and Planned visits! See it {1}!',
        messageTemplateData: ['My visits', {
            url: 'https://seraphinedevimpexpvtltd2--sbox1.sandbox.lightning.force.com/lightning/n/My_Visits',
            label: 'here',
            },
        ]
    });
    toastEvent.fire();
                    
                }*/
       
            }
        });
        $A.enqueueAction(action);		
    },
     createExpense : function(component,event,helper) {
             //https://brahminsgroup--sbox1.lightning.force.com/lightning/n/My_Visits
             //                
         /*    if(component.get('v.inprogress') >0 || component.get('v.planned') >0){
                     var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
        mode: 'dismissible',
        message: 'Please work on Inprogress and Planned visits!',
        type:'error',
        duration : 10000,
        messageTemplate: 'Please work on Inprogress and Planned visits! See it {1}!',
        messageTemplateData: ['My visits', {
            url: 'https://seraphinedevimpexpvtltd2--sbox1.sandbox.lightning.force.com/lightning/n/My_Visits',
            label: 'here',
            }
        ]
    });
    toastEvent.fire();
                    
                }else{*/
                    //alert('1');
                     var action=component.get("c.insertExpense");
          action.setParams({
                'expense' :component.get('v.Expense')
            });
        action.setCallback(this,function(response){
            alert(response.getState());
            if(response.getState() == "SUCCESS"){
                var expid = response.getReturnValue();
                component.set('v.Expense',expid);
                 component.set('v.currentsetp',"2");
                 if( component.get('v.showUpdate')!=true){
                     component.set('v.showexpense',false);
                    helper.showToast("Expense Created Successfully \n Please upload bills","Success");
                }
                if( component.get('v.showUpdate')==true){
                    component.set('v.showUpdate',false);
                     component.set('v.showexpense',false);
                    helper.showToast("Expense Updated Successfully \n Please upload bills","Success");
                }
                
                 component.set('v.showUpload',true);
            }
        });
        $A.enqueueAction(action);		
              //  }
        
    },
    approvalSubmit: function(component,event,helper) {
        var action=component.get("c.submitapproval");
          action.setParams({
                'expId' :component.get('v.Expense.Id')
            });
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
               helper.showToast("Expense Submited for Approval","Success");
                var navEvt = $A.get("e.force:navigateToSObject");
   			 navEvt.setParams({
      		"recordId": component.get('v.Expense.Id'),
      		"slideDevName": "detail"
    });
    navEvt.fire();
            }
        });
        $A.enqueueAction(action);		
    },
     showToast : function(message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type":type,
            "message":  message
        });
        toastEvent.fire();
    },
    getAccount: function(component,event,helper) {
        	var userId = $A.get("$SObjectType.CurrentUser.Id");
             var action=component.get("c.getExpenseAccount");
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
    component.set('v.account',response.getReturnValue());
            }
        });
        $A.enqueueAction(action);	   
    },
})