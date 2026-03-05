public class NewStockReqController {

    
      @auraEnabled
    Public static List<Product__c> getStock(){
        return [SELECT Id,name from Product__c];
    }
     @AuraEnabled
    public static String getUIThemeDescription() {
        String theme = UserInfo.getUiThemeDisplayed();
        return theme;
    }
    
    @auraEnabled
    public static Product__c getSelectedProduct(string recordId){
        List<Product__c> selectedProduct = [select Id,Name, Product_Code__c, Item_Description__c, Unit__c,Product_catogery__c,Product_Image__c,Product_Image_Url__c,Fixed_Price_Item__c
                                            from Product__c where Id =: recordId Limit 1];
        return selectedProduct[0];
    }
    
      @auraEnabled
    Public static List<Product__c> getProducts(String pageSize, String pageNumber, string searchText, string sortDirection,string sortBy, string searchType){
        List<Product__c> plist = new List<Product__c>();
        String searchKey = '%'+searchText+ '%';
 
        String query = 'select Id,Name, Product_Code__c, Item_Description__c, Unit__c,Product_catogery__c,Product_Image__c,Product_Image_Url__c,Fixed_Price_Item__c from Product__c';
        if (String.isNotBlank(searchText)) {
            if(searchType == 'Name'){
                query += ' where (Name like: searchKey)';
            } else if(searchType == 'Code'){
                query += ' where (Product_Code__c LIKE: searchKey)';
            } 
        }
 
        query += ' limit 1000';
        system.debug('query:' + query);
        plist =  Database.query(query);
        system.debug('plist:' + plist);
        
        return plist;
    }
    
      @AuraEnabled
    public static String saveNewRequest(List<Stock_Request_Item__c> reqList ){
        system.debug(reqList);
        User user = [select id,name,Route_Id__c from User where id=:UserInfo.getUserId() limit 1];
        List<Route__c> rt = new List<Route__c>();

        Stock_Request__c sr = new Stock_Request__c();
        sr.Request_Date__c = system.today();
        sr.Status__c = 'Requested';
        if(user.Route_Id__c != null){
            rt = [select id,Route_Id__c,Warehouse__c,Branch_Name__c,Branch_Name__r.Manager_Name__c,Vehicle__c from Route__c where Route_Id__c =:user.Route_Id__c limit 1];
            if(rt.size() > 0){
                sr.Route__c = rt[0].Id;
                sr.Vehicle__c = rt[0].Vehicle__c;
                sr.Branch__c = rt[0].Branch_Name__c;
                sr.Godown_Manager__c = rt[0].Branch_Name__r.Manager_Name__c;
            }
        }
        
        //insert sr;
         try {
           insert sr;
        }
        catch (System.Exception ae) { 
            ExceptionHandler.addLog(ae,String.valueOf(sr) ); 
        }     
        
        for(Stock_Request_Item__c sri: reqList){
            sri.Stock_request__c = sr.Id;
        }
        
          try {
           insert reqList;
        }
        catch (System.Exception ae) { 
            ExceptionHandler.addLog(ae,String.valueOf(reqList) ); 
        }     
      
        return sr.Id;
    }
  /*  @AuraEnabled
    public static List<Invoice_item__c> upsertReqItem(string  orderItemList,string ordId ){
      
      /*  List<Order_Item__c> ordItList = new List<Order_Item__c>();
        for(Order_Item__c ord : orderItemList){
          Order_Item__c orl = ord;
            ordItList.add(orl);
        }
          upsert orderItemList;*/
      /*   system.debug(orderItemList);
        system.debug('ordId-'+ordId);
        string newstring = orderItemList.replace('[','');
        string newstring2 = newstring.replace(']','');
        string newstring3 = '['+newstring2+']';
        string newstring4 = newstring3.replace('Id', 'Product__c');
         List<Invoice_item__c> ordList = (List<Invoice_item__c>)JSON.deserialize( newstring4, List<Invoice_item__c>.class);
        system.debug('final list-'+ordList);
        list<Invoice_item__c>upsertlst=new list<Invoice_item__c>();
        for(Invoice_item__c t:ordList){
            Invoice_item__c i =new Invoice_item__c();
            i.Total_Amount__c=t.Total_Amount__c;
            i.TAX_Per_GST__c=t.TAX_Per_GST__c;
            i.Product__c=t.Product__c;
            i.Quantity__c=t.Quantity__c;
            i.Invoice__c=ordId;
            upsertlst.add(i);
        }
        Upsert upsertlst;
      
       /* system.debug(orderItemList + ' '+storeId);
        List<Order_Item__c> orList = new List<Order_Item__c>();
        Order__c ord = new Order__c();
        ord.Store__c = storeId;
        ord.Order_Date__c = system.today();
        //ord.Grand_Total__c = grandtotal;
        insert ord;
        
        for(Order_Item__c ol : orderItemList){
            ol.Order__c = ord.id;
            orList.add(ol);
            
        }
        insert orList;*/
     /*    List<Invoice_item__c> orderList =  [SELECT Id, Name,Invoice__r.EID__c,Visit__r.EID__c,Store__r.EID__c, Unit_Price__c,Visit__c,Store__c, Price_MRP__c, Invoice__c, Product__c, Quantity__c, TAX_Per_GST__c, Tax_Value__c, Total_Amount__c, Total_Price__c FROM Invoice_item__c WHERE CreatedDate=TODAY  AND Invoice__r.OwnerId=:userinfo.getUserId()];

        return orderList;
    }*/
    
}