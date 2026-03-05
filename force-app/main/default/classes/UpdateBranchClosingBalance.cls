global class UpdateBranchClosingBalance  implements Database.Batchable<sObject>,Database.Stateful,Schedulable{
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query='select Id,Name,Branch_ID__c,Cash_In_Hand__c from Branch__c';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Branch__c> scope){
        Set<Id> rtIds = new Set<Id>();
           Map<Id,Decimal> rtMap = new Map<Id,Decimal>();
        
        for(Branch__c rt : scope){
            rtIds.add(rt.Id);
             if(rt.Cash_In_Hand__c == null){
                rt.Cash_In_Hand__c = 0;
            }
            rtMap.put(rt.Id,rt.Cash_In_Hand__c);
        }
        Map<Id,Cashbook__c> cbMap = new Map<Id,Cashbook__c>();
        
        List<Cashbook__c> cbList = [select Id,Name,Route__c,Branch__c,Opening_Balance__c,Closing_Balance__c,CreatedDate from Cashbook__c where CreatedDate = today and Branch__c IN:rtIds];
       
         if(cbList.size() != 0){
            for(Cashbook__c cb: cbList){
                cbMap.put(cb.Branch__c,cb);
            }
        }
        
     /*   List<Cashbook__c> cbListToUpdate = new List<Cashbook__c>();
        
        //Decimal totalDr=0,totalCr=0,ClosingBalance=0;
        Map<Id,Decimal> totalDrMap = new Map<Id,Decimal>();
        Map<Id,Decimal> totalCrMap = new Map<Id,Decimal>();
        
        List<Cash_Transfer__c> translist = [select id,Name,From__c, TO__c, Branch__c, Amount__c, CreatedDate from Cash_Transfer__c where Branch__c IN:rtIds and CreatedDate = today];
        if(translist.size() > 0){
            for(Cash_Transfer__c ct: translist){
                if(ct.Amount__c !=null){
                    if((ct.From__c == 'Route' || ct.From__c == 'Head Office') && ct.To__c == 'Branch'){
                        //totalCr = totalCr + ct.Amount__c;
                        if(totalCrMap.containsKey(ct.Branch__c)){
                            totalCrMap.put(ct.Branch__c,totalCrMap.get(ct.Branch__c) + ct.Amount__c);
                        }
                        else{
                           totalCrMap.put(ct.Branch__c,ct.Amount__c); 
                        }
                        
                    }
                    else if(ct.From__c == 'Branch' && (ct.To__c == 'Route' || ct.To__c == 'Head Office' )){
                        if(totalDrMap.containsKey(ct.Branch__c)){
                            totalDrMap.put(ct.Branch__c,totalDrMap.get(ct.Branch__c) + ct.Amount__c);
                        }
                        else{
                           totalDrMap.put(ct.Branch__c,ct.Amount__c); 
                        }
                      //  totalDr = totalDr + ct.Amount__c;
                    }
                }
            }
        }
        
        List<Receipt__c> recList = [select Id,Name,Branch__c,Branch__r.Name,Route__c,Route__r.Name,Amount__c,Customer__c,Customer__r.Name,Remarks__c,CreatedDate from Receipt__c where Mode_of_Payment__c = 'Cash' and Branch__c IN:rtIds and CreatedDate = today];
        if(recList.size() > 0){
            for(Receipt__c rec: recList){
                if(rec.Amount__c != null && rec.Branch__c != null && rec.Customer__c != null){
                    if(totalDrMap.containsKey(rec.Branch__c)){
                            totalDrMap.put(rec.Branch__c,totalDrMap.get(rec.Branch__c) + rec.Amount__c);
                        }
                        else{
                           totalDrMap.put(rec.Branch__c,rec.Amount__c); 
                        }
                    //totalCr = totalCr + rec.Amount__c;
                }
            }
        }
        
        List<Expense__c> explist = [select Id,Name,Branch__c,Route__c,Branch__r.Name,Route__r.Name,Total_Amount__c,Expense_Comments__c,CreatedDate from Expense__c where Branch__c IN:rtIds and Approval_Status__c = 'Approved' and CreatedDate = today];
        if(explist.size() > 0){
            for(Expense__c exp: explist){
                if(exp.Total_Amount__c != null){
                    if(totalCrMap.containsKey(exp.Branch__c)){
                            totalCrMap.put(exp.Route__c,totalCrMap.get(exp.Branch__c) + exp.Total_Amount__c);
                        }
                        else{
                           totalCrMap.put(exp.Branch__c,exp.Total_Amount__c); 
                        }
                      //totalDr = totalDr + exp.Total_Amount__c;
                }
            }
        }
        
         //ClosingBalance = totalCr - totalDr;
        system.debug('cbMap:' + cbMap.values());
         if(cbMap.size() != 0){
            for(Branch__c rt: scope){
                if(cbMap.containsKey(rt.Id)){
                    Cashbook__c cb1 = cbMap.get(rt.Id);
                    cb1.Branch__c = rt.Id;
                    if(totalCrMap.containsKey(rt.Id) && totalDrMap.containsKey(rt.Id)){
                    cb1.Closing_Balance__c = totalDrMap.get(rt.Id) - totalCrMap.get(rt.Id);
                    }
                    if(totalCrMap.containsKey(rt.Id) && !totalDrMap.containsKey(rt.Id)){
                    cb1.Closing_Balance__c = 0 - totalCrMap.get(rt.Id);
                    }
                    if(!totalCrMap.containsKey(rt.Id) && totalDrMap.containsKey(rt.Id)){
                    cb1.Closing_Balance__c = totalDrMap.get(rt.Id);
                    }
                     // cbList.add(cb1);
                }
                
            }
             
             
         }*/
        
        if(cbMap.size() != 0){
            for(Branch__c rt: scope){
                if(cbMap.containsKey(rt.Id)){
                    Cashbook__c cb1 = cbMap.get(rt.Id);
                    cb1.Branch__c = rt.Id;
                   cb1.Closing_Balance__c = rtMap.get(rt.Id);
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
        database.executeBatch(new UpdateBranchClosingBalance(),100);
      
    } 
}