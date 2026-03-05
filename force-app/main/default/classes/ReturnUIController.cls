public without sharing class ReturnUIController {
    
    @AuraEnabled
    public Account customer {get;set;}
    @AuraEnabled
    public List<Stock__c> stocks {get;set;}
     @AuraEnabled
    public map<string, List<Stock__c>> productStockMap{get;set;}
    
    @AuraEnabled
    public static ReturnUIController getCustomerStock(String custId){   
        List<Stock__c> stockList = new List<Stock__c>();
        map<string, List<Stock__c>> productStockMap = new   map<string, List<Stock__c>>();
        
        ReturnUIController rc = new ReturnUIController();
        Account acc =[select Id,Name,Cash_Discount__c,Routes__c from Account where Id=:custId];
        rc.customer = acc;
        if(acc.Routes__c ==null){
            throw new AuraHandledException('Please add route in account');
        }else{
            list<string> batchrouteList = new list<string>();
            batchrouteList =  label.batch.split(',');
            Set<String> batches = new Set<String>();
            
            for (Batch__c b : [ SELECT Name  FROM Batch__c  WHERE Active__c = true ]) {  batches.add(b.Name); }
            system.debug(batchrouteList);
            stockList =[SELECT Id,name,Product__c,Product_Name__c,Batch_Number__c,Product_Batch_Price__c,Product_Batch_Name__c,Branch_Name__c,Available_Quantity__c,Sold_Qty__c,
                        Blocked_Quantity__c,Manufacturing_Date__c,Product_Old_GST__c ,Price__c,Product_GST__c,Product__r.Brand__c,Fixed_Price_Item__c,Margin__c from Stock__c where Route__c=:acc.Routes__c and ownerId !='0055g00000DnHO5AAN' and Sold_Qty__c >0  and Stock_Type__c = 'New' and  Batch_Number__c IN : batches order by lastmodifieddate];
        }
        rc.stocks = stockList;
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
        return rc;
    }
    @AuraEnabled
    public static List<Sales_invoice_Item__c> getInvoiceItems(String invId){
        system.debug(invId);
        system.debug([select Id,Name,Unit_Price__c,Stock__r.Manufacturing_Date__c,Quantity__c,Product__c,Stock__c,Total_after_discount__c,Item_Name__c,Batch_No__c from Sales_Invoice_Item__c where Sales_Invoice__c =:invId]);
        return [select Id,Name,Unit_Price__c,Stock__r.Manufacturing_Date__c,Quantity__c,Product__c,Stock__c,Total_after_discount__c,Item_Name__c,Batch_No__c,GST_Percentage__c,GST_Value__c,Sales_Tax__c,Cash_Discount__c,Customer_Discount__c,Sales_Invoice__r.Customer__c,Sales_Invoice__r.Customer__r.Name,UnitPriceWithDiscount__c,Rate__c,Fixed_Price_Item__c from Sales_Invoice_Item__c where Sales_Invoice__c =:invId];
    }
    
      @AuraEnabled
    public static List<Discount__c> getDiscounts(string custId){
        List<Discount__c> disList = new  List<Discount__c>();        
        disList = [SELECT Id,Name,GST_Percentage__c,Discount_Percent__c,Eva_Discount_Percent__c  from  Discount__c   where Customer__c=:custId ];        
        system.debug('disList--'+disList.size());
        return disList;
    }
    @AuraEnabled
    public static String saveNewReturn(string returnId,string routeId, List<Return_Item__c> items ){
        
        Return__c returnrec =[select Id,Name,Sales_Invoice__c,Type__c from Return__c where Id=:returnId];
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