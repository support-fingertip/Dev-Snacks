public class MasterDetail{
 
 @AuraEnabled(cacheable=true)
 public static List<pickValue> getPickValues(String objectName,string fieldName){
 
         Map<String, String> mapPickListValues = new Map<String, String>();
         Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(objectName);
         Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
         Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
         List<Schema.PicklistEntry> lstPickListValues = mapFields.get(fieldName).getDescribe().getPickListValues();
         List<pickValue> pickValues =  new  List<pickValue>();
         for (Schema.PicklistEntry objPickList : lstPickListValues) {
             pickValue p = new pickValue();
             p.label =    objPickList.getLabel() ;
             p.value =    objPickList.getValue() ;
             pickValues.add(p);
         }
     system.debug(pickValues);
         return pickValues;
 
 
 }
 class pickValue{ 
 
   @AuraEnabled public string label{get;set;}
   @AuraEnabled  public string value{get;set;}
 }
    
    @AuraEnabled(cacheable=true)
    public static List<sobject> searchRecords(string  objectName, String fields, string filter ){ 
     
        
        string query = ' select ' + fields + ' from '+ objectName + filter;
        system.debug(query);
        return database.query(query);
        
    }
    @AuraEnabled(cacheable=true)
    public static records  readRecords(Id recordId){ 
        records records = new records(); 
        if(  recordId.getSObjectType().getDescribe().getName()  ==  'Order__c' ){
          records.orders = [ SELECT Visit__c, Store_name__c, Store__c,Store__r.Id,Store__r.Name, Store_Name_Text__c, OwnerId,  Order_Status__c, Order_Date__c, Name,  Id, Grand_Total__c, Grand_Total_Edit__c, EID__c FROM Order__c where id=: recordId  ] ;           
          records.order_items  = [ SELECT Id,  Name,Product__r.Name, Order__c, Current_Stock__c, Last_order_Quantity__c, Minimum_Stock__c, Price_MRP__c, Product_Name__c, Product__c, Quantity__c, TAX_Per_GST__c, Tax_Value__c, Total_Amount__c, Total_Price__c, Unit_Price__c, EID__c, Total_Edit__c, Tax_value_edit__c, Visit__c, Store__c FROM Order_Item__c   where Order__c=: recordId  ] ;           
        }
        if(  recordId.getSObjectType().getDescribe().getName()  ==  'Invoice__c' ){
          records.invoices = [ SELECT   Store__c,Store__r.Name,Store__r.Id,  OwnerId,  Invoice_Status__c, Invoice_Date__c, Name,  Id, Grand_Total__c,  EID__c FROM Invoice__c where id=: recordId  ] ;           
          records.invoice_items  = [  SELECT Id,   Name,   Invoice__c, Quantity__c, TAX_Per_GST__c, Unit_Price__c, Tax_value__c, Total_Price2__c, EID__c, Store__c FROM Invoice_item__c  where Invoice__c=: recordId  ] ;           
        }
        return records;     
        
    }
    @AuraEnabled(cacheable=false)
    public static records  saveRecords(string  recordsString ){  
        system.debug(recordsString);
         records records = (records)JSON.deserialize(recordsString, records.class);
         List<account>  accounts  = (  List<account>) records.accounts;
         List<order__c>  orders   = (  List<order__c>) records.orders;
         List<order_item__c>  order_items = (  List<order_item__c>) records.order_items;
         List<invoice__c>  invoices   = (  List<invoice__c>) records.invoices;
         List<invoice_item__c>  invoice_items = (  List<invoice_item__c>) records.invoice_items;        
        
         List<visit__c>  visits  = (  List<visit__c>) records.visits;
         List<product__c>  products  = (  List<product__c>) records.products;
         List<sobject> solist = new      List<sobject>();
        system.debug(records.invoices);
        system.debug(invoices);
         if( accounts != null){
              for(account  o :  accounts){
                   solist.add(o);
              }
         }
         if( visits != null){
             for(visit__c  o :  visits){
                  solist.add(o);
             }
         }
         if( orders != null){
             for(order__c  o :  orders){
                  solist.add(o);
             }
         }
         if( order_items != null){
             for(order_item__c o:  order_items){
                  o.order__r = new order__c(EID__c=o.EID__c.split('-')[0] );  
                  solist.add(o); 
             }
         } 
         if( invoices != null){
             for(sobject  i :  invoices){
                 system.debug(i);
                  solist.add(i);
             }
         }
         if( invoice_items != null){ 
             for(invoice_item__c i:  invoice_items){
                  i.Invoice__r = new Invoice__c(EID__c=i.EID__c.split('-')[0] );  
                  solist.add(i);  
             }
         } 
         upsert invoices;
         upsert solist; 
         return records;
    }
    
    public class records{
        @AuraEnabled public  List<account>  accounts ;
        @AuraEnabled public  List<order__c>  orders ;
        @AuraEnabled public  List<order_item__c>  order_items ;  
        @AuraEnabled public  List<invoice__c>  invoices ;
        @AuraEnabled public  List<invoice_item__c>  invoice_items ; 
        @AuraEnabled public  List<visit__c>  visits ;
        @AuraEnabled public  List<product__c>  products ;
    }
     
}