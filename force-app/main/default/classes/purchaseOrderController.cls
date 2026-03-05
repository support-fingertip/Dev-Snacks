public class purchaseOrderController {
     @AuraEnabled
    public static databox getdata(string recId){
        databox db = new databox();
        system.debug(recId);
        if(recId !=null && recId !=''){
        Purchase_order__c po = [SELECT Id,Name,Po_date__c,Vendor__c,vendor__r.Name,Grand_Total__c FROM Purchase_order__c WHERE Id=:recId];
        db.poDate = po.PO_Date__c;
        db.vendorId = po.Vendor__c;
        db.vendorName = po.vendor__r.Name;
        db.grandTotal = po.Grand_Total__c;
        db.recId = recId;
        db.recList = [SELECT Id, Name, Product__c, Ordered_Quantity__c, Unit_Price__c, Tax__c, Total_Price__c, Product_Name__c FROM PO_Item__c WHERE Purchase_order__c=:recId];    
        }
        db.productList = [SELECT Id,Name,Product_Code__c,TAX_Per_GST__c FROM Product__c];
        db.vendorList =  [SELECT Id,Name FROM Vendor__c];
        return db;
    }
    @AuraEnabled
    public static List<Product__c> getproductList(){    
        List<Product__c> listproducts =  [SELECT Id,Name,Product_Code__c FROM Product__c];
        return listproducts;
    }
    @AuraEnabled
    public static List<Vendor__c> getVendorList(){    
        List<Vendor__c> listvendors =  [SELECT Id,Name FROM Vendor__c];
        return listvendors;
    }
     @AuraEnabled
    public static string insertItemList(List<PO_Item__c> ItemList, string parentId, string objName, string vendorId, date poDate ){ 
        system.debug(ItemList + ' '+parentId);
        List<PO_Item__c> orList = new List<PO_Item__c>();
        Purchase_Order__c po = new Purchase_Order__c();
        po.Vendor__c = vendorId;
        po.PO_Date__c = poDate;
       insert po;
        for(PO_Item__c ol : ItemList){
            ol.Purchase_Order__c = po.id;
            orList.add(ol);
        }
        insert orList;
        return po.Id;
    }
     public class databox{
         @AuraEnabled
        public List<PO_Item__c> recList;
         @AuraEnabled
        public List<Product__c> productList;
         @AuraEnabled
        public List<Vendor__c> vendorList;
         @AuraEnabled
        public Decimal grandTotal;
          @AuraEnabled
        public string vendorId;
          @AuraEnabled
        public date poDate;
         @AuraEnabled
        public string vendorName;
        @AuraEnabled
        public string objectName;
         @AuraEnabled
        public string recId;
        
    }

}