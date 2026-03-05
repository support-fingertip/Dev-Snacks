public class vanStockController {
 public list<Stock_History__c> stockList{get;set;}
      public vanStockController(){
     
        Id recordId = ApexPages.currentPage().getParameters().get('Id'); 
        String fromDate = ApexPages.currentPage().getParameters().get('from'); 
        String toDate = ApexPages.currentPage().getParameters().get('to'); 
          if(fromDate != null && toDate!= null && recordId != null){
             Date fromDate1 = date.valueof(fromDate);
        Date toDate1 = date.valueof(toDate);
        stockList = [SELECT Id, Opening_Quantity__c, Initial_Quantity__c, Total_Quantity__c, Sold_Quantity__c, Available_Quantity__c, Damaged_Quantity__c, Free_Quantity__c, Unsealed_Quantity__c, Date__c, Total_Qty__c, Product__c,Product__r.Name FROM Stock_History__c where Route__c=:recordId and (DAY_ONLY(createdDate)>=:fromDate1  and DAY_ONLY(createdDate)<=:toDate1) limit 1000];
        }
      }
}