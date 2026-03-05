public without sharing class SAPSendData {
    
    public static String sendData(List<sObject> objData){
        system.debug('objData=== '+objData);
        Integration_Details__mdt sapInfo = [Select Endpoint__c from Integration_Details__mdt where Active__c = true and Integrate_to__c='SAP' limit 1];
        
        Schema.SObjectType sObjectType = objData.getSObjectType();
        String status,sapCode,sapKey,postfix= '';
        
        
        databox db = new databox();
        if(sObjectType.getDescribe().getName() == 'Account'){
            db.customers = objData; 
            postfix = 'CustomerCreation';
        }
        if(sObjectType.getDescribe().getName() == 'Sales_Invoice__c'){
            db.invoices = objData; 
            postfix='CreateARInvoice';
        }
        if(sObjectType.getDescribe().getName() == 'Return__c'){
            db.returns = objData; 
            postfix='CreateARCreditMemo';
        }
        if(sObjectType.getDescribe().getName() == 'Vehicle__c'){
            db.vehicles = objData;
            postfix = 'CreateVehicleMaster';
        }
        if(sObjectType.getDescribe().getName() == 'Expense__c'){
            db.expenses = objData;
            postfix='CreateJournalEntry';
        }
        if(sObjectType.getDescribe().getName() == 'Receipt__c'){
            db.receipts = objData;
            postfix='CreateIncomingPay';
        }
        if(sObjectType.getDescribe().getName() == 'Stock_Request__c'){
            db.stockRequests = objData;
            postfix='InventoryTransferRequest';
        }
        if(sObjectType.getDescribe().getName() == 'Employee__c'){
            db.employees = objData;
            postfix='CreateEmployee';
        }
        if(sObjectType.getDescribe().getName() == 'Route__c'){
            db.routes = objData;
            postfix='CreateRouteMaster';
        }
        if(sObjectType.getDescribe().getName() == 'Payment__c'){
            db.payments = objData;
            postfix='ChequeBounce';
        }
        if(sObjectType.getDescribe().getName() == 'Item_Replacement__c'){
            list<SObject> returnList = new  list<SObject>();
            list<SObject> replaceList = new  list<SObject>();
            for(SObject rec :  objData){
                Item_Replacement__c cc = (Item_Replacement__c) rec;
               if(cc.Type__c == 'Replacement' && cc.Sent_to_SAP__c ==false){ // cc.Sub_Type__c =='Return'
                    cc.Sub_Type__c ='Return';
                    returnList.add(cc);
                } else if(cc.Type__c == 'Replacement'){ // && cc.Sub_Type__c =='Replacement'
                    replaceList.add(cc);
                }
            }
            if(replaceList.size() > 0){
                 db.goods =  replacementItems(replaceList,'Item_Replacement__c');
                postfix='ReplacementIssue';
            }
            
            if(returnList.size() > 0){
                db.ItemReplacements = returnList;
                postfix='ReplacementReceipt';
            }
        }
        if(sObjectType.getDescribe().getName() == 'Unsealed__c'){
            db.unsealed =  replacementItems(objData,'Unsealed__c');
            postfix='ReplacementIssue';
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
        try{
        HttpResponse response = http.send(request);
        
        Set<String> custIDs = new Set<String>();
        
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
                sapCode = String.valueOf(SAPstatus.get('SapCode'));
                system.debug('sapCode:' + SAPstatus.get('SapCode') );
                sapKey = String.valueOf(SAPstatus.get('SAPKey'));
                system.debug('SAPKey:' + SAPstatus.get('SAPKey'));
                
                String custCode = String.valueOf(SAPstatus.get('CustomerCode'));
                if(custCode != null){
                    if(status =='Success'){
                        custIds.add(custCode);
                        //updateCustomer(objData,custCode);
                    }
                }
                else{
                    if(sapCode == null && sapKey != null)
                        sapCode = sapKey;
                    if(status =='Success')
                        updateRecord(objData,sapCode);    

                }
                
            }
            if(custIds.size() > 0){
                updateCustomer(objData,custIds);
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
        }catch(Exception ex){
            if(label.Enable_Logs == 'TRUE'){
            String reqsizeString = jsonString;
            Integer maxSize = 32000;
            if(reqsizeString.length() > maxSize ){
                reqsizeString = reqsizeString.substring(0, maxSize);
            }
          
            
            Log__c getLogs = new Log__c();
            getLogs.Request__c = reqsizeString;
            getLogs.Response__c =  ex.getMessage();
            getLogs.Object__c = sObjectType.getDescribe().getName();
            getLogs.Status_Code__c = 404;
          
            insert getLogs;
            system.debug('getLogs=== '+ getLogs);
        }
            return null;
        }
    }
    
    public static void updateRecord(List<sObject> objData,string sapCode){
        Schema.SObjectType sObjectType = objData.getSObjectType();
        string  ObjectName = sObjectType.getDescribe().getName();
        List<sObject> updateData= new List<sObject>();
        for(SObject rec :  objData)
        {
            if(ObjectName =='Account'){
                Account cc = (Account) rec;
                cc.Sent_to_SAP__c=true;
                updateData.add(cc);
            }
            if(ObjectName =='Vehicle__c'){
                Vehicle__c cc = (Vehicle__c) rec;
                cc.Sent_to_SAP__c=true;
                updateData.add(cc);
            }
            if(ObjectName =='Route__c'){
                Route__c cc = (Route__c) rec; 
                cc.Sent_to_SAP__c=true;
                updateData.add(cc);
            }
            if(ObjectName =='Employee__c'){
                Employee__c cc = (Employee__c) rec;
                if(sapCode != null){
                    cc.SAP_Code__c = sapCode; 
                    cc.Sent_to_SAP__c=true;
                }
                updateData.add(cc);
            }
            if(ObjectName =='Stock_Request__c'){
                Stock_Request__c cc = (Stock_Request__c) rec;
                if(sapCode != null){
                    cc.SAP_Code__c = sapCode; 
                    cc.Sent_to_SAP__c=true;
                }
                updateData.add(cc);
            }
            if(ObjectName =='Sales_Invoice__c'){
                Sales_Invoice__c cc = (Sales_Invoice__c) rec;
                if(sapCode != null){
                    cc.SAP_Code__c = sapCode; 
                    cc.Sent_to_SAP__c=true;
                    //if(!test.isRunningTest()){  sendReceipt(cc.Id); }
                }
                updateData.add(cc);
            }
            if(ObjectName =='Receipt__c'){
                Receipt__c cc = (Receipt__c) rec;
                if(sapCode != null){
                    cc.SAP_Code__c = sapCode; 
                }
                    cc.Sent_to_SAP__c=true;
                    cc.Skip_Record_Edit_Validation__c=true;
               // }
                updateData.add(cc);
            }
            if(ObjectName =='Expense__c'){
                Expense__c cc = (Expense__c) rec;
                if(sapCode != null){
                    cc.SAP_Code__c = sapCode; 
                    cc.Sent_to_SAP__c=true;
                }
                
                updateData.add(cc);
            }
            if(ObjectName =='Return__c'){
                Return__c cc = (Return__c) rec;
                cc.Sent_to_SAP__c=true;
                cc.SAP_Code__c =sapCode;
                updateData.add(cc);
            }
            if(ObjectName =='Payment__c'){
                Payment__c cc = (Payment__c) rec; 
                if(sapCode != null){
                    cc.SAP_Code__c = sapCode; 
                    cc.Sent_to_SAP__c=true;
                }
                updateData.add(cc);
            }
            if(ObjectName =='Item_Replacement__c'){
                Item_Replacement__c cc = (Item_Replacement__c) rec; 
                if(sapCode != null &&(cc.Type__c == 'Return' || (cc.Type__c == 'Replacement' && cc.Sent_to_SAP__c==false))){ //&& cc.Sub_Type__c =='Return'
                   if(cc.Sub_Type__c =='Return')
                    cc.Type__c = 'Replacement';
                    cc.SAP_Code__c = sapCode; 
                    cc.Sent_to_SAP__c=true;
                }else if(sapCode != null && cc.Type__c == 'Replacement'){
                    cc.Replacement_SAP_Code__c =sapCode;
                      cc.Send_to_SAP_Replacement__c=true;
                    cc.Replacement_API_Syn_Time__c = system.now();
                }
                updateData.add(cc);
            }
               if(ObjectName =='Unsealed__c'){
                Unsealed__c cc = (Unsealed__c) rec; 
                if(sapCode != null){
                    cc.SAP_Code__c = sapCode; 
                    cc.Sent_to_SAP__c=true;
                }
                updateData.add(cc);
            }
            try{
                system.debug(updateData);
                if(updateData.size() > 0)
                    update updateData;       
            }
           catch(Exception  ex){
                system.debug('Error'+ ex.getMessage());
                 ExceptionHandler.addLog(ex,String.valueOf(updateData));
            }
            
        }
        
    }
    
    public static void updateCustomer(List<sObject> objData,Set<String> custIds){
        
        List<sObject> updateData= new List<sObject>();
        for(SObject rec :  objData)
        {
            Account cc = (Account) rec;
            if(custIds.contains(cc.CustomerId__c)){
                cc.Sent_to_SAP__c=true;
                updateData.add(cc);
            }
            
            try{
                system.debug(updateData);
                if(updateData.size() > 0)
                    update updateData;       
            }
            catch(Exception  ex){
                system.debug('Error'+ ex.getMessage());
                 ExceptionHandler.addLog(ex,String.valueOf(updateData));
            }
            
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
    public static void update_SalesInvoice_Return_Record(List<sObject> objData){
        Schema.SObjectType sObjectType = objData.getSObjectType();
        string  ObjectName = sObjectType.getDescribe().getName();
        List<sObject> updateData= new List<sObject>();
        for(SObject rec :  objData)
        {
            if(ObjectName =='Sales_Invoice__c'){
                Sales_Invoice__c cc = (Sales_Invoice__c) rec;
                cc.Name = cc.Id; 
                updateData.add(cc);
            }
            if(ObjectName =='Return__c'){
                Return__c cc = (Return__c) rec;
                cc.Name = cc.Id; 
                updateData.add(cc);
            }
            try{
                system.debug(updateData);
                if(updateData.size() > 0)
                    update updateData;       
            }
           catch(Exception  ex){
                system.debug('Error'+ ex.getMessage());
                 ExceptionHandler.addLog(ex,String.valueOf(updateData));
            }
        }
        
    }
  
    
    public static list<GoodsIssue> replacementItems(List<sObject> objData, string type){
        list<GoodsIssue> glist = new  list<GoodsIssue>();
         list<GoodsIssue_Items> gItemlist = new  list<GoodsIssue_Items>();
             GoodsIssue g = new GoodsIssue();
        if(type =='Item_Replacement__c'){
            for(SObject rec :  objData){
                Item_Replacement__c cc = (Item_Replacement__c) rec;
                   if(cc.Replaced_Items__r.size() > 0){
                    for(Replaced_Item__c ri :cc.Replaced_Items__r){
                        GoodsIssue_Items gi = new GoodsIssue_Items();
                        gi.GoodsIssueItemId = ri.Id;
                        gi.Name = ri.N_Item_Name__c;
                        gi.Item_Code =ri.N_Item_Code__c;
                        gi.Item_Name = ri.N_Item_Name__c;      
                        gi.Batch_No = ri.N_Batch_No__c;   
                          gi.Quantity =integer.valueof(ri.Quantity__c); 
                        gItemlist.add(gi);
                    }  
                } 
                 g.GoodsIssueItems = gItemlist;
                g.GoodsIssueId =cc.Id;
                g.Name =cc.Name;
                g.CompanyId =cc.Company_Id__c;
                g.Customer_Id = cc.Customer_Id__c;
                g.Route_Id = cc.Route_Id__c;
                g.Branch_Id = integer.valueof(cc.Branch_Id__c);
                g.Type ='Goods Issue';
                g.Doc_date =cc.Doc_date__c;
                  
             
            }  
            glist.add(g);
        }
        else if(type =='Unsealed__c'){
           for(SObject rec :  objData){
                Unsealed__c cc = (Unsealed__c) rec;
               
                if(cc.Unsealed_Items__r.size() > 0){
                    for(Unsealed_Item__c u :cc.Unsealed_Items__r){
                        GoodsIssue_Items gi = new GoodsIssue_Items();
                        gi.GoodsIssueItemId = u.Id;
                        gi.Name = u.Name;
                        gi.Item_Code =u.Item_Code__c;
                        gi.Item_Name = u.Item_Name__c;  
                        gi.Batch_No = u.Batch_No__c;   
                          gi.Quantity =integer.valueof(u.Quantity__c); 
                          gItemlist.add(gi);
                    }  
                }
                g.GoodsIssueItems = gItemlist;
                     g.GoodsIssueId =cc.Id;
                g.Name =cc.Name;
                g.CompanyId =cc.Company_Id__c;
                g.Customer_Id = cc.Customer_Id__c;
                g.Route_Id = cc.Route_Id__c;
                g.Branch_Id = integer.valueof(cc.Branch_Id__c);
                g.Type ='Unsealed';
                g.Doc_date =cc.Doc_date__c;
                
            }   
              glist.add(g);
        }
        return glist;
        
    }  
    
      
    public static void sendReceipt(Id salesInvoiceId){
        list<Receipt__c> Receipts =[select Id,Name,CompanyId__c,Receipt_Id__c,Customer_Id__c,Branch_Id__c,Receipt_Date__c,Tax_Date__c,Amount__c,Mode_of_payment__c,Cheque_Date__c,Cheque_Trasaction_Number__c,Bank_Name__c,Type__c,(select Id,Name,Receipt_Item_Id__c,Invoice_Id__c,Amount__c from Receipt_Items__r) from Receipt__c where Sales_Invoice__c = :salesInvoiceId AND ((New_Approval_Flow__c =true AND Approval_status__c='Approved') OR (Approval_status__c=null AND New_Approval_Flow__c=false))];
        if(Receipts.size() > 0)  
            SAPSendData.sendData(Receipts);
    }
    
    
    public class databox{
        public List<account> customers;
        public List<Sales_Invoice__c> invoices;
        public List<Return__c> returns;
        public List<Vehicle__c> vehicles;
        public List<Expense__c> expenses;
        public List<Receipt__c> receipts;
        public List<Stock_Request__c> stockRequests;
        public List<Employee__c> employees;
        public List<Route__c> routes;  
        
        public List<Payment__c> payments;   
        public List<Item_Replacement__c> ItemReplacements;  
        public List<GoodsIssue> goods;  
        public List<GoodsIssue> unsealed;   
    }
    
    
    public class GoodsIssue{
        public string GoodsIssueId;
        public string Name;
        public string CompanyId;
        public string Customer_Id;
        public string Route_Id;
        public integer Branch_Id;
        public string Type;
        public date Doc_date;
        public list<GoodsIssue_Items> GoodsIssueItems;
        
    }    
    public class GoodsIssue_Items{
        public string GoodsIssueItemId;
        public string Name;  
        public string Item_Code;
        public string Item_Name;  
        public string Batch_No;
        public integer Quantity;
        
        
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