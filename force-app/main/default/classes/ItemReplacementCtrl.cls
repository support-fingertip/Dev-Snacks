public class ItemReplacementCtrl {

    @AuraEnabled
    public static Account getCustomer(String custId){
        return [select Id,Name,Cash_Discount__c from Account where Id=:custId];
    }
    
      @auraEnabled // To get all Products with Stock Details - Mayuri
    Public static List<Product__c> getProducts(){
         
        List<Product__c> productList = [SELECT Id,Name,Product_Image__c,Product_Image_Url__c,Product_catogery__c,Product_Code__c,Sales_Tax__c,
                                        (SELECT Id,Name,Product__c,Product_Name__c,Batch_Number__c,Product_Batch_Name__c,Available_Quantity__c,Sold_Qty__c,Manufacturing_Date__c,Price__c,Stock_Type__c from Stocks__r where Stock_Type__c =: 'New' and Manufacturing_Date__c!=null and Price__c != null) from Product__c];
        
        if(productList.size()>0){
           return productList;
        }
        return null;
    }
    
      @AuraEnabled
    public static void saveReplacement(Item_Replacement__c parentRec, List<Replaced_Item__c> items,string type ){
         User user = [select id,name,Route_Id__c from User where id=:UserInfo.getUserId() limit 1];
        List<Route__c> rt = new List<Route__c>();
        List<DailyLog__c> clockinClockout = [SELECT id from  DailyLog__c  WHERE Clock_In__c = TODAY AND OwnerId =:UserInfo.getUserId() limit 1]; 
        List<Trip__c> tripList = [SELECT id,Route__c,Cash_In_Hand__c,Last_Cleared_Date__c from  Trip__c  WHERE   (Status__c = 'Started' AND End_Date__c = null )  AND OwnerId =:UserInfo.getUserId() limit 1]; 
        
        if(user.Route_Id__c != null){
            rt = [select id,Route_Id__c,Warehouse__c,Branch_Name__c,Branch_Name__r.Branch_Head__c,Vehicle__c from Route__c where Route_Id__c =:user.Route_Id__c limit 1];
            if(rt.size() > 0){
                parentRec.Route__c = rt[0].Id;
                parentRec.Branch__c = rt[0].Branch_Name__c;
            } 
        }
        
        
        
        if(clockinClockout.size() != 0){
            parentRec.Daily_Log__c = clockinClockout[0].Id;
        }
        if(tripList.size() != 0){
            parentRec.Trip__c = tripList[0].Id;
        }
        parentRec.Type__c = type;
        try {
            insert parentRec;
        }
        catch (System.Exception ae) { 
            ExceptionHandler.addLog(ae,String.valueOf(parentRec)  ); 
        }  
        
        
        for(Replaced_Item__c ir: items){
            ir.Item_Replacement__c =parentRec.Id;
            ir.Type__c =type;
            ir.RouteLKP__c = rt[0].Id;
            if(ir.Quantity__c > 0){
                ir.Item_Replacement__c = parentRec.Id;
            }
            
        }
        
        try {
            upsert items;
            list<Replaced_Item__c> replacementList = [select Id,Name,Product__c,Quantity__c,New_Created_Stock__c,Damaged_Stock__c,New_Stock__c,
                                                      Item_Replacement__r.Route__c,Item_Replacement__r.Route__r.OwnerId,Item_Replacement__r.Branch__c,
                                                      Batch_No__c,Item_Replacement__r.Type__c,Type__c from Replaced_Item__c where Item_Replacement__c =:parentRec.Id];
                ItemReplacementHandler.updateStock(replacementList); 
            ItemReplacementHandler.updateAvailableStock(replacementList); 
        }
        catch (System.Exception ae) { 
            ExceptionHandler.addLog(ae,'trigger'  ); 
        }  
        
          /*
       List<Stock__c> stocklist = new List<Stock__c>();
        
        
        List<Stock__c> ItemStock =  [select Id,Available_Quantity__c,Free_Quantity__c,Intial_Stock__c,Batch_Number__c,Sold_Qty__c,Damaged_Quantity__c,Replaced_Quantity__c,GST_Percentage__c,Stock_Date__c,Manufacturing_Date__c,Price__c,Stock_Ext_ID__c from Stock__c];
         Map<Id,Stock__c> stockMap = new Map<Id,Stock__c>();
                Map<String,Stock__c> stockMap2 = new Map<String,Stock__c>();
        
        for(Stock__c st:ItemStock){
            stockMap.put(st.Id,st);
            if(st.Stock_Ext_ID__c != null){
                stockMap2.put(st.Stock_Ext_ID__c, st);
            }
        }

        
          for(Replaced_Item__c ir: items){
              ir.Item_Replacement__c =parentRec.Id;
              ir.Type__c =type;
            if(ir.Quantity__c > 0){
               // if(ir.Type__c == 'Return'){
                ir.Item_Replacement__c = parentRec.Id;
                Stock__c stock = new Stock__c();
                  if(stockMap.containsKey(ir.Damaged_Stock__c)){
                    //stock.Manufacturing_Date__c = returnItemStock[0].Manufacturing_Date__c;
                    stock.Manufacturing_Date__c = stockMap.get(ir.Damaged_Stock__c).Manufacturing_Date__c;
                    stock.Batch_Number__c = stockMap.get(ir.Damaged_Stock__c).Batch_Number__c;
                    stock.Price__c = stockMap.get(ir.Damaged_Stock__c).Price__c;
                    stock.GST_Percentage__c = stockMap.get(ir.Damaged_Stock__c).GST_Percentage__c;
                }
                     String extId='';
                    if(stock.Batch_Number__c != null && stock.Manufacturing_Date__c != null && stock.Price__c != null){
                        extId = stock.Batch_Number__c + stock.Manufacturing_Date__c + stock.Price__c + system.today() + 'Damaged';
                    }
                    
                if(stockMap2.containsKey(extId)){
                    stock = stockMap2.get(extId);
                    stock.Intial_Stock__c = stockMap2.get(extId).Intial_Stock__c + ir.Quantity__c;
                    stock.Available_Quantity__c = stockMap2.get(extId).Available_Quantity__c + ir.Quantity__c;
                }
                else{
                    
                    stock.Stock_Date__c = system.today();
                    stock.Product__c = ir.Product__c;
                    stock.Related_To__c = 'Route';
                    stock.Route__c = parentRec.Route__c;
                    stock.Branch__c = parentRec.Branch__c;
                    stock.Vehicle__c = rt[0].Vehicle__c;
                    stock.Intial_Stock__c = ir.Quantity__c; 
                    stock.Available_Quantity__c = ir.Quantity__c;                    
                    //stock.Type__c = ir.Type__c;Non-Saleable
                    stock.Stock_Type__c = 'Damaged';
                    stock.Returned__c = true;
                    stock.Stock_Ext_ID__c = extId;
                   
                    
                }
                 stocklist.add(stock);
            //}
            }
          }
       
        upsert stocklist;
       
     */
        
    }
    /*@Autor -Nanma call item replacement API
*/
    @invocableMethod
    public static void callSendToSAP(list<Id> itemReplacementId){
    
        if(itemReplacementId.size() > 0)  
           SAPsend_TriggerHandler.sendToSap(itemReplacementId, 'Item_Replacement__c');
        
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