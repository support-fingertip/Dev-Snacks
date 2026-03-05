@IsTest
public class SalesInvoiceTriggerHandlerTest {
    @IsTest
    public static void salesInvoiceTriggerTest1() {
        // Create test data
        Account testAccount = new Account(
            Name = 'Test Account',
            Approval_Status__c = 'Approved',
            CompanyId__c = 'Dev'
        );
        insert testAccount;
        
        testAccount.Approval_Status__c = 'Approved';
        update testAccount;
        
        Route__c testRoute = new Route__c(
            Route_Id__c = 'Route123'
        );
        insert testRoute;
        
        Receipt__c testReceipt = new Receipt__c(
            Type__c = 'On Account',
            On_Account_Value__c = 25563.53,
            Customer__c = testAccount.Id
        );
        insert testReceipt;
        
        // Create a test Sales_Invoice__c record
         Warehouse__c wh = new Warehouse__c();
        wh.name = 'test';
        insert wh;
        
        User user = [select id,name,Route_Id__c from User where id=:UserInfo.getUserId() limit 1];
        Route__c r = new Route__c();
        r.warehouse__c = wh.id;
        r.Name = 'test route';
        r.Route_Id__c = user.Route_Id__c;
        insert r;
        
        List<Sales_invoice__c>salesInvoices = new List<Sales_invoice__c>();
         Sales_invoice__c salesInvoice = new Sales_invoice__c();
         salesInvoice.Customer__c = testAccount.id;
         salesInvoice.Route__c = r.id;
         salesInvoice.Doc_Date__c = Date.NewInstance(2022,03,09);
         salesInvoice.Tax_Date__c = Date.NewInstance(2022,03,09);
         salesInvoice.Payment_Type__c = 'Credit';
        //insert salesInvoice;
        salesInvoices.add(salesInvoice);
        
        test.startTest();
     //   SalesInvoiceTriggerHandler.insertSalesInvoiceName(salesInvoices);
        SalesInvoiceTriggerHandler.insertSalesInvoiceName2(salesInvoices);
        test.stopTest();        
        system.debug('salesInvoice.Name=== '+salesInvoice.Name);
        //system.assertEquals(salesInvoice.Name, 'INV-1/2024');
    }
    
    @IsTest
    public static void salesInvoiceTriggerTest2() {
        // Create test data
        Account testAccount = new Account(
            Name = 'Test Account',
            Approval_Status__c = 'Approved',
            CompanyId__c = 'Dev'
        );
        insert testAccount;
        
        testAccount.Approval_Status__c = 'Approved';
        update testAccount;
        
        Route__c testRoute = new Route__c(
            Route_Id__c = '123'
        );
        insert testRoute;
        
        
        Invoice_Number_Series__c invNumSeries = new Invoice_Number_Series__c(
            Last_Invoice_Number__c = 1,
            Invoice_number_prefix__c = 'INV-',
            Start_Number__c = 1,
            Invoice_Post_fix__c = '/2024',
            Route__c = testRoute.id,
            Active__c = true
        );
        insert invNumSeries;
        
        Receipt__c testReceipt = new Receipt__c(
            Type__c = 'On Account',
            On_Account_Value__c = 25563.53,
            Customer__c = testAccount.Id
        );
        insert testReceipt;
        
        // Create a test Sales_Invoice__c record
         Warehouse__c wh = new Warehouse__c();
        wh.name = 'test';
        insert wh;
        
        List<Sales_invoice__c>salesInvoices = new List<Sales_invoice__c>();
         Sales_invoice__c salesInvoice = new Sales_invoice__c();
        salesInvoice.Name = 'INV-3/2024';
         salesInvoice.Customer__c = testAccount.id;
         salesInvoice.Route__c = testRoute.id;
         salesInvoice.Doc_Date__c = Date.NewInstance(2022,03,09);
         salesInvoice.Tax_Date__c = Date.NewInstance(2022,03,09);
         salesInvoice.Payment_Type__c = 'Credit';
        //insert salesInvoice;
                Sales_invoice__c salesInvoice1 = new Sales_invoice__c();
        salesInvoice1.Name = '20023';
         salesInvoice1.Customer__c = testAccount.id;
         salesInvoice1.Route__c = testRoute.id;
         salesInvoice1.Doc_Date__c = Date.NewInstance(2022,03,09);
         salesInvoice1.Tax_Date__c = Date.NewInstance(2022,03,09);
         salesInvoice1.Payment_Type__c = 'Credit';

     //  insert salesInvoice1;
        salesInvoices.add(salesInvoice);
        
        test.startTest();
        //SalesInvoiceTriggerHandler.insertSalesInvoiceName(salesInvoices);
        //SalesInvoiceTriggerHandler.updateLastInvoiceNumber(salesInvoices);
        SalesInvoiceTriggerHandler.insertSalesInvoiceName2(salesInvoices);
        //SalesInvoiceTriggerHandler.insertSalesInvoiceSeriesUpdate(salesInvoice1);
        test.stopTest();        
        
    }
    
    @IsTest
    public static void salesInvoiceTriggerTest3() {
        // Create test data
        Account testAccount = new Account(
            Name = 'Test Account',
            Approval_Status__c = 'Approved',
            CompanyId__c = 'Dev'
        );
        insert testAccount;
        
        testAccount.Approval_Status__c = 'Approved';
        update testAccount;
        
        Route__c testRoute = new Route__c(
            Route_Id__c = 'Route456'
        );
        insert testRoute;
        
        
        Invoice_Number_Series__c invNumSeries = new Invoice_Number_Series__c(
            Last_Invoice_Number__c = 1,
            Invoice_number_prefix__c = 'INV-',
            Start_Number__c = 1,
            Invoice_Post_fix__c = null,
            Route__c = testRoute.id,
            Active__c = true 
        );
        insert invNumSeries;
        
        Receipt__c testReceipt = new Receipt__c(
            Type__c = 'On Account',
            On_Account_Value__c = 25563.53,
            Customer__c = testAccount.Id
        );
        insert testReceipt;
        
        // Create a test Sales_Invoice__c record
         Warehouse__c wh = new Warehouse__c();
        wh.name = 'test';
        insert wh;
        
        List<Sales_invoice__c>salesInvoices = new List<Sales_invoice__c>();
         Sales_invoice__c salesInvoice = new Sales_invoice__c();
         salesInvoice.Customer__c = testAccount.id;
         salesInvoice.Route__c = testRoute.id;
         salesInvoice.Doc_Date__c = system.today();
         salesInvoice.Tax_Date__c = system.today();
        salesInvoices.add(salesInvoice);
        
        test.startTest();
       // SalesInvoiceTriggerHandler.insertSalesInvoiceName(salesInvoices);
        SalesInvoiceTriggerHandler.insertSalesInvoiceName2(salesInvoices);
        test.stopTest();
        system.assertEquals(salesInvoice.Name, '1');
    }
    
       @IsTest
    public static void salesInvoiceTriggerTest4() {
        // Create test data
        Account testAccount = new Account(
            Name = 'Test Account',
            Approval_Status__c = 'Approved',
            CompanyId__c = 'Dev'
        );
        insert testAccount;
        
        testAccount.Approval_Status__c = 'Approved';
        update testAccount;
        
        Route__c testRoute = new Route__c(
            Route_Id__c = '123'
        );
        insert testRoute;
        
        Receipt__c testReceipt = new Receipt__c(
            Type__c = 'On Account',
            On_Account_Value__c = 25563.53,
            Customer__c = testAccount.Id
        );
        insert testReceipt;
        
        // Create a test Sales_Invoice__c record
         Warehouse__c wh = new Warehouse__c();
        wh.name = 'test';
        insert wh;
        
        List<Sales_invoice__c>salesInvoices = new List<Sales_invoice__c>();
         Sales_invoice__c salesInvoice = new Sales_invoice__c();
        salesInvoice.Name = 'INV-3/2023';
         salesInvoice.Customer__c = testAccount.id;
         salesInvoice.Route__c = testRoute.id;
         salesInvoice.Doc_Date__c = Date.NewInstance(2022,03,09);
         salesInvoice.Tax_Date__c = Date.NewInstance(2022,03,09);
         salesInvoice.Payment_Type__c = 'Credit';
        insert salesInvoice;
                Sales_invoice__c salesInvoice1 = new Sales_invoice__c();
        salesInvoice1.Name = '20023';
         salesInvoice1.Customer__c = testAccount.id;
         salesInvoice1.Route__c = testRoute.id;
         salesInvoice1.Doc_Date__c = Date.NewInstance(2022,03,09);
         salesInvoice1.Tax_Date__c = Date.NewInstance(2022,03,09);
         salesInvoice1.Payment_Type__c = 'Credit';

        salesInvoices.add(salesInvoice);
        update salesInvoice;
        test.startTest();
       // SalesInvoiceTriggerHandler.insertSalesInvoiceName(salesInvoices);
        //SalesInvoiceTriggerHandler.updateLastInvoiceNumber(salesInvoices);
        SalesInvoiceTriggerHandler.insertSalesInvoiceName2(salesInvoices);
       // SalesInvoiceTriggerHandler.insertSalesInvoiceSeriesUpdate(salesInvoice1);
        test.stopTest();        
        
    }
    
    @IsTest
    public static void salesInvoiceTriggerTest5() {
         Account testAccount = new Account(
            Name = 'Test Account',
            Approval_Status__c = 'Approved',
            CompanyId__c = 'Dev'
        );
        insert testAccount;
        
        testAccount.Approval_Status__c = 'Approved';
        update testAccount;
        
        Route__c testRoute = new Route__c(
            Route_Id__c = 'Route456'
        );
        insert testRoute;
               
         Sales_invoice__c salesInvoice = new Sales_invoice__c();
         salesInvoice.Name = 'INV-31/2023';
         salesInvoice.Customer__c = testAccount.id;
         salesInvoice.Route__c = testRoute.id;
         salesInvoice.Doc_Date__c = system.today();
         salesInvoice.Tax_Date__c = system.today();
        salesInvoice.Invoice_Date__c = system.today();
        salesInvoice.Payment_Type__c = 'Credit';
        insert salesInvoice;
          Sales_invoice__c salesInvoice1 = new Sales_invoice__c();
         salesInvoice1.Name = 'INV-30/2023';
         salesInvoice1.Customer__c = testAccount.id;
         salesInvoice1.Route__c = testRoute.id;
         salesInvoice1.Doc_Date__c = system.today();
         salesInvoice1.Tax_Date__c = system.today();
        salesInvoice.Invoice_Date__c = system.today()+1;
        salesInvoice1.Payment_Type__c = 'Immediate';
      //  insert salesInvoice1;
        
        salesInvoice.SAP_Code__c='123';
      // update salesInvoice1;
         Receipt__c testReceipt = new Receipt__c(
            Type__c = 'On Account',
            On_Account_Value__c = 25563.53,
            Customer__c = testAccount.Id
        );
        insert testReceipt;
        
        Product__c productRec = new Product__c();
        productRec.Name = 'Dev Snacks Rosted peanut';
        productRec.Product_Code__c = 'P100';
        productRec.MRP__c = 25;
        productRec.GST__c = '5';
        insert productRec;
        
        Stock__c stock = new Stock__c();
        stock.Intial_Stock__c = 100;
        stock.Available_Quantity__c = 70;
        stock.Sold_Qty__c = 15;
        stock.Blocked_Quantity__c = 15;
        stock.Product__c = productRec.id;
        Insert stock;
        
        Sales_Invoice_Item__c slInvItem = new Sales_Invoice_Item__c();
        slInvItem.Total__c = 100;
        slInvItem.GST_Percentage__c = 1;
        slInvItem.Sales_Invoice__c = salesInvoice.Id;
        slInvItem.Product__c = stock.Product__c;
        slInvItem.Stock__c = stock.Id;
        slInvItem.Quantity__c = 1;
        slInvItem.Unit_Price__c = 100;
        slInvItem.Discount_Percent__c = 1;
        slInvItem.Total_after_discount__c = 100;
      //  insert slInvItem;
        
        StopRecursion.executeSalesInvoiceItemTrigger = true;
        salesInvoice1.Sales_Invoice_Status__c = 'Cancelled';
       // update salesInvoice1;
        
        
    }
   
}