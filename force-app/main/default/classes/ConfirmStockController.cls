public class ConfirmStockController {
    
     @AuraEnabled
    public static String getUIThemeDescription() {
        String theme = UserInfo.getUiThemeDisplayed();
        return theme;
    }
    
    @AuraEnabled
    public static List<Stock_Request_Item__c> getStock(String recId){
        
        return [select Id,Name,Product__c,Item_Code__c,Quantity__c,Transfered_Quantity__c,Manufacturing_Date__c,Batch_Number__c,Expiry_Date__c,MRP__c,
                Received_Qunatity__c,Status__c,Stock_Request_Item_Id__c,Stock_Request__c,Product__r.GST__c,Stock_Request__r.Status__c,Margin__c from Stock_Request_Item__c where Stock_Request__c =:recId and (Transfered_Quantity__c != null and Transfered_Quantity__c != 0) ];
    }
     @AuraEnabled
    public static String checkStatus(String recId){
        
        return [select Id,Name,Status__c from Stock_Request__c where Id =:recId  ].Status__c;
    }
    @AuraEnabled
    public static String rejectNewRequest(List<Stock_Request_Item__c> reqList, String recId){
        system.debug('reqList=== '+reqList);
        system.debug('recId=== '+recId);
        List<Stock_Request_Item__c> stockReqItems = new List<Stock_Request_Item__c>();
        Stock_Request__c stockReq = [Select Id,Name,Status__c,Branch__c,Route__c,Route__r.Warehouse__c,Route__r.Vehicle__c from Stock_Request__c where id=:recId];
        stockReq.Status__c = 'Cancelled';
        
         try {
          update stockReq;
        }
        catch (System.Exception ae) { 
           ExceptionHandler.addLog(ae,String.valueOf(stockReq) ); 
        }     
        
        for(Stock_Request_Item__c stockReqItem: reqList){
            stockReqItem.Status__c = 'Cancelled';
            stockReqItems.add(stockReqItem);
        }
        if(stockReqItems.size()>0){
            
            try {
                update stockReqItems;
            }
            catch (System.Exception ae) { 
                ExceptionHandler.addLog(ae,String.valueOf(stockReqItems) ); 
            }
        }
        system.debug('stockReqItems=== '+stockReqItems);
        return stockReq.Id;
    }
    @AuraEnabled
    public static String saveNewRequest(List<Stock_Request_Item__c> reqList, String recId ){
        
        Stock_Request__c sr = [Select Id,Name,Status__c,Branch__c,Route__c,Route__r.Warehouse__c,Route__r.Vehicle__c,Transfer_Date__c from Stock_Request__c where id=:recId];
        
        Stock_Transfer__c st = new Stock_Transfer__c();
        st.Transfer_Date__c = sr.Transfer_Date__c != null ? sr.Transfer_Date__c : system.today();
        st.Stock_Request__c = sr.Id;
        st.From__c = 'Branch';
        st.To__c = 'Route';
        st.Route__c = sr.Route__c;
        st.Branch__c = sr.Branch__c;
        st.Warehouse__c = sr.Route__r.Warehouse__c;
        st.Vehicle__c = sr.Route__r.Vehicle__c;
        try {
            insert st;
        }
        catch (System.Exception ae) { 
            ExceptionHandler.addLog(ae,String.valueOf(st) ); 
        }
        
        
        List<Stock__c> stList = [select Id,Name,Stock_Date__c,Product__c,Route__c,Batch_Number__c,Intial_Stock__c,Available_Quantity__c,Sold_Qty__c,Manufacturing_Date__c,Price__c,Stock_Ext_ID__c from Stock__c where Stock_Ext_ID__c != null ];
        Map<String,Stock__c> stockMap = new Map<String,Stock__c>();
        for(Stock__c stk:stList){
            stockMap.put(stk.Stock_Ext_ID__c, stk);
        }
        
        String extId='';
        
        List<Stock__c> stocklist = new List<Stock__c>();
        for(Stock_Request_Item__c sri: reqList){
          system.debug('sri=== '+sri.MRP__c);
            
            Stock__c stock = new Stock__c();
            
            if(sri.Batch_Number__c != null && sri.Product__c != null && sri.Manufacturing_Date__c != null && sri.MRP__c != null){
                extId = sr.Route__c + String.valueOf(sri.Product__c) + sri.Batch_Number__c + sri.Manufacturing_Date__c + sri.MRP__c.setScale(2) + system.today();
            }
            
            if(stockMap.containsKey(extId)){
                stock = stockMap.get(extId);
                stock.Intial_Stock__c = stockMap.get(extId).Intial_Stock__c + sri.Received_Qunatity__c;
                stock.Available_Quantity__c = stockMap.get(extId).Available_Quantity__c + sri.Received_Qunatity__c;
            }
            else{
                stock.Stock_Date__c = system.today();
                stock.Product__c = sri.Product__c;
                stock.Related_To__c = 'Route';
                stock.Route__c = sr.Route__c;
                stock.Batch_Number__c = sri.Batch_Number__c;
                stock.Branch__c = sr.Branch__c;
                stock.Warehouse__c = sr.Route__r.Warehouse__c;
                stock.Vehicle__c = sr.Route__r.Vehicle__c;
                stock.GST_Percentage__c = sri.Product__r.GST__c != null ? Decimal.valueOf(sri.Product__r.GST__c) : 0;
                stock.Intial_Stock__c = sri.Received_Qunatity__c;
                stock.Available_Quantity__c = sri.Received_Qunatity__c;
                stock.Sold_Qty__c = stock.Intial_Stock__c - stock.Available_Quantity__c;
                stock.Stock_Transfer__c = st.Id;
                stock.Manufacturing_Date__c = sri.Manufacturing_Date__c;
                stock.Expiry_Date__c = sri.Expiry_Date__c;  
                stock.Price__c = sri.MRP__c;
                stock.Margin__c = sri.Margin__c;
                stock.Stock_Ext_ID__c = extId;
            }
            
            sri.Status__c = 'Received';
            
            stocklist.add(stock);
            
        }
       
        
        try{
            
            upsert stocklist Stock_Ext_ID__c ;
            
            sr.Status__c = 'Received';
            sr.Received_Date_Time__c = system.now();
            update sr;
            
            update reqList;
            
        }
        catch(Exception ae){
            ExceptionHandler.addLog(ae,String.valueOf(stocklist) + '---' + String.valueOf(sr) + '---' + String.valueOf(reqList)  ); 
        }
        
        return recId;
    }
}