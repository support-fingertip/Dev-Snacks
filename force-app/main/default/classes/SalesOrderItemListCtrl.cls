public class SalesOrderItemListCtrl {
    
    @auraEnabled
    Public static Sales_order__c getOrder(String ordId){
        return [SELECT Id,Name,Customer__r.Name,Customer__r.Cash_Discount__c,Grand_Total__c,Branch__c,Order_Date__c,Status__c,Total_GST_Amount__c,Trip__c,Route__c from Sales_order__c where id=:ordId];
    }
    
    @auraEnabled
    Public static String getOrderStatus(String ordId){
        return [SELECT Id,Name,Status__c from Sales_order__c where id=:ordId].Status__c;
    }
    
    @auraEnabled
    Public static List<Sales_order_item__c> getOrderItems(string ordId){
        system.debug('ordId=== '+ordId);
        List<Sales_order_item__c> salesOrderItemList = [SELECT Id,Name,Discount_Percent__c,Sales_order__r.Name,GST_Percentage__c,Cash_Discount__c,Customer_Discount__c,Sales_Tax__c,Stock__c,Stock__r.Available_Quantity__c,Stock__r.Blocked_Quantity__c,Product__c,Total__c,Unit_Price__c,Quantity__c,Total_after_discount__c,Product_Name__c,Stock__r.Manufacturing_Date__c,Total_Before_Tax__c,Sales_Order__r.New_Flow__c,Rate__c,Stock__r.Price__c,Fixed_Price_Item__c
                                                        from Sales_order_item__c where Sales_order__c =: ordId ];
        system.debug('salesOrderItemList=== '+salesOrderItemList);
        return salesOrderItemList;
    }
    
    @AuraEnabled
    public static Decimal getCashDiscount(string storeId) {
        return [SELECT Customer__r.Cash_Discount__c FROM Sales_order__c WHERE Id =: storeId].Customer__r.Cash_Discount__c;
    } 
    @AuraEnabled
    public static List<Discount__c> getDiscounts(string accId){
        List<Discount__c> disList = new  List<Discount__c>();        
        disList = [SELECT Id,Name,GST_Percentage__c,Discount_Percent__c,Eva_Discount_Percent__c  from  Discount__c   where Customer__c=:accId ];        
        system.debug('disList--'+disList.size());
        return disList;
    }
    
    @auraEnabled
    Public static List<Stock__c> getStock(string routeId){
        return [SELECT Id,name,Product__c,Product_Name__c,Batch_Number__c,Product_Batch_Name__c,Branch_Name__c,Available_Quantity__c,Sold_Qty__c,Product__r.Brand__c,
                Blocked_Quantity__c,Manufacturing_Date__c,Price__c,Product_GST__c,Fixed_Price_Item__c,Margin__c from Stock__c where Available_Quantity__c > 0 AND Stock_Type__c = 'New' AND Route__c = :routeId];
    }
    
    @AuraEnabled 
    public static List<String>  getBanks(){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Receipt__c.Bank_Name__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
    }
    
    
    
    @AuraEnabled
    public static String createInvoice(List<Sales_Order_Item__c>  orderItemList,string ordId,string paymentType ){
        
        system.debug(orderItemList);
        system.debug('orderItemList : '+orderItemList);
        system.debug('ordId-'+ordId); 
        system.debug('paymentType-'+paymentType); 
        
        //User user = [select id,name,Route_Id__c from User where id=:UserInfo.getUserId() limit 1];
        List<DailyLog__c> log = [SELECT id,Clock_In__c,Trip__r.Id,Clock_Out__c from DailyLog__c WHERE Clock_In__c = TODAY AND Clock_In__c!=null AND Clock_out__c = null AND OwnerId =: UserInfo.getUserId() limit 1];
        //List<Route__c> routeRecord = [select id,Route_Id__c,Warehouse__c,Branch_Name__c,Vehicle__c from Route__c where Route_Id__c =:user.Route_Id__c limit 1];
        List<Sales_Invoice__c> upsertSalesOrders = new List<Sales_Invoice__c>();
        Sales_Order__c salesOrderRec = [select id,Route__c,Customer__c,Route__r.Vehicle__c,Route__r.Branch_Name__c,Route__r.Warehouse__c from Sales_Order__c
                                        where Id =: ordId];
        
        List<Address__c> getAddress = [select Id,GST_No__c,Customer__c from Address__c where Address_Type__c =:'B' AND Customer__c =: salesOrderRec.Customer__c Limit 1];
        system.debug('getAddress== '+getAddress);
        
        Sales_Invoice__c si = new Sales_Invoice__c();
        si.Invoice_Date__c = system.today();  
        si.Customer__c = [select Customer__c from Sales_Order__c where Id=:ordId].Customer__c;
        si.Sales_Order__c = ordId;
        si.New_Flow__c = true;
        
        if(getAddress.size()>0){
            si.Gstin__c = getAddress[0].GST_No__c;
        }
        
        
        //si.Sales_Order__r.Status__c= 'Converted';
        if(salesOrderRec.Route__c != null){
            si.Route__c = salesOrderRec.Route__c; 
            si.Vehicle__c = salesOrderRec.Route__r.Vehicle__c;
            si.Branch__c = salesOrderRec.Route__r.Branch_Name__c;
            si.Warehouse__c = salesOrderRec.Route__r.Warehouse__c;
            si.Payment_Type__c = paymentType;
        }
        if(log.size() > 0){
            si.Daily_log__c = log[0].Id;
            si.Trip__c = log[0].Trip__c;
        }
        //   upsertSalesOrders.add(si);
        
        try {
            insert si;
        }
        catch (System.Exception ae) { 
           ExceptionHandler.addLog(ae,String.valueOf(si) );
        }     
            
        //database.upsert(si);
        
        list<Sales_Invoice_Item__c>upsertlst=new list<Sales_Invoice_Item__c>();
        for(Sales_Order_Item__c t:orderItemList){
            Sales_Invoice_Item__c i =new Sales_Invoice_Item__c();
            i.Total__c=t.Total__c;
            i.Total_Before_Tax__c=t.Total_Before_Tax__c;
            i.GST_Percentage__c=t.GST_Percentage__c;
            i.Sales_Tax__c = t.Sales_Tax__c;
            i.Product__c=t.Product__c;
            i.Stock__c = t.Stock__c;
            i.Quantity__c=t.Quantity__c;
            i.Rate__c=t.Rate__c;
            i.Unit_Price__c = t.Unit_Price__c;
            i.Sales_Invoice__c=si.Id;
            i.Discount_Percent__c = t.Discount_Percent__c;
            i.Customer_Discount__c = t.Customer_Discount__c;
            i.Cash_Discount__c = t.Cash_Discount__c;
            i.Total_after_discount__c = t.Total__c;
            upsertlst.add(i);
        }
        
        try {
            insert upsertlst;
        }
        catch (System.Exception ae) { 
            ExceptionHandler.addLog(ae,String.valueOf(upsertlst) );
        }   
        system.debug('upsertlst : '+upsertlst);
        system.debug('upsertlst size : '+upsertlst.size());
        
        
        Sales_Order__c salesOrder = new  Sales_Order__c();
        salesOrder.Id = ordId;
        salesOrder.Status__c = 'Converted';
        
        try {
            upsert salesOrder;
        }
        catch (System.Exception ae) { 
             ExceptionHandler.addLog(ae,String.valueOf(salesOrder) );
        } 
        //List<Sales_Invoice_Item__c> orderList =  [SELECT Id, Name, Unit_Price__c, Sales_Invoice__c, Product__c,Stock__c, Quantity__c, GST_Percentage__c, GST_Value__c, Total__c,Discount_Percent__c,Total_after_discount__c FROM Sales_Invoice_Item__c WHERE CreatedDate=TODAY  AND Sales_Invoice__r.CreatedById=:userinfo.getUserId()];
        // system.debug('orderList : '+orderItemList);
        
        // return orderList;
        return si.Id;
    }
    
    @AuraEnabled
    public static String saveReceipt(Receipt__c receipt, Decimal amt, string invId ){
        
        system.debug('receipt:' + receipt);
        
        Sales_Invoice__c inv = [select id,name,Customer__c,Amount_Received__c,Invoice_Date__c,Grand_Total_Discounted__c,Invoice_Total__c,Pending_Amount__c,Pending_Amount_SAP__c from Sales_Invoice__c where Id=:invId];
        if(receipt != null){
            receipt.Sales_Invoice__c = invId;
            receipt.Amount__c = inv.Invoice_Total__c;
            
            User user = [select id,name,Route_Id__c from User where id=:UserInfo.getUserId() limit 1];
            List<Route__c> rt = new List<Route__c>();
            List<DailyLog__c> log = [SELECT id,Clock_In__c,Trip__r.Id,Clock_Out__c from DailyLog__c WHERE Clock_In__c = TODAY AND Clock_In__c!=null AND Clock_out__c = null AND OwnerId =: UserInfo.getUserId() limit 1];
            if(log.size() > 0){
                receipt.Daily_log__c = log[0].Id;
                receipt.Trip__c = log[0].Trip__c;
            }
            
            if(user.Route_Id__c != null){
                rt = [select id,Route_Id__c,Warehouse__c,Branch_Name__c,Vehicle__c from Route__c where Route_Id__c =:user.Route_Id__c limit 1];
                if(rt.size() > 0){
                    receipt.Route__c = rt[0].Id;
                    receipt.Vehicle__c = rt[0].Vehicle__c;
                    receipt.Branch__c = rt[0].Branch_Name__c;
                    receipt.Warehouse__c = rt[0].Warehouse__c;
                    
                }
            }
            receipt.Type__c = 'Against Invoice';
            receipt.Receipt_Date__c = system.today();
        }
        
        try {
            insert receipt;
            system.debug(receipt.Id);
            return receipt.Id;
        }
        catch (System.Exception ae) { 
            ExceptionHandler.addLog(ae,String.valueOf(receipt) );
            return null;
        }   
        //database.upsert(receipt,false);
       
    }
    
    @AuraEnabled
    public static void deleteSalesOrderItem(string prId){
        
        
        try {
            DELETE[SELECT Id FROM Sales_order_item__c WHERE Id=:prId];
        }
        catch (System.Exception ae) { 
             ExceptionHandler.addLog(ae,String.valueOf(prId) );
        }   
    }
    @AuraEnabled
    public static boolean checkCreditPeriod(Id recordId){
        
        system.debug('recordId=== '+recordId);
        Sales_order__c salesOrderRecord= [select Id,Status__c,Name,Route__c,Vehicle__c,Visit__c,Warehouse__c,Customer__c,Skip_Credit_Limit_For_Next_Order__c from Sales_order__c  
                                          where Id =:recordId Limit 1]; 
        List<Sales_Invoice__c> salesInvoice = [select id,name,customer__c,pending_amount__c,Pending_Amount_SAP__c,invoice_date__c,Customer__r.Credit_period__c,Customer__r.Credit_Limit__c,Customer__r.Name
                                               from Sales_Invoice__c where Customer__c =: salesOrderRecord.Customer__c and Pending_Amount__c > 0 and invoice_date__c != null and Sales_Invoice_Status__c != 'Cancelled'
                                               order by Invoice_Date__c,createdDate asc nulls last limit 1];
        system.debug('salesInvoice : checkCreditPeriod'+salesInvoice);
        
        if(salesInvoice.size() > 0){
            Integer salesInvoiceDateFromToday = salesInvoice[0].Invoice_Date__c.daysBetween(System.today());
            if(salesInvoiceDateFromToday > salesInvoice[0].Customer__r.Credit_period__c && !salesOrderRecord.Skip_Credit_Limit_For_Next_Order__c){
                return true;
                // add here that credit period is  over.
            }
        }
        
        return false;
    }    
}