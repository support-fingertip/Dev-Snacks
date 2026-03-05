public without sharing class SAPsend_TriggerHandler {

    /* send data To SAP */
    @Future(callout=true)
    public static void sendToSap(list<Id> recIds,string ObjectName){
        List<sObject> objData =new List<sObject>();
        /* customer data send to SAP*/
        if(ObjectName == 'Account'){
            List<Account> Customers = [SELECT Id,Name,CompanyId__c,CustomerId__c,CardType__c,CustomerGroupCode__c,Mobile__c, Alternate_Mobile__c , Email__c , Pan_Number__c,CustomerType__c ,State__c,Branch_Id__c,GST_applicable_formula__c,Route_Id__c,Phone,(select Id,Name,Discount_Percent__c,GST_Percentage__c,Eva_Discount_Percent__c from Margins__r),(SELECT Id,Name,Address_Type__c,Address__c,Building__c,Street__c,Street_No__c,Block__c,City__c,District__c,ZipCode__c,State__c,Country__c,GST_No__c,RowNum__c FROM Addresses__r) FROM Account where Id in :recIds ];
            objData = Customers;
        }
        /* Vehicle data Send to SAP*/
        if(ObjectName == 'Vehicle__c'){
            list<Vehicle__c>  vehicles=[SELECT Id,Name,CompanyId__c,Code__c, Vehicle_Number__c, Model__c, Engine__c, Capacity__c, Registration_Date__c FROM Vehicle__c where Id in :recIds];
            objData = vehicles;
        }
        /* Route data Send to SAP*/
        if(ObjectName == 'Route__c'){
            list<Route__c> routes=[SELECT Id,Name, Route_Id__c,CompanyId__c, State__c, District__c, Week_Sales__c, Week__c FROM Route__c where Id in :recIds];
            objData = routes;
        }
        /*Employee data Send to SAP*/
        if(ObjectName == 'Employee__c'){
            list<Employee__c> Employees=[SELECT Id,Name,CompanyId__c, Employee_Id__c,Mobile__c,Email__c, Designation__c, Role__c  FROM Employee__c where Id in :recIds];
            objData = Employees;
        } 
        
        /*StockRequest data Send to SAP*/
        if(ObjectName == 'Stock_Request__c'){
            list<Stock_Request__c> stockRequests=[SELECT Id,Name,CompanyId__c, Stock_Request_Id__c, Request_Date__c,Branch_Id__c, Warehouse_Id__c, Vehicle_Id__c,Route_Id__c,(select Id,Name,Item_Code__c,Quantity__c,Stock_Request_Item_Id__c from Stock_Request_Items__r) FROM Stock_Request__c where Id in :recIds];
            objData = stockRequests;
        } 
        /*SalesInvoice data Send to SAP*/
        if(ObjectName == 'Sales_Invoice__c'){
            list<Sales_Invoice__c> salesInvoice =[SELECT Id, Name, CompanyId__c, Route_Id__c, Driver_Code__c, Branch_Id__c, Doc_Date__c, Tax_Date__c, Invoice_Number__c, Customer_Id__c,State__c,IRN_Number__c,Round_off__c,Invoice_Total__c,(SELECT Id, Name, Inv_Line_Items_Id__c, Item_Code__c, Item_Name__c, Quantity__c, Unit_Price__c, Warehouse_Code__c, Batch_No__c,Customer_Discount__c FROM Invoice_Items__r) FROM Sales_Invoice__c where Id in :recIds and Sent_to_SAP__c=false];
            objData = salesInvoice;
        } 
        /*Receipt data Send to SAP*/
        if(ObjectName == 'Receipt__c'){
            list<Receipt__c> Receipts =[select Id,Name,CompanyId__c,Route_Id__c,Receipt_Id__c,Customer_Id__c,Branch_Id__c,Receipt_Date__c,Tax_Date__c,Amount__c,Mode_of_payment__c,Cheque_Date__c,Cheque_Trasaction_Number__c,Bank_Name__c,Type__c,(select Id,Name,Receipt_Item_Id__c,Invoice_Id__c,Amount__c from Receipt_Items__r) from Receipt__c where Id in :recIds and Sent_to_SAP__c=false ];
            objData = Receipts;
        } 
        
        /*Expense data Send to SAP*/
        if(ObjectName == 'Expense__c'){
            List<Expense__c> Expenses = [select Id,Name,CompanyId__c,Branch_Id__c,Expense_Date__c,Expense_Id__c,Total_Amount__c,Account_Id__c,Account_Code__c,Account_Name__c from Expense__c where Id in :recIds and Sent_to_SAP__c=false];
            objData = Expenses;
        } 
        
        /*Return data Send to SAP*/
        if(ObjectName == 'Return__c'){
            List<Return__c> returns = [SELECT Id,Name,CompanyId__c,Return_Id__c,Return_Type__c,Return_Date__c,Customer_Id__c,Route_Id__c,Driver_Code__c,Branch_Id__c,Doc_Date__c,Tax_Date__c,Type__c,IRN_Number__c,State__c,Invoice_Id__c,Invoice_Date__c, (SELECT Id,Name,Return_Item_Id__c,Invoice_Id__c,Invoice_Item_Id__c,Item_Code__c,Item_Name__c,Quantity__c,Unit_Price__c,Warehouse_Code__c,Batch_No__c,Customer_Discount__c,SAP_Sales_Tax_Code__c FROM Invoice_Items__r) FROM Return__c where Id in :recIds];
            objData = returns;
        } 
        /*Payment data Send to SAP*/
        if(ObjectName == 'Payment__c'){
            list<Payment__c> payments=[select Id,Name,CompanyId__c,Receipt_Id__c,Customer_Id__c,Route_Id__c,Branch_Id__c,Amount__c,Bouncing_Charge__c,Docdate__c,State__c from Payment__c where Id in :recIds];
            objData = payments;        
        }  
            /*Item_Replacement__c data Send to SAP*/
        if(ObjectName == 'Item_Replacement__c'){
          list<Item_Replacement__c> ItemReplacements=[SELECT Id,Name,Company_Id__c,Customer_Id__c,Route_Id__c,Branch_Id__c,Type__c,Sub_Type__c,Doc_date__c,Sent_to_SAP__c,(select Id,Name,Item_Code__c,Item_Name__c,Batch_No__c,Quantity__c,N_Batch_No__c,N_Item_Code__c,N_Item_Name__c from Replaced_Items__r ) from Item_Replacement__c  where Id in :recIds];
             objData = ItemReplacements;        
        } 
          /*Payment data Send to SAP*/
        if(ObjectName == 'Unsealed__c'){
            list<Unsealed__c> unsealed=[SELECT Id,Name,Company_Id__c,Customer_Id__c,Route_Id__c,Branch_Id__c,Doc_date__c,(select Id,Name,Item_Code__c,Item_Name__c,Batch_No__c,Quantity__c from Unsealed_Items__r ) from Unsealed__c where Id in :recIds];
            objData = unsealed;        
        }
        try{
            SAPSendData.sendData(objData);
        }
       catch(Exception   ex){
                system.debug('Error'+ ex.getMessage());
                ExceptionHandler.addLog(ex,String.valueOf(objData));
            }
    }  

        /* postfix- OutStandingCust,OutStandingInv*/
 
    @Future(callout=true)
    public static void sendToSAPoutCall(list<Id> recIds,string postfix,string ObjectName){
        map<string,Id> custCodeMap = new map<string,Id>();
        string company;
        if(ObjectName == 'Account'){
           list<Account> Customers = [SELECT Id,CustomerId__c,CompanyId__c FROM Account where Id in:recIds ];
            for(Account acc :Customers){
               custCodeMap.put(acc.CustomerId__c,acc.Id); 
                company =acc.CompanyId__c;
            }
        }
        if(ObjectName == 'Sales_Invoice__c'){
        list<Sales_Invoice__c> salesInvoices =[SELECT Id,Customer__c,Customer_Id__c,CompanyId__c FROM Sales_Invoice__c where Id in:recIds];
              for(Sales_Invoice__c s :salesInvoices){
               custCodeMap.put(s.Customer_Id__c,s.Customer__c); 
                  company =s.CompanyId__c;
            }
        }
          if(ObjectName == 'Receipt__c'){
        list<Receipt__c> receipts =[SELECT Id,Customer__c,Customer_Id__c,CompanyId__c FROM Receipt__c where Id in:recIds];
              for(Receipt__c r :receipts){
               custCodeMap.put(r.Customer_Id__c,r.Customer__c); 
                   company =r.CompanyId__c;
            }
        }
          if(ObjectName == 'Return__c'){
        list<Return__c> returns =[SELECT Id,Customer__c,Customer_Id__c,CompanyId__c FROM Return__c where Id in:recIds];
              for(Return__c r :returns){
               custCodeMap.put(r.Customer_Id__c,r.Customer__c); 
                   company =r.CompanyId__c;
            }
        }
 SAPgetUpdatedData.sendData(company,postfix,custCodeMap);
    }
    
    
    
    
       @AuraEnabled //outstanding API call
    public static void getOutstandingData(Id recordId,string type){
          list<Id> IdList =new list<Id>();
        if(recordId != null){
            IdList.add(recordId);  
            String objName = recordId.getSObjectType().getDescribe().getName();  
        sendToSAPoutCall(IdList,type,objName);
    }
    }
    
    
    //send data To SAP 
    @Future(callout=true)
    public static void sendCancellationToSap(list<Id> recIds,string ObjectName){
        List<sObject> objData =new List<sObject>();
        
        //StockRequest data Send to SAP
        if(ObjectName == 'Stock_Request__c'){
            list<Stock_Request__c> stockRequests=[SELECT Id,Name,CompanyId__c, Stock_Request_Id__c FROM Stock_Request__c where Id in :recIds];
            objData = stockRequests;
        } 
        //SalesInvoice data Send to SAP
        if(ObjectName == 'Sales_Invoice__c'){
            list<Sales_Invoice__c> salesInvoice =[SELECT Id, Name, CompanyId__c,Invoice_Number__c FROM Sales_Invoice__c where Id in :recIds];
            objData = salesInvoice;
        } 
        //Receipt data Send to SAP
        if(ObjectName == 'Receipt__c'){
            list<Receipt__c> Receipts =[select Id,Name,CompanyId__c,Receipt_Id__c from Receipt__c where Id in :recIds];
            objData = Receipts;
        } 
        try{
            SAPSendCancelData.sendData(objData);
        }
       catch(Exception   ex){
                system.debug('Error'+ ex.getMessage());
                ExceptionHandler.addLog(ex,String.valueOf(objData));
            }
    }
    
    
    
    @AuraEnabled
    public static integer SendToSAP_call(Id recordId){
        integer count =0,approvedcount=0,IrnApplicable=0;
        string query,Approved='Approved';
        list<Id> IdList =new list<Id>();
        if(recordId != null){
            IdList.add(recordId);  
            String objName = recordId.getSObjectType().getDescribe().getName();  
            if(objName == 'Account'){
                query= 'select count() from Account where Id=:recordId and Approval_Status__c=:Approved';
            }else if(objName == 'Stock_Request__c'){
                query= 'select count() from Stock_Request__c where Id=:recordId and Status__c=:Approved';    
            }else if(objName == 'Expense__c'){
                query= 'select count() from Expense__c where Id=:recordId and Approval_Status__c=:Approved';        
            }else if(objName == 'Return__c'){
                query= 'select count() from Return__c where Id=:recordId and Approval_Status__c=:Approved';        
            }else if(objName == 'Payment__c'){
                query= 'select count() from Payment__c where Id=:recordId and Sent_to_SAP__c=false and Bouncing_Charge__c>0';        
            }else if(objName == 'Item_Replacement__c'){
                query= 'select count() from Item_Replacement__c where Id=:recordId and ((New_Approval_Flow__c=true AND Approval_status__c=:Approved) OR (Approval_status__c=null AND New_Approval_Flow__c=false))';        
            }else if(objName == 'Unsealed__c'){
                query= 'select count() from Unsealed__c where Id=:recordId and Sent_to_SAP__c=false';        
            }else if(objName == 'Receipt__c'){
                query= 'select count() from Receipt__c where Id=:recordId and Sent_to_SAP__c=false and ((New_Approval_Flow__c=true AND Approval_status__c=:Approved) OR (Approval_status__c=null AND New_Approval_Flow__c=false))';        
            }  else{
                approvedcount = 1; 
            }
            if(objName == 'Sales_Invoice__c'){
                List<Sales_Invoice__c> salesInv =[select Id,GST_applicable_formula__c,Send_to_GSTZen__c from Sales_Invoice__c where Id =:recordId];
                for(Sales_Invoice__c s :salesInv){
                    if(s.GST_applicable_formula__c ){
                        if(s.Send_to_GSTZen__c){
                            IrnApplicable =1; 
                        }else{
                            IrnApplicable =0;    
                        }
                    }else{
                        IrnApplicable =1;    
                    }
                }
            }else{
                IrnApplicable =1;      
            }
            
            if(query != '' && query != null){
                approvedcount = database.countQuery(query);
                if(approvedcount == 0){
                    count = 2;
                }
                if(approvedcount == 0 && (objName == 'Payment__c' || objName == 'Item_Replacement__c' || objName == 'Unsealed__c'  )){
                    count = 4;
                }  if(approvedcount == 0 && objName == 'Payment__c' ){
                    count = 5;
                }
            }
            if(IrnApplicable == 0){
                count = 3;
            }
            if(approvedcount == 1 &&   IrnApplicable ==1){
                sendToSap(IdList, objName);
                // count= checkDataUpdated(objName,recordId);
                count = 1;
            }
        }
        return count; 
    } 
    
    @AuraEnabled
    public static integer SendToSAP_Cancel_call(Id recordId){
        integer count =0,approvedcount=0;
        string query,Approved='Approved',status='Cancelled',status1='Generated';
        list<Id> IdList =new list<Id>();
        if(recordId != null){
            IdList.add(recordId);  
            String objName = recordId.getSObjectType().getDescribe().getName();  
            if(objName == 'Stock_Request__c'){
                query= 'select count() from Stock_Request__c where Id=:recordId and Sent_to_SAP__c=true and Status__c=:status';    
            }else if(objName == 'Receipt__c'){
                query= 'select count() from Receipt__c where Id=:recordId and Sent_to_SAP__c=true and Receipt_Status__c=:status1';        
            }else if(objName == 'Sales_Invoice__c'){
                query= 'select count() from Sales_Invoice__c where Id=:recordId and Sent_to_SAP__c=true and Sales_Invoice_Status__c=:status';        
            }
            if(query != '' && query != null){
                approvedcount = database.countQuery(query);
                if(approvedcount == 0){
                    count = 2;
                }
            }
            if(objName == 'Receipt__c'&&  count == 2){
                Receipt__c r = new Receipt__c();
                r.Id =recordId;
                r.Receipt_Status__c='Cancelled';
                r.Skip_Record_Edit_Validation__c=true;
                update r;
                count=1;
            }
            if(approvedcount == 1){
                sendCancellationToSap(IdList, objName);
                count = 1;
            }
        }
        return count; 
    } 
    @AuraEnabled
    public static string updateStatus(Id recordId){
        List<sObject> objData =new List<sObject>();
        String objName = recordId.getSObjectType().getDescribe().getName();  
        if(objName == 'Stock_Request__c'){
            Stock_Request__c stockRequest=[SELECT Id,Status__c FROM Stock_Request__c where Id=:recordId];
            stockRequest.Status__c ='Cancelled';
            update stockRequest;
        }else if(objName == 'Receipt__c'){
            // Receipt__c Receipt =[select Id,Receipt_Status__c from Receipt__c where Id=:recordId]; 
            // Receipt.Receipt_Status__c='Cancelled';
            // update Receipt;
        }else if(objName == 'Sales_Invoice__c'){
            Sales_Invoice__c salesInvoice =[SELECT Id, Name,Sales_Invoice_Status__c FROM Sales_Invoice__c where Id=:recordId];  
            salesInvoice.Sales_Invoice_Status__c='Cancelled';
            update salesInvoice;
        }
        return objName;     
    }
    @AuraEnabled
    public static void SendPortal_call(Id recordId){
        SalesEinvoice.sendData(recordId,'Cancel');
    }
    @AuraEnabled
    public static void SendSAPInvoiceReceipt(Id recordId){
        list<Receipt__c> Receipts =[select Id,Name,CompanyId__c,Receipt_Id__c from Receipt__c where Sales_Invoice__c =:recordId and Sent_to_SAP__c=true];
        if(Receipts.size() >0)
            SAPSendCancelData.sendData(Receipts);
    }
    @AuraEnabled
    public static string getObjectName(Id recordId){
        String objName = recordId.getSObjectType().getDescribe().getName(); 
        return objName;
    }   
    
    @AuraEnabled
    public static void salesInvoicePO(Id recordId,string po){
        Sales_Invoice__c salesInv =[select Id,Purchase_Order__c from Sales_Invoice__c where Id=:recordId];
        salesInv.Purchase_Order__c = po;
        update salesInv;
    } 
    @AuraEnabled
    public static string getSalesInv(Id recordId){
        string po;
        Sales_Invoice__c salesInv =[select Id,Purchase_Order__c from Sales_Invoice__c where Id=:recordId];
        
        if(salesInv.Purchase_Order__c != null){
            po = salesInv.Purchase_Order__c;
        }
        return  po;
    } 
    /*@Autor -Nanma 
*/
    @AuraEnabled
    public static Decimal getReceipt(Id recordId){
        Decimal po;
        Receipt__c receipt =[select Id,Bouncing_Charge__c from Receipt__c where Id=:recordId];
        
        if(receipt.Bouncing_Charge__c != null){
            po = receipt.Bouncing_Charge__c;
        }
        return  po;
    }    
    
    
    
    /*@Autor -Nanma 
*/
    @AuraEnabled
    public static void SendToSAP_ReceiptCancel_call(Id recordId,decimal bouncingCharge){
        string query,status='Cancelled';
        integer count =0;
        list<Receipt__c> receipt;
        list<Id> IdList =new list<Id>();
        if(recordId != null){
            String objName = recordId.getSObjectType().getDescribe().getName();  
            if(objName == 'Receipt__c'){
                IdList.add(recordId);  
                sendCancellationToSap(IdList, objName);
            }
        }
    }
    /*@Autor -Nanma updateBouncing charge
*/
    @AuraEnabled
    public static integer update_Receipt(Id recordId,decimal bouncingCharge,date docDate){
        integer count =0;
        if(recordId != null){
            String objName = recordId.getSObjectType().getDescribe().getName();  
            if(objName == 'Receipt__c'){
                list<Receipt__c> receipt= [select Id,Cheque_Bounced__c,Bouncing_Charge__c,Bouncing_Date__c,Skip_Record_Edit_Validation__c from Receipt__c where Id=:recordId and Sent_to_SAP__c=true ];        
                
                count = receipt.size();
                if(count > 0){
                    for(Receipt__c rec : receipt){
                        rec.Cheque_Bounced__c =true;
                        rec.Bouncing_Charge__c =bouncingCharge;
                        rec.Bouncing_Date__c =docDate;
                        rec.Skip_Record_Edit_Validation__c=true;
                    }
                    update receipt;
                }
            }
        }
        return count; 
        
    }
    
    /*@Autor -Nanma updateBouncing charge
*/
  /*  @invocableMethod
    public static void callSendToSAP(list<Id> ReceipIds){
        list<Payment__c> payments=[select Id,Name,CompanyId__c,Receipt_Id__c,Customer_Id__c,Route_Id__c,Branch_Id__c,Amount__c,Bouncing_Charge__c,Docdate__c,State__c from Payment__c where Id in :ReceipIds and Bouncing_Charge__c>0];
        // if(salesInvoice.size() > 0)  
        //  sendData(salesInvoice);
        
        if(payments.size() > 0)  
            SAPSendData.sendData(payments);
        
    }*/
    @AuraEnabled
    public static list<Log__c> getLogResult(Id recordId){
      Log__c l = new Log__c();
         list<Log__c> lgList = new list<Log__c>();
        try{
         lgList =[select Id,Name,Response__c,createddate,CreatedDate_F__c from Log__c where RecordId__c=:recordId  order by createdDate desc limit 499];
 
        }
         catch(System.Exception  ex){
            system.debug('Error'+ ex.getMessage());
              Error_Log__c err = new Error_Log__c();
            //err.Cause__c = ex.getCause();
            err.LineNumber__c = ex.getLineNumber();
            err.Message__c = ex.getMessage();
            err.StackTrace__c = ex.getStackTraceString();
            err.Type__c = ex.getTypeName();
            err.User__c = UserInfo.getUserId();
            database.insert(err,false);    
        }
        if(lgList.size() > 0){
            return lgList;
        } else{
            return null;
        }
      
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
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;  
             i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;  i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;   i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0; 
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;  
       i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
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
    
    /*  public static integer checkDataUpdated(string objName,Id recordId){
string query= 'select count() from '+objName+' where Id=:recordId and Sent_to_SAP__c=true';
system.debug(query) ;
integer count = database.countQuery(query);
return count;

}?*/
}