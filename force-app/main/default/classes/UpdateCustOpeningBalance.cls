global class UpdateCustOpeningBalance implements Database.Batchable<sObject>,Database.Stateful,Schedulable{

     public Database.QueryLocator start(Database.BatchableContext BC){
        String query='Select Id,Name from Account where Account_Status__c = \'Approved\'';
      return Database.getQueryLocator(query);
   }

    public void execute(Database.BatchableContext BC, List<Account> scope){
        Set<Id> accIds = new Set<Id>();
        
        for(Account acc : scope){
            accIds.add(acc.Id);
        }
        Map<Id,Customer_Cashbook__c> cbMap = new Map<Id,Customer_Cashbook__c>();
         List<Customer_Cashbook__c> cbList = [select Id,Name,Customer__c,Opening_Balance__c,Closing_Balance__c,CreatedDate from Customer_Cashbook__c where CreatedDate = yesterday and Customer__c IN:accIds];
        List<Customer_Cashbook__c> cbListToUpdate = new List<Customer_Cashbook__c>();
        if(cbList.size() != 0){
            for(Customer_Cashbook__c cb: cbList){
                cbMap.put(cb.Customer__c,cb);
            }
        }
        else{
             for(Account acc: scope){
                Customer_Cashbook__c cb1 = new Customer_Cashbook__c();
                cb1.Customer__c = acc.Id;
                cb1.Opening_Balance__c = 0;
                 cbListToUpdate.add(cb1);
            }
        }      
        
        
        if(cbMap.size() != 0){
            for(Account acc: scope){
                if(cbMap.containsKey(acc.Id)){
                    Customer_Cashbook__c cb1 = new Customer_Cashbook__c();
                    cb1.Customer__c = acc.Id;
                    cb1.Opening_Balance__c = cbMap.get(acc.Id).Closing_Balance__c;
                    cbListToUpdate.add(cb1);
                }
                else{
                    Customer_Cashbook__c cb1 = new Customer_Cashbook__c();
                    cb1.Customer__c = acc.Id;
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
        database.executeBatch(new UpdateCustOpeningBalance(),100);
      
    } 

}