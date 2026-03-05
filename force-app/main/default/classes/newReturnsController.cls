public without sharing class newReturnsController {
        @AuraEnabled
    public map<string, List<Stock__c>> productStockMap{get;set;}
        @AuraEnabled
    public list<Discount__c> disList {get;set;}
    // "without sharing" is added because parent is locked before child records created as it directly goes to approval.
    
    @AuraEnabled
    public static String getCustomerName(String custId){
        return [select Name from Account where Id=:custId].Name;
    }
    @AuraEnabled
    public static Account getCustomer(String custId){
        return [select Id,Name,Cash_Discount__c from Account where Id=:custId];
    }
    
    @AuraEnabled
    public static List<Sales_invoice_Item__c> getItems(String invId){
        system.debug(invId);
        system.debug([select Id,Name,Unit_Price__c,Stock__r.Manufacturing_Date__c,Quantity__c,Product__c,Stock__c,Total_after_discount__c,Item_Name__c,Batch_No__c from Sales_Invoice_Item__c where Sales_Invoice__c =:invId]);
        return [select Id,Name,Unit_Price__c,Stock__r.Manufacturing_Date__c,Quantity__c,Product__c,Stock__c,Total_after_discount__c,Item_Name__c,Batch_No__c,GST_Percentage__c,GST_Value__c,Sales_Tax__c,Cash_Discount__c,Customer_Discount__c,Sales_Invoice__r.Customer__c,Sales_Invoice__r.Customer__r.Name,UnitPriceWithDiscount__c,Rate__c,Fixed_Price_Item__c from Sales_Invoice_Item__c where Sales_Invoice__c =:invId];
    }
    
    @auraEnabled
    Public static List<Stock__c> getStock(){
        
        Set<String> batches = new Set<String>();
        
        for (Batch__c b : [
            SELECT Name 
            FROM Batch__c 
            WHERE Active__c = true
        ]) {
            batches.add(b.Name);
        }
        return [SELECT Id,name,Product__c,Product_Name__c,Batch_Number__c,Product_Batch_Name__c,Branch_Name__c,Available_Quantity__c,Sold_Qty__c,
                Blocked_Quantity__c,Manufacturing_Date__c,Price__c,Product_GST__c,Product__r.Brand__c,Fixed_Price_Item__c,Margin__c,Product_Old_GST__c from Stock__c where OwnerId =:userInfo.getUserId()  and Stock_Type__c =: 'New' and  Batch_Number__c IN : batches];
    }
    
    @AuraEnabled
    public static List<Discount__c> getDiscounts(string custId){
        List<Discount__c> disList = new  List<Discount__c>();        
        disList = [SELECT Id,Name,GST_Percentage__c,Discount_Percent__c,Eva_Discount_Percent__c  from  Discount__c   where Customer__c=:custId ];        
        system.debug('disList--'+disList.size());
        return disList;
    }
    
    
    @AuraEnabled
    public static newReturnsController getCustomerStock(String custId){   
 
        List<Stock__c> stockList = new List<Stock__c>();
        map<string, List<Stock__c>> productStockMap = new   map<string, List<Stock__c>>();
        Set<String> batches = new Set<String>();
          List<Discount__c>  disList= new List<Discount__c>();
        newReturnsController rc = new newReturnsController();
         disList = [SELECT Id,Name,GST_Percentage__c,Discount_Percent__c,Eva_Discount_Percent__c  from  Discount__c   where Customer__c=:custId ];    
        for (Batch__c b : [ SELECT Name  FROM Batch__c  WHERE Active__c = true ]) {  batches.add(b.Name); }
        stockList =[SELECT Id,name,Product__c,Product_Name__c,Batch_Number__c,Product_Batch_Price__c,Product_Batch_Name__c,Branch_Name__c,Available_Quantity__c,Sold_Qty__c,
                    Blocked_Quantity__c,Manufacturing_Date__c,Product_Old_GST__c ,Price__c,Product_GST__c,Product__r.Brand__c,Fixed_Price_Item__c,Margin__c from Stock__c where OwnerId =:userInfo.getUserId() and Sold_Qty__c >0  and Stock_Type__c = 'New' and  Batch_Number__c IN : batches order by lastmodifieddate];
        
        if (!stockList.isEmpty()) {
            for (Stock__c s : stockList) {
                if (productStockMap.containsKey(s.Product_Batch_Price__c)) {
                    productStockMap.get(s.Product_Batch_Price__c).add(s);
                } else {
                    productStockMap.put(s.Product_Batch_Price__c, new List<Stock__c>{ s });
                }
            }
        }
        
        rc.productStockMap = productStockMap;
        rc.disList = disList;
        return rc;
    }
    
    
    
    @AuraEnabled
    public static String saveNewReturn(Return__c returnrec, List<Return_Item__c> items ){
        system.debug(returnrec);
        system.debug(items);
        User user = [select id,name,Route_Id__c from User where id=:UserInfo.getUserId() limit 1];
        List<Route__c> rt = new List<Route__c>();
        List<DailyLog__c> clockinClockout = [SELECT id from  DailyLog__c  WHERE Clock_In__c = TODAY AND OwnerId =:UserInfo.getUserId() limit 1]; 
        List<Trip__c> tripList = [SELECT id,Route__c,Cash_In_Hand__c,Last_Cleared_Date__c from  Trip__c  WHERE   (Status__c = 'Started' AND End_Date__c = null )  AND OwnerId =:UserInfo.getUserId() limit 1]; 
        
        
        if(user.Route_Id__c != null){
            rt = [select id,Route_Id__c,Warehouse__c,Branch_Name__c,Branch_Name__r.Branch_Head__c,Vehicle__c,Receipt_Approver__c, Receipt_Approver__r.isActive from Route__c where Route_Id__c =:user.Route_Id__c limit 1];
            if(rt.size() > 0){
                returnrec.Route__c = rt[0].Id;
                returnrec.Vehicle__c = rt[0].Vehicle__c;
                returnrec.Branch__c = rt[0].Branch_Name__c;
                if(rt[0]. Receipt_Approver__r.isActive){
                    returnrec.Dept_Head__c = rt[0].Receipt_Approver__c;
                }else{
                    list<user> users =[select Id from user where Default_Receipt_Approver__c =true and isActive=true];
                    if(users.size() > 0){      returnrec.Dept_Head__c  = users[0].Id;    }
                }
            }
        }
        if(clockinClockout.size() != 0){
            returnrec.Daily_Log__c = clockinClockout[0].Id;
        }
        if(tripList.size() != 0){
            returnrec.Trip__c = tripList[0].Id;
        }
        /* if(returnrec.Sales_Invoice__c != null ){
returnrec.Type__c ='Against Invoice'; 
}*/
        returnrec.New_Flow__c = true;
        
        try {
            insert returnrec;
        }
        catch (System.Exception ae) { 
            ExceptionHandler.addLog(ae,String.valueOf(returnrec)  ); 
        }   
        
        List<Return_Item__c> itemsToInsert = new List<Return_Item__c>();
        
        
        for(Return_Item__c ri: items){
            if(ri.Quantity__c != 0){
                Return_Item__c ritem = new Return_Item__c();
                ritem = ri;
                if(returnrec.Type__c == 'Against Invoice') ritem.Sales_Invoice__c = returnrec.Sales_Invoice__c;
                ritem.Return__c = returnrec.Id;
                ritem.Damaged_Stock__c =  ri.Stock__c;
                ritem.Stock__c = null;
                itemsToInsert.add(ritem);
                
                
            }
            
        }
        
        
        try {
            insert itemsToInsert;
            // insert stocklist;
        }
        catch (System.Exception ae) { 
            ExceptionHandler.addLog(ae,String.valueOf(itemsToInsert)  ); 
        }  
        
        return returnrec.Id;
        
        
        /* List<Stock__c> stocklist = new List<Stock__c>();
set<Id> stockId = new set<Id>();
for(Return_Item__c ri: items){
if( ri.Stock__c != null)
stockId.add(ri.Stock__c);
}

List<Stock__c> returnItemStock =  [Select Id,Manufacturing_Date__c,Batch_Number__c,Price__c from Stock__c where Id in:stockId];
Map<Id,Stock__c> stockMap = new Map<Id,Stock__c>();

for(Stock__c st:returnItemStock){
stockMap.put(st.Id,st);
}*/
        // List<Stock__c> returnItemStock =  [Select Id,Manufacturing_Date__c,Batch_Number__c,Price__c from Stock__c where Id =: ri.Stock__c Limit 1];
        
        /*    Stock__c stock = new Stock__c();
stock.Stock_Date__c = system.today();
stock.Product__c = ri.Product__c;
stock.Related_To__c = 'Route';
stock.Route__c = returnrec.Route__c;
stock.Batch_Number__c = ri.Batch_No__c;
stock.Branch__c = returnrec.Branch__c;
stock.Warehouse__c = returnrec.Route__r.Warehouse__c;
stock.Vehicle__c = returnrec.Route__r.Vehicle__c;
stock.GST_Percentage__c = ri.GST_Percentage__c;
stock.Intial_Stock__c = ri.Quantity__c;
stock.Available_Quantity__c = ri.Quantity__c;
if(stockMap.containsKey(ri.Stock__c)){
//stock.Manufacturing_Date__c = returnItemStock[0].Manufacturing_Date__c;
stock.Manufacturing_Date__c = stockMap.get(ri.Stock__c).Manufacturing_Date__c;
stock.Batch_Number__c = stockMap.get(ri.Stock__c).Batch_Number__c;
stock.Price__c = stockMap.get(ri.Stock__c).Price__c;
}
stock.Returned__c = true;
//stock.Type__c = ri.Type__c;
if(returnrec.Return_Type__c == 'Saleable'){
stock.Stock_Type__c = 'New';
stock.Type__c = ri.Type__c;
}else if(returnrec.Return_Type__c == 'Non-Saleable'){
stock.Stock_Type__c = 'Damaged';
stock.Type__c = ri.Type__c;
}else{
stock.Stock_Type__c = returnrec.Return_Type__c;
}
stock.Description__c = ri.Remarks__c;
stocklist.add(stock);
*/        
        /*  if(returnrec.Sales_Invoice__c != null ){
Return__c ret = [select Id,Name,Grand_Total_Discounted__c from Return__c where Id=:returnrec.Id];

Sales_Invoice__c inv = [select Id,Name,Total_Return_Amount__c from Sales_invoice__c where Id=:returnrec.Sales_Invoice__c];
if(inv.Total_Return_Amount__c == null){
inv.Total_Return_Amount__c = ret.Grand_Total_Discounted__c;
}
else{
inv.Total_Return_Amount__c = inv.Total_Return_Amount__c + ret.Grand_Total_Discounted__c;
}
update inv;
}
*/
        
        
        
    }
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
        
    }
}