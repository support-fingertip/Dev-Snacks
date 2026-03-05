public class NewOrderController {
  @auraEnabled
    Public static List<Stock__c> getStock(){
        return [SELECT Id,name,Product__r.Name,Available_Quantity__c,Batch_Number__c,Price__c FROM Stock__c];
    }
}