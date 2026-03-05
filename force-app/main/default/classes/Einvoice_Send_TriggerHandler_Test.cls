@isTest
public class Einvoice_Send_TriggerHandler_Test {
    @isTest
    static void testSendToPortal() {
        User u = new User( ProfileId = [SELECT Id FROM Profile WHERE Name = 'system administrator'].Id,  LastName = 'last', Email = 'test@gmail.com',Username = 'test@gmail.com' + System.currentTimeMillis(), CompanyName = 'TEST', Title = 'title', Alias = 'alias', TimeZoneSidKey = 'America/Los_Angeles', EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US',  LocaleSidKey = 'en_US',  Route_Id__c='Route123');
        insert u;
        Account acc = new Account(Name='Test',CompanyId__c='Dev',CardType__c='C',CustomerGroupCode__c='100',Mobile__c='1234567123', Alternate_Mobile__c='1234567123' , Email__c='test@gmail.com', Pan_Number__c='ASWER1234D',CustomerType__c='1',State__c='KL');
        insert acc;
        Address__c add1 = new Address__c();
        add1.Customer__c = acc.id; 
        add1.Address__c = 'Church Street';
        add1.Address_Type__c = 'B';
        add1.Block__c = 'Test';
        add1.Building__c = 'Test';
        add1.City__c = 'Test';
        add1.Country__c = 'IN';
        add1.District__c = 'Kannur';
        add1.GST_No__c = '1ZDJMPA0010AQAZ';
        add1.RowNum__c = 2;
        add1.State__c = 'KL';
        add1.Street__c = 'Street';
        add1.Street_No__c = 'Street No';
        add1.ZipCode__c = 670331;
        insert add1;
        Address__c add2 = new Address__c();
        add2.Customer__c = acc.id; 
        add2.Address_Type__c = 'S';
        add2.State__c = 'KL';
        add2.ZipCode__c = 670331;
        add2.Same_as_Billing_Address__c=true;
        insert add2;
        acc.Approval_Status__c = 'Approved';
        update acc;
        Vehicle__c veh = new Vehicle__c(CompanyId__c='Dev', Vehicle_Number__c='KL 13A 1000', Model__c='test', Engine__c='100cc', Capacity__c='1000', Registration_Date__c=system.today());
        insert veh;
        Route__c rt =  new Route__c(name='test',Route_Id__c='',CompanyId__c='Dev', State__c='KL', District__c='Kannur', Week_Sales__c='SUN', Week__c='FIR');
        insert rt;
        Employee__c emp =new Employee__c(Name='test',CompanyId__c='Dev',Mobile__c='12345665432',Email__c='test@gmail.com', Designation__c='test', Role__c='Driver' );
        insert emp;
        Branch__c bran=new Branch__c(name='test',Account_Id__c='_SYS00000002064',Account_Code__c='512018-01',Account_Name__c='test',Branch_Id__c=1,Manager_Name__c = UserInfo.getUserId());
        insert bran;
        Stock_Request__c sr = new Stock_Request__c(Request_Date__c=system.today(),Branch__c=bran.Id,Route__c=rt.Id,Vehicle__c=veh.Id,Godown_Manager__c =  UserInfo.getUserId()); 
        insert sr;
        sr.Status__c ='Approved';
        update sr;
        Product__c productRec = new Product__c(Name='Dev Snacks Rosted peanut',Product_Code__c = 'P100',MRP__c = 25,GST__c = '5');
        insert productRec;
        Stock__c stock = new Stock__c(Intial_Stock__c= 10000,Available_Quantity__c = 2000,Sold_Qty__c = 2500,Blocked_Quantity__c = 1500,Product__c = productRec.id);
        Insert stock;
        Sales_Invoice__c salInvoice = new Sales_Invoice__c(Name = 'Test',Customer__c=acc.Id,Route__c = rt.Id,Doc_Date__c = system.today(),Tax_Date__c = system.today(), Invoice_Date__c=system.today() ,Payment_Type__c = 'credit',Branch__c=bran.Id);                                     
        insert salInvoice;
        Sales_Invoice_Item__c slInvItem = new Sales_Invoice_Item__c(Total__c = 100,GST_Percentage__c = 1,Sales_Invoice__c = salInvoice.Id,Product__c = stock.Product__c,Stock__c = stock.Id,Quantity__c = 70,Unit_Price__c = 100,Discount_Percent__c = 1,Total_after_discount__c = 7000,Sales_Tax__c=2,Total_Before_Tax__c=600);
        insert slInvItem;
        insert new State_Code__c(Name='KL',State__c = 'KL',Code__c ='32');
               Return_Number_Series__c rn = new Return_Number_Series__c(Active__c=true,Start_Number__c=0,Last_Return_Number__c=1,Route__c=rt.Id);
        insert rn;
        Return__c ret = new Return__c(Name = 'Test Return',Customer__c = acc.Id,Route__c=rt.Id,Branch__c=bran.Id,Return_Date__c=system.today(),sales_Invoice__c=salInvoice.Id,Dept_Head__c = UserInfo.getUserId());
        insert ret;
        ret.Approval_Status__c='Approved';
        update ret;
        Return_Item__c ri = new Return_Item__c();
        ri.Quantity__c =1;
        ri.Return__c =ret.Id;
        ri.Unit_Price__c =10;
        insert ri;
        list<Id> recIds =new list<Id>();
        recIds.add(salInvoice.Id);
         list<Id> recIds1 =new list<Id>();
        recIds1.add(ret.Id);
        Einvoice_Send_TriggerHandler.sendToPortal(recIds,'Generate');
        Einvoice_Send_TriggerHandler.SendToPortal_call(salInvoice.Id,'Generate');
        Einvoice_Send_TriggerHandler.SendToPortal_creditCall(ret.Id, 'Generate'); 
        Einvoice_Send_TriggerHandler.sendToPortalCredit(recIds1, 'Generate');
        //Einvoice_Send_TriggerHandler.callSendToSAP(recIds);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator()); 
        
        
        
    }
    
}