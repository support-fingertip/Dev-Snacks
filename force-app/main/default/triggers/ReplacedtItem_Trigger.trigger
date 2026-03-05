trigger ReplacedtItem_Trigger on Replaced_Item__c (before insert,after insert) {
    if(trigger.isInsert && trigger.isAfter){
        list<Id> listReplaceId =new List<Id>();
        for(Replaced_Item__c ir : trigger.New){
            if(!listReplaceId.contains(ir.Item_Replacement__c)) 
                listReplaceId.add(ir.Item_Replacement__c);
        } 
        if(listReplaceId.size() > 0){
            SAPsend_TriggerHandler.sendToSap(listReplaceId,'Item_Replacement__c');
        }
    }
    
    
    
    if(trigger.isInsert && trigger.isAfter){
       ReplacedItemTriggerHandler.updateStockHistory(trigger.New);
    }
}