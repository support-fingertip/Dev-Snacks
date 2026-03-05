global class UpdateBranchOpeningBalance  implements Database.Batchable<sObject>,Database.Stateful,Schedulable{

     public Database.QueryLocator start(Database.BatchableContext BC){
        String query='select Id,Name,Branch_ID__c from Branch__c';
      return Database.getQueryLocator(query);
   }

    public void execute(Database.BatchableContext BC, List<Branch__c> scope){
        Set<Id> rtIds = new Set<Id>();
        
        for(Branch__c rt : scope){
            rtIds.add(rt.Id);
        }
        Map<Id,Cashbook__c> cbMap = new Map<Id,Cashbook__c>();
         List<Cashbook__c> cbList = [select Id,Name,Route__c,Branch__c,Opening_Balance__c,Closing_Balance__c,CreatedDate from Cashbook__c where CreatedDate = yesterday and Branch__c IN:rtIds];
        List<Cashbook__c> cbListToUpdate = new List<Cashbook__c>();
        if(cbList.size() != 0){
            for(Cashbook__c cb: cbList){
                cbMap.put(cb.Branch__c,cb);
            }
        }
        else{
             for(Branch__c rt: scope){
                Cashbook__c cb1 = new Cashbook__c();
                cb1.Branch__c = rt.Id;
                cb1.Opening_Balance__c = 0;
                 cbListToUpdate.add(cb1);
            }
        }      
        
        
        if(cbMap.size() != 0){
            for(Branch__c rt: scope){
                if(cbMap.containsKey(rt.Id)){
                    Cashbook__c cb1 = new Cashbook__c();
                    cb1.Branch__c = rt.Id;
                    cb1.Opening_Balance__c = cbMap.get(rt.Id).Closing_Balance__c;
                    cbListToUpdate.add(cb1);
                }
                else{
                    Cashbook__c cb1 = new Cashbook__c();
                    cb1.Branch__c = rt.Id;
                    cb1.Opening_Balance__c = 0;
                    cbListToUpdate.add(cb1);
                }
              
            }
             
             
         }
     system.debug('cbListToUpdate:' + cbListToUpdate);
       insert cbListToUpdate;
    }
    
    public void finish(Database.BatchableContext BC){
   }
    
     global void execute(SchedulableContext SC){
        database.executeBatch(new UpdateBranchOpeningBalance(),100);
      
    } 

}