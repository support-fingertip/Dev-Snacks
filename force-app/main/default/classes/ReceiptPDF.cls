public class ReceiptPDF {
    Public String numToWord{get;set;}
    public List<Receipt_Item__c> receiptItems {get; set; }
     public Branch__c branchRecord{get; set;}
    public string rid;
    
    public ReceiptPDF(ApexPages.StandardController controller) 
    {
        rid=ApexPages.currentPage().getParameters().get('id'); 
        system.debug(rid+'Hello');
        Receipt__c rec = [select Id,Name,Initial_On_Account_Value__c,Route__r.Branch_Name__c from Receipt__c where Id=:rid];
        receiptItems = [select id,Sales_Invoice__r.Name,Amount__c from Receipt_Item__c where Receipt__c =: rid];
        system.debug('receiptItems == '+receiptItems);
        
        numberToWordConvertor inv = new numberToWordConvertor();
        numToWord = inv.getNumberTOWordConvertion(rec.Initial_On_Account_Value__c);
        
          List<Branch__c> branchRec = [select id,Account_Id__c,Account_Name__c,Address__c,Branch_Id__c,Cash_In_Hand__c,Company_Id__c,Contact_Number__c,
                                     District__c,Emails__c,GST_No__c,Name,State__c,Warehouse__c,Fssai_Licence_Number__c from Branch__c where Id =:rec.Route__r.Branch_Name__c Limit 1];
        if(branchRec.size()>0){
            branchRecord = branchRec[0];
        }
        
        
    }
    
}