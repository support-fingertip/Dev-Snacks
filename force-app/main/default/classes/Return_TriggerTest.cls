@isTest
public class Return_TriggerTest 
{
    @isTest
    Public static void Test()
    {
        User testUser = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'system administrator'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            Route_Id__c='Route123');
        insert testUser;
        
        Route__c rt =  new Route__c();
        rt.name = 'Route123';
        rt.ownerid = testUser.Id;
        rt.Route_Id__c = '123';
        insert rt;
        Branch__c bran=new Branch__c(name='test',Account_Id__c='_SYS00000002064',Account_Code__c='512018-01',Account_Name__c='test',Branch_Id__c=1,Manager_Name__c = UserInfo.getUserId());
        insert bran;
        // Create test Account records
        Account testAccount1 = new Account(
            Name = 'Test Account 1',
            Approval_Status__c = 'Approved',
            Routes__c=rt.Id,
            CompanyId__c = 'Dev'
            
        );
        
        insert testAccount1;
        
        Address__c add1 = new Address__c();
        add1.Customer__c = testAccount1.id; 
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
        add2.Customer__c = testAccount1.id; 
        add2.Address_Type__c = 'S';
        add2.State__c = 'KL';
        add2.ZipCode__c = 670331;
        add2.Same_as_Billing_Address__c=true;
        insert add2;
        
        Sales_invoice__c salesInvoice = new Sales_invoice__c();
        salesInvoice.Customer__c = testAccount1.id;
        salesInvoice.Route__c = rt.id;
        salesInvoice.Doc_Date__c = system.today();
        salesInvoice.Tax_Date__c = system.today();
        salesInvoice.Invoice_Date__c = system.today();
        salesInvoice.Payment_Type__c = 'Credit';
        salesInvoice.Branch__c=bran.Id;
        insert salesInvoice;
        
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
        stock.Batch_Number__c = 'ABC23';
        stock.Price__c = 100;
        stock.Manufacturing_Date__c = system.today();
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
        slInvItem.Sales_Tax__c=10;
        insert slInvItem;
        
        
        insert new State_Code__c(Name='KL',State__c = 'KL',Code__c ='32');
        
        Return_Number_Series__c rn = new Return_Number_Series__c();
        rn.Active__c=true;
        rn.Start_Number__c=0;
        rn.Last_Return_Number__c=1;
        rn.Return_Number_Prefix__c = 'RN';
        rn.Return_Post_Fix__c = '/23';
        rn.Route__c=rt.Id;
        insert rn;
        
        Return__c ret = new Return__c();
        ret.Name = 'Test Return';
        ret.Customer__c = testAccount1.Id;
        ret.Route__c=rt.Id;
        ret.Branch__c=bran.Id;
        ret.Sales_Invoice__c=salesInvoice.Id;
        ret.Dept_Head__c = UserInfo.getUserId();
        ret.Return_Type__c = 'Saleable';
        insert ret;
        
          Return_Item__c ri =new Return_Item__c();
        ri.Total__c=200;
        ri.GST_Percentage__c=10;
        ri.Product__c=productRec.Id;
        ri.Quantity__c=2;
        ri.Unit_Price__c = 30;
        ri.Sales_Invoice__c=salesInvoice.Id;
       	ri.Invoice_Item__c = slInvItem.Id;
        ri.Return__c = ret.Id;
        ri.Damaged_Stock__c = stock.Id;
        insert ri;
        
        ret.Approval_Status__c='Approved';
        update ret;
        
      
        
        list<Return__c> returnInvoiceList =new  list<Return__c>();
        returnInvoiceList.add(ret);
        
         list<Return_Item__c> itemList =new  list<Return_Item__c>();
        itemList.add(ri);
        
       // Return_Trigger_Handler.insertReturnSeriesUpdate(ret);
        Return_Trigger_Handler.insertSalesReturnName(returnInvoiceList);
        
       //  Return_Trigger_Handler.updateStock(itemList);
       Return_Trigger_Handler.testCoverage();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator()); 
      //  stock.Stock_Ext_ID__c = rt.id + String.valueOf(stock.Product__c) + stock.Batch_Number__c + stock.Manufacturing_Date__c + stock.Price__c + system.today();
       // update stock;
        //Return_Trigger_Handler.updateStock(itemList);
    }
}