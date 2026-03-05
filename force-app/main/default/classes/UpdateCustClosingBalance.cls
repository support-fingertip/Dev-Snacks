global class UpdateCustClosingBalance  implements Database.Batchable<sObject>,Database.Stateful,Schedulable{
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query='select Id,Name,Outstanding_Amount__c from Account where Account_Status__c = \'Approved\'';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Account> scope){
        Set<Id> accIds = new Set<Id>();
        Map<Id,Decimal> accMap = new Map<Id,Decimal>();
        
        for(Account acc : scope){
            accIds.add(acc.Id);
            if(acc.Outstanding_Amount__c == null){
                acc.Outstanding_Amount__c = 0;
            }
            accMap.put(acc.Id,acc.Outstanding_Amount__c);
        }
      Map<Id,Customer_Cashbook__c> cbMap = new Map<Id,Customer_Cashbook__c>();
        
          List<Customer_Cashbook__c> cbList = [select Id,Name,Customer__c,Opening_Balance__c,Closing_Balance__c,CreatedDate from Customer_Cashbook__c where CreatedDate = today and Customer__c IN:accIds];
       
         if(cbList.size() != 0){
            for(Customer_Cashbook__c cb: cbList){
                cbMap.put(cb.Customer__c,cb);
            }
        }
        
      /*  List<Cashbook__c> cbListToUpdate = new List<Cashbook__c>();
        
        //Decimal totalDr=0,totalCr=0,ClosingBalance=0;
        Map<Id,Decimal> totalDrMap = new Map<Id,Decimal>();
        Map<Id,Decimal> totalCrMap = new Map<Id,Decimal>();
        
        List<Cash_Transfer__c> translist = [select id,Name,From__c, TO__c, Route__c, Amount__c, CreatedDate from Cash_Transfer__c where Route__c IN:rtIds and CreatedDate = today];
        if(translist.size() > 0){
            for(Cash_Transfer__c ct: translist){
                if(ct.Amount__c !=null){
                    if(ct.From__c == 'Branch' && ct.To__c == 'Route'){
                        //totalCr = totalCr + ct.Amount__c;
                        if(totalCrMap.containsKey(ct.Route__c)){
                            totalCrMap.put(ct.Route__c,totalCrMap.get(ct.Route__c) + ct.Amount__c);
                        }
                        else{
                           totalCrMap.put(ct.Route__c,ct.Amount__c); 
                        }
                        
                    }
                    else if(ct.From__c == 'Route' && ct.To__c == 'Branch'){
                        if(totalDrMap.containsKey(ct.Route__c)){
                            totalDrMap.put(ct.Route__c,totalDrMap.get(ct.Route__c) + ct.Amount__c);
                        }
                        else{
                           totalDrMap.put(ct.Route__c,ct.Amount__c); 
                        }
                      //  totalDr = totalDr + ct.Amount__c;
                    }
                }
            }
        }
        
        List<Receipt__c> recList = [select Id,Name,Branch__c,Branch__r.Name,Route__c,Route__r.Name,Amount__c,Customer__c,Customer__r.Name,Remarks__c,CreatedDate from Receipt__c where Mode_of_Payment__c = 'Cash' and Route__c IN:rtIds and CreatedDate = today];
        if(recList.size() > 0){
            for(Receipt__c rec: recList){
                if(rec.Amount__c != null && rec.Route__c != null && rec.Customer__c != null){
                    if(totalCrMap.containsKey(rec.Route__c)){
                            totalCrMap.put(rec.Route__c,totalCrMap.get(rec.Route__c) + rec.Amount__c);
                        }
                        else{
                           totalCrMap.put(rec.Route__c,rec.Amount__c); 
                        }
                    //totalCr = totalCr + rec.Amount__c;
                }
            }
        }
        
        List<Expense__c> explist = [select Id,Name,Branch__c,Route__c,Branch__r.Name,Route__r.Name,Total_Amount__c,Expense_Comments__c,CreatedDate from Expense__c where Route__c IN:rtIds and Approval_Status__c = 'Approved' and CreatedDate = today];
        if(explist.size() > 0){
            for(Expense__c exp: explist){
                if(exp.Total_Amount__c != null){
                    if(totalDrMap.containsKey(exp.Route__c)){
                            totalDrMap.put(exp.Route__c,totalDrMap.get(exp.Route__c) + exp.Total_Amount__c);
                        }
                        else{
                           totalDrMap.put(exp.Route__c,exp.Total_Amount__c); 
                        }
                      //totalDr = totalDr + exp.Total_Amount__c;
                }
            }
        }
        
         //ClosingBalance = totalCr - totalDr;
        system.debug('cbMap:' + cbMap.values());
         if(cbMap.size() != 0){
            for(Route__c rt: scope){
                if(cbMap.containsKey(rt.Id)){
                    Cashbook__c cb1 = cbMap.get(rt.Id);
                    cb1.Route__c = rt.Id;
                    if(totalCrMap.containsKey(rt.Id) && totalDrMap.containsKey(rt.Id)){
                    cb1.Closing_Balance__c = totalCrMap.get(rt.Id) - totalDrMap.get(rt.Id);
                    }
                    if(totalCrMap.containsKey(rt.Id) && !totalDrMap.containsKey(rt.Id)){
                    cb1.Closing_Balance__c = totalCrMap.get(rt.Id);
                    }
                    if(!totalCrMap.containsKey(rt.Id) && totalDrMap.containsKey(rt.Id)){
                    cb1.Closing_Balance__c = 0 - totalDrMap.get(rt.Id);
                    }
                      //cbList.add(cb1);
                }
                
            }
             
             
         }*/
        
         if(cbMap.size() != 0){
            for(Account acc: scope){
                if(cbMap.containsKey(acc.Id)){
                    Customer_Cashbook__c cb1 = cbMap.get(acc.Id);
                    // cb1.Customer__c = acc.Id;
                   cb1.Closing_Balance__c = accMap.get(acc.Id);
                      //cbList.add(cb1);
                }
                
            }
         }
        system.debug('cbMap:' + cbMap);
        update cbMap.values();
    }
    
    public void finish(Database.BatchableContext BC){
    }
    
     global void execute(SchedulableContext SC){
        database.executeBatch(new UpdateCustClosingBalance(),100);
      
    } 
}