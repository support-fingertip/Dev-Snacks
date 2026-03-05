@isTest
public class SalesOrderItemListCtrlTest {
    
    public static testmethod void testConvert(){
        Account acc=new Account();
        acc.Name='testaccount';
        acc.Phone = '9985522322';
        acc.Contact_Person__c = 'test';
        acc.CompanyId__c = 'Dev';
        acc.Cash_Discount__c = 1;
        insert acc;
        
        acc.Approval_Status__c = 'Approved';
        update acc;
        
         Route__c rt = new Route__c();
        rt.Name = 'RT1';
        insert rt;
        
         Trip__c tr = new Trip__c();
        tr.Route__c = rt.id;
        tr.Cash_In_Hand__c = 100;
        tr.Last_Cleared_Date__c = System.today();
        tr.Status__c = 'Started';
        insert tr;
		system.debug('Trip is - '+tr);
        
        // Create a test daily log
        DailyLog__c dl = new DailyLog__c();
        dl.Clock_In__c = System.Today();
        dl.Trip__c = tr.Id;
        insert dl;
        
        Discount__c dis = new Discount__c();
        dis.GST_Percentage__c = '12';
        dis.Discount_Percent__c = 5;
        dis.Customer__c = acc.Id;
        insert dis;
        
          Product__c pro = new Product__c();
         pro.Name = 'test';
         insert pro;
        
         Stock__c st = new Stock__c();
         st.Product__c = pro.Id;
        st.Intial_Stock__c = 100;
         insert st;
        
        Sales_Order__c so = new Sales_Order__c();
        so.Order_Date__c = system.today();
        so.Customer__c = acc.id;
        so.Route__c = rt.id;
        insert so;
        
        list<Sales_order_item__c>upsertlst=new list<Sales_order_item__c>();
        Sales_order_item__c soItem = new Sales_order_item__c();
        soItem.Total__c=200;
        soItem.GST_Percentage__c=10;
        soItem.Product__c=pro.Id;
        soItem.Stock__c =st.id;
        soItem.Quantity__c=20;
        soItem.Unit_Price__c = 30;
        soItem.Sales_order__c=so.Id;
        soItem.Discount_Percent__c = 1;
        soItem.Total_after_discount__c = 200;
        upsertlst.add(soItem);
        insert upsertlst;
        
        Receipt__c rec = new Receipt__c();
        rec.Mode_of_payment__c = 'Cash';
        rec.Customer__c = acc.Id;
        
        Test.startTest();
        
        SalesOrderItemListCtrl.getOrder(so.Id);
        SalesOrderItemListCtrl.getOrderStatus(so.Id);
        SalesOrderItemListCtrl.getOrderItems(so.Id);
        SalesOrderItemListCtrl.getCashDiscount(so.Id);
        SalesOrderItemListCtrl.getDiscounts(acc.Id);
        SalesOrderItemListCtrl.getStock(rt.Id);
        SalesOrderItemListCtrl.getBanks();
       String invId =  SalesOrderItemListCtrl.createInvoice(upsertlst, so.id,'Credit');
        SalesOrderItemListCtrl.deleteSalesOrderItem(soItem.Id);
        SalesOrderItemListCtrl.checkCreditPeriod(so.Id);
        SalesOrderItemListCtrl.saveReceipt(rec, 2000.0, invId);
        Test.stopTest();
    }
}