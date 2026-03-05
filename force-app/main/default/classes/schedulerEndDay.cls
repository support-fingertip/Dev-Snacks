global class schedulerEndDay implements Database.Batchable <sObject>,Database.Stateful,Schedulable{
     
    global schedulerEndDay(){
    }
  
 global Database.QueryLocator start(Database.BatchableContext info){ 

     String SOQL='SELECT id,Clock_In__c,Clock_Out__c,First_Check_In_Visit__c,Last_Check_Out_Visit__c,OwnerId from  DailyLog__c  WHERE  Clock_In__c =TODAY';
       return Database.getQueryLocator(SOQL);
   }     
   global void execute(Database.BatchableContext info, List<DailyLog__c> scope){
       List<DailyLog__c> logsToUpdate = new List<DailyLog__c>();
       for(DailyLog__c a : scope)
          { 
              if(a.Clock_Out__c ==null){
                   a.Clock_Out__c = system.now();
                 
              }
              List<visit__c> vList = [Select id,Actual_Start_Time__c,Actual_End_Time__c from Visit__c WHERE Planned_Start_Time__c = TODAY AND ownerId=:a.OwnerId AND Actual_Start_Time__c != null Order by Actual_Start_Time__c ASC];
    if(vList.size() >0){
        a.First_Check_In_Visit__c = vList[0].id;
        
        if(vList[vList.size()-1].Actual_End_Time__c != null){
           a.Last_Check_Out_Visit__c = vList[vList.size()-1].id;
        }else{
            if(vList.size() >1){
                a.Last_Check_Out_Visit__c = vList[vList.size()-2].id;
            }
        }
        logsToUpdate.add(a); 
    }
          
       }       
       Database.SaveResult[] srList = Database.update(logsToUpdate, false);
   
   }     
   global void finish(Database.BatchableContext info){ 
   
       
   } 
 
    global void execute(SchedulableContext SC){
        database.executeBatch(new schedulerEndDay(),100);
      
    } 
}