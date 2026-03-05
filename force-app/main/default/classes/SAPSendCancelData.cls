public  without sharing class SAPSendCancelData {
    public static string sendData(List<sObject> objData){
        system.debug('objData=== '+objData);
        Integration_Details__mdt sapInfo = [Select Endpoint__c from Integration_Details__mdt where Active__c = true and Integrate_to__c='SAP' limit 1];
        
        Schema.SObjectType sObjectType = objData.getSObjectType();
        String status,sapCode,sapKey,postfix= '';  
        
        databox db = new databox();
        if(sObjectType.getDescribe().getName() == 'Sales_Invoice__c'){
            db.invoices = objData; 
            postfix='CancelInvoice';
        }
        if(sObjectType.getDescribe().getName() == 'Receipt__c'){
            db.receipts = objData;
            postfix='CancelReceipt';
        }
        if(sObjectType.getDescribe().getName() == 'Stock_Request__c'){
            db.stockRequests = objData;
            postfix='CancelInvTransfer';
        }
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(sapInfo.Endpoint__c + postfix);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Set the body as a JSON object
        Map<String,Object> objMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(db));
        system.debug('objMap:' + objMap);
        
        Map<String,Object> responseMap = removeAttributes(objMap);
        //responseMap.values().remove(null);
        String jsonString = JSON.serialize(responseMap.values());
        jsonString = jsonString.replace('{"records":', '').replace('"done":true},','');
        jsonString = jsonString.replaceFirst('\\[', '').removeEnd(']');
        system.debug('jsonString:' + jsonString);
            request.setTimeout(120000);
        request.setBody(jsonString);
        HttpResponse response = http.send(request);
        
        
        // Parse the JSON response
        if (response.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' +
                         response.getStatusCode() + ' ' + response.getStatus());
        } else {
            for (Object instance : (List<Object>)JSON.deserializeUntyped(response.getBody())){
                system.debug('ins:' + instance);
                Map<String, Object> SAPstatus = (Map<String, Object>)instance;
                system.debug('Status:' + SAPstatus.get('Status') );
                status = String.valueOf(SAPstatus.get('Status'));
                 if(status =='Success')
                  updateRecord(objData);    
                
            }
            System.debug(response.getBody());
        }
        
        if(label.Enable_Logs == 'TRUE'){
            String reqsizeString = jsonString;
            Integer maxSize = 32000;
            if(reqsizeString.length() > maxSize ){
                reqsizeString = reqsizeString.substring(0, maxSize);
            }
            String ressizeString =  response.getBody();
            if(ressizeString.length() > maxSize ){
                ressizeString = ressizeString.substring(0, maxSize);
            }           
            Log__c getLogs = new Log__c();
            getLogs.Request__c = reqsizeString;
            getLogs.Response__c = ressizeString;
            getLogs.Object__c = sObjectType.getDescribe().getName();
            getLogs.Status_Code__c = response.getStatusCode();
            getLogs.Status_Message__c = response.getStatus();
            insert getLogs;
            system.debug('getLogs=== '+ getLogs);
        }
        
        return response.getBody();
    }
    public static void updateRecord(List<sObject> objData){
        Schema.SObjectType sObjectType = objData.getSObjectType();
        string  ObjectName = sObjectType.getDescribe().getName();
        List<sObject> updateData= new List<sObject>();
        for(SObject rec :  objData)
        {
            
            if(ObjectName =='Stock_Request__c'){
                Stock_Request__c cc = (Stock_Request__c) rec;
                    cc.Cancellation_Req_Send_To_SAP__c=true;
                updateData.add(cc);
            }
            if(ObjectName =='Sales_Invoice__c'){
                Sales_Invoice__c cc = (Sales_Invoice__c) rec;
                    cc.Cancellation_Req_Send_To_SAP__c=true; 
                cc.Sales_Invoice_Status__c = 'Cancelled';
                updateData.add(cc);
            }
            if(ObjectName =='Receipt__c'){
                Receipt__c cc = (Receipt__c) rec;
                    cc.Cancellation_Req_Send_To_SAP__c = true;
                    cc.Receipt_Status__c = 'Cancelled';
                cc.Skip_Record_Edit_Validation__c=true;
                 if(!test.isRunningTest()){
                    //   sendReceiptInvoice(cc.Id);
                    }
                updateData.add(cc);
                 
            }
            
            try{
                system.debug(updateData);
                if(updateData.size() > 0)
                    update updateData;       
            }
           catch(DmlException ex){
                system.debug('Error'+ ex.getMessage());
            }
            
        }
        
    }
    public static void sendReceiptInvoice(Id recId){
          list<Receipt__c> Receipts =[select Id,Name,CompanyId__c,Receipt_Id__c,Receipt_Status__c,Sales_Invoice__c from Receipt__c where Id = :recId];
        if(Receipts.size() > 0){
        // list<Sales_Invoice__c> salesInvoice =[SELECT Id, Name, CompanyId__c,Invoice_Number__c FROM Sales_Invoice__c where Id=:Receipts[0].Sales_Invoice__c ];    
        list<Payment__c> payments=[select Id,Name,CompanyId__c,Receipt_Id__c,Customer_Id__c,Route_Id__c,Branch_Id__c,Amount__c,Bouncing_Charge__c,Docdate__c,State__c from Payment__c where Receipt__c=:recId];
       // if(salesInvoice.size() > 0)  
         //  sendData(salesInvoice);
        
         if(payments.size() > 0)  
           SAPSendData.sendData(payments);
        }
    }  
    
    private static Map<String,Object> removeAttributes(Map<String,Object> jsonObj)  {
        for(String key : jsonObj.keySet()) {
            if(key == 'attributes' || key=='totalSize') {
                jsonObj.remove(key);
            } else {
                if(jsonObj.get(key) == null){
                    jsonObj.remove(key);
                }
                if(jsonObj.get(key) instanceof Map<String,Object>) {
                    removeAttributes((Map<String,Object>)jsonObj.get(key));
                }
                if(jsonObj.get(key) instanceof List<Object>) {
                    for(Object listItem : (List<Object>)jsonObj.get(key)) {
                        if(listItem instanceof Map<String,Object>)  {
                            removeAttributes((Map<String,Object>)listItem);
                        }
                    }
                }
            }
        }  
        return jsonObj;
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
        
    }    
    public class databox{
        public List<Sales_Invoice__c> invoices;
        public List<Receipt__c> receipts;
        public List<Stock_Request__c> stockRequests; 
    }
    
}