trigger UnsealedItemTrigger on Unsealed_Item__c (After insert) {

    if(trigger.isAfter && trigger.isInsert ){
        
       
          UnsealedItemTrigger_Handler.updateStockHistory(trigger.New);
        
        /*List<Stock__c> stocksToUpdate = new List<Stock__c>();
        set<Id> stockIds = new set<Id>();
        
        List<Unsealed_Item__c> items = [select Id,Name,Quantity__c,Stock__c from Unsealed_Item__c where Unsealed__c IN:trigger.new];
        
        Map<Id,Decimal> qtyMap = new Map<Id,Decimal>();
        for(Unsealed_Item__c item : items){
            if(item.Quantity__c != null){
                stockIds.add(item.Stock__c);
                
                if(qtyMap.containsKey(item.Stock__c)){
                    qtyMap.put(item.Stock__c, qtyMap.get(item.Stock__c) + item.Quantity__c);
                }
                else{
                    qtyMap.put(item.Stock__c, item.Quantity__c);
                }
                
            }
        }
        
        if(stockIds.size()>0){
            system.debug('stockIds=== '+stockIds);
            
            List<Stock__c> stocks = [select Id,Available_Quantity__c,Sold_Qty__c,Product__c,Route__c from Stock__c where Id in : stockIds];
            Set<String> extids = new Set<String>();
            Map<String,Decimal> unsealMap = new Map<String,Decimal>();
            
            for(Stock__c stock:stocks){
                string ext = String.valueOf(stock.Product__c) + String.valueOf(stock.Route__c) + system.today();
                extids.add(ext);
                Decimal totalqty = qtyMap.get(stock.Id);
                if(unsealMap.containsKey(ext)){
                    unsealMap.put(ext,unsealMap.get(ext) + totalqty);
                }
                else{
                    unsealMap.put(ext,totalqty);
                }
                
            }
            
            List<Stock_History__c> hisList = [select Id,Name,Route__c,Product__c,Available_Quantity__c,Initial_Quantity__c,
                                              Damaged_Quantity__c,Free_Quantity__c,Sold_Quantity__c,
                                              Replaced_Quantity__c,Unsealed_Quantity__c,CreatedDate,Ext_ID__c from Stock_History__c where  Ext_ID__c IN:extIds];
            List<Stock_History__c> hisListToUpdate = new List<Stock_History__c>();
            if(hisList.size() > 0){
                for(Stock_History__c his : hisList){
                    his.Unsealed_Quantity__c = his.Unsealed_Quantity__c + unsealMap.get(his.Ext_ID__c);
                    hisListToUpdate.add(his);
                }
            }
            upsert hisListToUpdate;
        }*/
    }
}