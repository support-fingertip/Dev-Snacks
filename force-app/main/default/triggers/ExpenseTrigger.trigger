trigger ExpenseTrigger on Expense__c (before insert,before update,after insert,after update) {
    
    if(Label.Enable_Expense_Trigger == 'TRUE'){
        
        
        User currentUser = [SELECT Id, Company_Name__c,Route_Id__c,Branch_Id__c FROM User WHERE Id = :UserInfo.getUserId()];
        // String useRrouteId = [select Id,Route_Id__c from User where Id =: UserInfo.getUserId() Limit 1][0].Route_Id__c;
        List<DailyLog__c> log = [SELECT id,Clock_In__c,Trip__r.Id,Clock_Out__c from DailyLog__c WHERE Clock_In__c = TODAY AND Clock_In__c!=null AND Clock_out__c = null AND OwnerId =: UserInfo.getUserId() limit 1];
       // system.debug('Apex Daily log - '+log);
        List<Trip__c> trp = [SELECT id,Route__c,Cash_In_Hand__c,Last_Cleared_Date__c from  Trip__c  WHERE   (Status__c = 'Started' AND End_Date__c = null )  AND OwnerId =:UserInfo.getUserId() limit 1];
        List<Route__c> route = [select Id,Route_Id__c,Branch_Name__r.Id,Warehouse__r.Id,Vehicle__r.Id,Cash_In_Hand__c,Last_Cleared_Date__c from Route__c where Route_Id__c =: currentUser.Route_Id__c Limit 1];
        List<Branch__c> branch = [select Id,Cash_In_Hand__c from Branch__c where Branch_Id__c = :currentUser.Branch_Id__c];
        
        if(trigger.isBefore && trigger.isInsert){
            
            for(Expense__c expenseRecord : Trigger.new){
                 expenseRecord.CompanyId__c = currentUser.Company_Name__c;
                if(log.size() > 0){
                    expenseRecord.Daily_Log__c = log[0].Id;
                }
                if(trp.size() > 0){
                    expenseRecord.Trip__c = trp[0].Id;
                }
                if(route.size() > 0){
                    expenseRecord.Route__c = route[0].Id;
                    expenseRecord.Branch__c = route[0].Branch_Name__r.Id;
                    expenseRecord.Warehouse__c = route[0].Warehouse__r.Id;
                    expenseRecord.Vehicle__c = route[0].Vehicle__r.Id;
                }
                else if(branch.size() > 0){
                    expenseRecord.Branch__c = branch[0].Id;
                }
            }
        }
        
        
        /*To send data to SAP*/
        if(trigger.isUpdate || Trigger.isAfter){
            list<Id> listExpenseId =new List<Id>();
            for(Expense__c exp : trigger.new){    
                if(exp.Approval_Status__c =='Approved' && trigger.oldMap.get(exp.Id).Approval_Status__c != exp.Approval_Status__c){
                    listExpenseId.add(exp.Id);    
                }
            }
            if(listExpenseId.size() > 0){
                SAPsend_TriggerHandler.sendToSap(listExpenseId,'Expense__c');
                
            }
            
        } 
        
        
        if(Trigger.isupdate && trigger.isBefore){
            
             Map<Id,Route__c> rtMap = new Map<Id,Route__c>();
            Map<Id,Trip__c> trpMap = new Map<Id,Trip__c>();
            Map<Id,Branch__c> brMap = new Map<Id,Branch__c>();
            
            Set<Id> rtIds = new Set<Id>();
            Set<Id> trpIds = new Set<Id>();
            Set<Id> brIds = new Set<Id>();
            
            for(Expense__c exp : Trigger.new){
                if(exp.Route__c != null){
                    rtIds.add(exp.Route__c);
                }
                else if(exp.Branch__c != null){
                    brIds.add(exp.Branch__c);
                }
                if(exp.Trip__c != null){
                    trpIds.add(exp.Trip__c);
                }
            }
            
            List<Route__c> rtlist = [select Id,Name,Cash_In_Hand__c from Route__c where Id IN:rtIds];
            for(Route__c rt: rtlist){
                rtMap.put(rt.Id,rt);
            }
            List<Branch__c> brlist = [select Id,Name,Cash_In_Hand__c from Branch__c where Id IN:brIds];
            for(Branch__c br: brlist){
                brMap.put(br.Id,br);
            }
            List<Trip__c> trplist = [select Id,Name,Cash_In_Hand__c from Trip__c where Id IN:trpIds];
            for(Trip__c tr: trplist){
               trpMap.put(tr.Id,tr);
            }
            
            for(Expense__c exp : Trigger.new){
                //@Mayuri - Updating the Cash in hand in Route/Branch, Trip  when Expense record is approved
                if(exp.Approval_Status__c == 'Approved' && exp.ApprovalChek__c == false){
                    
                    if(trpMap.size() > 0 && trpMap.get(exp.Trip__c).Cash_In_Hand__c != null){
                        trpMap.get(exp.Trip__c).Cash_In_Hand__c = trpMap.get(exp.Trip__c).Cash_In_Hand__c - exp.Total_Amount__c;
                    }
                     if(rtMap.size() > 0 && rtMap.get(exp.Route__c).Cash_In_Hand__c != null){
                        rtMap.get(exp.Route__c).Cash_In_Hand__c = rtMap.get(exp.Route__c).Cash_In_Hand__c - exp.Total_Amount__c;
                    }
                    else if(brMap.size() > 0 && brMap.get(exp.Branch__c).Cash_In_Hand__c != null){
                        brMap.get(exp.Branch__c).Cash_In_Hand__c  = brMap.get(exp.Branch__c).Cash_In_Hand__c  - exp.Total_Amount__c;
                    }
                    
                    
                   /* if(trp.size() > 0 && trp[0].Cash_In_Hand__c != null){
                        trp[0].Cash_In_Hand__c = trp[0].Cash_In_Hand__c - exp.Total_Amount__c;
                    }
                    if(route.size() > 0 && route[0].Cash_In_Hand__c != null){
                        route[0].Cash_In_Hand__c = route[0].Cash_In_Hand__c - exp.Total_Amount__c;
                    }
                    else if(branch.size() > 0 && branch[0].Cash_In_Hand__c != null){
                        branch[0].Cash_In_Hand__c = branch[0].Cash_In_Hand__c - exp.Total_Amount__c;
                    }*/
                    
                    CustomNotificationType notificationType = [SELECT Id, DeveloperName
                                                               FROM CustomNotificationType
                                                               WHERE DeveloperName='Expense_Approval_Notification'];
                    
                    Messaging.CustomNotification notification = new Messaging.CustomNotification();
                    
                    notification.setTitle('Expense Approved');
                    notification.setBody(exp.Expense_Date__c+' Expense is Approved');
                    
                    notification.setNotificationTypeId(notificationType.Id);
                    notification.setTargetId(exp.Id);
                    
                    Set<String> addressee = new Set<String>();
                    addressee.add(exp.OwnerId);
                    
                    try {
                        notification.send(addressee);
                    }
                    catch (Exception e) {
                        System.debug('Problem sending notification: ' + e.getMessage());
                         ExceptionHandler.addLog(e,String.valueOf(exp)  ); 
                    }
                    exp.ApprovalChek__c = true;
                    //expLIst.add(exp);
                }else if(exp.Approval_Status__c == 'Rejected' && exp.RejectCheck__c == false){
                    CustomNotificationType notificationType = [SELECT Id, DeveloperName
                                                               FROM CustomNotificationType
                                                               WHERE DeveloperName='Expense_Approval_Notification'];
                    
                    Messaging.CustomNotification notification = new Messaging.CustomNotification();
                    
                    notification.setTitle('Expense Rejected');
                    notification.setBody(exp.Expense_Date__c+' Expense is Rejected');
                    notification.setNotificationTypeId(notificationType.Id);
                    notification.setTargetId(exp.Id);
                    Set<String> addressee = new Set<String>();
                    addressee.add(exp.OwnerId);
                    
                    try {
                        notification.send(addressee);
                    }
                    catch (Exception e) {
                        System.debug('Problem sending notification: ' + e.getMessage());
                         ExceptionHandler.addLog(e,String.valueOf(exp)  ); 
                    }
                    exp.RejectCheck__c = true;
                }
                
            }
            
            try{
               // update route;
               // update trp;
                if(rtMap.size()>0){
                    update rtMap.values();
                }
                if(brMap.size() > 0){
                    update brMap.values();
                }
                if(trpMap.size()>0){
                    update trpMap.values();
                }
            }
            catch(DmlException ex){
                system.debug('ex:' + ex.getMessage());
                 ExceptionHandler.addLog(ex,String.valueOf(rtMap) + '----' + String.valueOf(brMap) + '----' + String.valueOf(trpMap)   ); 
            }
            
        }else{
            /*for(Expense__c exp : Trigger.new){
CustomNotificationType notificationType = [SELECT Id, DeveloperName
FROM CustomNotificationType
WHERE DeveloperName='Expense_Approval_Notification'];

Messaging.CustomNotification notification = new Messaging.CustomNotification();

notification.setTitle('Upload Bills');
notification.setBody('Please Upload bills before submitting Approval ');

notification.setNotificationTypeId(notificationType.Id);
notification.setTargetId(exp.Id);

Set<String> addressee = new Set<String>();
addressee.add(exp.OwnerId);

try {
notification.send(addressee);
}
catch (Exception e) {
System.debug('Problem sending notification: ' + e.getMessage());
}

}*/
            
        }
    }
}