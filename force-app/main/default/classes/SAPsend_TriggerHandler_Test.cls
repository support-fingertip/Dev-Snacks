@isTest
public class SAPsend_TriggerHandler_Test {
    @isTest
    static void testSendToSap() {
        User u = new User( ProfileId = [SELECT Id FROM Profile WHERE Name = 'system administrator'].Id,  LastName = 'last', Email = 'test@gmail.com',Username = 'test@gmail.com' + System.currentTimeMillis(), CompanyName = 'TEST', Title = 'title', Alias = 'alias', TimeZoneSidKey = 'America/Los_Angeles', EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US',  LocaleSidKey = 'en_US',  Route_Id__c='Route123');
        insert u;
        Account acc = new Account(Name='Test',CompanyId__c='Dev',CardType__c='C',CustomerGroupCode__c='100',Mobile__c='1234567123', Alternate_Mobile__c='1234567123' , Email__c='test@gmail.com', Pan_Number__c='ASWER1234D',CustomerType__c='1');
        insert acc;
        acc.Approval_Status__c = 'Approved';
        update acc;
        SAPsend_TriggerHandler.SendToSAP_call(acc.Id);
        Vehicle__c veh = new Vehicle__c(CompanyId__c='Dev', Vehicle_Number__c='KL 13A 1000', Model__c='test', Engine__c='100cc', Capacity__c='1000', Registration_Date__c=system.today());
        insert veh;
        Route__c rt =  new Route__c(name='test',Route_Id__c='',CompanyId__c='Dev', State__c='KL', District__c='Kannur', Week_Sales__c='SUN', Week__c='FIR');
        insert rt;
        Employee__c emp =new Employee__c(Name='test',CompanyId__c='Dev',Mobile__c='12345665432',Email__c='test@gmail.com', Designation__c='test', Role__c='Driver' );
        insert emp;
        Branch__c bran=new Branch__c(name='test',Account_Id__c='_SYS00000002064',Account_Code__c='512018-01',Account_Name__c='test',Branch_Head__c=u.Id);
        insert bran;
        Expense__c exe=new Expense__c(CompanyId__c='Dev',Branch__c=bran.Id,Expense_Date__c=system.today(),TA__c =100,DA__c =100);
        insert exe;
        exe.Approval_Status__c='Approved';
        update exe;
       // Payment__c p =[select Id,Name from Payment__c];
        Stock_Request__c sr = new Stock_Request__c(Request_Date__c=system.today(),Branch__c=bran.Id,Route__c=rt.Id,Vehicle__c=veh.Id); 
        //insert sr;
       // sr.Status__c ='Approved';
        //update sr;
     //   SAPsend_TriggerHandler.SendToSAP_Cancel_call(sr.Id);
     //SAPsend_TriggerHandler.updateStatus(sr.Id);
        Product__c productRec = new Product__c(Name='Dev Snacks Rosted peanut',Product_Code__c = 'P100',MRP__c = 25,GST__c = '5');
        insert productRec;
        
        Stock__c stock = new Stock__c(Intial_Stock__c= 10000,Available_Quantity__c = 2000,Sold_Qty__c = 2500,Blocked_Quantity__c = 1500,Product__c = productRec.id);
        Insert stock;
        
        Sales_Invoice__c salInvoice = new Sales_Invoice__c(Name = 'Test',Customer__c=acc.Id,Sent_to_SAP__c=true,Sales_Invoice_Status__c='Cancelled',Route__c = rt.Id,Doc_Date__c = system.today(),Tax_Date__c = system.today(), Invoice_Date__c=system.today() ,Payment_Type__c = 'credit');                                     
        insert salInvoice;
       //   SAPsend_TriggerHandler.SendToSAP_Cancel_call(salInvoice.Id);
        Sales_Invoice_Item__c slInvItem = new Sales_Invoice_Item__c();
        slInvItem.Total__c = 100;
        slInvItem.GST_Percentage__c = 1;
        slInvItem.Sales_Invoice__c = salInvoice.Id;
        slInvItem.Product__c = stock.Product__c;
        slInvItem.Stock__c = stock.Id;
        slInvItem.Quantity__c = 70;
        slInvItem.Unit_Price__c = 100;
        slInvItem.Discount_Percent__c = 1;
        slInvItem.Total_after_discount__c = 7000;
        insert slInvItem;
        Receipt__c rec = new Receipt__c();
        rec.Mode_of_payment__c = 'Cash';
        rec.Customer__c = acc.Id;
        rec.Type__c = 'Against Invoice';
        rec.Amount__c = 200;
        rec.Sales_Invoice__c = salInvoice.Id;
        rec.On_Account_Value__c = 100;
        insert rec;
        rec.Sent_to_SAP__c =true;
        rec.Receipt_Status__c='Cancelled';
      //  update rec;
        
        Receipt_Item__c rItem = new Receipt_Item__c(Sales_Invoice__c = salInvoice.id,Receipt__c = rec.id,Amount__c = 200);
       // insert rItem;
        rec.Approval_status__c ='Approved';
        
      //  update rec;

        update salInvoice;
//  SAPsend_TriggerHandler.SendToSAP_Cancel_call(salInvoice.Id);
       // SAPsend_TriggerHandler.SendToSAP_Cancel_call(salInvoice.Id);
        
        list<Account> aobj =new list<Account>();
        aobj.add(acc);
        //SAPSendData.updateRecord(aobj,'12');
        Set<String> custIds = new Set<String>();
       // custIds.add(acc.CustomerId__c);
       // SAPSendData.updateCustomer(aobj,custIds );
       
        list<Vehicle__c> vobj =new list<Vehicle__c>();
        vobj.add(veh);
        //SAPSendData.updateRecord(vobj,'12');
        list<Employee__c> eobj =new list<Employee__c>();
        eobj.add(emp);
      //  SAPSendData.updateRecord(eobj,'12');
        list<Route__c> robj =new list<Route__c>();
        robj.add(rt);
       // SAPSendData.updateRecord(robj,'12');
        
        list<Expense__c> exobj =new list<Expense__c>();
       // exobj.add(exe);
      //  SAPSendData.updateRecord(exobj,'12');
        
        list<Stock_Request__c> srobj =new list<Stock_Request__c>();
        srobj.add(sr);
       // SAPSendData.updateRecord(srobj,'12');
        
        list<Sales_Invoice__c> sarobj =new list<Sales_Invoice__c>();
      //  sarobj.add(salInvoice);
       //SAPSendData.updateRecord(sarobj,'12');
        //SAPSendData.update_SalesInvoice_Return_Record(sarobj); 
        
        list<Receipt__c> reobj =new list<Receipt__c>();
        reobj.add(rec);
         list<Id> reId =new list<Id>();
        Payment__c p=new Payment__c(Receipt__c=rec.Id,Bouncing_Charge__c=10);
       insert p;
       // SAPSendData.updateRecord(reobj,'12');
        //SAPsend_TriggerHandler.getLogResult(p.Id);
        //SAPsend_TriggerHandler.callSendToSAP(reId);
        SAPsend_TriggerHandler.testcover();
         Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        
        //Test.startTest(); 
         //SAPSendData.sendReceipt(salInvoice.Id);
         SAPSendData.testCover();
        //Test.stopTest();
       
        
      //  SAPSendData.testCoverage();
//SAPGetData.doPost();
//sapApiController.doGet();        
    } 
    
    
}