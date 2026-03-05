public class Einvoice_Send_TriggerHandler {
    @Future(callout=true)
    public static void sendToPortal(list<Id> recIds,string type){
        for(Id recId: recIds){
            try{
                SalesEinvoice.sendData(recId,type);   
            }
          catch(Exception   ex){
                system.debug('Error'+ ex.getMessage());
                ExceptionHandler.addLog(ex,String.valueOf(recId));
            }
        }
    }
        @Future(callout=true)
    public static void sendToPortalCredit(list<Id> recIds,string type){
        for(Id recId: recIds){
            try{
                SalesEinvoiceCreditDebit.sendData(recId,type);   
            }
            catch(Exception   ex){
                system.debug('Error'+ ex.getMessage());
                ExceptionHandler.addLog(ex,String.valueOf(recId));
            }
        }
    }
    @AuraEnabled
    public static integer SendToPortal_call(Id recordId,string type){
        integer count =0,approvedcount=0,gstApplicable=0;
        string query,query1,Approved='Approved';
        list<Id> IdList =new list<Id>();
        if(recordId != null){
            IdList.add(recordId);  
            String objName = recordId.getSObjectType().getDescribe().getName();  
            if(objName == 'Sales_Invoice__c' && type == 'Generate'){
                query = 'select count() from Sales_Invoice__c where Id=:recordId and GST_applicable_formula__c=true and Send_to_GSTZen__c=false ';        
            }
                if(objName == 'Sales_Invoice__c' && type == 'Cancel'){
                query = 'select count() from Sales_Invoice__c where Id=:recordId and GST_applicable_formula__c=true and Send_to_GSTZen__c=true ';        
            }
            system.debug(query1);
            if(query != '' && query != null){
                    gstApplicable =  database.countQuery(query);
                system.debug(query);
                system.debug('gst'+gstApplicable);
                if(gstApplicable == 0){
                    count = 3;
                }
            }
            if(gstApplicable == 1){
                sendToPortal(IdList,type);
                // count= checkDataUpdated(objName,recordId);
                count = 1;
            }
        }
        return count; 
    } 
    
     
        /*@Autor -Nanma send IRN to Sap*/
    @invocableMethod
    public static void callSendToSAP(list<Id> SalesInvIds){
      list<Sales_Invoice__c> salesInvoice =[SELECT Id, Name, CompanyId__c, Route_Id__c, Driver_Code__c, Branch_Id__c, Doc_Date__c, Tax_Date__c, Invoice_Number__c, Customer_Id__c,State__c,IRN_Number__c,(SELECT Id, Name, Inv_Line_Items_Id__c, Item_Code__c, Item_Name__c, Quantity__c, Unit_Price__c, Warehouse_Code__c, Batch_No__c,Customer_Discount__c FROM Invoice_Items__r) FROM Sales_Invoice__c where Id in :SalesInvIds and Sent_to_SAP__c=false];
       // if(salesInvoice.size() > 0)    sendData(salesInvoice);
         if(salesInvoice.size() > 0)  
           SAPSendData.sendData(salesInvoice);
    
    }
    
        @AuraEnabled
    public static integer SendToPortal_creditCall(Id recordId,string type){
        integer count =0,gstApplicable=0;
        string query,query1,Approved='Approved';
        list<Id> IdList =new list<Id>();
        if(recordId != null){
            IdList.add(recordId);  
            String objName = recordId.getSObjectType().getDescribe().getName();  

             if(objName == 'Return__c' && type == 'Generate'){
                 query= 'select count() from Return__c where Id=:recordId and Approval_Status__c=:Approved and Sales_Invoice__r.GST_applicable_formula__c=true  ';          
            }
                if(objName == 'Return__c' && type == 'Cancel'){
                query = 'select count() from Return__c where Id=:recordId and Send_to_GSTZen__c=true ';        
            }
            if(query != '' && query != null){
                    gstApplicable = database.countQuery(query);
                system.debug(query);
             
                if(gstApplicable == 0 && type == 'Generate'){
                    count = 2;
                }
                  if(gstApplicable == 0 && type == 'Cancel'){
                    count = 3;
                }
            }
            if(gstApplicable == 1){
                sendToPortalCredit(IdList,type);
                count = 1;
            }
        }
        return count; 
    } 
          
}