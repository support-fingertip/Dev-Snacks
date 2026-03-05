trigger ItemReplacement_Trigger on Item_Replacement__c (After Update) {
    
 /*   if(trigger.operationType == TriggerOperation.AFTER_UPDATE){
        list<Id> listReplaceId =new List<Id>();
        list<Id> listRejectedReplaceId =new List<Id>();
        
        for(Item_Replacement__c ir : trigger.New){
            if(ir.Approval_Status__c =='Approved' && ir.Approval_Status__c != trigger.oldMap.get(ir.Id).Approval_Status__c && ir.New_Approval_Flow__c){
                listReplaceId.add(ir.Id);       
            } 
              if(ir.Approval_Status__c =='Rejected' && ir.Approval_Status__c != trigger.oldMap.get(ir.Id).Approval_Status__c && ir.New_Approval_Flow__c){
                listRejectedReplaceId.add(ir.Id);       
            } 
        }   
        
        if(listReplaceId.size() > 0){
               map<Id,decimal> blockStockMap =new map<Id,decimal>();
            list<Replaced_Item__c> Items =[select Id,Name,Quantity__c,New_Stock__c,Damaged_Stock__c,Product__c,New_Created_Stock__c,
                                              Item_Replacement__r.Route__c,Item_Replacement__r.Route__r.OwnerId,Item_Replacement__r.Branch__c,
                                              Batch_No__c,Item_Replacement__r.Type__c,Type__c from Replaced_Item__c where Item_Replacement__c in :listReplaceId and Quantity__c!=null and New_Stock__c !=null];
            for(Replaced_Item__c r :Items){
                decimal sumUpQty=0;
                if(blockStockMap.containsKey(r.New_Stock__c)){
                    sumUpQty =blockStockMap.get(r.New_Stock__c);
                }
                sumUpQty += r.Quantity__c;
                blockStockMap.put(r.New_Stock__c,sumUpQty);
            }
            if(!blockStockMap.isEmpty()){
                stockHandler.removeBlockedQuantityToStock(blockStockMap,'Replacement'); remove Blocked qty from stock and add in replaced quantity
            }
            ItemReplacementHandler.updateStock(Items);
            SAPsend_TriggerHandler.sendToSap(listReplaceId,'Item_Replacement__c'); sending to sap
        }
        if(listRejectedReplaceId.size() > 0){
               map<Id,decimal> blockStockMap =new map<Id,decimal>();
              list<Replaced_Item__c> Items =[select Id,Quantity__c,New_Stock__c from Replaced_Item__c where Item_Replacement__c in :listRejectedReplaceId and Quantity__c!=null and New_Stock__c !=null];
            for(Replaced_Item__c r :Items){
                decimal sumUpQty=0;
                if(blockStockMap.containsKey(r.New_Stock__c)){
                    sumUpQty =blockStockMap.get(r.New_Stock__c);
                }
                sumUpQty += r.Quantity__c;
                blockStockMap.put(r.New_Stock__c,sumUpQty);
            }
            if(!blockStockMap.isEmpty()){
                stockHandler.removeBlockedQuantityToStock(blockStockMap,''); remove Blocked qty from stock
            } 
        }
        
    }*/
}