@isTest
public class InvoicePDFControllerClassTest {
    public static testmethod void testReceiptPDF(){
        Account acc=new Account();
        acc.Name='testaccount';
        acc.Phone = '9985522322';
        acc.Contact_Person__c = 'test';
        acc.CompanyId__c = 'Dev';
        acc.Cash_Discount__c = 1;
        acc.CustomerType__c ='1';
        insert acc;
        Route__c rt = new Route__c();
        rt.Name = 'RT1';
        rt.Route_Id__c = 'RI-00003';
        insert rt;
        
        Product__c productRec = new Product__c();
        productRec.Name = 'Dev Snacks Rosted peanut';
        productRec.Product_Code__c = 'P100';
        productRec.MRP__c = 25;
        productRec.GST__c = '5';
        insert productRec;
        
        Stock__c stock = new Stock__c();
        stock.Intial_Stock__c = 10000;
        stock.Available_Quantity__c = 2000;
        stock.Sold_Qty__c = 2500;
        stock.Blocked_Quantity__c = 1500;
        stock.Product__c = productRec.id;
        Insert stock;
        
        Sales_Invoice__c salInvoice = new Sales_Invoice__c();
        salInvoice.Name = 'Test';
        salInvoice.Route__c = rt.Id;
        salInvoice.Doc_Date__c = system.today();
        salInvoice.Tax_Date__c = system.today();
        salInvoice.Customer__c = acc.id;
        salInvoice.Invoice_Date__c  = Date.newInstance(2023, 05, 21);
        salInvoice.Payment_Type__c = 'Immediate';
        insert salInvoice;
        
        Sales_Invoice_Item__c slInvItem = new Sales_Invoice_Item__c();
        slInvItem.Total__c = 100;
        slInvItem.GST_Percentage__c = 1;
        slInvItem.Sales_Invoice__c = salInvoice.Id;
        slInvItem.Product__c = stock.Product__c;
        slInvItem.Stock__c = stock.Id;
        slInvItem.Sales_Tax__c = 5;
        slInvItem.Quantity__c = 70;
        slInvItem.Unit_Price__c = 100;
        slInvItem.Discount_Percent__c = 1;
        slInvItem.Total_after_discount__c = 7000;
        insert slInvItem;
        
        Sales_Invoice_Item__c slInvItem2 = new Sales_Invoice_Item__c();
        slInvItem2.Total__c = 100;
        slInvItem2.GST_Percentage__c = 1;
        slInvItem2.Sales_Invoice__c = salInvoice.Id;
        slInvItem2.Product__c = stock.Product__c;
        slInvItem2.Stock__c = stock.Id;
        slInvItem2.Sales_Tax__c = 5;
        slInvItem2.Quantity__c = 70;
        slInvItem2.Unit_Price__c = 100;
        slInvItem2.Discount_Percent__c = 1;
        slInvItem2.Total_after_discount__c = 7000;
        insert slInvItem2;
        
        Address__c add1 = new Address__c();
		add1.Customer__c = acc.id; 
        add1.Address__c = 'Church Street';
        add1.Address_Type__c = 'B';
        add1.Block__c = 'Test';
        add1.Building__c = 'Test';
        add1.City__c = 'Test';
        add1.Country__c = 'IN';
        add1.District__c = 'Bagalkot';
       // add1.GST_No__c = 'DRTYUIOPMBDERTY';
        add1.RowNum__c = 2;
        add1.State__c = 'KT';
        add1.Street__c = 'Street';
        add1.Street_No__c = 'Street No';
        add1.ZipCode__c = 000000;
        
      
        insert add1;
        Test.startTest();
        
        
        PageReference pageRef = Page.InvoicePDF;
        pageRef.getParameters().put('id', salInvoice.Id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(salInvoice);
        InvoicePDFControllerClass testAccPlan = new InvoicePDFControllerClass(sc);
        
        Test.stopTest(); 
    }

}