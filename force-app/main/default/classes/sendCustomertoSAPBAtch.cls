global class sendCustomertoSAPBAtch  implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful{
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query='SELECT Id,Name,CompanyId__c,CustomerId__c,CardType__c,CustomerGroupCode__c,Mobile__c, Alternate_Mobile__c , Email__c , Pan_Number__c,CustomerType__c ,State__c,Branch_Id__c,GST_applicable_formula__c,Route_Id__c,(select Id,Name,Discount_Percent__c,GST_Percentage__c from Margins__r),(SELECT Id,Name,Address_Type__c,Address__c,Building__c,Street__c,Street_No__c,Block__c,City__c,District__c,ZipCode__c,State__c,Country__c,GST_No__c,RowNum__c FROM Addresses__r) FROM Account where Sent_to_Sap__c = false and Approval_Status__c = \'Approved\'';
       system.debug(Database.getQueryLocator(query));
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Account> scope){
       try{
            SAPSendData.sendData(scope);
        }
       catch(Exception ex){
            system.debug('Error'+ ex.getMessage());
       }
        
        /*   Integration_Details__mdt sapInfo = [Select Endpoint__c from Integration_Details__mdt where Active__c = true and Integrate_to__c='SAP' limit 1];
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        request.setEndpoint(sapInfo.Endpoint__c + 'CustomerCreation');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setTimeout( 120000 );
        // Set the body as a JSON object
        
        SAPSendData.databox db = new SAPSendData.databox();
        db.customers = scope;
        
        Map<String,Object> objMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(db));
        system.debug('objMap:' + objMap);
        
        Map<String,Object> responseMap = removeAttributes(objMap);
        //responseMap.values().remove(null);
        String jsonString = JSON.serialize(responseMap.values());
        jsonString = jsonString.replace('{"records":', '').replace('"done":true},','');
        jsonString = jsonString.replaceFirst('\\[', '').removeEnd(']');
        system.debug('jsonString:' + jsonString);
        
        request.setBody(jsonString);
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
                String status = String.valueOf(SAPstatus.get('Status'));
               
                String custCode = String.valueOf(SAPstatus.get('CustomerCode'));
                if(custCode != null){
                    if(status =='Success'){
                        custIds.add(custCode);
                        //updateCustomer(objData,custCode);
                    }
                }
               
                
            }
            if(custIds.size() > 0){
                       List<sObject> updateData= new List<sObject>();
        for(Account rec :  scope)
        {
            
            if(custIds.contains(rec.CustomerId__c)){
                rec.Sent_to_SAP__c=true;
                updateData.add(rec);
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
            System.debug(response.getBody());
        }
        
        if(label.Enable_Logs == 'TRUE'){
            Log__c getLogs = new Log__c();
            getLogs.Request__c = jsonString;
            getLogs.Response__c = response.getBody();
            getLogs.Object__c = 'Account';
            getLogs.Status_Code__c = response.getStatusCode();
            getLogs.Status_Message__c = response.getStatus();
            insert getLogs;
            system.debug('getLogs=== '+ getLogs);
        }
        */
        
        
    }
    
    public void finish(Database.BatchableContext BC){
    }
    /*  private static Map<String,Object> removeAttributes(Map<String,Object> jsonObj)  {
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
    }*/
}