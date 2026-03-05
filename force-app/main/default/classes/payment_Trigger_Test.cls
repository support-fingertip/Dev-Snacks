@isTest
public class payment_Trigger_Test {

    public static testmethod void test1()
    {
        
        
        Branch__c br = new Branch__c();
        br.Name = 'tesbranch';
        br.Address__c = 'Bengaluru';
        br.Branch_Id__c = 4;
        br.Account_Id__c = 'AccountId';
        br.Account_Name__c = 'Acc';
        insert br;
        
        User testUser = new User( ProfileId = [SELECT Id FROM Profile WHERE Name = 'system administrator'].Id, LastName = 'last', Email = 'puser000@amamama.com', Username = 'puser000@amamama.com' + System.currentTimeMillis(), CompanyName = 'TEST',Title = 'title', Alias = 'alias', Branch_Id__c = 123,TimeZoneSidKey = 'America/Los_Angeles', EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US');
        insert testUser;
        
        Route__c rt = new Route__c();
        rt.Name = 'RT1';
        rt.Route_Id__c = [select id,name,Route_Id__c,Branch_Id__c from User where id=:UserInfo.getUserId() limit 1].Route_Id__c;
        insert rt;
        //User name = [select id,Route_Id__c,Warehouse__c,Branch_Name__c,Vehicle__c,Cash_In_Hand__c,Last_Cleared_Date__c from]
        Trip__c tr = new Trip__c();
        tr.Route__c = rt.id;
        tr.Cash_In_Hand__c = 100;
        tr.Last_Cleared_Date__c = System.today();
        tr.Status__c = 'Started';
        insert tr;
		system.debug('Trip is - '+tr);
        
        DailyLog__c dl = new DailyLog__c();
        dl.Clock_In__c = System.Today();
        dl.Trip__c = tr.Id;
        insert dl;
        
        Account acc=new Account();
        acc.Name='testaccount';
        acc.Phone = '9985522322';
        acc.Contact_Person__c = 'test';
        acc.CompanyId__c = 'Dev';
        acc.Cash_Discount__c = 1;
        insert acc;
        
        acc.Approval_Status__c = 'Approved';
        update acc;

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
        slInvItem.Quantity__c = 70;
        slInvItem.Unit_Price__c = 100;
        slInvItem.Discount_Percent__c = 1;
        slInvItem.Total_after_discount__c = 7000;
        insert slInvItem;
        
       
        
        Receipt__c rec = new Receipt__c();
        rec.Mode_of_payment__c = 'Cheque';
        rec.Cheque_Date__c = system.today();
        rec.Cheque_Trasaction_Number__c = 89856;
        rec.Customer__c = acc.Id;
        rec.Type__c = 'On Account';
        rec.On_Account_Value__c = 1;
        rec.Amount__c = 200;
          rec.Bouncing_Charge__c=100;
        rec.Sales_Invoice__c = salInvoice.Id;
        //rec.On_Account_Value__c = 100;
        insert rec;
        
        Receipt_Item__c rItem = new Receipt_Item__c();
        rItem.Sales_Invoice__c = salInvoice.id;
        rItem.Receipt__c = rec.id;
        rItem.Amount__c = 200;
        insert rItem;
        list<Receipt__c> recl =new list<Receipt__c>();
         Receipt__c rec1 = new Receipt__c();
        rec1.Mode_of_payment__c = 'Cheque';
        rec1.Cheque_Date__c = system.today();
        rec1.Cheque_Trasaction_Number__c = 89856;
        rec1.Customer__c = acc.Id;
        rec1.Type__c = 'On Account';
        rec1.On_Account_Value__c = 1;
        rec1.Amount__c = 200;
        rec1.Bouncing_Charge__c=100;
        rec1.Sales_Invoice__c = salInvoice.Id;
        //rec.On_Account_Value__c = 100;
        //insert rec1;
        rec.Receipt_Status__c ='Cancelled';
        rec.Cheque_Bounced__c=true;
     recl.add(rec);
          rec1.Receipt_Status__c ='Cancelled';
        rec1.Cheque_Bounced__c=true;
         recl.add(rec1);
       // update recl;
       Payment__c p=new Payment__c();
        p.Bouncing_Charge__c=9;
        insert p;
    }

}