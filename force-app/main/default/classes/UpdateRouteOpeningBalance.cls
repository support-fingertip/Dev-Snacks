global class UpdateRouteOpeningBalance  implements Database.Batchable<sObject>,Database.Stateful,Schedulable{

     public Database.QueryLocator start(Database.BatchableContext BC){
        String query='select Id,Name,Route_ID__c from Route__c';
      return Database.getQueryLocator(query);
   }

    public void execute(Database.BatchableContext BC, List<Route__c> scope){
        Set<Id> rtIds = new Set<Id>();
        
        for(Route__c rt : scope){
            rtIds.add(rt.Id);
        }
        Map<Id,Cashbook__c> cbMap = new Map<Id,Cashbook__c>();
         List<Cashbook__c> cbList = [select Id,Name,Route__c,Branch__c,Opening_Balance__c,Closing_Balance__c,CreatedDate from Cashbook__c where CreatedDate = yesterday and Route__c IN:rtIds];
        List<Cashbook__c> cbListToUpdate = new List<Cashbook__c>();
        if(cbList.size() != 0){
            for(Cashbook__c cb: cbList){
                cbMap.put(cb.Route__c,cb);
            }
        }
        else{
             for(Route__c rt: scope){
                Cashbook__c cb1 = new Cashbook__c();
                cb1.Route__c = rt.Id;
                cb1.Opening_Balance__c = 0;
                 cbListToUpdate.add(cb1);
            }
        }      
        
        
        if(cbMap.size() != 0){
            for(Route__c rt: scope){
                if(cbMap.containsKey(rt.Id)){
                    Cashbook__c cb1 = new Cashbook__c();
                    cb1.Route__c = rt.Id;
                    cb1.Opening_Balance__c = cbMap.get(rt.Id).Closing_Balance__c;
                    cbListToUpdate.add(cb1);
                }
                else{
                    Cashbook__c cb1 = new Cashbook__c();
                    cb1.Route__c = rt.Id;
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
        database.executeBatch(new UpdateRouteOpeningBalance(),100);
      
    } 

}