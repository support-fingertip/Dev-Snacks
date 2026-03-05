public class VisitManagerClone {
    
      public static List<Visit__c> visitList {get;set;} 
    public List<user> usersList {get;set;} 
    
    public class dataBox{
        @AuraEnabled
        public List<Visit__c> visits {get; set;}
        @AuraEnabled
        public dailylog__c dailyLog {get; set;} 
        @AuraEnabled
        public List<Account> accounts {get; set;}
        
    }
    public VisitManagerClone (){  
       usersList = [select id ,name from user where isactive = true and ( profile.name = 'Guest profile' or profile.name = 'System Administrator')];
 
    }
    
    @remoteaction
    public static  List<Visit__c>  loadVisits(id userid){  
       visitList = [select id ,name,status__c,    CheckedInLatitude__c, CheckedInLongitude__c from Visit__c  where createdbyid =:userid ];
       return visitList ;
    }
    
    @AuraEnabled // To get the banks picklist values from receipt - Mayuri
    public static List<String>  getBanks(){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Receipt__c.Bank_Name__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
    }
    
    @AuraEnabled // To check the Credit Period of the Customer. If any Pending sales Invoices are there after the credit period is over, it will return true. - Mayuri
    public static boolean checkCreditPeriod(Id accountID){ 
        
        system.debug('accountID=== '+accountID);
        List<Account> accountRec = [select Id,Credit_period__c from Account where Id =: accountID limit 1];
        
        if(accountRec.size()>0 && accountRec[0].Credit_period__c != null){
            List<Sales_Invoice__c> salesInvoice = [select id,name,customer__c,pending_amount__c,invoice_date__c,Customer__r.Credit_period__c,Customer__r.Credit_Limit__c,Customer__r.Name
                                             from Sales_Invoice__c where Customer__c =: accountID and Pending_Amount__c > 0 and invoice_date__c != null and Sales_Invoice_Status__c != 'Cancelled'
                                             order by Invoice_Date__c,createdDate asc nulls last limit 1];
            system.debug('salesInvoice : checkCreditPeriod'+salesInvoice);
            
            if(salesInvoice.size() > 0){
                Integer salesInvoiceDateFromToday = salesInvoice[0].Invoice_Date__c.daysBetween(System.today());
                system.debug('salesInvoiceDateFromToday=== '+salesInvoiceDateFromToday);
                if(salesInvoiceDateFromToday > salesInvoice[0].Customer__r.Credit_period__c){
                    return true;
                }
            }
        }
        
        return false;   
    }
 
    @auraEnabled // To check the available Stock of the selected product. - Mayuri
    Public static boolean checkStockForPrpduct(string productId){
        system.debug('productId== '+productId);
        boolean showProduct = false;
        Product__c productList = [SELECT Id,Name,Product_Image__c,GST__C,MRP__c,Product_Image_Url__c,Product_catogery__c,Product_Code__c,Sales_Tax__c,
                                  (select Id,Manufacturing_Date__c,Available_Quantity__c,Stock_Type__c from Stocks__r where Stock_Type__c =: 'New')
                                  from Product__c where Id =: productId];
        system.debug('productList== '+ productList);
        if(productList.Stocks__r.size()>0){
            for(Stock__c stk : productList.Stocks__r){
                if(stk.Manufacturing_Date__c != null && stk.Available_Quantity__c > 0 && stk.Stock_Type__c == 'New'){
                    showProduct = true;
                }
            }
            return showProduct;
        }
        return false;
    }
    
    @auraEnabled // To get the Selected Product details - Mayuri 
    Public static List<Product__c> getCartProducts(List<string> cartProductIds){
        system.debug('cartProductIds== '+cartProductIds);
        List<Product__c> productList = [SELECT Id,Name,Product_Image__c,GST__C,MRP__c,Product_Image_Url__c,Product_catogery__c,Product_Code__c,Sales_Tax__c
                                        from Product__c where Id In : cartProductIds];
        system.debug('productList== '+ productList);
        system.debug('productList size== '+ productList.size());
        return productList;
    }
    
    @auraEnabled // To get the Selected Product's Stock details - Mayuri
    Public static List<Stock__c> getCartProductStocks(string cartProductId){
        system.debug('cartProductId : '+ cartProductId);
        return [SELECT Id,name,Product__c,Manufacturing_Date__c,Available_Quantity__c,Product__r.GST__c,Product__r.MRP__c,Batch_Number__c,Branch_Name__c,Sold_Qty__c,Price__c from Stock__c
                where Product__c =: cartProductId AND Available_Quantity__c > 0 AND Stock_Type__c =: 'New'];
    }
    
    @auraEnabled // To get Selected Stock's detail - Mayuri
    public static Stock__c getSelectedStockRec(string stockId){
        Stock__c  selectedStock = [select id,name,Product__c,Product__r.GST__c,Product__r.MRP__c,Batch_Number__c,Branch_Name__c,Available_Quantity__c,Sold_Qty__c,Price__c from Stock__c where id =: stockId limit 1];
        return selectedStock;
    }
     
    @auraEnabled // To get all Products with Stock Details - Mayuri
    Public static List<productWrapper> getProducts(){
         
        List<productWrapper> productToReturn = new List<productWrapper>();
        List<Product__c> productList = [SELECT Id,Name,Product_Image__c,Product_Image_Url__c,Product_catogery__c,Product_Code__c,Sales_Tax__c,
                                        (select Id,Manufacturing_Date__c,Available_Quantity__c,Stock_Type__c from Stocks__r where Stock_Type__c =: 'New' and Manufacturing_Date__c!=null)from Product__c];
        
        system.debug('productList== '+ productList);
        for(Product__c product : productList){
            Decimal totalQuantity = 0;
            for(Stock__c stock : product.Stocks__r){
                if(stock.Available_Quantity__c > 0){
                     totalQuantity = totalQuantity + stock.Available_Quantity__c; 
                }
               
            }
            if(product.Stocks__r.size()>0){
                //productToReturn.add(product);
                productWrapper wrpClass = new productWrapper();
                wrpClass.productObj = product;
                wrpClass.totalAvailableQuantity = totalQuantity;
                if(totalQuantity > 0){
                    productToReturn.add(wrpClass);
                }
                
            }            
        }
        if(productToReturn.size()>0){
           return productToReturn;
        }
        return null;
    }
    
    @auraEnabled // To get all Orders - Mayuri
    Public static List<Sales_order__c> getOders(string cusName){
        return [SELECT Id,Name,Customer__r.Name,Grand_Total__c,Branch__c,Order_Date__c,Status__c,Total_GST_Amount__c,Vehicle__c from Sales_order__c where Status__c = 'New' and Customer__c =: cusName];
    }
    
    @auraEnabled // To get all Order Items - Mayuri
    Public static List<Sales_order_item__c> getOdersItems(string ordName){
        return [SELECT Id,Name,Sales_order__r.Name,GST_Percentage__c,Stock__c,Stock__r.Available_Quantity__c,Product__c,Total__c,Unit_Price__c,Quantity__c,Total_after_discount__c,Total_Before_Tax__c from Sales_order_item__c where Sales_order__c =: ordName ];
    }

    @AuraEnabled // To get all Customers - Mayuri
    public static List<Account> getAccounts(){
        List<Account> accountsList = new  List<Account>();        
        accountsList = [SELECT Id,Phone,Name,Contact_Person__c,GeoLocation__Latitude__s,GeoLocation__Longitude__s,Alternate_Mobile__c,Email__c,Store_Category__c,Grade__c,Approval_Status__c,Cash_Discount__c   from  Account   where ownerId =: userinfo.getUserId() and Approval_Status__c=:'Approved' ];        
       system.debug('accountsList--'+accountsList.size());
        return accountsList;
    }
    
    @AuraEnabled // To get the Discount Details for the Checked-in Customer - Mayuri
    public static List<Discount__c> getDiscounts(string accId){
        List<Discount__c> disList = new  List<Discount__c>();        
        disList = [SELECT Id,Name,GST_Percentage__c,Discount_Percent__c  from  Discount__c   where Customer__c=:accId ];        
       system.debug('disList--'+disList.size());
        return disList;
    }
    
    @AuraEnabled // To get Current Trip of the logged-in user - Mayuri
    public static Trip__c getTripData(){
        List<Trip__c> tripList = [SELECT id,Start_Location__Latitude__s,Start_Location__Longitude__s,End_Location__Latitude__s,End_Location__Longitude__s,Start_Date__c,End_Date__c,Route__c from  Trip__c  WHERE   (Status__c = 'Started' AND End_Date__c = null )  AND OwnerId =:UserInfo.getUserId() limit 1]; 
        if(tripList.size() == 0){
            return null;
        }else{
            system.debug(tripList[0]);
        } 
        return tripList[0]; 
    }
    
    @AuraEnabled // To get Current Login/Logout detail of the logged-in user - Mayuri
    public static DailyLog__c getDailyLog(){
        List<DailyLog__c> clockinClockout = [SELECT id,Clock_In_Location__Latitude__s,Clock_In_Location__Longitude__s,Clock_Out_Location__Latitude__s,Clock_Out_Location__Longitude__s,Clock_In__c,Clock_Out__c,Driver__c,Sales_Man__c,Assistant_SalesMan__c,Sales_Manager__c,Trip__c,Start_KM__c,End_KM__c from  DailyLog__c  WHERE    Clock_In__c = TODAY AND OwnerId =:UserInfo.getUserId() limit 1]; 
        if(clockinClockout.size() == 0){
            return null;
        }else{
            system.debug(clockinClockout[0]);
        } return clockinClockout[0]; 
    }
    
    @AuraEnabled  // Getting today's all visits for the current user - Mayuri
    public static List<Visit__c> getTodaysVisits(){    
        List<Visit__c> listVisits =  [SELECT Id,Revisit__c,Account1__r.GeoLocation__Latitude__s,TA_DA_Applicable__c,Account1__r.GeoLocation__Longitude__s,
                                      EId__c,Meet_and_greet__c,Placements__c,Checked_expiry__c,Product_introduction__c,presentation__c,marketing_material__c,
                                      AccountName__c,Check_In_location__Latitude__s,Check_In_location__Longitude__s,Check_out_location__Latitude__s,
                                      Check_out_location__Longitude__s,CheckedOutLatitude__c,CheckedOutLongitude__c,ClockIn_Latitude__c,Clockin_Longitude__c,
                                      Clockout_Longitude__c,Comments__c,Name,OwnerId,Actual_Start_Time__c,Actual_End_Time__c,Missed_PostPone_Reason__c,
                                      Planned_Start_Time__c,Status__c,Account1__r.Mobile__c,Account1__r.Phone,Account1__r.Name,Daily_log__c,Account1__r.Cash_Discount__c 
                                      from Visit__c where  Planned_Start_Time__c = TODAY  and  OwnerId =:userinfo.getUserId()  ORDER BY status__c asc ]; 
        return  listVisits;    
    }
    
    @AuraEnabled // To update the current visit details if user check-in/check-out - Mayuri
    public static List<Visit__c> upsertVisits(string visitList ){ 
        system.debug(visitList);
        List<visit__c> vlist = (List<visit__c>)JSON.deserialize( visitList, List<visit__c>.class);
        //database.upsert(vlist);
        upsert vlist;
        
        List<Visit__c> listVisits =  [SELECT Id,Revisit__c,Account1__r.GeoLocation__Latitude__s,TA_DA_Applicable__c,
                                      Account1__r.GeoLocation__Longitude__s,EId__c,Meet_and_greet__c,Placements__c,
                                      Checked_expiry__c,Product_introduction__c,presentation__c,marketing_material__c,
                                      AccountName__c,Check_In_location__Latitude__s,Check_In_location__Longitude__s,
                                      Check_out_location__Latitude__s,Check_out_location__Longitude__s,CheckedOutLatitude__c,
                                      CheckedOutLongitude__c,ClockIn_Latitude__c,Clockin_Longitude__c,Clockout_Longitude__c,
                                      Comments__c,Name,OwnerId,Actual_Start_Time__c,Actual_End_Time__c,Missed_PostPone_Reason__c,
                                      Planned_Start_Time__c,Status__c,Account1__r.Phone,Account1__r.Name,Daily_log__c,Account1__r.Cash_Discount__c 
                                      from Visit__c where  Planned_Start_Time__c = TODAY  and  OwnerId =:userinfo.getUserId()  ORDER BY status__c asc ];
        return listVisits; 
    }
    
    @AuraEnabled // Updating the login/logout details - Mayuri
    public static DailyLog__c upsertDailyLog(DailyLog__c dailylog,Trip__c trip){ 
        system.debug(dailylog);
        if(dailylog !=null ){
            List<Employee__c> emp = [select id,Email__c from Employee__c where Email__c =:UserInfo.getUserEmail() limit 1];
            if(emp.size() > 0){
                dailylog.Employee__c = emp[0].Id;
            }
            dailyLog.Present__c = true;
            
            if(trip != null){
                dailyLog.Route__c = trip.Route__c;
                dailyLog.Trip__c = trip.Id;
            }
            
            upsert dailylog;
        }						
        List<DailyLog__c> dl = [SELECT id,Clock_In_Location__Latitude__s,Clock_In_Location__Longitude__s,Clock_Out_Location__Latitude__s,Clock_Out_Location__Longitude__s,Clock_In__c,Clock_Out__c,Driver__c,Sales_Man__c,Assistant_SalesMan__c,Sales_Manager__c,Trip__c,Start_KM__c,End_KM__c from  DailyLog__c  WHERE    Clock_In__c = TODAY AND OwnerId =:UserInfo.getUserId() limit 1];
        if(dl.size() == 0){
            return null;
        }else{
            return dl[0];
        }
    }
    
    @AuraEnabled // Getting all product - Mayuri
    public static List<Product__c> getproductList(){    
        List<Product__c> listproducts =  [SELECT Id,Name,MRP__c,Product_Image_Url__c,Sales_Tax__c,GST__c FROM Product__c];
        return listproducts;
    }
    
    @AuraEnabled // To get Employee details - Mayuri
    public static List<Employee__c> getEmployees(){    
        List<Employee__c> listemployees =  [SELECT Id,Name,Email__c,Mobile__c,Employee_Id__c,Role__c,Branch__c,CompanyId__c FROM Employee__c where Active__c = TRUE];
        return listemployees;
    }
   
    @AuraEnabled // Create Unsealed Records - Mayuri
    public static List<Unsealed__c> addUnsealed(string orderList,string accountId){
        system.debug('Orders to add : '+orderList);
        List<Account> accountList = [select Id,Name,CompanyId__c from Account where Id =: accountId Limit 1];
        List<Unsealed__c> unsealedList = (List<Unsealed__c>)JSON.deserialize( orderList, List<Unsealed__c>.class);
        User user = [select id,name,Route_Id__c from User where id=:UserInfo.getUserId() limit 1];
        List<Route__c> routeRecord = [select id,Route_Id__c,Warehouse__c,Branch_Name__c,Vehicle__c from Route__c where Route_Id__c =:user.Route_Id__c limit 1];
        List<DailyLog__c> log = [SELECT id,Clock_In__c,Trip__r.Id,Clock_Out__c from DailyLog__c WHERE Clock_In__c = TODAY AND Clock_In__c!=null AND Clock_out__c = null AND OwnerId =: UserInfo.getUserId() limit 1];
        if(routeRecord.size()>0){
            for(Unsealed__c unsealed: unsealedList){
                if(routeRecord != null){
                    unsealed.Route__c = routeRecord[0].Id;
                    unsealed.Customer__c = accountId;
                    unsealed.Branch__c = routeRecord[0].Branch_Name__c;
                    unsealed.Company_Id__c = accountList[0].CompanyId__c;
                    unsealed.Date__c = system.today();  
                }
                if(log.size()>0){
                    unsealed.Daily_logs__c = log[0].Id;
                    unsealed.Trip__c = log[0].Trip__r.Id;
                }
            }
            for(Integer i = (unsealedList.size()-1) ; i>= 0 ; i--){
                system.debug('p i== '+i);
                if(i != 0){
                    system.debug('i== '+i);
                    unsealedList.remove(i);
                }
            }
        }
        
        database.upsert(unsealedList);
        return unsealedList;
    }
    
    @AuraEnabled // Create Unsealed Items Records - Mayuri
    public static List<Unsealed_Item__c> addUnsealedItems(string  orderItemList,string ordId,string accountId ){
        system.debug(orderItemList);
        system.debug('ordId-'+ordId);
        string newstring = orderItemList.replace('[','');
        string newstring2 = newstring.replace(']','');
        string newstring3 = '['+newstring2+']';
        string newstring4 = newstring3.replace('"Id"', '"Product__c"');
        system.debug('Formatted order item list : ' + newstring4);
        List<Unsealed_Item__c> unsealedItemList = (List<Unsealed_Item__c>)JSON.deserialize( newstring4, List<Unsealed_Item__c>.class);
        system.debug('final Goods Issue Item list-'+unsealedItemList);
        list<Unsealed_Item__c> upsertunsealedItem = new list<Unsealed_Item__c>();
        for(Unsealed_Item__c unsealedItem : unsealedItemList){
            system.debug('salesOrderItem === '+unsealedItem);
            Unsealed_Item__c unsealedItm = new Unsealed_Item__c();
            unsealedItm.Stock__c = unsealedItem.Stock__c;
            unsealedItm.Product__c = unsealedItem.Product__c;
            unsealedItm.Unsealed__c = ordId;
            unsealedItm.Quantity__c = unsealedItem.Quantity__c;
            upsertunsealedItem.add(unsealedItm);
            system.debug('upsertunsealedItem ; '+upsertunsealedItem);
            }
            
        Upsert upsertunsealedItem;
        List<Unsealed_Item__c> unsealedItmList =  [SELECT Id,Stock__c,Product__c,Unsealed__c,Quantity__c  FROM Unsealed_Item__c 
                                                   WHERE CreatedDate=TODAY AND Unsealed__r.CreatedById=:userinfo.getUserId()];
        
        return unsealedItmList;
    }
    
    @AuraEnabled // To Create New Sales Invoice - Mayuri
    public static List<Sales_Invoice__c> upsertNewOrder(string orderList,string accountId){
        system.debug(orderList);
        List<Sales_Invoice__c> ordList = (List<Sales_Invoice__c>)JSON.deserialize( orderList, List<Sales_Invoice__c>.class);
       
        User user = [select id,name,Route_Id__c from User where id=:UserInfo.getUserId() limit 1];
        List<Route__c> rt = new List<Route__c>();
        List<Address__c> getAddress = [select Id,GST_No__c,Customer__c from Address__c where Address_Type__c =:'B' AND Customer__c =: accountId Limit 1];
        List<DailyLog__c> log = [SELECT id,Clock_In__c,Trip__r.Id,Clock_Out__c from DailyLog__c WHERE Clock_In__c = TODAY AND Clock_In__c!=null AND Clock_out__c = null AND OwnerId =: UserInfo.getUserId() limit 1];
         if(user.Route_Id__c != null){
            rt = [select id,Route_Id__c,Warehouse__c,Branch_Name__c,Vehicle__c from Route__c where Route_Id__c =:user.Route_Id__c limit 1];
            if(rt.size() > 0){
                for(Sales_Invoice__c si: ordList){
                    si.Route__c = rt[0].Id;
                    si.Vehicle__c = rt[0].Vehicle__c;
                    si.Branch__c = rt[0].Branch_Name__c;
                    si.Warehouse__c = rt[0].Warehouse__c;
                    si.Invoice_Date__c = system.today();
                    si.New_Flow__c = true;

                    if(getAddress.size()>0){
                        si.Gstin__c = getAddress[0].GST_No__c;
                    }
                    if(log.size()>0){
                        si.Trip__c = log[0].Trip__r.Id;
                        si.Daily_log__c = log[0].Id;
                    }
                }
                for(Integer i = (ordList.size()-1) ; i>= 0 ; i--){
                    system.debug('p i== '+i);
                    if(i != 0){
                        system.debug('i== '+i);
                        ordList.remove(i);
                    }
                }
            }
        }
        
        database.upsert(ordList);
        //Upsert ordList;
      //  List<Invoice__c> updatedOrderList =  [SELECT Id,EID__c, Name, Invoice_Date__c, Store__c,Store__r.EID__c, Store_name__c, Visit__c, Grand_Total__c,Visit__r.EID__c FROM Invoice__c WHERE CreatedDate=TODAY  AND OwnerId=:userinfo.getUserId()];
        return ordList;
    }
    
    @AuraEnabled // To Create New Sales Invoice Items - Mayuri
    public static List<Sales_Invoice_Item__c> upsertOrderItem(string orderItemList,string ordId,string accountId ){
      /*  List<Order_Item__c> ordItList = new List<Order_Item__c>();
        for(Order_Item__c ord : orderItemList){
          Order_Item__c orl = ord;
            ordItList.add(orl);
        }
          upsert orderItemList;*/
        system.debug(orderItemList);
        system.debug('orderItemList : '+orderItemList);
        system.debug('ordId-'+ordId);
        Map<Id,Decimal> stockQuantityMAp = new Map<Id,Decimal>();
        string newstring = orderItemList.replace('[','');
        string newstring2 = newstring.replace(']','');
        string newstring3 = '['+newstring2+']';
        string newstring4 = newstring3.replace('"Id"', '"Product__c"');
        system.debug('newstring4 : ' + newstring4);
        List<Sales_Invoice_Item__c> ordList = (List<Sales_Invoice_Item__c>)JSON.deserialize( newstring4, List<Sales_Invoice_Item__c>.class);
        List<Rack_Stock__c> rackStockList = (List<Rack_Stock__c>)JSON.deserialize( newstring4, List<Rack_Stock__c>.class);
        system.debug('final list-'+ordList);
        system.debug('final list size-'+ordList.size());
        list<Sales_Invoice_Item__c>upsertlst=new list<Sales_Invoice_Item__c>();
        list<Rack_Stock__c> upsertRackStockItem = new list<Rack_Stock__c>();
        for(Sales_Invoice_Item__c t:ordList){
            if(!stockQuantityMAp.containsKey(t.Stock__c) && stockQuantityMAp.get(t.Stock__c) != t.Quantity__c){
                Sales_Invoice_Item__c i =new Sales_Invoice_Item__c();
                i.Total__c=t.Total__c;
                i.Total_Before_Tax__c=t.Total_Before_Tax__c;
                //i.GST_Percentage__c=t.GST_Percentage__c;
                //i.GST_Value__c = t.GST_Value__c;
                i.Sales_Tax__c = t.Sales_Tax__c;
                i.Product__c=t.Product__c;
                i.Stock__c = t.Stock__c;
                i.Quantity__c=t.Quantity__c;
                i.Unit_Price__c = t.Unit_Price__c;
                i.Sales_Invoice__c=ordId;
                i.Discount_Percent__c = t.Discount_Percent__c;
                i.Customer_Discount__c = t.Customer_Discount__c;
                i.Cash_Discount__c = t.Cash_Discount__c;
                i.Total_after_discount__c = t.Total__c;
                stockQuantityMAp.put(t.Stock__c,t.Quantity__c);
                upsertlst.add(i);
            }
        }
        
        for(Rack_Stock__c rstk : rackStockList){
            Rack_Stock__c rStkRec = new Rack_Stock__c();
            rStkRec.Product__c = rstk.Product__c;
            rStkRec.Stock__c = rstk.Stock__c;
            rStkRec.Quantity__c = rstk.Quantity__c;
            if(accountId != null){
                rStkRec.Customer__c = accountId;
            }
            upsertRackStockItem.add(rStkRec);
        }
        
        Upsert upsertlst;
        system.debug('upsertlst : '+upsertlst);
        system.debug('upsertlst size : '+upsertlst.size());
      
        List<Sales_Invoice_Item__c> orderList =  [SELECT Id, Name, Unit_Price__c, Sales_Invoice__c, Product__c,Stock__c, Quantity__c, GST_Percentage__c, GST_Value__c, Total__c,Discount_Percent__c,Total_after_discount__c,Total_Before_Tax__c FROM Sales_Invoice_Item__c WHERE CreatedDate=TODAY  AND Sales_Invoice__r.CreatedById=:userinfo.getUserId()];
        system.debug('orderList : '+upsertlst);
        system.debug('orderList size : '+upsertlst.size());
        
        
           /* @author -Nanma  
* update outstanding amount in customer 
 //try{
          list<Sales_Invoice__c> salesInv =[select Id,Customer__c,Customer__r.Outstanding_Amount__c from Sales_Invoice__c where Id =:ordId]; 
      for(Sales_Invoice__c sl: salesInv){
                    Account acc = new Account();
                    acc.Id = sl.Customer__c;
                    if(sl.Customer__r.Outstanding_Amount__c == null || sl.Customer__r.Outstanding_Amount__c == 0){
                       acc.Outstanding_Amount__c =outstanding;
                    }else{
                         acc.Outstanding_Amount__c  =sl.Customer__r.Outstanding_Amount__c +outstanding;
                    }
          update acc;
      }
    
 //}
      //  catch(DmlException ex){
       //     system.debug('Error'+ ex.getMessage());
       // } */
        
        
        return orderList;
    }
    
    @AuraEnabled // To Create New Sales Order - Mayuri
    public static List<Sales_order__c> addNewOrder(string orderList){
        system.debug('Orders to add : '+orderList);
        List<Sales_order__c> ordList = (List<Sales_order__c>)JSON.deserialize( orderList, List<Sales_order__c>.class);
        User user = [select id,name,Route_Id__c from User where id=:UserInfo.getUserId() limit 1];
        //DailyLog__c log = [SELECT id,Clock_In__c,Trip__r.Id,Clock_Out__c from DailyLog__c WHERE Clock_In__c = TODAY AND Clock_In__c!=null AND Clock_out__c = null AND OwnerId =: UserInfo.getUserId() limit 1];
        List<Route__c> routeRecord = [select id,Route_Id__c,Warehouse__c,Branch_Name__c,Vehicle__c from Route__c where Route_Id__c =:user.Route_Id__c limit 1];
        List<DailyLog__c> log = [SELECT id,Clock_In__c,Trip__r.Id,Clock_Out__c from DailyLog__c WHERE Clock_In__c = TODAY AND Clock_In__c!=null AND Clock_out__c = null AND OwnerId =: UserInfo.getUserId() limit 1];
        //List<Sales_order__c> upsertSalesOrders = new List<Sales_order__c>();
        if(routeRecord.size()>0){
            for(Sales_order__c salesOrder: ordList){
                if(routeRecord != null){
                    salesOrder.Route__c = routeRecord[0].Id;
                    salesOrder.Vehicle__c = routeRecord[0].Vehicle__c;
                    salesOrder.Branch__c = routeRecord[0].Branch_Name__c;
                    salesOrder.Warehouse__c = routeRecord[0].Warehouse__c;
                    salesOrder.Order_Date__c = system.today();  
                    salesOrder.New_Flow__c = true;
                }
                if(log.size()>0){
                    salesOrder.Daily_logs__c = log[0].Id;
                    salesOrder.Trip__c = log[0].Trip__r.Id;
                }
                //upsertSalesOrders.add(salesOrder);
            }
            for(Integer i = (ordList.size()-1) ; i>= 0 ; i--){
                system.debug('pre i== '+i);
                if(i != 0){
                    system.debug('i== '+i);
                    ordList.remove(i);
                }
            }
        }
        database.upsert(ordList);
        system.debug('Orders to add : '+ordList);
        return ordList;
    }
     
    @AuraEnabled // To Create New Sales Order Items - Mayuri
    public static List<Sales_order_item__c> addOrderItem(string  orderItemList,string ordId,string accountId ){
        system.debug(orderItemList);
        system.debug('ordId-'+ordId);
        Map<Id,Decimal> stockQuantityMAp = new Map<Id,Decimal>();
        string newstring = orderItemList.replace('[','');
        string newstring2 = newstring.replace(']','');
        string newstring3 = '['+newstring2+']';
        string newstring4 = newstring3.replace('"Id"', '"Product__c"');
        system.debug('Formatted order item list : ' + newstring4);
        List<Sales_order_item__c> ordItemList = (List<Sales_order_item__c>)JSON.deserialize( newstring4, List<Sales_order_item__c>.class);
        List<Rack_Stock__c> rackStockList = (List<Rack_Stock__c>)JSON.deserialize( newstring4, List<Rack_Stock__c>.class);
        system.debug('final Order Item list-'+ordItemList);
        list<Sales_order_item__c> upsertSalesOrderItem = new list<Sales_order_item__c>();
        list<Rack_Stock__c> upsertRackStockItem = new list<Rack_Stock__c>();
        for(Sales_order_item__c salesOrderItem:ordItemList){
            if(!stockQuantityMAp.containsKey(salesOrderItem.Stock__c) && stockQuantityMAp.get(salesOrderItem.Stock__c) != salesOrderItem.Quantity__c){
                system.debug('salesOrderItem === '+salesOrderItem);
                Sales_order_item__c salesOrderItm = new Sales_order_item__c();
                salesOrderItm.Total__c=salesOrderItem.Total__c;
                //salesOrderItm.GST_Percentage__c=salesOrderItem.GST_Percentage__c;
                //salesOrderItm.GST_Value__c = salesOrderItem.GST_Value__c;
                salesOrderItm.Sales_Tax__c	= salesOrderItem.Sales_Tax__c;	
                salesOrderItm.Stock__c = salesOrderItem.Stock__c;
                salesOrderItm.Product__c = salesOrderItem.Product__c;
                salesOrderItm.Quantity__c=salesOrderItem.Quantity__c;
                salesOrderItm.Unit_Price__c = salesOrderItem.Unit_Price__c;
                salesOrderItm.Sales_order__c=ordId;
                salesOrderItm.Discount_Percent__c = salesOrderItem.Discount_Percent__c;
                salesOrderItm.Customer_Discount__c = salesOrderItem.Customer_Discount__c;
                salesOrderItm.Cash_Discount__c = salesOrderItem.Cash_Discount__c;
                salesOrderItm.Total_after_discount__c = salesOrderItem.Total_after_discount__c;
                salesOrderItm.Total_Before_Tax__c = salesOrderItem.Total_Before_Tax__c;
                stockQuantityMAp.put(salesOrderItem.Stock__c,salesOrderItem.Quantity__c);
                upsertSalesOrderItem.add(salesOrderItm);
                system.debug('upsertSalesOrderItem ; '+upsertSalesOrderItem);
            }
        }
        
        for(Rack_Stock__c rstk : rackStockList){
            Rack_Stock__c rStkRec = new Rack_Stock__c();
            rStkRec.Product__c = rstk.Product__c;
            rStkRec.Stock__c = rstk.Stock__c;
            rStkRec.Quantity__c = rstk.Quantity__c;
            if(accountId != null){
                rStkRec.Customer__c = accountId;
            }
            upsertRackStockItem.add(rStkRec);
        }
        //rackStock.Quantity__c = salesOrderItem.Rack_Stock___c;
        
        Upsert upsertSalesOrderItem;
        upsert upsertRackStockItem;
        List<Sales_order_item__c> orderItmList =  [SELECT Id, Name, Unit_Price__c, Sales_Order__c, Product__c,Stock__c, Quantity__c, GST_Percentage__c, GST_Value__c, Total__c,Discount_Percent__c,Total_after_discount__c,Total_Before_Tax__c FROM Sales_order_item__c 
                                                   WHERE CreatedDate=TODAY AND Sales_Order__r.CreatedById=:userinfo.getUserId()];
        
        return orderItmList;
    }
    
    @AuraEnabled // To Save Receipt after Sales Invoice is Created if Customers are paying on the shop - Mayuri
    public static Receipt__c saveReceipt(Receipt__c receipt, Decimal amt, string ordId){
        system.debug('receipt:' + receipt);
       
         Sales_Invoice__c inv = [select id,name,Customer__c,Amount_Received__c,Invoice_Date__c,Grand_Total_Discounted__c,Pending_Amount__c from Sales_Invoice__c where Id=:ordId];
        if(receipt != null){
            receipt.Sales_Invoice__c = ordId;
            receipt.Amount__c = inv.Grand_Total_Discounted__c;
            
            User user = [select id,name,Route_Id__c from User where id=:UserInfo.getUserId() limit 1];
            
            if(user.Route_Id__c != null){
                Route__c rt = [select id,Route_Id__c,Warehouse__c,Branch_Name__c,Vehicle__c from Route__c where Route_Id__c =:user.Route_Id__c limit 1];
                if(rt != null){
                    receipt.Route__c = rt.Id;
                    receipt.Vehicle__c = rt.Vehicle__c;
                    receipt.Branch__c = rt.Branch_Name__c;
                    receipt.Warehouse__c = rt.Warehouse__c;
                    receipt.Type__c = 'Against Invoice';
                    receipt.Receipt_Date__c = system.today();
                }
            }
            
        }
        
        database.upsert(receipt,false);
        return receipt;
    }
    
    @AuraEnabled // Getting the access of buttons to be visible for current user from the User Details - Mayuri
    public static String getCurrentButtonValue() {
        return [SELECT Buttons_To_Be_Visible__c FROM User WHERE Id =: UserInfo.getUserId()].Buttons_To_Be_Visible__c;
    }
 
    @AuraEnabled // Not USING
    public static List<account> upsertAccounts(List<account> accountList ){
        List<account> updatelist = new List<account>();
        for(account acc : accountList){
            if(acc.Approval_Status__c == 'Approved' || acc.Approval_Status__c == ''){
                updatelist.add(acc);
            }
        }
        system.debug(updatelist);
        upsert updatelist;
        List<account> newaccList = [SELECT Id,Phone,Name,Contact_Person__c,GeoLocation__Latitude__s,GeoLocation__Longitude__s,Alternate_Mobile__c,Email__c,Store_Category__c,Grade__c,Approval_Status__c,Cash_Discount__c    from  Account   where ownerId =: userinfo.getUserId() and Approval_Status__c=:'Approved']; 
        return newaccList; 
    }
    
    @AuraEnabled // Not USING
    public static List<Sales_Invoice__c> getOrders(){    
        List<Sales_Invoice__c> orderList =  [SELECT Id, Name, Invoice_Date__c, Customer__c,  Visit__c, Grand_Total__c,Visit__r.EID__c FROM Sales_Invoice__c WHERE CreatedDate=TODAY AND createdById=:userinfo.getUserId()];
        system.debug('getOrders****');
        return orderList;
    }
    
    @AuraEnabled // Not USING
    public static List<Sales_Invoice_Item__c> getOrderItems(){    
        List<Sales_Invoice_Item__c> orderList =  [SELECT Id, Name, Unit_Price__c, Sales_Invoice__c, Product__c, Quantity__c, GST_Percentage__c, GST_Value__c, Total__c,Discount_Percent__c,Total_after_discount__c,Total_Before_Tax__c FROM Sales_Invoice_Item__c WHERE CreatedDate=TODAY  AND Sales_Invoice__r.CreatedById=:userinfo.getUserId()];
        return orderList;
    }
    
    @AuraEnabled // Not USING
    public static void upsertSalesInvoiceItem(List<Sales_Invoice_Item__c> orderItemList,string ordId ){

        system.debug(orderItemList);
        system.debug('orderItemList : '+orderItemList);
        system.debug('ordId-'+ordId);
        list<Sales_Invoice_Item__c>upsertlst=new list<Sales_Invoice_Item__c>();
        for(Sales_Invoice_Item__c t:orderItemList){
            Sales_Invoice_Item__c i =new Sales_Invoice_Item__c();
            i.Total__c=t.Total__c;
            i.Total_Before_Tax__c=t.Total_Before_Tax__c;
            //i.GST_Percentage__c=t.GST_Percentage__c;
            i.Product__c=t.Product__c;
            i.Stock__c = t.Stock__c;
            i.Quantity__c=t.Quantity__c;
            i.Unit_Price__c = t.Unit_Price__c;
            i.Sales_Invoice__c=ordId;
            i.Sales_Tax__c = t.Sales_Tax__c;
            i.Discount_Percent__c = t.Discount_Percent__c;
            i.Total_after_discount__c = t.Total__c;
            upsertlst.add(i);
        }
        Upsert upsertlst;
        system.debug('upsertlst : '+upsertlst);
        system.debug('upsertlst size : '+upsertlst.size());
      
        List<Sales_Invoice_Item__c> orderList =  [SELECT Id, Name, Unit_Price__c, Sales_Invoice__c, Product__c,Stock__c, Quantity__c, GST_Percentage__c, GST_Value__c, Total__c,Discount_Percent__c,Total_after_discount__c,Total_Before_Tax__c FROM Sales_Invoice_Item__c WHERE CreatedDate=TODAY  AND Sales_Invoice__r.CreatedById=:userinfo.getUserId()];
        system.debug('orderList : '+upsertlst);
        system.debug('orderList size : '+upsertlst.size());
       // return orderList;
    }
    
    @AuraEnabled // Not USING
    public static void insertSalesItem(string quoteItemList, string storeId){ 
 		List <Sales_order_item__c> editRedsLst = (List<Sales_order_item__c>) System.JSON.deserialize(quoteItemList, List<Sales_order_item__c>.Class);
        List<Sales_order_item__c> orList = new List<Sales_order_item__c>();
        for(Sales_order_item__c so : editRedsLst){
            //Sales_order_item__c ol =  (Sales_order_item__c)so;
            if(so.Sales_order__c == null){
                so.Sales_order__c = storeId;
                //so.Product__c = so.Stock__r.Product__c;
               // so.Stock__r.Product__c = null;
            //ol.Sales_order__c = storeId;
           // ol.Grand_total__c=gt;
            
            }
            orList.add(so);
            
        } 
        Sales_order__c opp = new Sales_order__c();
        opp.Id = storeId;
		system.debug('Received quote item list'+quoteItemList);
        system.debug('To be updated'+orList);
        upsert orList;
         update opp;
        //return ol.Id;
    }
    
    @AuraEnabled // Not USING
    public static void deleteSalesOrderItem(string prId){
        DELETE[SELECT Id FROM Sales_order_item__c WHERE Id=:prId];
    }

    @AuraEnabled // Not USING
    public static Decimal getCashDiscount(string storeId) {
        return [SELECT Customer__r.Cash_Discount__c FROM Sales_order__c WHERE Id =: storeId].Customer__r.Cash_Discount__c;
    }
    
     // Wrapper to set the data of all products with available stock - Mayuri
    public class productWrapper{ 
         @AuraEnabled
        public Product__c productObj {get; set;}
         @AuraEnabled
        public Decimal totalAvailableQuantity {get; set;}
    }


}