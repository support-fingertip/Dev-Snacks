@isTest
public class NewInvoiceCmpCtrlTest {
    
    @isTest
    Public static void Test(){
        
         User user = [select id,name,Route_Id__c from User where id=:UserInfo.getUserId() limit 1];
        List<Route__c> rut = new List<Route__c>();
        Route__c r = new Route__c();
        r.Name = 'test route';
        r.Route_Id__c = user.Route_Id__c;
        insert r;
         
        Trip__c tr = new Trip__c();
        tr.Route__c = r.id;
        insert tr;
        
        List<Account> acLIst = new List<Account>();
        Account acc=new Account();
        acc.Name='testaccount';
        acc.Phone = '9985522322';
        acc.Contact_Person__c = 'test';
        acc.Store_Category__c = 'Hyper market';
        acc.Grade__c = 'A';
        acc.EId__c = 'S25321252hsb2';
        acc.CompanyId__c = 'Dev';
      	acc.OwnerId = UserInfo.getUserId();
        acc.GeoLocation__latitude__s=23.733732;
        acc.GeoLocation__Longitude__s=69.859741;
        acc.routes__c = r.id;
         acc.Credit_period__c = 10;
        
         acLIst.add(acc);
        insert acLIst;
         Discount__c d = new Discount__c();
        d.Customer__c =acLIst[0].Id;
        d.GST_Percentage__c='12';
        d.Discount_Percent__c=10;
        d.Eva_Discount_Percent__c=10;
        insert d;
                 Discount__c d1 = new Discount__c();
        d1.Customer__c =acLIst[0].Id;
        d1.GST_Percentage__c='5';
        d1.Discount_Percent__c=10;
        d1.Eva_Discount_Percent__c=10;
        insert d1;
         acc.Approval_Status__c = 'Approved';
         update acc;
         
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
        stock.Stock_Type__c = 'New';
        stock.Manufacturing_Date__c = system.today()-1;
        stock.Price__c = 45;
        Insert stock;
        
        
        List<Visit__c> visitList = new List<Visit__c>();
        
        Visit__c vst2 = new Visit__c();
        vst2.Actual_Start_Time__c = system.now();
        vst2.Account1__c=acLIst[0].id;
        vst2.Planned_Start_Time__c = system.now();
        vst2.Eid__c = 'mnh25ad221a5';
        vst2.Status__c = 'In Progress';
        vst2.Comments__c = 'Reachndhd';
        vst2.Actual_Start_Time__c = system.today();
        visitList.add(vst2);
        insert visitList;
        
         List<Sales_invoice__c> sllist = new List<Sales_invoice__c>();
         Sales_invoice__c sl = new Sales_invoice__c();
         sl.Name = 'testsal';
         sl.Customer__c = acc.id;
         sl.Route__c = r.id;
         sl.Doc_Date__c = Date.NewInstance(2022,03,09);
         sl.Tax_Date__c = Date.NewInstance(2022,03,09);
         sl.Payment_Type__c = 'Credit';
        
         
         List<Sales_Invoice_Item__c> slInvItems = new List<Sales_Invoice_Item__c>();
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
         slInvItems.add(slInvItem);
        
         Test.startTest();
        NewInvoiceCmpCtrl.getData();
        NewInvoiceCmpCtrl.createInvoice(slInvItems, sl);
        
        Test.stopTest();
        
    }

}