@isTest
public class CollectionSheetControllerTest {

    public static testmethod void testRoute(){
                 Account acc=new Account();
        acc.Name='testaccount';
        acc.Phone = '9985522322';
        acc.Contact_Person__c = 'test';
    	acc.CompanyId__c = 'Dev';
       // acc.Approval_Status__c = 'approved';
        insert acc;
        
        acc.Approval_Status__c = 'Approved';
        update acc;
       
        
        Branch__c br = new Branch__c();
        br.Name = 'BR1';
        br.Cash_In_Hand__c = 100000;
        insert br;
        
        Route__c rt = new Route__c();
        rt.Name = 'RT1';
        insert rt;
        
         
        Cashbook__c cb = new Cashbook__c();
        cb.Opening_Balance__c = 2000;
        cb.Closing_Balance__c = 3000;
        cb.Date__c = system.today();
        cb.Route__c = rt.Id;
        insert cb;
        
        Cash_Transfer__c ct = new Cash_Transfer__c();
        ct.From__c = 'Branch';
        ct.To__c = 'Route';
        ct.Branch__c = br.Id;
        ct.Route__c = rt.Id;
        ct.Amount__c = 30000;
        insert ct;
        
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
        
         Sales_invoice__c sl = new Sales_invoice__c();
         sl.Name = 'testsal';
         sl.Customer__c = acc.id;
         sl.Route__c = rt.id;
         sl.Doc_Date__c = Date.NewInstance(2022,03,09);
         sl.Tax_Date__c = Date.NewInstance(2022,03,09);
         sl.Payment_Type__c = 'Immediate';
        sl.Invoice_Date__c = system.today();
        insert sl;

         
         Sales_Invoice_Item__c slInvItem = new Sales_Invoice_Item__c();
         slInvItem.Total__c = 100;
         slInvItem.GST_Percentage__c = 1;
         slInvItem.Sales_Invoice__c = sl.Id;
         slInvItem.Product__c = stock.Product__c;
         slInvItem.Stock__c = stock.Id;
         slInvItem.Quantity__c = 1;
         slInvItem.Unit_Price__c = 100;
         slInvItem.Discount_Percent__c = 1;
         slInvItem.Total_after_discount__c = 100;
        insert slInvItem;
        
        Receipt__c rec = new Receipt__c();
        rec.Branch__c = br.Id;
        rec.Sales_Invoice__c = sl.Id;
        rec.Mode_of_payment__c = 'Cheque';
        rec.Cheque_Date__c = system.today();
        rec.Cheque_Trasaction_Number__c = 123456789;
        rec.Customer__c = acc.Id;
        rec.Amount__c = 2000;
        rec.Route__c = rt.Id;
        insert rec;
        

        
        Test.startTest();

        
        PageReference pageRef = Page.Cashbook;
        Test.setCurrentPage(pageRef);
        
        
         ApexPages.currentPage().getParameters().put('Id',rt.Id );
        ApexPages.currentPage().getParameters().put('from', String.valueOf(System.today()) );
        ApexPages.currentPage().getParameters().put('to', String.valueOf(System.today())  );
        
        CollectionSheetController b2 = new CollectionSheetController();
        Test.stopTest(); 
        
    }
}