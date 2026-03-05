@RestResource(urlMapping='/send/*')
global class SAPGetData {
    
    @HttpPost
    global static void  doPost() {
        RestRequest req=RestContext.request;
        RestResponse res = RestContext.response;
        
        String url = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        String key = RestContext.request.params.get('key');
        //system.debug('key:'+ key);
        String value = RestContext.request.params.get('value');
       // system.debug('value:'+ value);
        
        String data = req.requestBody.toString();
        
        system.debug('data:' + data);
        
        String postfix = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        if(Label.API_Key == key){
            
            Map<String, Object> prodMap = (Map<String, Object>) JSON.deserializeUntyped(data);
            Map<String, Object> prodMap2 = (Map<String, Object>) JSON.deserializeUntyped(data);
            
            for(String key2 : prodMap2.keySet()) {
                
                if(prodMap2.get(key2) == null){
                    prodMap2.remove(key2);
                }
            }
            
            
            List<string > finalJsonString = new List<string>();
            List<Map<String, Object>> datalist = new List<Map<String, Object>>();
            
            for (Object instance : (List<Object>)prodMap.get('data')){
                
                finalJsonString.add(JSON.serialize(instance)); 
                datalist.add((Map<String, Object>)instance);
            }
            
            system.debug('finalJsonString:' + finalJsonString);
            
            Map<String, Object> succMap = new Map<String, Object>();
            Map<String, Object> errMap = new Map<String, Object>();
            
            if(value == 'productMaster'){
                
                List < Response > lstResponse = new List < Response > ();
                
                List<Product__c> prdlist = new List<Product__c>();
                List<String> prdIds = new List<String>();
                for(string s: finalJsonString){
                    s = s.replaceFirst('\\{', '{"attributes" : {"type" : "Product__c", "referenceId" : "ref1"},');
                    Product__c prd = (Product__c)JSON.deserialize(s, Sobject.class);
                    System.debug('prd '+ prd);
                    // prdlist.add(prd); //prdIds.add(prd.Product_Code__c); //Database.upsert(prd);
                    try{
                        upsert prd;
                        
                                                /*   Map<String,String> successMap = new Map<String,String>();
                        successMap.put('Status', 'Success');
                        successMap.put('Id',JSON.serialize(prdIds));
                        
                        String successJson = JSON.serializePretty(successMap);
                        system.debug('successJson:' + successJson);
                        res.responseBody = Blob.valueOf(successJson);*/
                        
                        
                        lstResponse.add(new Response('Success',prd.Product_Code__c));
                        
                        // return successJson;
                    }
                    catch(DmlException ex){
                                                /* Map<String,String> errorMap = new Map<String,String>();
                        errorMap.put('Status', 'Failure');
                        errorMap.put('Message',ex.getMessage());
                        String errorJson = JSON.serializePretty(errorMap);*/
                                                
                                                //List < Response > lstResponse = new List < Response > ();
                        lstResponse.add(new Response('Failure', prd.Product_Code__c,ex.getMessage()));
                        // res.statusCode = 500;
                        //res.addHeader('Content-Type', 'application/json');
                        //res.responseBody = Blob.valueOf(JSON.serialize(lstResponse));
                        
                        //return errorJson;
                    }
                    
                }
                res.statusCode = 200;
                res.addHeader('Content-Type', 'application/json');
                res.responseBody = Blob.valueOf(JSON.serialize(lstResponse));
                
                if(label.Enable_Logs == 'TRUE'){
                    String reqsizeString = data;
                    Integer maxSize = 32000;
                    if(reqsizeString.length() > maxSize ){
                        reqsizeString = reqsizeString.substring(0, maxSize);
                    }
                    String ressizeString = JSON.serialize(lstResponse);
                    if(ressizeString.length() > maxSize ){
                        ressizeString = ressizeString.substring(0, maxSize);
                    }                    
                    Log__c getLogs = new Log__c();
                    getLogs.Request__c = reqsizeString;
                    getLogs.Response__c = ressizeString;
                    getLogs.Object__c = 'Product';
                    getLogs.Status_Code__c = res.statusCode;
                    insert getLogs;
                  //  system.debug('getLogs=== '+ getLogs);
                }
                
            }
            else if(value == 'StockTransfer'){
                string sockrequestId='';
                List < Response > lstResponse = new List < Response > ();
                Map<String,Stock_Request__c> reqMap = new Map<String,Stock_Request__c>();
                Map<String,Stock_Request_Item__c> reqlstMap = new Map<String,Stock_Request_Item__c>();
                Map<String,Stock_Request_Item__c> reqlstMapBatch = new Map<String,Stock_Request_Item__c>();
                for(string s: finalJsonString){
                    
                    s = s.replaceFirst('\\{', '{"attributes" : {"type" : "Stock_Request__c", "referenceId" : "ref1"},');
                    s = s.replace('[{','{"records": [{').replaceFirst('}]','}]}');
                    
                    Stock_Request__c sreq = (Stock_Request__c)JSON.deserialize(s, sObject.class);
                    sreq.status__c = 'Transferred';
                    
                    System.debug('sreq: '+ sreq);
                    reqMap.put(sreq.Stock_Request_Id__c,sreq);
                    //upsert sreq;
                    
                    String req1 = s.substringBetween('[', ']');
                    List<String> strlst = req1.split('},');
                  //  system.debug('strlst:' + strlst.size());
                    for(String item: strlst){
                        item = '{"attributes" : {"type" : "Stock_Request_Item__c", "referenceId" : "ref1"},'+item.remove('{')+'}';
                      //  system.debug('item:' + item);
                        Stock_Request_Item__c reqItem = (Stock_Request_Item__c)JSON.deserialize(item, sObject.class);
                        //reqItem.Stock_Request__c = sreq.Id;
                       // System.debug('reqItem: '+ reqItem);
                      //  system.debug('reqlstMap:' + reqlstMap);
                       // system.debug('reqItem.Stock_Request_Item_Id__c:' + reqItem.Stock_Request_Item_Id__c);
                        // if(!reqlstMap.containsKey(reqItem.Stock_Request_Item_Id__c)){
                        if(reqItem.Stock_Request_Item_Id__c != null){
                            reqlstMap.put(reqItem.Stock_Request_Item_Id__c,reqItem);
                        }
                        else{
                            reqlstMapBatch.put(reqItem.Batch_Number__c,reqItem);
                        }
                        
                        //upsert reqItem;
                    }
                    
                }
                
                Map<String,Product__c> prdMap = new Map<String,Product__c>();
                List<Product__c> prdList = [select Id,Name,Product_Code__c from Product__c];
                for(Product__c prd: prdList){
                    prdMap.put(prd.Product_Code__c, prd);
                }
                
                Map<String,Stock_Request__c> reqMapToUpdate = new Map<String,Stock_Request__c>();
                Map<String,Stock_Request_Item__c> reqlstMapToUpdate = new Map<String,Stock_Request_Item__c>();
                List<String> reqIds = new List<String>();
                List<Stock_Request__c> reqlist = [select Id,Name,CompanyId__c,Stock_Request_Id__c,Request_Date__c,Vehicle_Id__c,Route_Id__c,Branch_Id__c,Warehouse_Id__c,(select Id,Name,Stock_Request_Item_Id__c,Item_Code__c,Quantity__c,Status__c,Transfered_Quantity__c,Batch_Number__c,Margin__c from Stock_Request_Items__r) from Stock_Request__c where Stock_Request_Id__c IN :reqMap.keySet()];
                if(reqlist.size() > 0){
                    for(Stock_Request__c sreq:reqlist){
                        Stock_Request__c stockReq = new Stock_Request__c();
                        stockReq = reqMap.get(sreq.Stock_Request_Id__c);
                        stockReq.Id = sreq.Id;
                        stockReq.Status__c = 'Transferred';
                        reqMapToUpdate.put(sreq.Id,stockReq);
                        reqIds.add(sreq.Stock_Request_Id__c);
                       sockrequestId=sreq.Id;
                        for(Stock_Request_Item__c item: sreq.Stock_Request_Items__r){
                            if(reqlstMap.containsKey(item.Stock_Request_Item_Id__c)){
                                Stock_Request_Item__c stockItem = new Stock_Request_Item__c();
                                stockItem = reqlstMap.get(item.Stock_Request_Item_Id__c);
                                stockItem.Stock_Request__c = sreq.id;
                                stockItem.Status__c = 'Transferred';
                                stockItem.Id = item.Id;
                                reqlstMapToUpdate.put(item.id,stockItem);
                            }
                        }
                        
                        if(reqlstMapBatch.size() > 0){
                            for(Stock_Request_Item__c item: reqlstMapBatch.values() ){
                                Stock_Request_Item__c stockItem = new Stock_Request_Item__c();
                                stockItem = reqlstMapBatch.get(item.Batch_Number__c);
                                stockItem.Stock_Request__c = sreq.id;
                                stockItem.Status__c = 'Transferred';
                                stockItem.Product__c = prdMap.get(item.Item_Code__c).Id;
                                
                                reqlstMapToUpdate.put(item.Batch_Number__c,stockItem);
                            }
                        }
                        try{
                            Update stockReq;
                            system.debug('reqlstMapToUpdate:' + reqlstMapToUpdate.values());
                            upsert reqlstMapToUpdate.values();
                            
                            lstResponse.add(new Response('Success', stockReq.Stock_Request_Id__c));
                            
                            reqlstMapToUpdate.clear();
                            // return successJson;
                        }
                        catch(DmlException ex){
                            
                            // List < Response > lstResponse = new List < Response > ();
                            lstResponse.add(new Response('Failure', stockReq.Stock_Request_Id__c, ex.getMessage()));
                            //res.statusCode = 500;
                            // res.addHeader('Content-Type', 'application/json');
                            // res.responseBody = Blob.valueOf(JSON.serialize(lstResponse));
                            //return errorJson;
                        }
                        
                    }
                }
                else{
                    lstResponse.add(new Response('Failure',  'Stock Request Id Not found.'));
                }
                
                res.statusCode = 200;
                res.addHeader('Content-Type', 'application/json'); 
                res.responseBody = Blob.valueOf(JSON.serialize(lstResponse));
                // System.debug('reqMapToUpdate:' + reqMapToUpdate.values());
                //  System.debug('reqlstMapToUpdate:' + reqlstMapToUpdate.values());
                
                if(label.Enable_Logs == 'TRUE'){
                    String reqsizeString = data;
                    Integer maxSize = 32000;
                    if(reqsizeString.length() > maxSize ){
                        reqsizeString = reqsizeString.substring(0, maxSize);
                    }
                    String ressizeString = JSON.serialize(lstResponse);
                    if(ressizeString.length() > maxSize ){
                        ressizeString = ressizeString.substring(0, maxSize);
                    }                    
                    Log__c getLogs = new Log__c();
                    getLogs.Request__c = reqsizeString;
                    getLogs.Response__c = ressizeString;
                    getLogs.Object__c = 'Stock Transfer';
                    getLogs.Status_Code__c = res.statusCode;
                    getLogs.RecordId__c=sockrequestId;
                    insert getLogs;
                 //   system.debug('getLogs=== '+ getLogs);
                }
            }
            else{
                                    /* Map<String,String> errorMap = new Map<String,String>();
                    errorMap.put('Error', 'Wrong parameter');
                    errorMap.put('Message','Invalid Value.');
                    String errorJson = JSON.serializePretty(errorMap);*/
                
                List < Response > lstResponse = new List < Response > ();
                lstResponse.add(new Response('Failure', 'Invalid Parameter Value.',false));
                res.statusCode = 403;
                res.addHeader('Content-Type', 'application/json');
                res.responseBody = Blob.valueOf(JSON.serialize(lstResponse));   
                // return errorJson;
            }
            
        }
        else{
                            /*Map<String,String> errorMap = new Map<String,String>();
                errorMap.put('Error', 'Authorisation error');
                errorMap.put('Message','Invalid Key.');
                String errorJson = JSON.serializePretty(errorMap);*/
            List < Response > lstResponse = new List < Response > ();
            lstResponse.add(new Response('Failure', 'Invalid Key.',false));
            res.statusCode = 401;
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(JSON.serialize(lstResponse));               
            //return errorJson;
        }
        
        
    }
    
    public class Response {
        public String Status;
        public String Message;
        public String ID;
        public Response(String Status, String ID) {
            this.Status = Status;
            this.ID = ID;
        }
        public Response(String Status, String Message,Boolean noIds) {
            this.Status = Status;
            this.Message = Message;
        }
        public Response(String Status, String ID, String Message) {
            this.Status = Status;
            this.ID = ID;
            this.Message = Message;
        }
    }
}