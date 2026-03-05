trigger AccountTrigger on Account (before insert,before update,after update) {
    
    if(Label.Enable_Customer_Trigger == 'TRUE'){
        
        if (trigger.isInsert && Trigger.isBefore){
            String useRrouteId = [select Id,Route_Id__c from User where Id =: UserInfo.getUserId() Limit 1][0].Route_Id__c;
            if(useRrouteId != null && useRrouteId != ''){
                List<Route__c> routes = [select Id,Route_Id__c,Branch_Name__r.Id,Warehouse__r.Id,Vehicle__r.Id from Route__c where Route_Id__c =: useRrouteId Limit 1];
                if (!routes.isEmpty()) {
                    Route__c route = routes[0];
                    for(Account account : trigger.new){
                        if(route != null){
                            account.Routes__c = route.Id;
                            account.Vehicle__c = route.Vehicle__r.Id;
                            account.Warehouse__c = route.Warehouse__r.Id;
                        }
                    }
                }
            }
        }
        
        
        
        
           /* @author -Nanma  
* update outstanding amount in customer */
        
        if (trigger.isInsert && Trigger.isBefore){
                 for(Account account : trigger.new){
                     if(account.Opening_Balance__c != null ){
                          if(account.Outstanding_Amount__c != null ){
                              Decimal amount =0;
                              amount =account.Outstanding_Amount__c +account.Opening_Balance__c;
                              account.Outstanding_Amount__c =amount;
                              
                          }else{
                             account.Outstanding_Amount__c = account.Opening_Balance__c;
                          }
                 }
        }
        }
        if (trigger.isUpdate && Trigger.isBefore){
                 for(Account account : trigger.new){
                     
                     if(account.Skip_Credit_Limit_For_Next_Order__c ==true && account.Skip_Credit_Limit_For_Next_Order__c !=trigger.oldMap.get(account.Id).Skip_Credit_Limit_For_Next_Order__c){
                         account.Skip_Credit_Period_limit_Date__c=system.now();
                     } else if(account.Skip_Credit_Limit_For_Next_Order__c ==false && account.Skip_Credit_Limit_For_Next_Order__c !=trigger.oldMap.get(account.Id).Skip_Credit_Limit_For_Next_Order__c){
                            account.Skip_Credit_Period_limit_Date__c=null;
                     }
                     

                     if(account.Opening_Balance__c != null && trigger.oldMap.get(account.Id).Opening_Balance__c != account.Opening_Balance__c){
                          if(account.Outstanding_Amount__c != null ){
                              Decimal amount =0,oldPend=0;
                              if(trigger.oldMap.get(account.Id).Opening_Balance__c !=null)
                              oldPend =trigger.oldMap.get(account.Id).Opening_Balance__c;
                              amount =account.Outstanding_Amount__c - oldPend;
                              amount += account.Opening_Balance__c ;
                              account.Outstanding_Amount__c =amount;
                              
                          }else{
                             account.Outstanding_Amount__c = account.Opening_Balance__c;
                          }
                 }
        }
        }
        if(trigger.isBefore && trigger.isUpdate){
            for(Account acc: trigger.new){
                 //system.debug('App:' + Approval.isLocked(acc));
                if(Approval.isLocked(acc)){
                    Approval.Unlock(acc, false);
                }
               // system.debug('App:' + Approval.isLocked(acc));
            }
        }
        
        /*To send data to SAP*/
        if(trigger.isUpdate || Trigger.isAfter){
            list<Id> listCustomerId =new List<Id>();
            for(Account cust : trigger.new){    
                if(cust.Approval_Status__c =='Approved' && trigger.oldMap.get(cust.Id).Approval_Status__c != cust.Approval_Status__c){
                    listCustomerId.add(cust.Id);    
                }
            }
            if(listCustomerId.size() > 0){
                SAPsend_TriggerHandler.sendToSap(listCustomerId,'Account');
                
            }
            
        }

    }
}