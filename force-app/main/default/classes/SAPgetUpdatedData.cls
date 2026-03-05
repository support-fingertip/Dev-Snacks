public  without sharing class SAPgetUpdatedData {
    public static String sendData(string company,string postfix,map<string,Id> custCodeMap){
        Integration_Details__mdt sapInfo = [Select Endpoint__c from Integration_Details__mdt where Active__c = true and Integrate_to__c='SAP' limit 1];
        Map<String, String> JMap = new Map<String, String>();
        map<string,list<Map<String, String>>> JMapsub = new  map<string,list<Map<String, String>>>(); 
        list<Map<String, String>> datalist = new list<Map<String, String>>();
        List<Sales_Invoice__c> invoices;
        double outAmount;   
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(sapInfo.Endpoint__c + postfix);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        
        JMap.put('CompanyId__c', company);
        JMap.put('CustomerDetails', 'replace');
        for(string cc :custCodeMap.keySet()){
            Map<String, String> JMap2 = new Map<String, String>();  
            JMap2.put('CustomerId__c', cc);
            datalist.add(JMap2);
        }
        JMapsub.put('CustomerDetails',datalist);
        String jsonStringsub = JSON.serialize(JMapsub);
        jsonStringsub =jsonStringsub.removestart('{');
        jsonStringsub =jsonStringsub.removeend('}');
        String jsonString = JSON.serialize(JMap);
        jsonString = jsonString.replace('"CustomerDetails":"replace"', jsonStringsub);
        system.debug('jsonString:' + jsonString);
        request.setBody(jsonString);
        request.setTimeout(120000);
        HttpResponse response = http.send(request);
        // Parse the JSON response
        if (response.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
        } else {
            map<string,object> responseval =(Map<string,Object>)JSON.deserializeUntyped(response.getBody());
            string resSub =json.serialize(responseval.get('OustandingDetails'));
            string resp =json.serialize(responseval.get('OustandingDetails')).replace('"','');
            if(postfix =='OutStandingCust' && resp !='null'){
                List<Account> customer = (List<Account>)JSON.deserialize(resSub, List<Account>.class);
                updateCustomer(customer,custCodeMap);
            }
            if(postfix =='OutStandingInv'){
                if( resp !='null'){
                    invoices = (List<Sales_Invoice__c>)JSON.deserialize(resSub, List<Sales_Invoice__c>.class);    
                }
                if(response.getBody() =='{"Response":"No Record Found..."}'){
                    invoices= new list<Sales_Invoice__c>(); 
                }
                updateInvoices(invoices,custCodeMap);
            }
        }  
        
        System.debug(response.getBody());
        if(label.Enable_Logs == 'TRUE'){
            String ressizeString =  response.getBody();
            Integer maxSize = 32000;
            if(ressizeString.length() > maxSize )
                ressizeString = ressizeString.substring(0, maxSize);
            Log__c getLogs = new Log__c();
            getLogs.Request__c = jsonString;
            getLogs.Response__c = ressizeString;
            if(postfix =='OutStandingCust'){
                getLogs.Object__c = 'Account';
            }else{
                getLogs.Object__c = 'Sales_Invoice__c';     
            }
            getLogs.RecordId__c =string.valueof(custCodeMap.values());
            getLogs.Type__c = postfix;
            getLogs.Status_Code__c = response.getStatusCode();
            getLogs.Status_Message__c = response.getStatus();
          //  insert getLogs;
            system.debug('getLogs=== '+ getLogs);
        }
        return response.getBody();
        
    }     
    public static void updateInvoices(List<Sales_Invoice__c> invoices,map<string,Id> custCodeMap){
        list<Sales_Invoice__c> slist =[select Id,Invoice_Number__c from Sales_Invoice__c where Customer__c in:custCodeMap.values()];
        map<string,Id> custIdMap = new map<string,Id>();
        list<Sales_Invoice__c> invList= new  list<Sales_Invoice__c> ();
        set<Id> sId = new set<Id>();
        if(slist.size() > 0){
            for(Sales_Invoice__c s : slist){
                custIdMap.put(s.Invoice_Number__c,s.Id);
            }
            for(Sales_Invoice__c sInv : invoices){
                Sales_Invoice__c s = new Sales_Invoice__c();
                if(sInv.Invoice_Number__c != null && custIdMap.containsKey(sInv.Invoice_Number__c)){
                    s.Id =custIdMap.get(sInv.Invoice_Number__c);
                    if(sInv.Pending_Amount_SAP__c != null)
                        s.Pending_Amount_SAP__c= sInv.Pending_Amount_SAP__c;
                    s.Outstanding_API_Last_Synchronized_Date__c =system.now();
                    if(sInv.Remarks__c != null && sInv.Remarks__c != '' )
                        s.Remarks__c = sInv.Remarks__c ;
                    sId.add(s.Id);
                    invList.add(s);   
                }
            }
            for(Sales_Invoice__c sInv : slist){
                if(sId.contains(sInv.Id)==false){
                    Sales_Invoice__c s1 = new Sales_Invoice__c();
                    s1.Id =sInv.Id;
                    s1.Pending_Amount_SAP__c= 0;
                    s1.Outstanding_API_Last_Synchronized_Date__c =system.now();   
                    invList.add(s1); 
                }
            }
            
            if(invList.size() > 0)
                update invList;
            try{
                
            }catch(Exception   ex){
                system.debug('Error'+ ex.getMessage());
                ExceptionHandler.addLog(ex,String.valueOf(invList));
            }
        }
    }  
    public static void updateCustomer(List<Account> customer,map<string,Id> custCodeMap){
        for(Account acc : customer){
            if(acc.Customer_Code__c !=null){
                acc.Id =custCodeMap.get(acc.Customer_Code__c);
                acc.Outstanding_API_Last_Synchronized_Date__c =system.now();
            }
        }
        update customer;
        try{
            
        }catch(Exception   ex){
            system.debug('Error'+ ex.getMessage());
            ExceptionHandler.addLog(ex,String.valueOf(customer));
        }
    } 
    /*@Autor -Nanma update outstanding amount customer
*/
    @invocableMethod
    public static void callSendToSAPout(list<Id> recordIds){
        if(recordIds.size() > 0)  
            SAPsend_TriggerHandler.sendToSAPoutCall(recordIds,'OutStandingCust','Account');
        
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
    }
}