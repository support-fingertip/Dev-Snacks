public class stockHandler {
    
    public static void addBlockedQuantityToStock(map<Id,decimal> blockStockMap){
        
        map<Id,Stock__c> StockMap = new map<Id,Stock__c>([select Id,Blocked_Quantity__c,Intial_Stock__c,Sold_Qty__c,Free_Quantity__c,Replaced_Quantity__c,Available_Quantity__c from Stock__c where Id in :blockStockMap.keySet() limit 4999]);
        for(Stock__c s : StockMap.values()){
            s.Replaced_Quantity__c =  s.Replaced_Quantity__c ==null?0:s.Replaced_Quantity__c;
            s.Blocked_Quantity__c += blockStockMap.get(s.Id);
            s.Available_Quantity__c=s.Intial_Stock__c-s.Sold_Qty__c-s.Blocked_Quantity__c-s.Free_Quantity__c-s.Replaced_Quantity__c ;
        }
        try {
            update StockMap.values();
        }
        catch(Exception ex){
            ExceptionHandler.addLog(ex,String.valueOf(StockMap.values())); 
            system.debug(ex.getMessage());
        }
    }
    public static void removeBlockedQuantityToStock(map<Id,decimal> blockStockMap,string type){
        map<Id,Stock__c> StockMap = new map<Id,Stock__c>([select Id,Blocked_Quantity__c,Intial_Stock__c,Sold_Qty__c,Free_Quantity__c,Replaced_Quantity__c,Available_Quantity__c from Stock__c where Id in :blockStockMap.keySet() limit 4999]);
        for(Stock__c s : StockMap.values()){
        
            s.Blocked_Quantity__c -= blockStockMap.get(s.Id); /*deduct blocked qty*/
            
            if(type == 'Replacement'){
                    s.Replaced_Quantity__c =  s.Replaced_Quantity__c ==null?0:s.Replaced_Quantity__c;
                s.Replaced_Quantity__c +=blockStockMap.get(s.Id);
            }
            if(type == 'Unsealed'){
                  s.Free_Quantity__c =  s.Free_Quantity__c ==null?0:s.Free_Quantity__c;
                s.Free_Quantity__c +=blockStockMap.get(s.Id);
            }
            
            s.Available_Quantity__c=s.Intial_Stock__c-s.Sold_Qty__c-s.Blocked_Quantity__c-s.Free_Quantity__c-s.Replaced_Quantity__c;  
            
        }
        try {
            update StockMap.values();
        }
        catch(Exception ex){
            ExceptionHandler.addLog(ex,String.valueOf(StockMap.values())); 
            system.debug(ex.getMessage());
        }
    }
}