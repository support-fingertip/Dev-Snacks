global class visitScheduler implements Database.Batchable <sObject>,Database.Stateful,Schedulable{
     
    global visitScheduler(){
    }
  
 global Database.QueryLocator start(Database.BatchableContext info){ 
	string pla = 'Planned';
     string inp = 'In Progress';
     String SOQL='SELECT Id,Planned_Start_Time__c,Status__c FROM visit__c where  Planned_Start_Time__c = TODAY and (Status__c=:pla OR Status__c=:inp)';
       return Database.getQueryLocator(SOQL);
   }     
   global void execute(Database.BatchableContext info, List<visit__c> scope){
       List<visit__c> visitsToUpdate = new List<visit__c>();
       for(visit__c a : scope)
          { 
           a.status__c = 'Incomplete';
           visitsToUpdate.add(a); 
       }       
       Database.SaveResult[] srList = Database.update(visitsToUpdate, false);
   
   }     
   global void finish(Database.BatchableContext info){ 
   
   } 
 
    global void execute(SchedulableContext SC){
        database.executeBatch(new visitScheduler(),100);
      
    } 
}