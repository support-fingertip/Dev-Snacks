trigger RouteTrigger on Route__c (after update, before insert,After insert) {
    
   /* Route data Send to SAP*/ 
    if(trigger.isAfter && trigger.isInsert){
        list<Id> lstRouteId= new list<Id>();
        for(Route__c route : trigger.New){
           lstRouteId.add(route.Id); 
        }
        SAPsend_TriggerHandler.sendToSap(lstRouteId,'Route__c');
    }
    
    
    
	/*List<account> accList = new List<account>();
    Map<Id,Id> rtIds = new Map<Id,Id>();
    for(Route__c rt : Trigger.new){
        if(rt.ownerId != Trigger.oldmap.get(rt.Id).OwnerId){
            rtIds.put(rt.Id,rt.OwnerId);
        }
        
    }
    if(rtIds.size()>0){
        List<Account> oldAccounts = [SELECT Id,Routes__c,OwnerId FROM Account WHERE  Routes__c IN : rtIds.keySet()];
        
        for(Account act : oldAccounts){
            Account acc = new Account();
            acc.Id = act.Id;
            acc.ownerId = rtIds.get(act.Routes__c);
            accList.add(acc);
        }
        if(accList.size()>0){
            database.update(accList);
        }
    }*/
}