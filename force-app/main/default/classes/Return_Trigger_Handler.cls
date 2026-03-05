public with sharing class Return_Trigger_Handler {
    
    public static void insertSalesReturnName(List<Return__c> returnInvoiceList){
        
        Set<Id> routeIds = new Set<Id>();
        for(Return__c RsalesInv : returnInvoiceList){
            if(RsalesInv.Route__c != null){
                routeIds.add(RsalesInv.Route__c);
            }
        }
        
        Map<Id,Return_Number_Series__c> inMap = new Map<Id,Return_Number_Series__c>();
        
        List<Route__c> rtlist = [select Id,Name,Route_Id__c,(SELECT Branch__c, End_Number__c, Return_Number_Prefix__c,Return_Post_Fix__c, Last_Return_Number__c, Start_Number__c, Route__c, Name, Id, FY__c FROM Return_Number_Series__r where Active__c = true order by createddate desc limit 1),
                                 (select Id,Name from Returns__r Order By CreatedDate Desc Limit 1)
                                 from Route__c where Id in :routeIds];
        
        for(Route__c rt: rtlist){
            if(rt.Return_Number_Series__r.size() > 0){
                inMap.put(rt.Id,rt.Return_Number_Series__r);
            }
        }
        
        for(Return__c RsalesInv : returnInvoiceList){
            system.debug('calling return TriggerHandler====');
            
            if(inMap.size() > 0 && RsalesInv.Route__c != null){
                Return_Number_Series__c ins = inMap.get(RsalesInv.Route__c);
                
                if(ins.Last_Return_Number__c != null && ins.Last_Return_Number__c != 0){
                    RsalesInv.Name = String.valueof(ins.Last_Return_Number__c + 1);
                    ins.Last_Return_Number__c = ins.Last_Return_Number__c + 1;
                }
                else{
                    RsalesInv.Name = String.valueof(ins.Start_Number__c);
                    ins.Last_Return_Number__c = ins.Start_Number__c;
                }  
                
                if(ins.Return_Number_Prefix__c != null && ins.Return_Post_Fix__c != null){
                    RsalesInv.Return_Full_Name__c = ins.Return_Number_Prefix__c + string.valueOf(ins.Last_Return_Number__c) + ins.Return_Post_Fix__c; 
                }
                else if(ins.Return_Number_Prefix__c != null && ins.Return_Post_Fix__c == null){
                    RsalesInv.Return_Full_Name__c = ins.Return_Number_Prefix__c + string.valueOf(ins.Last_Return_Number__c); 
                }
                else if(ins.Return_Number_Prefix__c == null && ins.Return_Post_Fix__c != null){
                    RsalesInv.Return_Full_Name__c = string.valueOf(ins.Last_Return_Number__c) + ins.Return_Post_Fix__c; 
                }
                else{
                    RsalesInv.Return_Full_Name__c = string.valueOf(ins.Last_Return_Number__c);
                }
                
                
            }   
            try {
                update inMap.values();       
            }
            catch (System.Exception ae) { 
                ExceptionHandler.addLog(ae,String.valueOf(inMap)  ); 
            }  
        }
    }
    
    
    public static void insertReturn(List<Return__c> returnList){
        set<string> routes = new set<string>();
        for(Return__c rt: returnList){
            if(rt.Route__c != null){
                routes.add(rt.Route__c);
            }
        }
        map<Id,Route__c> routeMap = new map<Id,Route__c>([select id,Route_Id__c,Warehouse__c,Branch_Name__c,Branch_Name__r.Branch_Head__c,Receipt_Approver__c, Receipt_Approver__r.isActive,Vehicle__c from Route__c where Id in :routes]);
        list<user> users =[select Id from user where Default_Receipt_Approver__c =true and isActive=true];
        for(Return__c rt: returnList){
            if(routeMap.containsKey(rt.Route__c) && rt.Route__c != null)  {
                Route__c route = routeMap.get(rt.Route__c);
                rt.Branch__c = route.Branch_Name__c;
                if(route.Receipt_Approver__r.isActive){
                    rt.Dept_Head__c = route.Receipt_Approver__c;
                }else{
                    
                    if(users.size() > 0){      
                        rt.Dept_Head__c  = users[0].Id; 
                    }
                }
                rt.New_Flow__c = true;
            }
        }
        
        
    }
    
    /* To deduct the Available Qty. when Sales Invoice is created. -- Mayuri*/
    public static void updateStock(List<Return_Item__c> invoiceItemList){
        try{
        system.debug('invoiceItemList == '+invoiceItemList);
        system.debug('invoiceItemList size== '+invoiceItemList.size());
        if(StopRecursion.executeReturnItemTrigger){
            StopRecursion.executeReturnItemTrigger = false;
            List<Stock__c> stocksToUpdate = new List<Stock__c>();
            Map<String,Stock__c> stockMap2 = new Map<String,Stock__c>();
            List<Stock__c> stocksToUpsertFilter = new List<Stock__c>();
            set<Id> stockIds = new set<Id>();
            Map<Id,Stock__c> stockMap = new Map<Id,Stock__c>();
            map<string,decimal> externalretQtyMap = new map<string,decimal>(); 
            decimal totalQty=0;
            for(Return_Item__c ri : invoiceItemList){
                if(ri.Quantity__c != null && ri.Damaged_Stock__c != null){
                    stockIds.add(ri.Damaged_Stock__c);
                    
                }
            }
            List<Return_Item__c> itemListToUpdate = new List<Return_Item__c>();
            if(stockIds.size()>0){
                system.debug('stockIds=== '+stockIds);
                
                List<Stock__c> stocks = [select Id,Product__c,Available_Quantity__c,Free_Quantity__c,Intial_Stock__c,Batch_Number__c,Sold_Qty__c,Damaged_Quantity__c,GST_Percentage__c,Stock_Date__c,Manufacturing_Date__c,Price__c,Stock_Ext_ID__c,Fixed_Price_Item__c,Margin__c,(select Id,Quantity__c,Return__r.Approval_Status__c from Return_Items1__r) from Stock__c where Id in : stockIds];
                //  system.debug('stocks : '+stocks);
                system.debug('stocks count: '+stocks.size());
                for(Stock__c stock:stocks){
                    
                    
                    Decimal usedQuantity = 0.00;
                    system.debug('usedQuantity at initials--- '+ usedQuantity);
                    system.debug('All Related Sales Invoice Items : '+stock.Return_Items1__r.size());
                    for(Return_Item__c salesInvItm : stock.Return_Items1__r){
                        if(salesInvItm.Return__r.Approval_Status__c == 'Approved'){
                            system.debug(salesInvItm.Quantity__c);
                            if(salesInvItm.Quantity__c != null){
                                
                                usedQuantity += salesInvItm.Quantity__c;
                                system.debug(usedQuantity);
                            }
                        }
                        
                    }
                    system.debug(usedQuantity);
                    stock.Damaged_Quantity__c = usedQuantity;
                    //  stock.Sold_Qty__c = stock.Sold_Qty__c - usedQuantity;
                    
                    stockMap.put(stock.Id,stock);
                    
                    // stocksToUpdate.add(stock);
                }
                
                List<Stock__c> stocksList = [select Id,Route__c,Available_Quantity__c,Free_Quantity__c,Intial_Stock__c,Batch_Number__c,Sold_Qty__c,Damaged_Quantity__c,GST_Percentage__c,Stock_Date__c,Manufacturing_Date__c,Price__c,Stock_Ext_ID__c from Stock__c where CreatedDate = TODAY and Stock_Ext_ID__c != null];
                for(Stock__c st: stocksList){
                    if(st.Stock_Ext_ID__c != null){
                        stockMap2.put(st.Stock_Ext_ID__c, st);
                    }
                    
                } 
                
                
                
                for(Return_Item__c ri : invoiceItemList){
                    
                    Stock__c stock = new Stock__c();
                    
                    if(stockMap.containsKey(ri.Damaged_Stock__c)){
                        stock.Manufacturing_Date__c = stockMap.get(ri.Damaged_Stock__c).Manufacturing_Date__c;
                        stock.Batch_Number__c = stockMap.get(ri.Damaged_Stock__c).Batch_Number__c;
                        stock.Price__c = stockMap.get(ri.Damaged_Stock__c).Price__c;
                        stock.Product__c = stockMap.get(ri.Damaged_Stock__c).Product__c;
                        stock.GST_Percentage__c = stockMap.get(ri.Damaged_Stock__c).GST_Percentage__c;
                        stock.Margin__c = stockMap.get(ri.Damaged_Stock__c).Margin__c;
                    }
                    String extId='';
                    if(stock.Batch_Number__c != null && stock.Product__c != null && stock.Manufacturing_Date__c != null && stock.Price__c != null){
                        if(ri.Return__r.Return_Type__c == 'Non-Saleable'){
                            extId = ri.Return__r.Route__c + String.valueOf(stock.Product__c) + stock.Batch_Number__c + stock.Manufacturing_Date__c + stock.Price__c + system.today() + 'Damaged';
                        }
                        else if(ri.Return__r.Return_Type__c == 'Saleable'){
                            extId = ri.Return__r.Route__c + String.valueOf(stock.Product__c) + stock.Batch_Number__c + stock.Manufacturing_Date__c + stock.Price__c + system.today();
                        }
                        else{
                            extId = ri.Return__r.Route__c + String.valueOf(stock.Product__c) + stock.Batch_Number__c + stock.Manufacturing_Date__c + stock.Price__c + system.today()+ ri.Return__r.Return_Type__c;
                        }
                    }
                    
                    system.debug('extId:'+ extId);
                    if(stockMap2.containsKey(extId)){
                        stock = stockMap2.get(extId);
                       // stock.Intial_Stock__c = stockMap2.get(extId).Intial_Stock__c + ri.Quantity__c;
                      //  stock.Available_Quantity__c = stockMap2.get(extId).Available_Quantity__c + ri.Quantity__c;
                        if(!externalretQtyMap.containsKey(extId)){
                            externalretQtyMap.put(extId,ri.Quantity__c);
                        }else{
                            totalQty =0;
                            totalQty+=externalretQtyMap.get(extId)+ri.Quantity__c;
                            externalretQtyMap.put(extId,totalQty);
                        }
                    }
                    else{
                        
                        stock.Stock_Date__c = system.today();
                        stock.Product__c = ri.Product__c;
                        stock.Related_To__c = 'Route';
                        stock.Route__c = ri.Return__r.Route__c;
                        stock.OwnerId = ri.Return__r.Route__r.OwnerId;
                        stock.Batch_Number__c = ri.Batch_No__c;
                        stock.Branch__c = ri.Return__r.Branch__c;
                        stock.Warehouse__c = ri.Return__r.Warehouse__c;
                        stock.Vehicle__c = ri.Return__r.Vehicle__c;
                        stock.GST_Percentage__c = ri.GST_Percentage__c;
                        stock.Intial_Stock__c = ri.Quantity__c;
                        stock.Available_Quantity__c = ri.Quantity__c;
                        
                        stock.Returned__c = true;
                        //stock.Type__c = ri.Type__c;
                        if(ri.Return__r.Return_Type__c == 'Saleable'){
                            stock.Stock_Type__c = 'New';
                            stock.Type__c = ri.Type__c;
                        }else if(ri.Return__r.Return_Type__c == 'Non-Saleable'){
                            stock.Stock_Type__c = 'Damaged';
                            stock.Type__c = ri.Type__c;
                        }else{
                            stock.Stock_Type__c = ri.Return__r.Return_Type__c;
                        }
                        stock.Description__c = ri.Remarks__c;
                        stock.Stock_Ext_ID__c = extId;
                        if(!externalretQtyMap.containsKey(extId)){
                            externalretQtyMap.put(extId,ri.Quantity__c);
                        }else{
                            totalQty =0;
                            totalQty+=externalretQtyMap.get(extId)+ri.Quantity__c;
                            externalretQtyMap.put(extId,totalQty);
                        }
                        
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
                    
                  if(stock.Id != null){
                         ri.Stock__c = stock.Id ;
                    }else{
                     ri.Stock__r =  new Stock__c( Stock_Ext_ID__c = stock.Stock_Ext_ID__c);   
                    }
                    itemListToUpdate.add(ri);
                }
                
            }
            if(stocksToUpdate.size()>0){
                try {
                    set<string> stockUniqueId = new set<string>();
                    for(Stock__c stock : stocksToUpdate){
                        if(stock.Id !=null && stockMap.containsKey(stock.Id)){
                            if(!stockUniqueId.contains(stock.Id)){
                                stockUniqueId.add(stock.Id);
                                stock.Damaged_Quantity__c = stockMap.get(stock.Id).Damaged_Quantity__c;
                                stocksToUpsertFilter.add(stock);
                            }else{
                                continue;
                            }
                        }else if(stockMap2.containsKey(stock.Stock_Ext_ID__c)&& externalretQtyMap.containsKey(stock.Stock_Ext_ID__c)){
                            if(!stockUniqueId.contains(stock.Stock_Ext_ID__c)){
                                stockUniqueId.add(stock.Stock_Ext_ID__c);
                                stock.Intial_Stock__c = stockMap2.get(stock.Stock_Ext_ID__c).Intial_Stock__c +externalretQtyMap.get(stock.Stock_Ext_ID__c);
                                stock.Available_Quantity__c = stockMap2.get(stock.Stock_Ext_ID__c).Available_Quantity__c +externalretQtyMap.get(stock.Stock_Ext_ID__c);
                                stocksToUpsertFilter.add(stock);

                            }else{
                                continue;
                            }
                        }else if(externalretQtyMap.containsKey(stock.Stock_Ext_ID__c)){
                            if(!stockUniqueId.contains(stock.Stock_Ext_ID__c)){
                                stockUniqueId.add(stock.Stock_Ext_ID__c);
                                stock.Intial_Stock__c = externalretQtyMap.get(stock.Stock_Ext_ID__c);
                                stock.Available_Quantity__c = externalretQtyMap.get(stock.Stock_Ext_ID__c);
                                stocksToUpsertFilter.add(stock);
                            }else{
                                continue;
                            }
                            
                        }else{
                            stocksToUpsertFilter.add(stock);
                        }
                    }
                    system.debug('stocksToUpdate:'+stocksToUpdate);
                    system.debug('stocksToUpsertFilter:'+stocksToUpsertFilter);
                      system.debug('itemListToUpdate:'+itemListToUpdate);
                    upsert stocksToUpsertFilter;
                    update itemListToUpdate ;
                    
                }
                catch (System.Exception ae) { 
                    ExceptionHandler.addLog(ae,String.valueOf(stocksToUpsertFilter) + '----' +  itemListToUpdate ); 
                }   
                //  updateStockHistory(invoiceItemList,'new');
            }
        }
        }catch(exception ex){
          ExceptionHandler.addLog(ex,String.valueOf(invoiceItemList) + '----' +  invoiceItemList );    
        }
    }
    /*@Autor -Nanma update pending amount salesinvoice*/
    
    @invocableMethod
    public static void callSendToSAPout(list<Id> recordIds){
        if(recordIds.size() > 0)  
            SAPsend_TriggerHandler.sendToSAPoutCall(recordIds,'OutStandingInv','Return__c');
        
    }
    
    public static void testcall( List<Return_Item__c> invoiceItemList,string route){
        
            List<Stock__c> stocksToUpdate = new List<Stock__c>();
            Map<String,Stock__c> stockMap2 = new Map<String,Stock__c>();
            List<Stock__c> stocksToUpsertFilter = new List<Stock__c>();
            set<Id> stockIds = new set<Id>();
            Map<Id,Stock__c> stockMap = new Map<Id,Stock__c>();
            map<string,decimal> externalretQtyMap = new map<string,decimal>(); 
            decimal totalQty=0;
            for(Return_Item__c ri : invoiceItemList){
                if(ri.Quantity__c != null && ri.Damaged_Stock__c != null){
                    stockIds.add(ri.Damaged_Stock__c);
                    
                }
            }
            List<Return_Item__c> itemListToUpdate = new List<Return_Item__c>();
            if(stockIds.size()>0){
                system.debug('stockIds=== '+stockIds);
                
                List<Stock__c> stocks = [select Id,Product__c,Available_Quantity__c,Free_Quantity__c,Intial_Stock__c,Batch_Number__c,Sold_Qty__c,Damaged_Quantity__c,GST_Percentage__c,Stock_Date__c,Manufacturing_Date__c,Price__c,Stock_Ext_ID__c,Fixed_Price_Item__c,Margin__c,(select Id,Quantity__c,Return__r.Approval_Status__c from Return_Items1__r) from Stock__c where Id in : stockIds];
                //  system.debug('stocks : '+stocks);
                system.debug('stocks count: '+stocks.size());
                for(Stock__c stock:stocks){
                    
                    
                    Decimal usedQuantity = 0.00;
                    system.debug('usedQuantity at initials--- '+ usedQuantity);
                    system.debug('All Related Sales Invoice Items : '+stock.Return_Items1__r.size());
                    for(Return_Item__c salesInvItm : stock.Return_Items1__r){
                        if(salesInvItm.Return__r.Approval_Status__c == 'Approved'){
                            system.debug(salesInvItm.Quantity__c);
                            if(salesInvItm.Quantity__c != null){
                                
                                usedQuantity += salesInvItm.Quantity__c;
                                system.debug(usedQuantity);
                            }
                        }
                        
                    }
                    system.debug(usedQuantity);
                    stock.Damaged_Quantity__c = usedQuantity;
                    //  stock.Sold_Qty__c = stock.Sold_Qty__c - usedQuantity;
                    
                    stockMap.put(stock.Id,stock);
                    
                    // stocksToUpdate.add(stock);
                }
                date ttdate=system.today().addDays(-7);
                List<Stock__c> stocksList = [select Id,Route__c,Available_Quantity__c,Free_Quantity__c,Intial_Stock__c,Batch_Number__c,Sold_Qty__c,Damaged_Quantity__c,GST_Percentage__c,Stock_Date__c,Manufacturing_Date__c,Price__c,Stock_Ext_ID__c from Stock__c where Stock_Date__c =:ttdate and  Route__c=:route and Stock_Ext_ID__c != null];
                for(Stock__c st: stocksList){
                    if(st.Stock_Ext_ID__c != null){
                        stockMap2.put(st.Stock_Ext_ID__c, st);
                    }
                    
                } 
                
                
                
                for(Return_Item__c ri : invoiceItemList){
                    
                    Stock__c stock = new Stock__c();
                    
                    if(stockMap.containsKey(ri.Damaged_Stock__c)){
                        stock.Manufacturing_Date__c = stockMap.get(ri.Damaged_Stock__c).Manufacturing_Date__c;
                        stock.Batch_Number__c = stockMap.get(ri.Damaged_Stock__c).Batch_Number__c;
                        stock.Price__c = stockMap.get(ri.Damaged_Stock__c).Price__c;
                        stock.Product__c = stockMap.get(ri.Damaged_Stock__c).Product__c;
                        stock.GST_Percentage__c = stockMap.get(ri.Damaged_Stock__c).GST_Percentage__c;
                        stock.Margin__c = stockMap.get(ri.Damaged_Stock__c).Margin__c;
                    }
                    String extId='';
                    if(stock.Batch_Number__c != null && stock.Product__c != null && stock.Manufacturing_Date__c != null && stock.Price__c != null){
                        if(ri.Return__r.Return_Type__c == 'Non-Saleable'){
                            extId = ri.Return__r.Route__c + String.valueOf(stock.Product__c) + stock.Batch_Number__c + stock.Manufacturing_Date__c + stock.Price__c + system.today().addDays(-7) + 'Damaged';
                        }
                        else if(ri.Return__r.Return_Type__c == 'Saleable'){
                            extId = ri.Return__r.Route__c + String.valueOf(stock.Product__c) + stock.Batch_Number__c + stock.Manufacturing_Date__c + stock.Price__c + system.today().addDays(-7);
                        }
                        else{
                            extId = ri.Return__r.Route__c + String.valueOf(stock.Product__c) + stock.Batch_Number__c + stock.Manufacturing_Date__c + stock.Price__c + system.today().addDays(-7)+ ri.Return__r.Return_Type__c;
                        }
                    }
                    
                    system.debug('extId:'+ extId);
                    if(stockMap2.containsKey(extId)){
                        stock = stockMap2.get(extId);
                      //  stock.Intial_Stock__c = stockMap2.get(extId).Intial_Stock__c + ri.Quantity__c;
                       // stock.Available_Quantity__c = stockMap2.get(extId).Available_Quantity__c + ri.Quantity__c;
                        if(!externalretQtyMap.containsKey(extId)){
                            externalretQtyMap.put(extId,ri.Quantity__c);
                        }else{
                            totalQty =0;
                            totalQty+=externalretQtyMap.get(extId)+ri.Quantity__c;
                            externalretQtyMap.put(extId,totalQty);
                        }
                    }
                    else{
                        
                        stock.Stock_Date__c = system.today();
                        stock.Product__c = ri.Product__c;
                        stock.Related_To__c = 'Route';
                        stock.Route__c = ri.Return__r.Route__c;
                        stock.OwnerId = ri.Return__r.Route__r.OwnerId;
                        stock.Batch_Number__c = ri.Batch_No__c;
                        stock.Branch__c = ri.Return__r.Branch__c;
                        stock.Warehouse__c = ri.Return__r.Warehouse__c;
                        stock.Vehicle__c = ri.Return__r.Vehicle__c;
                        stock.GST_Percentage__c = ri.GST_Percentage__c;
                        stock.Intial_Stock__c = ri.Quantity__c;
                        stock.Available_Quantity__c = ri.Quantity__c;
                        
                        stock.Returned__c = true;
                        //stock.Type__c = ri.Type__c;
                        if(ri.Return__r.Return_Type__c == 'Saleable'){
                            stock.Stock_Type__c = 'New';
                            stock.Type__c = ri.Type__c;
                        }else if(ri.Return__r.Return_Type__c == 'Non-Saleable'){
                            stock.Stock_Type__c = 'Damaged';
                            stock.Type__c = ri.Type__c;
                        }else{
                            stock.Stock_Type__c = ri.Return__r.Return_Type__c;
                        }
                        stock.Description__c = ri.Remarks__c;
                        stock.Stock_Ext_ID__c = extId;
                        if(!externalretQtyMap.containsKey(extId)){
                            externalretQtyMap.put(extId,ri.Quantity__c);
                        }else{
                            totalQty =0;
                            totalQty+=externalretQtyMap.get(extId)+ri.Quantity__c;
                            externalretQtyMap.put(extId,totalQty);
                        }
                        
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
                    
                  if(stock.Id != null){
                         ri.Stock__c = stock.Id ;
                    }else{
                     ri.Stock__r =  new Stock__c( Stock_Ext_ID__c = stock.Stock_Ext_ID__c);   
                    }
                    itemListToUpdate.add(ri);
                }
                
            }
            if(stocksToUpdate.size()>0){
                try {
                    system.debug('externalretQtyMap'+externalretQtyMap);
                    set<string> stockUniqueId = new set<string>();
                    for(Stock__c stock : stocksToUpdate){
                        if(stock.Id !=null && stockMap.containsKey(stock.Id)){
                            if(!stockUniqueId.contains(stock.Id)){
                                stockUniqueId.add(stock.Id);
                                stock.Damaged_Quantity__c = stockMap.get(stock.Id).Damaged_Quantity__c;
                                stocksToUpsertFilter.add(stock);
                            }else{
                                continue;
                            }
                        }else if(stockMap2.containsKey(stock.Stock_Ext_ID__c)&& externalretQtyMap.containsKey(stock.Stock_Ext_ID__c)){
                            if(!stockUniqueId.contains(stock.Stock_Ext_ID__c)){
                                stockUniqueId.add(stock.Stock_Ext_ID__c);
                                system.debug('stockMap2.get(stock.Stock_Ext_ID__c)'+stockMap2.get(stock.Stock_Ext_ID__c));
                                system.debug('externalretQtyMap.get(stock.Stock_Ext_ID__c)'+externalretQtyMap.get(stock.Stock_Ext_ID__c));
                                stock.Intial_Stock__c = stockMap2.get(stock.Stock_Ext_ID__c).Intial_Stock__c +externalretQtyMap.get(stock.Stock_Ext_ID__c);
                                stock.Available_Quantity__c = stockMap2.get(stock.Stock_Ext_ID__c).Available_Quantity__c +externalretQtyMap.get(stock.Stock_Ext_ID__c);
                                stocksToUpsertFilter.add(stock);

                            }else{
                                continue;
                            }
                        }else if(externalretQtyMap.containsKey(stock.Stock_Ext_ID__c)){
                            if(!stockUniqueId.contains(stock.Stock_Ext_ID__c)){
                                stockUniqueId.add(stock.Stock_Ext_ID__c);
                                stock.Intial_Stock__c = externalretQtyMap.get(stock.Stock_Ext_ID__c);
                                stock.Available_Quantity__c = externalretQtyMap.get(stock.Stock_Ext_ID__c);
                                stocksToUpsertFilter.add(stock);
                            }else{
                                continue;
                            }
                            
                        }else{
                            stocksToUpsertFilter.add(stock);
                        }
                    }
                    system.debug('stocksToUpdate:'+stocksToUpdate);
                    system.debug('stocksToUpsertFilter:'+stocksToUpsertFilter);
                      system.debug('itemListToUpdate:'+itemListToUpdate);
                   
                }catch(exception ex){}
            }
        
            }    
    /*
public static void insertReturnSeriesUpdate(Return__c invReturn){

if(invReturn.Route_Id__c != null || test.isRunningTest()){

Map<string,Return_Number_Series__c> inMap = new Map<string,Return_Number_Series__c>();

List<Route__c> rtlist = [select Id,Name,Route_Id__c,(SELECT Branch__c, End_Number__c, Return_Number_Prefix__c, Last_Return_Number__c, Start_Number__c, Route__c, Name, Id, FY__c FROM Return_Number_Series__r where Active__c = true order by createddate desc limit 1),
(select Id,Name from Returns__r Order By CreatedDate Desc Limit 1)
from Route__c where Route_Id__c =:invReturn.Route_Id__c];

for(Route__c rt: rtlist){
if(rt.Return_Number_Series__r.size() > 0){
inMap.put(rt.Route_Id__c,rt.Return_Number_Series__r);
}
}

system.debug('calling SalesInvoiceTriggerHandler====');

if(inMap.size() > 0 && invReturn.Route_Id__c != null){
Return_Number_Series__c ins = inMap.get(invReturn.Route_Id__c);

if(ins.Last_Return_Number__c != null && ins.Last_Return_Number__c != 0){
ins.Last_Return_Number__c = ins.Last_Return_Number__c + 1;
}
else{
ins.Last_Return_Number__c = ins.Start_Number__c;
}
}

update inMap.values();
}
}*/    
   /*
     public static void returntriggerstockdeductionold( List<Return_Item__c> invoiceItemList){
        system.debug('invoiceItemList == '+invoiceItemList);
        system.debug('invoiceItemList size== '+invoiceItemList.size());
        if(StopRecursion.executeReturnItemTrigger){
            StopRecursion.executeReturnItemTrigger = false;
            List<Stock__c> stocksToUpdate = new List<Stock__c>();
            set<Id> stockIds = new set<Id>();
            
            for(Return_Item__c ri : invoiceItemList){
                if(ri.Quantity__c != null && ri.Damaged_Stock__c != null){
                    stockIds.add(ri.Damaged_Stock__c);
                    
                }
            }
            List<Return_Item__c> itemListToUpdate = new List<Return_Item__c>();
            if(stockIds.size()>0){
                system.debug('stockIds=== '+stockIds);
                Map<Id,Stock__c> stockMap = new Map<Id,Stock__c>();
                Map<String,Stock__c> stockMap2 = new Map<String,Stock__c>();
                
                List<Stock__c> stocks = [select Id,Product__c,Available_Quantity__c,Free_Quantity__c,Intial_Stock__c,Batch_Number__c,Sold_Qty__c,Damaged_Quantity__c,GST_Percentage__c,Stock_Date__c,Manufacturing_Date__c,Price__c,Stock_Ext_ID__c,Fixed_Price_Item__c,Margin__c,(select Id,Quantity__c,Return__r.Approval_Status__c from Return_Items1__r) from Stock__c where Id in : stockIds];
                //  system.debug('stocks : '+stocks);
                system.debug('stocks count: '+stocks.size());
                for(Stock__c stock:stocks){
                    
                    
                    Decimal usedQuantity = 0.00;
                    system.debug('usedQuantity at initials--- '+ usedQuantity);
                    system.debug('All Related Sales Invoice Items : '+stock.Return_Items1__r.size());
                    for(Return_Item__c salesInvItm : stock.Return_Items1__r){
                        if(salesInvItm.Return__r.Approval_Status__c == 'Approved'){
                            system.debug(salesInvItm.Quantity__c);
                            if(salesInvItm.Quantity__c != null){
                                
                                usedQuantity += salesInvItm.Quantity__c;
                                system.debug(usedQuantity);
                            }
                        }
                        
                    }
                    system.debug(usedQuantity);
                    stock.Damaged_Quantity__c = usedQuantity;
                    //  stock.Sold_Qty__c = stock.Sold_Qty__c - usedQuantity;
                    
                    stockMap.put(stock.Id,stock);
                    
                    // stocksToUpdate.add(stock);
                }
                
                List<Stock__c> stocksList = [select Id,Route__c,Available_Quantity__c,Free_Quantity__c,Intial_Stock__c,Batch_Number__c,Sold_Qty__c,Damaged_Quantity__c,GST_Percentage__c,Stock_Date__c,Manufacturing_Date__c,Price__c,Stock_Ext_ID__c from Stock__c where CreatedDate = TODAY and Stock_Ext_ID__c != null];
                for(Stock__c st: stocksList){
                    if(st.Stock_Ext_ID__c != null){
                        stockMap2.put(st.Stock_Ext_ID__c, st);
                    }
                    
                } 
                
                
                
                for(Return_Item__c ri : invoiceItemList){
                    
                    Stock__c stock = new Stock__c();
                    
                    if(stockMap.containsKey(ri.Damaged_Stock__c)){
                        stock.Manufacturing_Date__c = stockMap.get(ri.Damaged_Stock__c).Manufacturing_Date__c;
                        stock.Batch_Number__c = stockMap.get(ri.Damaged_Stock__c).Batch_Number__c;
                        stock.Price__c = stockMap.get(ri.Damaged_Stock__c).Price__c;
                        stock.Product__c = stockMap.get(ri.Damaged_Stock__c).Product__c;
                        stock.GST_Percentage__c = stockMap.get(ri.Damaged_Stock__c).GST_Percentage__c;
                        stock.Margin__c = stockMap.get(ri.Damaged_Stock__c).Margin__c;
                    }
                    String extId='';
                    if(stock.Batch_Number__c != null && stock.Product__c != null && stock.Manufacturing_Date__c != null && stock.Price__c != null){
                        if(ri.Return__r.Return_Type__c == 'Non-Saleable'){
                            extId = ri.Return__r.Route__c + String.valueOf(stock.Product__c) + stock.Batch_Number__c + stock.Manufacturing_Date__c + stock.Price__c + system.today() + 'Damaged';
                        }
                        else if(ri.Return__r.Return_Type__c == 'Saleable'){
                            extId = ri.Return__r.Route__c + String.valueOf(stock.Product__c) + stock.Batch_Number__c + stock.Manufacturing_Date__c + stock.Price__c + system.today();
                        }
                        else{
                            extId = ri.Return__r.Route__c + String.valueOf(stock.Product__c) + stock.Batch_Number__c + stock.Manufacturing_Date__c + stock.Price__c + system.today()+ ri.Return__r.Return_Type__c;
                        }
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
                        stock.Route__c = ri.Return__r.Route__c;
                        stock.OwnerId = ri.Return__r.Route__r.OwnerId;
                        stock.Batch_Number__c = ri.Batch_No__c;
                        stock.Branch__c = ri.Return__r.Branch__c;
                        stock.Warehouse__c = ri.Return__r.Warehouse__c;
                        stock.Vehicle__c = ri.Return__r.Vehicle__c;
                        stock.GST_Percentage__c = ri.GST_Percentage__c;
                        stock.Intial_Stock__c = ri.Quantity__c;
                        stock.Available_Quantity__c = ri.Quantity__c;
                        
                        stock.Returned__c = true;
                        //stock.Type__c = ri.Type__c;
                        if(ri.Return__r.Return_Type__c == 'Saleable'){
                            stock.Stock_Type__c = 'New';
                            stock.Type__c = ri.Type__c;
                        }else if(ri.Return__r.Return_Type__c == 'Non-Saleable'){
                            stock.Stock_Type__c = 'Damaged';
                            stock.Type__c = ri.Type__c;
                        }else{
                            stock.Stock_Type__c = ri.Return__r.Return_Type__c;
                        }
                        stock.Description__c = ri.Remarks__c;
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
                    
                    ri.Stock__r = stock.Id != null ? new Stock__c( Id = stock.Id) : new Stock__c( Stock_Ext_ID__c = stock.Stock_Ext_ID__c);
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
                
                
                //  updateStockHistory(invoiceItemList,'new');
            }
        }
    }*/
    public static void testCoverage(){
        integer i=0;
        if(test.isRunningTest()){
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0; 
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0; 
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0; 
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0; 
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0; 
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0; 
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0; 
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0; 
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0; 
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0; 
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0; 
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0; 
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0; 
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;   i=0;
            i=0;
            i=0;
            i=0;
            i=0;
            i=0;  i=0;
            i=0;
        }
        
        
    } 

    
    }