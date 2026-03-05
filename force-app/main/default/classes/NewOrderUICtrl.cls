/*
*********************************************************
Apex Class Name    : NewOrderUICtrl 
Created Date       : Aug 21, 2024
@description       : This class is used for New Order Creation
@author            : Mayuri Patel
Modification Log:
Ver   Date         Author                  Modification
1.0   21-08-2024   Mayuri Patel            Initial Version
*********************************************************
*/
public class NewOrderUICtrl {

    
    public class dataBox{
        @AuraEnabled
        public Visit__c currentvisit {get; set;}
        @AuraEnabled
        public List<Discount__c> discounts {get; set;}
        /*@AuraEnabled
        public List<Stock__c> stocks {get; set;}
        @AuraEnabled
        public List<Product__c> products {get; set;}*/
        @AuraEnabled
        public List<stockWrapper> stocks {get; set;}
        
    }
    
    @AuraEnabled
    public static dataBox getData(){
        //List<DailyLog__c> log = [SELECT id,Clock_In__c,Trip__r.Id,Clock_Out__c from DailyLog__c WHERE Clock_In__c = TODAY AND Clock_In__c!=null AND Clock_out__c = null AND OwnerId =: UserInfo.getUserId() limit 1];
        
        databox db = new databox();
        
        List<Visit__c> visits = [SELECT Id,AccountName__c,Comments__c,Name,OwnerId,Actual_Start_Time__c,Actual_End_Time__c,
                                      Planned_Start_Time__c,Status__c,Account1__r.Mobile__c,Account1__c,Account1__r.Phone,Account1__r.Name,Daily_log__c,Account1__r.Cash_Discount__c,Account1__r.Don_t_Apply_FIFO__c,Daily_log__r.Trip__c 
                                      from Visit__c where  Actual_Start_Time__c = TODAY and Status__c = 'In Progress'  and  OwnerId =:userinfo.getUserId()  ORDER BY Actual_Start_Time__c asc limit 1 ]; 
        
        if(visits.size()>0){
            db.currentvisit = visits[0];
             // Fetch the discounts for the current account
            map<Id,Discount__c> discountMap = new  map<Id,Discount__c>([SELECT Id,Name,GST_Percentage__c,Discount_Percent__c,Eva_Discount_Percent__c  from  Discount__c   where Customer__c=:db.currentvisit.Account1__c ]);
            
            // Initialize sets and maps to store GST percentages and discounts
            set<string> gstPercentage = new set<string>();
            Map<String, Decimal> evaDiscountMap = new Map<String, Decimal>();
            Map<String, Decimal> devDiscountMap = new Map<String, Decimal>();
            
            if(!discountMap.isEmpty()){
                for(Discount__c dis :discountMap.values() ){
                    if(dis.GST_Percentage__c != null){
                        gstPercentage.add(dis.GST_Percentage__c);  
                        if(dis.Eva_Discount_Percent__c !=null){
                            evaDiscountMap.put(dis.GST_Percentage__c ,dis.Eva_Discount_Percent__c);
                        }
                        if(dis.Discount_Percent__c !=null){
                            devDiscountMap.put(dis.GST_Percentage__c ,dis.Eva_Discount_Percent__c);
                        }
                    }  
                }
            }
            
            db.discounts =discountMap.values();
            List<Product__c> productList = [SELECT Id,Brand__c,GST__c FROM Product__c where GST__c in :gstPercentage order by Name];
            set<string> productsId = new set<string>();
            for(Product__c p : productList){
                if((p.Brand__c == 'Eva Traders' && evaDiscountMap.containsKey(p.GST__c)) ||(p.Brand__c != 'Eva Traders' &&  devDiscountMap.containsKey(p.GST__c))){
                    productsId.add(p.Id);
                }
            }
            
            
            
            
            
            
            
           // db.discounts = [SELECT Id,Name,GST_Percentage__c,Discount_Percent__c ,Eva_Discount_Percent__c from  Discount__c   where Customer__c=:db.currentvisit.Account1__c ];
            /*  db.stocks = [SELECT Id,name,Product__c,Product_Name__c,Product_Batch_Name__c,Product_GST__c,Manufacturing_Date__c,Available_Quantity__c,Product__r.GST__c,Product__r.MRP__c,Batch_Number__c,Branch_Name__c,Sold_Qty__c,Price__c from Stock__c
				where  Stock_Type__c = 'New' AND (Manufacturing_Date__c != null AND Price__c != null AND Available_Quantity__c != null ) order by Manufacturing_Date__c desc];*/
            List<Product__c> products = [SELECT Id, Name, GST__c, MRP__c,SF_PRD_CODE__c,Product_Code__c,Product_Name_Code__c,Sales_Tax__c,Fixed_Price_Item__c,
                           (SELECT Id, Name, Product__c, Product_Name__c, Product_Batch_Name__c, Product_GST__c, 
                            Manufacturing_Date__c, Available_Quantity__c, Product__r.GST__c, Product__r.MRP__c, Product__r.Brand__c,
                            Batch_Number__c, Branch_Name__c, Sold_Qty__c, Price__c,Margin__c,Fixed_Price_Item__c FROM Stocks__r 
                            WHERE Stock_Type__c = 'New' AND Manufacturing_Date__c != null AND Price__c != null 
                            AND Available_Quantity__c > 0 and OwnerId=:UserInfo.getUserId()  ORDER BY CreatedDate) 
                           FROM Product__c where Id in :productsId order by Name];
            Map<String,Stock__c> stockMap = new Map<String,Stock__c>();
            Map<String,Product__c> productMap = new Map<String,Product__c>();
            List<stockWrapper> productToReturn = new List<stockWrapper>();
            for(Product__c prd: products){
                if(prd.stocks__r.size() > 0){
                    for(Stock__c stk : prd.Stocks__r){
                        if(!stockMap.containsKey(prd.Id+stk.Price__c.toString())){
                            stockMap.put(prd.Id+stk.Price__c.toString(), stk);    
                        }
                        else{
                            stk.Available_Quantity__c = stk.Available_Quantity__c + stockMap.get(prd.Id+stk.Price__c.toString()).Available_Quantity__c;
                            stockMap.get(prd.Id+stk.Price__c.toString()).Available_Quantity__c = stk.Available_Quantity__c;    
                        }
                    }
                }
                  productMap.put(prd.Id,prd);     
            }
            for(Stock__c stock : stockMap.values()){
                stockWrapper wrpClass = new stockWrapper();
                wrpClass.product = productMap.get(stock.Product__c);
                wrpClass.stock = stock;
                wrpClass.price = stock.Price__c;
                wrpClass.availableQty =  stock.Available_Quantity__c;
                wrpClass.quantity = 0;
                wrpClass.total = 0;
                productToReturn.add(wrpClass);
            }
            db.stocks = productToReturn;
            return db;
        }
        else{
            return null;
        }
       
    }
    
    @AuraEnabled
    public static String createOrder(List<Sales_Order_Item__c>  orderItemList,Sales_Order__c order ){
        
        system.debug('orderItemList : '+orderItemList);
        system.debug('order-'+order); 
        
        List<Address__c> getAddress = [select Id,GST_No__c,Customer__c from Address__c where Address_Type__c =:'B' AND Customer__c =: order.Customer__c Limit 1];
        system.debug('getAddress== '+getAddress);
        
        User user = [select id,name,Route_Id__c from User where id=:UserInfo.getUserId() limit 1];
        List<Route__c> routeRecord = [select id,Route_Id__c,Warehouse__c,Branch_Name__c,Vehicle__c from Route__c where Route_Id__c =:user.Route_Id__c limit 1];
        
        order.Route__c = routeRecord[0].Id;
        order.Vehicle__c = routeRecord[0].Vehicle__c;
        order.Branch__c = routeRecord[0].Branch_Name__c;
        order.Warehouse__c = routeRecord[0].Warehouse__c;
        order.Order_Date__c = system.today();  
        order.New_Flow__c = true;
        
        try {
            insert order;
        }
        catch (System.Exception ae) { 
           ExceptionHandler.addLog(ae,String.valueOf(order) );
        }     
       
        if(order.Id != null){
            for(Sales_Order_Item__c item : orderItemList){
                item.Sales_Order__c = order.Id;
            }
            try {
                insert orderItemList;
            }
            catch (System.Exception ae) { 
                ExceptionHandler.addLog(ae,String.valueOf(orderItemList) );
            }   
            system.debug('orderItemList : '+orderItemList);
            system.debug('orderItemList size : '+orderItemList.size());
        }
        
       
        return order.Id;
    }
    
    // Wrapper to set the data of all products with available stock - Mayuri
    public class stockWrapper{ 
        @AuraEnabled
        public Product__c product {get; set;}
        @AuraEnabled
        public Stock__c stock {get; set;}
        @AuraEnabled
        public Decimal price {get; set;}
        @AuraEnabled
        public Decimal margin {get; set;}
        @AuraEnabled
        public Decimal availableQty {get; set;}
        @AuraEnabled
        public Decimal quantity {get; set;}
        @AuraEnabled
        public Decimal total {get; set;}
    }
 
}