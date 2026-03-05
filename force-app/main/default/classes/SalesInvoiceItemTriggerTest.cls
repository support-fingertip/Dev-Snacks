@isTest
public class SalesInvoiceItemTriggerTest 
{
    @isTest
    Public static void Test(){
        // Create test data
        
        //List<Product__c> listproducts =  [SELECT Id,Name,MRP__c,Product_Image_Url__c , GST__c FROM Product__c where MRP__c != null];
        //system.debug('listproducts : '+listproducts);
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
        
        Sales_Invoice__c salInvoice = new Sales_Invoice__c();
        salInvoice.Route__c = routeRec.Id;
        salInvoice.Doc_Date__c = system.today();
        salInvoice.Tax_Date__c = system.today();
        salInvoice.Customer__c = acc.id;
        insert salInvoice;
        
        List<Sales_Invoice_Item__c> invoiceItems = new List<Sales_Invoice_Item__c>();
        Sales_Invoice_Item__c  sInvItems = new Sales_Invoice_Item__c();
        sInvItems.Unit_Price__c = 30;
        sInvItems.Quantity__c = 1;
        sInvItems.Stock__c = stock.id;
        sInvItems.Product__c = productRec.id;
        sInvItems.Sales_Invoice__c = salInvoice.id;
        invoiceItems.add(sInvItems);
        
        insert invoiceItems;
        Sales_Invoice_Item__c  sInvItems1 = new Sales_Invoice_Item__c();
        sInvItems1.Unit_Price__c = 30;
        sInvItems1.Quantity__c = 1;
        sInvItems1.Stock__c = stock.id;
        sInvItems1.Sales_Invoice__c = salInvoice.id;
        sInvItems1.Total_Before_Tax__c=0;
        sInvItems1.Sales_Tax__c=12;
        insert sInvItems1;
        // Set the recursion flag to true to simulate previous execution
        StopRecursion.executeSalesInvoiceItemTrigger = true;
        
     
        // Invoke the trigger
        Test.startTest();
        // Call the trigger explicitly
        SalesInvoiceItemTriggerHandler.deductStockForSalesInvoiceItem(invoiceItems);
        StopRecursion.executeSalesInvoiceItemTrigger = true;
        SalesInvoiceItemTriggerHandler.readdStockForSalesInvoiceItem(invoiceItems);
        system.assertEquals(stock.Available_Quantity__c, stock.Intial_Stock__c - stock.Sold_Qty__c - stock.Blocked_Quantity__c);
        Test.stopTest();
    }
    
     @isTest
    Public static void Test2(){
        // Create test data
        
        //List<Product__c> listproducts =  [SELECT Id,Name,MRP__c,Product_Image_Url__c , GST__c FROM Product__c where MRP__c != null];
        //system.debug('listproducts : '+listproducts);
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
        stock.Stock_Type__c = 'New';
        stock.Manufacturing_Date__c = system.today()-1;
        stock.Price__c = 45;
        Insert stock;
        
        Sales_Invoice__c salInvoice = new Sales_Invoice__c();
        salInvoice.Route__c = routeRec.Id;
        salInvoice.Doc_Date__c = system.today();
        salInvoice.Tax_Date__c = system.today();
        salInvoice.Customer__c = acc.id;
        insert salInvoice;
        
        List<Sales_Invoice_Item__c> invoiceItems = new List<Sales_Invoice_Item__c>();
        Sales_Invoice_Item__c  sInvItems = new Sales_Invoice_Item__c();
        sInvItems.Unit_Price__c = 30;
        sInvItems.Quantity__c = 1;
        sInvItems.Stock__c = stock.id;
        sInvItems.Product__c = productRec.id;
        sInvItems.Sales_Invoice__c = salInvoice.id;
        invoiceItems.add(sInvItems);
        Sales_Invoice_Item__c  sInvItems1 = new Sales_Invoice_Item__c();
        sInvItems1.Unit_Price__c = 30;
        sInvItems1.Quantity__c = 1;
        sInvItems1.Stock__c = stock.id;
        sInvItems1.Sales_Invoice__c = salInvoice.id;
        sInvItems1.Product__c = productRec.id;
        sInvItems1.Total_Before_Tax__c=0;
        sInvItems1.Sales_Tax__c=12;
        invoiceItems.add(sInvItems1);
        
        insert invoiceItems;
        // Set the recursion flag to true to simulate previous execution
        StopRecursion.executeSalesInvoiceItemTrigger = true;
        
     
        // Invoke the trigger
        Test.startTest();
        // Call the trigger explicitly
        SalesInvoiceItemTriggerHandler.deductStockforInvoice([select Id,Name,Product__c,Quantity__c,Stock_Price__c from Sales_Invoice_Item__c where Id in:invoiceItems]);
        StopRecursion.executeSalesInvoiceItemTrigger = true;
        SalesInvoiceItemTriggerHandler.readdStockForSalesInvoiceItem(invoiceItems);
        system.assertEquals(stock.Available_Quantity__c, stock.Intial_Stock__c - stock.Sold_Qty__c - stock.Blocked_Quantity__c);
        Test.stopTest();
    }
}