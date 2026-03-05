public with sharing class SalesInvoiceItemTriggerHandler {
    
	/* To deduct the Available Qty. when Sales Invoice is created. -- Mayuri*/
    public static void deductStockForSalesInvoiceItem(List<Sales_Invoice_Item__c> invoiceItemList){
        system.debug('invoiceItemList == '+invoiceItemList);
        system.debug('invoiceItemList size== '+invoiceItemList.size());
        system.debug('executeLogic : '+StopRecursion.executeSalesInvoiceItemTrigger);
        if(StopRecursion.executeSalesInvoiceItemTrigger){
            StopRecursion.executeSalesInvoiceItemTrigger = false;
            List<Stock__c> stocksToUpdate = new List<Stock__c>();
            set<Id> stockIds = new set<Id>();
            
            for(Sales_Invoice_Item__c invoiceItem : invoiceItemList){
                if(invoiceItem.Quantity__c != null){
                    stockIds.add(invoiceItem.Stock__c);
                }
            }
            
            if(stockIds.size()>0){
                system.debug('stockIds=== '+stockIds);
                
               List<Stock__c> stocks = [select Id,Available_Quantity__c,Free_Quantity__c,Intial_Stock__c,Batch_Number__c,Sold_Qty__c,Blocked_Quantity__c,Replaced_Quantity__c,(select Id,Quantity__c,Sales_Invoice__r.Sales_Invoice_Status__c from Sales_Invoice_Items__r) from Stock__c where Id in : stockIds];
                // List<Stock__c> stocks = [select Id,Available_Quantity__c,Free_Quantity__c,Intial_Stock__c,Batch_Number__c,Sold_Qty__c,Blocked_Quantity__c,(select Id,Quantity__c,Sales_Invoice__r.Sales_Invoice_Status__c from Sales_Invoice_Items__r) from Stock__c where Id in : stockIds];
                system.debug('stocks : '+stocks);
                system.debug('stocks count: '+stocks.size());
                for(Stock__c stock:stocks){
                    Decimal usedQuantity = 0.00;
                    system.debug('usedQuantity at initials--- '+ usedQuantity);
                    system.debug('All Related Sales Invoice Items : '+stock.Sales_Invoice_Items__r.size());
                    for(Sales_Invoice_Item__c salesInvItm : stock.Sales_Invoice_Items__r){
                        if(salesInvItm.Sales_Invoice__r.Sales_Invoice_Status__c != 'Cancelled'){
                            if(salesInvItm.Quantity__c != null){
                                usedQuantity += salesInvItm.Quantity__c;
                            }
                        }
                       
                    }
                    stock.Sold_Qty__c = usedQuantity;
                    if(stock.Blocked_Quantity__c == null){
                        stock.Blocked_Quantity__c = 0;
                    }
                    stock.Free_Quantity__c = stock.Free_Quantity__c != null?stock.Free_Quantity__c:0.0;
                     stock.Replaced_Quantity__c = stock.Replaced_Quantity__c != null?stock.Replaced_Quantity__c:0.0;
                    system.debug('stock.Intial_Stock__c:' + stock.Intial_Stock__c);
                    system.debug('stock.Sold_Qty__c:' + stock.Sold_Qty__c);
                    system.debug('stock.Blocked_Quantity__c:' + stock.Blocked_Quantity__c);
                   stock.Available_Quantity__c = stock.Intial_Stock__c - stock.Sold_Qty__c - stock.Blocked_Quantity__c - stock.Free_Quantity__c - stock.Replaced_Quantity__c;
                    // stock.Available_Quantity__c = stock.Intial_Stock__c - stock.Sold_Qty__c - stock.Blocked_Quantity__c - stock.Free_Quantity__c;
                    stocksToUpdate.add(stock);
                }
            }
            if(stocksToUpdate.size()>0){
                
                try {
                    update stocksToUpdate;
                    updateStockHistory(invoiceItemList,'new');
                }
                catch (System.Exception ae) { 
                    ExceptionHandler.addLog(ae,String.valueOf(stocksToUpdate) );
                }   
                
            }
        }
    }
    
    /* To restore the Available Qty. when Sales Invoice is cancelled. -- Mayuri*/
      public static void readdStockForSalesInvoiceItem(List<Sales_Invoice_Item__c> invoiceItemList){
        system.debug('invoiceItemList == '+invoiceItemList);
        system.debug('invoiceItemList size== '+invoiceItemList.size());
        system.debug('executeLogic : '+StopRecursion.executeSalesInvoiceItemTrigger);
        if(StopRecursion.executeSalesInvoiceItemTrigger){
            StopRecursion.executeSalesInvoiceItemTrigger = false;
            List<Stock__c> stocksToUpdate = new List<Stock__c>();
            set<Id> stockIds = new set<Id>();
            
            Map<Id,Decimal> qtyMap = new Map<Id,Decimal>();
            for(Sales_Invoice_Item__c invoiceItem : invoiceItemList){
                if(invoiceItem.Quantity__c != null){
                    stockIds.add(invoiceItem.Stock__c);
                    
                    if(qtyMap.containsKey(invoiceItem.Stock__c)){
                        qtyMap.put(invoiceItem.Stock__c, qtyMap.get(invoiceItem.Stock__c) + invoiceItem.Quantity__c);
                    }
                    else{
                        qtyMap.put(invoiceItem.Stock__c, invoiceItem.Quantity__c);
                    }
                    
                }
            }
            
            if(stockIds.size()>0){
                system.debug('stockIds=== '+stockIds);
                
                List<Stock__c> stocks = [select Id,Available_Quantity__c,Free_Quantity__c,Intial_Stock__c,Batch_Number__c,Sold_Qty__c,Blocked_Quantity__c from Stock__c where Id in : stockIds];
                system.debug('stocks : '+stocks);
                system.debug('stocks count: '+stocks.size());
                for(Stock__c stock:stocks){
                    
                    Decimal totalqty = qtyMap.get(stock.Id);
                    
                    stock.Sold_Qty__c = stock.Sold_Qty__c - totalqty;
                    stock.Available_Quantity__c = stock.Available_Quantity__c + totalqty;
                    
                    
                    stocksToUpdate.add(stock);
                }
            }
            if(stocksToUpdate.size()>0){
                
                 try {
                     update stocksToUpdate;
                     updateStockHistory(invoiceItemList,'cancel');
                }
                catch (System.Exception ae) { 
                    ExceptionHandler.addLog(ae,String.valueOf(stocksToUpdate) );
                }  
            }
        }
    }

	/* To update Stock History -- Mayuri */
    public static void updateStockHistory(List<Sales_Invoice_Item__c> invoiceItemList,String exp){
        
        List<AggregateResult> avaggList = [select Product__c prod,Sales_Invoice__r.Route__c rt, SUM(Quantity__c) soldQty from Sales_Invoice_Item__c where createddate=today AND Sales_Invoice__r.Sales_Invoice_Status__c !='Cancelled' group by Product__c,Sales_Invoice__r.Route__c];
        Map<String,Decimal> availMap = new Map<String,Decimal>();
        Set<String> extids = new Set<String>();
        for(AggregateResult agg:avaggList){
            
            string ext = String.valueOf(agg.get('prod')) + String.valueOf(agg.get('rt')) + system.today();
            extids.add(ext);
            availMap.put(ext,(Decimal)agg.get('soldQty'));
        }
        
        List<Stock_History__c> hisList = [select Id,Name,Route__c,Product__c,Available_Quantity__c,Initial_Quantity__c,
                                          Damaged_Quantity__c,Free_Quantity__c,Sold_Quantity__c,
                                          Replaced_Quantity__c,Unsealed_Quantity__c,CreatedDate,Ext_ID__c from Stock_History__c where  Ext_ID__c IN:extIds];
        List<Stock_History__c> hisListToUpdate = new List<Stock_History__c>();
        if(hisList.size() > 0){
            for(Stock_History__c his : hisList){
                his.Sold_Quantity__c = availMap.containsKey(his.Ext_ID__c) ? availMap.get(his.Ext_ID__c) : his.Sold_Quantity__c;
                
                hisListToUpdate.add(his);
            }
        }
        
       // database.upsert(hisListToUpdate,false);
        try {
            update hisListToUpdate;
        }
        catch (System.Exception ae) { 
            ExceptionHandler.addLog(ae,String.valueOf(hisListToUpdate) );
        }  
        
       /* List<Stock__c> stocksToUpdate = new List<Stock__c>();
        set<Id> stockIds = new set<Id>();
        
        Map<Id,Decimal> qtyMap = new Map<Id,Decimal>();
        for(Sales_Invoice_Item__c invoiceItem : invoiceItemList){
            if(invoiceItem.Quantity__c != null){
                stockIds.add(invoiceItem.Stock__c);
                
                if(qtyMap.containsKey(invoiceItem.Stock__c)){
                    qtyMap.put(invoiceItem.Stock__c, qtyMap.get(invoiceItem.Stock__c) + invoiceItem.Quantity__c);
                }
                else{
                    qtyMap.put(invoiceItem.Stock__c, invoiceItem.Quantity__c);
                }
                
            }
        }
        
        if(stockIds.size()>0){
            system.debug('stockIds=== '+stockIds);
            
            List<Stock__c> stocks = [select Id,Available_Quantity__c,Sold_Qty__c,Product__c,Route__c from Stock__c where Id in : stockIds];
            Set<String> extids = new Set<String>();
            Map<String,Decimal> soldMap = new Map<String,Decimal>();
            
            for(Stock__c stock:stocks){
                string ext = String.valueOf(stock.Product__c) + String.valueOf(stock.Route__c) + system.today();
                extids.add(ext);
                Decimal totalqty = qtyMap.get(stock.Id);
                if(soldMap.containsKey(ext)){
                    if(exp == 'new'){
                        soldMap.put(ext,soldMap.get(ext) + totalqty);
                    }
                    if(exp == 'cancel'){
                        soldMap.put(ext,soldMap.get(ext) - totalqty);
                    }
                }
                else{
                    soldMap.put(ext,totalqty);
                }
                
            }
            
            
            List<Stock_History__c> hisList = [select Id,Name,Route__c,Product__c,Available_Quantity__c,Initial_Quantity__c,
                                              Damaged_Quantity__c,Free_Quantity__c,Sold_Quantity__c,
                                              Replaced_Quantity__c,CreatedDate,Ext_ID__c from Stock_History__c where  Ext_ID__c IN:extIds];
            List<Stock_History__c> hisListToUpdate = new List<Stock_History__c>();
            if(hisList.size() > 0){
                for(Stock_History__c his : hisList){
                    his.Sold_Quantity__c = his.Sold_Quantity__c + soldMap.get(his.Ext_ID__c);
                    hisListToUpdate.add(his);
                }
            }
            upsert hisListToUpdate;
        }*/
        
    }

   /*
    *********************************************************
    @Method Name    : deductStockforInvoice
	@Created Date   : Aug 13, 2024
    @author         : Mayuri Patel
    @description    : This method is used to deduct Available quantity from stocks based on FIFO Method 
    @param          : invoiceItemList:- The list of Invoice Items created
    @return         : NA
    ********************************************************
    */
    public static void deductStockforInvoice(List<Sales_Invoice_Item__c> invoiceItemList){
        System.debug('invoiceItemList == ' + invoiceItemList);
        System.debug('invoiceItemList size == ' + invoiceItemList.size());
        System.debug('executeLogic : ' + StopRecursion.executeSalesInvoiceItemTrigger);
        
        if (StopRecursion.executeSalesInvoiceItemTrigger) {
            StopRecursion.executeSalesInvoiceItemTrigger = false;
            Set<Id> productIds = new Set<Id>();
            
            // Collect product IDs from invoice items
            for (Sales_Invoice_Item__c invoiceItem : invoiceItemList) {
                if (invoiceItem.Product__c != null) {
                    productIds.add(invoiceItem.Product__c);
                }
            }
            
            if (!productIds.isEmpty()) {
                System.debug('productIds === ' + productIds);
                
                // Query all stocks for these products, ordered by entry date (FIFO)
                List<Stock__c> stocks = [SELECT Id, Name,Product__c, Available_Quantity__c, Intial_Stock__c, Batch_Number__c,Price__c, 
                                         Fixed_Price_Item__c,Sold_Qty__c, Blocked_Quantity__c, Replaced_Quantity__c, CreatedDate
                                         FROM Stock__c 
                                         WHERE Product__c IN :productIds and Stock_Type__c = 'New' AND Manufacturing_Date__c != null AND Price__c != null 
                                         AND Available_Quantity__c > 0 and OwnerId=:UserInfo.getUserId() 
                                         ORDER BY Product__c, CreatedDate ASC];
                
                System.debug('stocks : ' + stocks);
                System.debug('stocks count: ' + stocks.size());
                
                // Map to hold the remaining quantities to be deducted for each product
                Map<String, Decimal> productQuantitiesToDeduct = new Map<String, Decimal>();
                // Map to store the stock IDs and numbers to be added to each Sales_Invoice_Item__c
            Map<Id, String> stockIdMap = new Map<Id, String>();
            Map<Id, String> stockNumberMap = new Map<Id, String>();
                
                // Initialize the map with the quantities from the invoice items
                for (Sales_Invoice_Item__c invoiceItem : invoiceItemList) {
                    if (invoiceItem.Quantity__c != null) {
                        if (productQuantitiesToDeduct.containsKey(invoiceItem.Product__c + invoiceItem.Stock_Price__c.toString())) {
                            productQuantitiesToDeduct.put(invoiceItem.Product__c + invoiceItem.Stock_Price__c.toString(), productQuantitiesToDeduct.get(invoiceItem.Product__c + invoiceItem.Stock_Price__c.toString()) + invoiceItem.Quantity__c);
                        } else {
                            productQuantitiesToDeduct.put(invoiceItem.Product__c + invoiceItem.Stock_Price__c.toString(), invoiceItem.Quantity__c);
                        }
                    
                    }
                }
                
                // Deduct quantities from stocks based on FIFO
                List<Stock__c> stocksToUpdate = new List<Stock__c>();
               // List<Sales_Invoice_Item__c> invoiceItemsToUpdate = new List<Sales_Invoice_Item__c>();
                
                for (Stock__c stock : stocks) {
                    if (productQuantitiesToDeduct.containsKey(stock.Product__c + stock.Price__c.toString()) && stock.Available_Quantity__c > 0) {
                        Decimal quantityToDeduct = productQuantitiesToDeduct.get(stock.Product__c + stock.Price__c.toString());
                        Decimal quantityDeducted = Math.min(stock.Available_Quantity__c, quantityToDeduct);
                        stock.Available_Quantity__c -= quantityDeducted;
                        // Update Sold_Qty__c field
                        stock.Sold_Qty__c = (stock.Sold_Qty__c != null) ? stock.Sold_Qty__c + quantityDeducted : quantityDeducted;
						
                        // Update stock references in the maps for Sales_Invoice_Item__c
                        for (Sales_Invoice_Item__c invoiceItem : invoiceItemList) {
                            if (invoiceItem.Product__c == stock.Product__c && invoiceItem.Stock_Price__c == stock.Price__c) {
                                // Append stock ID and batch number to the maps
                                String existingStockIds = stockIdMap.get(invoiceItem.Id);
                                String existingStockNumbers = stockNumberMap.get(invoiceItem.Id);
                                
                               stockIdMap.put(invoiceItem.Id, String.isNotBlank(existingStockIds) ? existingStockIds + ',ID_' + stock.Id : 'ID_' + stock.Id);
                                stockNumberMap.put(invoiceItem.Id, existingStockNumbers == null ? stock.Name : existingStockNumbers + ',' + stock.Name);
                                
                                break; // Move to the next invoice item as this item is updated
                            }
                        }
                        
                        productQuantitiesToDeduct.put(stock.Product__c + stock.Price__c.toString(), quantityToDeduct - quantityDeducted);
                        
                        stocksToUpdate.add(stock);
                        
                        // If all quantities for the product have been deducted, remove it from the map
                        if (productQuantitiesToDeduct.get(stock.Product__c + stock.Price__c.toString()) <= 0) {
                            productQuantitiesToDeduct.remove(stock.Product__c + stock.Price__c.toString());
                        }
                    }
                }
                 List<Sales_Invoice_Item__c> invoiceItemsToUpdate = new List<Sales_Invoice_Item__c>();
                if (!stocksToUpdate.isEmpty()) {
                    try {
                        update stocksToUpdate;
                        // Prepare Sales_Invoice_Item__c records to update with stock references
                       
                        for (Sales_Invoice_Item__c invoiceItem : invoiceItemList) {
                            Sales_Invoice_Item__c itm = new Sales_Invoice_Item__c();
                            itm.Id = invoiceItem.Id;
                            itm.Stock__c = stockIdMap.get(invoiceItem.Id).split(',')[0].split('ID_')[1];
                            itm.Stock_Ids__c = stockIdMap.get(invoiceItem.Id);
                            itm.Stock_Numbers__c = stockNumberMap.get(invoiceItem.Id);
                            invoiceItemsToUpdate.add(itm);
                        }
                        
                        if (!invoiceItemsToUpdate.isEmpty()) {
                            update invoiceItemsToUpdate; // Perform update outside the trigger context
                        }
                        
                    } catch (System.Exception ex) {
                            ExceptionHandler.addLog(ex, String.valueOf(stockIdMap));
                        ExceptionHandler.addLog(ex, String.valueOf(stocksToUpdate));
                        ExceptionHandler.addLog(ex, String.valueOf(invoiceItemsToUpdate));
                    }
                }
                
               /* if(invoiceItemsToUpdate.size() > 0){
                    try {
                        update invoiceItemsToUpdate;
                    } catch (System.Exception ex) {
                        ExceptionHandler.addLog(ex, String.valueOf(invoiceItemsToUpdate));
                    }
                }*/
                updateStockHistory(invoiceItemList, 'new');
            }
        }
    }
    
    
    /*@Autor -Nanma update pending amount salesinvoice*/
    @invocableMethod
    public static void callSendToSAPout(list<Id> recordIds){
        if(recordIds.size() > 0)  
            SAPsend_TriggerHandler.sendToSAPoutCall(recordIds,'OutStandingInv','Receipt__c');
        
    }
}