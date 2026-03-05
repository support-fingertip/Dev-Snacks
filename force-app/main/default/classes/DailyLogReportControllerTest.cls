@isTest
private class DailyLogReportControllerTest {

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
        DailyLogReportController.testcover();
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
        SalesInvoiceTriggerHandler.insertSalesInvoiceName2(salesInvoices);
        test.stopTest();        
        
    }
}