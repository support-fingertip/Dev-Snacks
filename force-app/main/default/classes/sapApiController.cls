@RestResource(urlMapping='/api/*')
global class sapApiController {
    
    @HttpGet
    global static String  doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String url = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        String key = RestContext.request.params.get('key');
        system.debug('key:'+ key);
        String value = RestContext.request.params.get('value');
        system.debug('value:'+ value);
       // SObjectType sObjType = ((SObject) Type.forName(objectName).newInstance()).getSObjectType();
        
        String objectname=RestContext.request.params.get('value');
        databox db = new databox();
        if(Label.API_Key == key){
             if(objectname == 'customers' || objectname == ''){
            List<account> aList = new  List<account>();
            aList = [SELECT Id,Name,CompanyId__c,CustomerId__c,CardType__c,CustomerGroupCode__c,Mobile__c, Alternate_Mobile__c , Email__c , Pan_Number__c,CustomerType__c ,State__c,Branch_Id__c,GST_applicable_formula__c,Route_Id__c,(select Id,Name,Discount_Percent__c,GST_Percentage__c,Eva_Discount_Percent__c from Margins__r),(SELECT Id,Name,Address_Type__c,Address__c,Building__c,Street__c,Street_No__c,Block__c,City__c,District__c,ZipCode__c,State__c,Country__c,GST_No__c,RowNum__c FROM Addresses__r) FROM Account where Sent_to_Sap__c = false and Approval_status__c = 'Approved'];
            db.customers = aList; 
        }
        if(objectname == 'invoices' || objectname == ''){
            List<Sales_Invoice__c> invList = new List<Sales_Invoice__c>();
            invList = [SELECT Id,Name, CompanyId__c,Invoice_Number__c,Invoice_Date__c,Customer_Id__c,Route_Id__c,Driver_Code__c,Branch_Id__c,Doc_Date__c,Tax_Date__c,State__c, (SELECT Id,Name,Inv_Line_Items_Id__c,Item_Code__c,Item_Name__c,Quantity__c,Unit_Price__c,Warehouse_Code__c,Batch_No__c,Customer_Discount__c from Invoice_Items__r) FROM Sales_Invoice__c  where Sent_to_Sap__c = false];
            db.invoices = invList; 
        }
        if(objectname == 'returns' || objectname == ''){
            List<Return__c> retList = [SELECT Id,Name,CompanyId__c,Return_Id__c,Return_Type__c,Return_Date__c,Customer_Id__c,Route_Id__c,Driver_Code__c,Branch_Id__c,Doc_Date__c,Tax_Date__c,Type__c, (SELECT Id,Name,Return_Item_Id__c,Invoice_Id__c,Invoice_Item_Id__c,Item_Code__c,Item_Name__c,Quantity__c,Unit_Price__c,Warehouse_Code__c,Batch_No__c,Customer_Discount__c FROM Invoice_Items__r) FROM Return__c  where Sent_to_Sap__c = false];
            db.returns = retList; 
        }
        if(objectname == 'vehicles' || objectname == ''){
           List<Vehicle__c> vehList = [select Id,Name,CompanyId__c,Code__c,Vehicle_Number__c,Model__c,Engine__c,Capacity__c,Registration_Date__c from Vehicle__c  where Sent_to_Sap__c = false];
           db.vehicles = vehList;
        }
        if(objectname == 'expenses' || objectname == ''){
            List<Expense__c> expList = [select Id,Name,CompanyId__c,Branch_Id__c,Expense_Date__c,Expense_Id__c,Total_Amount__c,Account_Id__c,Account_Code__c from Expense__c where Sent_to_Sap__c = false];
            db.expenses = expList;
        }
        if(objectname == 'receipts' || objectname == ''){
            List<Receipt__c> reclist = [select Id,Name,CompanyId__c,Receipt_Id__c,Customer_Id__c,Branch_Id__c,Receipt_Date__c,Tax_Date__c,Amount__c,Mode_of_payment__c,Cheque_Date__c,Cheque_Trasaction_Number__c,Bank_Name__c,Type__c,(select Id,Name,Receipt_Item_Id__c,Invoice_Id__c,Amount__c from Receipt_Items__r) from Receipt__c where Sent_to_Sap__c = false];
            db.receipts = reclist;
        }
        if(objectname == 'stockRequests' || objectname == ''){
            
            List<Stock_Request__c> reqlist = [SELECT Id,Name,CompanyId__c, Stock_Request_Id__c, Request_Date__c,Branch_Id__c, Warehouse_Id__c, Vehicle_Id__c,Route_Id__c,(select Id,Name,Item_Code__c,Quantity__c,Stock_Request_Item_Id__c from Stock_Request_Items__r) FROM Stock_Request__c  where Sent_to_Sap__c = false  and Status__c = 'Approved' ];
            db.stockRequests = reqlist;
        }
        if(objectname == 'employees' || objectname == ''){
            List<Employee__c> emplist = [select Id,Name,CompanyId__c,Employee_Id__c,Designation__c,Email__c,Mobile__c,Role__c from Employee__c  where Sent_to_Sap__c = false];
            db.employees = emplist;
        }
       if(objectname == 'routes' || objectname == ''){
            List<Route__c> routelist = [select Id,Name,CompanyId__c,Route_Id__c,State__c,District__c,Week__c,Week_Sales__c from Route__c  where Sent_to_Sap__c = false];
            db.routes = routelist;
            
        }
            if(objectname == 'payments' || objectname == ''){
                list<Payment__c> payments=[select Id,Name,CompanyId__c,Receipt_Id__c,Customer_Id__c,Route_Id__c,Branch_Id__c,Amount__c,Bouncing_Charge__c,Docdate__c,State__c from Payment__c where Sent_to_SAP__c =false];
                db.payments = payments;
            }     
            if(objectname == 'ItemReplacements' || objectname == ''){
                //list<Item_Replacement__c> ItemReplacements=[SELECT Id, Name, Damaged_stock_Batch_Number__c,New_Stock_Batch_Number__c, Item_Code__c, Route_Id__c, Branch_Id__c, Company_Id__c, Customer_Id__c, Date__c,Quantity__c FROM Item_Replacement__c where Sent_to_SAP__c =false];
              //  db.ItemReplacements = ItemReplacements;
            }     
        
       
        Map<String,Object> accMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(db));
        Map<String,Object> responseMap = removeAttributes(accMap);
        //responseMap.values().remove(null);
        String jsonString = JSON.serialize(responseMap.values());
        jsonString = jsonString.replace('{"records":', '').replace('"done":true},','');
       // jsonString = jsonString.replaceFirst('\\[', '').removeEnd(']');
        //system.debug('JSON.serializePretty(db):' + JSON.serialize(db));
         return jsonString;
        
        }
        else{
            Map<String,String> errorMap = new Map<String,String>();
            errorMap.put('error', 'Authorisation error');
            errorMap.put('message','Invalid Key.');
            String errorJson = JSON.serializePretty(errorMap);
           return errorJson;
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
    
    global class databox{
        List<account> customers;
        List<Sales_Invoice__c> invoices;
        List<Return__c> returns;
        List<Vehicle__c> vehicles;
        List<Expense__c> expenses;
        List<Receipt__c> receipts;
        List<Stock_Request__c> stockRequests;
        List<Employee__c> employees;
        List<Route__c> routes;
        List<Payment__c> payments;
        List<Item_Replacement__c> ItemReplacements;
        
        
    }
    
  
}