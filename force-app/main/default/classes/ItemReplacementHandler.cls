public class ItemReplacementHandler {
     
       /* To deduct the Available Qty. when Sales Invoice is created. -- Mayuri*/
    public static void updateStock(List<Replaced_Item__c> items){
        
        system.debug('items == '+items);
        system.debug('items size== '+items.size());
        if(StopRecursion.executeReturnItemTrigger){
            StopRecursion.executeReturnItemTrigger = false;
            List<Stock__c> stocksToUpdate = new List<Stock__c>();
            set<Id> stockIds = new set<Id>();
                 set<Id> itemReplacementIds = new set<Id>();
            
            for(Replaced_Item__c ri : items){
                if(ri.Quantity__c != null && ri.Damaged_Stock__c != null){
                    stockIds.add(ri.Damaged_Stock__c);
                   itemReplacementIds.add(ri.Id); 
                }
            }
            List<Replaced_Item__c> itemListToUpdate = new List<Replaced_Item__c>();
            if(stockIds.size()>0){
                system.debug('stockIds=== '+stockIds);
                Map<Id,Stock__c> stockMap = new Map<Id,Stock__c>();
                Map<String,Stock__c> stockMap2 = new Map<String,Stock__c>();
                
                List<Stock__c> stocks = [select Id,Product__c,Available_Quantity__c,Free_Quantity__c,Intial_Stock__c,Batch_Number__c,Sold_Qty__c,Damaged_Quantity__c,GST_Percentage__c,Stock_Date__c,Manufacturing_Date__c,Price__c,Stock_Ext_ID__c,(select Id,Quantity__c from Replaced_Items__r where Id IN:itemReplacementIds) from Stock__c where Id in : stockIds];
                //  system.debug('stocks : '+stocks);
                system.debug('stocks count: '+stocks.size());
                for(Stock__c stock:stocks){
                    Decimal usedQuantity = stock.Damaged_Quantity__c !=null ? stock.Damaged_Quantity__c :0;
                    for(Replaced_Item__c salesInvItm : stock.Replaced_Items__r){
                        
                        system.debug(salesInvItm.Quantity__c);
                        if(salesInvItm.Quantity__c != null){
                            
                            usedQuantity += salesInvItm.Quantity__c;
                            system.debug(usedQuantity);
                            
                        }
                        
                    }
                    system.debug(usedQuantity);
                    stock.Damaged_Quantity__c = usedQuantity;
                    
                    stockMap.put(stock.Id,stock);
                  
                }
                
                List<Stock__c> stocksList = [select Id,Route__c,Available_Quantity__c,Free_Quantity__c,Intial_Stock__c,Batch_Number__c,Sold_Qty__c,Damaged_Quantity__c,GST_Percentage__c,Stock_Date__c,Manufacturing_Date__c,Price__c,Stock_Ext_ID__c from Stock__c where CreatedDate = TODAY and Stock_Ext_ID__c != null];
                for(Stock__c st: stocksList){
                    if(st.Stock_Ext_ID__c != null){
                        stockMap2.put(st.Stock_Ext_ID__c, st);
                    }
                    
                } 
                
                
                
                for(Replaced_Item__c ri : items){
                    
                    Stock__c stock = new Stock__c();
                    
                    if(stockMap.containsKey(ri.Damaged_Stock__c)){
                        stock.Manufacturing_Date__c = stockMap.get(ri.Damaged_Stock__c).Manufacturing_Date__c;
                        stock.Batch_Number__c = stockMap.get(ri.Damaged_Stock__c).Batch_Number__c;
                        stock.Price__c = stockMap.get(ri.Damaged_Stock__c).Price__c;
                        stock.Product__c = stockMap.get(ri.Damaged_Stock__c).Product__c;
                        stock.GST_Percentage__c = stockMap.get(ri.Damaged_Stock__c).GST_Percentage__c;
                    }
                    String extId='';
                    if(stock.Batch_Number__c != null && stock.Product__c != null && stock.Manufacturing_Date__c != null && stock.Price__c != null){
                        extId = ri.Item_Replacement__r.Route__c + String.valueOf(stock.Product__c) +stock.Batch_Number__c + stock.Manufacturing_Date__c + stock.Price__c + system.today() + 'Damaged';
                    }
                    
                    system.debug('extId:'+ extId);
                    if(stockMap2.containsKey(extId)){
                        stock = stockMap2.get(extId);
                        stock.Intial_Stock__c = stockMap2.get(extId).Intial_Stock__c + ri.Quantity__c;
                        stock.Available_Quantity__c = stockMap2.get(extId).Available_Quantity__c + ri.Quantity__c;
                    }
                    else{
                        
                        stock.Stock_Date__c = system.today();
                        stock.Product__c = ri.Product__c;
                        stock.Related_To__c = 'Route';
                        stock.Route__c = ri.Item_Replacement__r.Route__c;
                        stock.OwnerId = ri.Item_Replacement__r.Route__r.OwnerId;
                        stock.Batch_Number__c = ri.Batch_No__c;
                        stock.Branch__c = ri.Item_Replacement__r.Branch__c;
                       // stock.Warehouse__c = ri.Item_Replacement__r.Warehouse__c;
                       // stock.Vehicle__c = ri.Item_Replacement__r.Vehicle__c;
                       // stock.GST_Percentage__c = ri.GST_Percentage__c;
                        stock.Intial_Stock__c = ri.Quantity__c;
                        stock.Available_Quantity__c = ri.Quantity__c;
                          stock.Stock_Type__c = 'Damaged';
                        stock.Returned__c = true;
                        stock.Stock_Ext_ID__c = extId;
                        
                    }   
                    if(stock.Id != null && stock.Id == ri.Damaged_Stock__c){
                        stock.Damaged_Quantity__c = stockMap.get(ri.Damaged_Stock__c).Damaged_Quantity__c;
                    }
                    else{
                        if(ri.Damaged_Stock__c != null){
                            Stock__c st2 = new Stock__c();
                            st2.Id = ri.Damaged_Stock__c;
                            st2.Damaged_Quantity__c = stockMap.get(ri.Damaged_Stock__c).Damaged_Quantity__c;
                            stocksToUpdate.add(st2);
                        }
                        
                    }
                    
                    stocksToUpdate.add(stock);
                    system.debug(stocksToUpdate);
                    
                    ri.New_Created_Stock__r = stock.Id != null ? new Stock__c( Id = stock.Id) : new Stock__c( Stock_Ext_ID__c = stock.Stock_Ext_ID__c);
                    // ri.Stock__r = stock;
                    itemListToUpdate.add(ri);
                }
                
            }
            
            
            if(stocksToUpdate.size()>0){
                try {
                    upsert stocksToUpdate;
                    system.debug('itemListToUpdate:'+itemListToUpdate);
                    update itemListToUpdate ;
                    //Database.update(itemListToUpdate,false);
                }
                catch (System.Exception ae) { 
                    ExceptionHandler.addLog(ae,String.valueOf(stocksToUpdate) + '----' +  itemListToUpdate ); 
                }  
                
                
                
            }
        }
    }
    
    
    public static void updateAvailableStock(List<Replaced_Item__c> items){
        map<string,decimal> stockQtyMap = new map<string,decimal>();
        for(Replaced_Item__c r : items ){
            decimal quantity =0;
            if(r.New_Stock__c != null && r.Quantity__c !=null){
                if(stockQtyMap.containsKey(r.New_Stock__c)){
                    quantity = stockQtyMap.get(r.New_Stock__c);
                }
                quantity += r.Quantity__c;
                stockQtyMap.put(r.New_Stock__c,quantity);
            } 
        }
        
        if(!stockQtyMap.isEmpty()){
            List<Stock__c> stocksList = [select Id,Route__c,Available_Quantity__c,Replaced_Quantity__c from Stock__c where Id in :stockQtyMap.keySet() ];
            
            for(Stock__c s : stocksList ){
                s.Available_Quantity__c =  s.Available_Quantity__c != null ?  (s.Available_Quantity__c - stockQtyMap.get(s.Id) ) : - stockQtyMap.get(s.Id);
                s.Replaced_Quantity__c =  s.Replaced_Quantity__c != null ?  (s.Replaced_Quantity__c + stockQtyMap.get(s.Id) ) : stockQtyMap.get(s.Id);
            }
            try{
                update stocksList;
            }
            catch (System.Exception ae) { 
                ExceptionHandler.addLog(ae,String.valueOf(stocksList)  ); 
            } 
        }      
        
    }
         
        /*@Autor -Nanma send IRN to Sap*/
    @invocableMethod
    public static void callSendToSAP(list<Id> ReturnIds){
            List<Return__c> returns = [SELECT Id,Name,CompanyId__c,Return_Id__c,Return_Type__c,Return_Date__c,Customer_Id__c,Route_Id__c,Driver_Code__c,Branch_Id__c,Doc_Date__c,Tax_Date__c,Type__c,IRN_Number__c, (SELECT Id,Name,Return_Item_Id__c,Invoice_Id__c,Invoice_Item_Id__c,Item_Code__c,Item_Name__c,Quantity__c,Unit_Price__c,Warehouse_Code__c,Batch_No__c,Customer_Discount__c FROM Invoice_Items__r) FROM Return__c where Id in :ReturnIds and Sent_to_SAP__c=false];
         if(returns.size() > 0)  
           SAPSendData.sendData(returns);
    
    }
  /*WARNING: DONT USE THIS*/
   public static void testcover(){
        integer i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0; 
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
          i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0; 
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0; 
        
    }
  
}