trigger Vehicle_Trigger on Vehicle__c ( After insert) {
    
   
    
    /* Vehicle data Send to SAP*/ 
    if(trigger.isAfter && trigger.isInsert){
        list<Id> lstvehicleId= new list<Id>();
        for(Vehicle__c veh : trigger.New){
           lstvehicleId.add(veh.Id); 
        }
        SAPsend_TriggerHandler.sendToSap(lstvehicleId,'Vehicle__c');
    }
}