trigger Employee_Trigger on Employee__c (before insert,After Insert) {
      /* Employee data Send to SAP*/ 
    if(trigger.isAfter && trigger.isInsert){
        list<Id> lstEmployeeId= new list<Id>();
        for(Employee__c employee : trigger.New){
           lstEmployeeId.add(employee.Id); 
        }
        SAPsend_TriggerHandler.sendToSap(lstEmployeeId,'Employee__c');
    }
    

}