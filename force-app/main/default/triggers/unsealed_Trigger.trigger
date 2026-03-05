trigger unsealed_Trigger on Unsealed__c (before insert,before update,after update) {
    if(Label.Enable_Unsealed_Trigger == 'TRUE'){
    /*    
        if(trigger.operationType == TriggerOperation.BEFORE_INSERT || trigger.operationType == TriggerOperation.BEFORE_UPDATE ){
            User user = [select id,name,Route_Id__c,Branch_Id__c,ManagerId,Profile.Name from User where id=:UserInfo.getUserId() limit 1];
            for(Unsealed__c un: trigger.new){
                if(un.Unsealed_Approver__c ==null && un.Approval_status__c =='New' && un.New_Approval_Flow__c){
                    string profileName =user.Profile.Name;
                    if(profileName != null && (profileName.contains('Admin') || profileName.contains('ADMIN') || profileName.contains('admin')) ){
                        un.Unsealed_Approver__c = user.Id;
                    }ELSE if(un.Route__c !=null && un.Branch__c!=null){
                        list<Route__c> routes = [select Id,Receipt_Approver__c from Route__c where Id=:un.Route__c and Receipt_Approver__r.isActive =true]; 
                        if(routes.size() > 0){    un.Unsealed_Approver__c = routes[0].Receipt_Approver__c;    }
                        
                    }
                    if(un.Unsealed_Approver__c == null){
                        list<user> users =[select Id from user where Default_Receipt_Approver__c =true and isActive=true];
                        if(users.size() > 0){    un.Unsealed_Approver__c = users[0].Id;    }
                    }
                    
                }
                if(trigger.operationType == TriggerOperation.BEFORE_UPDATE ){
                    if(un.Route__c !=null && un.Route__c != trigger.oldMap.get(un.Id).Route__c && un.New_Approval_Flow__c  && un.Approval_status__c =='New'){
                        list<Route__c> routes = [select Id,Receipt_Approver__c from Route__c where Id=:un.Route__c and Receipt_Approver__r.isActive =true]; 
                        if(routes.size() > 0){    un.Unsealed_Approver__c = routes[0].Receipt_Approver__c;    } 
                    }
                }
                
            }
        }
        if(trigger.operationType == TriggerOperation.AFTER_INSERT || trigger.operationType == TriggerOperation.AFTER_UPDATE ){
            list<Id> listUnsealedId =new List<Id>();
            list<Id> listRejectedUnsealedId =new List<Id>();
            
            for(Unsealed__c un : trigger.New){
                if(un.Approval_Status__c =='Approved' && un.Approval_Status__c != trigger.oldMap.get(un.Id).Approval_Status__c && un.New_Approval_Flow__c){
                    listUnsealedId.add(un.Id);       
                } 
                if(un.Approval_Status__c =='Rejected' && un.Approval_Status__c != trigger.oldMap.get(un.Id).Approval_Status__c && un.New_Approval_Flow__c){
                    listRejectedUnsealedId.add(un.Id);       
                } 
            }   
            
            if(listUnsealedId.size() > 0){
                map<Id,decimal> blockStockMap =new map<Id,decimal>();
                list<Unsealed_Item__c> Items =[select Id,Name,Quantity__c,Stock__c,Product__c from Unsealed_Item__c where Unsealed__c in :listUnsealedId and Quantity__c!=null and Stock__c !=null];
                for(Unsealed_Item__c u :Items){
                    decimal sumUpQty=0;
                    if(blockStockMap.containsKey(u.Stock__c)){
                        sumUpQty =blockStockMap.get(u.Stock__c);
                    }
                    sumUpQty += u.Quantity__c;
                    blockStockMap.put(u.Stock__c,sumUpQty);
                }
                if(!blockStockMap.isEmpty()){
                    stockHandler.removeBlockedQuantityToStock(blockStockMap,'Unsealed');remove Blocked qty from stock and add in unsealed quantity
                }
               
            }
          
            if(listRejectedUnsealedId.size() > 0){
                map<Id,decimal> blockStockMap =new map<Id,decimal>();
                   list<Unsealed_Item__c> Items =[select Id,Name,Quantity__c,Stock__c,Product__c from Unsealed_Item__c where Unsealed__c in :listRejectedUnsealedId and Quantity__c!=null and Stock__c !=null];
                for(Unsealed_Item__c item :Items){
                    decimal sumUpQty=0;
                    if(blockStockMap.containsKey(item.Stock__c)){
                        sumUpQty =blockStockMap.get(item.Stock__c);
                    }
                    sumUpQty += item.Quantity__c;
                    blockStockMap.put(item.Stock__c,sumUpQty);
                }
                if(!blockStockMap.isEmpty()){
                    stockHandler.removeBlockedQuantityToStock(blockStockMap,'');remove Blocked qty from stock
                }
            }
        }  **/
        
      }
}