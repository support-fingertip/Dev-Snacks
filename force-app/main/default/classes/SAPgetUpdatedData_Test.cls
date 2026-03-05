@isTest
public class SAPgetUpdatedData_Test {
  @isTest
    static void testSendToSap() {
  Account acc=new Account();
        acc.Name='testaccount1';
        acc.Phone = '9985542322';
        acc.Email__c = 'test@gmail.com';
        acc.CardType__c = 'C';
        acc.CompanyId__c = 'Dev';
        acc.OwnerId = UserInfo.getUserId();
        insert acc;
        
        Route__c routeRec = new Route__c();
        routeRec.Name = 'Kannur Route';
        routeRec.Route_Id__c = 'RI-01000';
        routeRec.Week_Sales__c = 'SUN';
        //routeRec.Week__c = 'First Week';
        insert routeRec;
        
        Product__c productRec = new Product__c();
        productRec.Name = 'Dev Snacks Rosted peanut';
        productRec.Product_Code__c = 'P009';
        productRec.MRP__c = 25;
        productRec.GST__c = '5';
        insert productRec;
        
        Stock_History__c his = new Stock_History__c();
        his.Route__c = routeRec.Id;
        his.Product__c = productRec.Id;
        his.Opening_Quantity__c = 100;
        his.Available_Quantity__c = his.Opening_Quantity__c;
        his.Ext_ID__c = String.valueOf(his.Product__c) + String.valueOf(his.Route__c)  + system.today();
        his.Date__c = system.today() ;
        insert his;      
        
        
        Stock__c stock = new Stock__c();
        stock.Intial_Stock__c = 100;
        stock.Available_Quantity__c = 70;
        stock.Sold_Qty__c = 15;
        stock.Blocked_Quantity__c = 15;
        stock.Product__c = productRec.id;
        Insert stock;
            Sales_Invoice__c salInvoice = new Sales_Invoice__c(Name = 'Test',Customer__c=acc.Id,Sent_to_SAP__c=true,Sales_Invoice_Status__c='Cancelled',Route__c = routeRec.Id,Doc_Date__c = system.today(),Tax_Date__c = system.today(), Invoice_Date__c=system.today() ,Payment_Type__c = 'credit');                                     
        insert salInvoice;
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
         list<Sales_Invoice__c> salI= new list< Sales_Invoice__c>();
        salI.add(salInvoice);
list<Account> customer=new list<Account>();
        customer.add(acc);
        map<string,Id> custCodeMap = new map<string,Id>();
        custCodeMap.put(acc.CustomerId__c,acc.Id);
//SAPgetUpdatedData.sendData('Dev', 'OutStandingCust', custCodeMap);
   list<Id> custId =new list<Id>();
        custId.add(acc.Id);
SAPsend_TriggerHandler.sendToSAPoutCall(custId, 'OutStandingCust', 'Account');
SAPgetUpdatedData.updateCustomer(customer, custCodeMap);
        SAPgetUpdatedData.updateInvoices(salI, custCodeMap);
        SAPgetUpdatedData.callSendToSAPout(custId);
          SAPgetUpdatedData.testCover();
         Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    }   
}