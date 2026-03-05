@isTest
public class VisitManagerCloneTest {
	 public static testMethod void movetoNext(){
         

         
        Warehouse__c wh = new Warehouse__c();
        wh.name = 'test';
        insert wh;
         
        User user = [select id,name,Route_Id__c from User where id=:UserInfo.getUserId() limit 1];
        List<Route__c> rut = new List<Route__c>();
        Route__c r = new Route__c();
        r.warehouse__c = wh.id;
        r.Name = 'test route';
        r.Route_Id__c = user.Route_Id__c;
        rut.add(r);
        insert rut;
         
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
        acc.warehouse__c = rut[0].warehouse__c;
        acc.routes__c = rut[0].id;
         acc.Credit_period__c = 10;
        
         acLIst.add(acc);
        insert acLIst;
         
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
        Insert stock;
         
         
      	
         List<Visit__c> visitList = new List<Visit__c>();
        /*Visit__c vst1 = new Visit__c();
        vst1.Actual_Start_Time__c = System.now();
        vst1.Planned_Start_Time__c = System.now();
        vst1.Account1__c=acc.id;
         vst1.Eid__c = 'mnh25ad221a5';
        vst1.Status__c = 'Planned';
        vst1.Comments__c = 'Reach ASAP';
        visitList.add(vst1);*/
         
        
        Visit__c vst2 = new Visit__c();
        vst2.Actual_Start_Time__c = system.now();
        vst2.Account1__c=acLIst[0].id;
        vst2.Planned_Start_Time__c = system.now();
        vst2.Eid__c = 'mnh25ad221a5';
        vst2.Status__c = 'Planned';
        vst2.Comments__c = 'Reachndhd';
         visitList.add(vst2);
        insert visitList;
         List<Product__c> proli = new List<Product__c>();
         Product__c pro = new Product__c();
         pro.Name = 'test';
         proli.add(pro);
         insert pro;
         
         List<String> cartProductIds = new List<String>();
         for (Product__c product : proli) {
             cartProductIds.add(product.Id);
         }
         
         Stock__c st = new Stock__c();
         st.Product__c = pro.Id;
         insert st;
         
         string acid= acc.id;
         string pid = pro.id;
     
         list<DailyLog__c> dllist = new list<DailyLog__c>();
         DailyLog__c dl = new DailyLog__c();
         dl.Clock_In__c = system.now();
         dl.Clock_In_Location__Latitude__s = 23.733732;
         dl.Clock_In_Location__Longitude__s = 69.859741;
         dllist.add(dl);
         insert dllist;
         string vs1 = JSON.serialize(visitList);
         
         List<Sales_invoice__c> sllist = new List<Sales_invoice__c>();
         Sales_invoice__c sl = new Sales_invoice__c();
         sl.Name = 'testsal';
         sl.Customer__c = acc.id;
         sl.Route__c = r.id;
         sl.Doc_Date__c = Date.NewInstance(2022,03,09);
         sl.Tax_Date__c = Date.NewInstance(2022,03,09);
         sl.Payment_Type__c = 'Credit';
         //sl.Grand_Total_Discounted__c = 10;
         //sl.Amount_Received__c = 10;
         sllist.add(sl);
         insert sllist;
         
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
         
         List<Sales_order__c> slOrder = new List<Sales_order__c>();
         Sales_order__c slo = new Sales_order__c();
         slo.Customer__c = acc.id;
         slo.Route__c = r.id;
         slo.Warehouse__c = wh.id;
         slOrder.add(slo);
         insert slOrder;  
         
         List<Sales_order_Item__c> slOrdItems = new List<Sales_order_Item__c>();
         Sales_order_Item__c slOrdItem = new Sales_order_Item__c();
         slOrdItem.Total__c = 100;
         slOrdItem.GST_Percentage__c = 1;
         slOrdItem.Sales_order__c = slo.Id;
         slOrdItem.Product__c = stock.Product__c;
         slOrdItem.Stock__c = stock.Id;
         slOrdItem.Quantity__c = 1;
         slOrdItem.Unit_Price__c = 100;
         slOrdItem.Discount_Percent__c = 1;
         slOrdItem.Total_after_discount__c = 100;
         slOrdItems.add(slOrdItem);
         
         Sales_Order__c sord = new Sales_Order__c();
         sord.customer__c = acc.id;
         insert sord;
         
         Receipt__c receipt = new Receipt__c();
         receipt.Route__c = r.Id;
         receipt.Vehicle__c = r.Vehicle__c;
         receipt.Branch__c = r.Branch_Name__c;
         receipt.Warehouse__c = r.Warehouse__c;
         receipt.Type__c = 'Against Invoice';
         receipt.Receipt_Date__c = system.today();
         receipt.Customer__c = acc.Id;

         List<Unsealed__c> unsealedList = new List<Unsealed__c>();
         Unsealed__c goodsIssue = new Unsealed__c();
         goodsIssue.Branch__c = r.Branch_Name__c;
         goodsIssue.Route__c = r.id;
         goodsIssue.Customer__c =  acc.id;
         goodsIssue.Date__c = system.today();  
         goodsIssue.Trip__c = tr.id;
         unsealedList.add(goodsIssue);
         
         List<Unsealed_Item__c> unsealedStrItemList = new List<Unsealed_Item__c>();
         Unsealed_Item__c unsealedItem = new Unsealed_Item__c();
         unsealedItem.Stock__c = stock.Id;
         unsealedItem.Product__c = stock.Product__c;
         unsealedItem.Quantity__c = 1;
         unsealedStrItemList.add(unsealedItem);
         
         String unsealedStr = JSON.serialize(unsealedList);
         String unsealedItemStr = JSON.serialize(unsealedStrItemList);
         String orderList = JSON.serialize(sllist);
         String salesOrderList = JSON.serialize(slOrder);
         String invItemList = JSON.serialize(slInvItems);
         String orderItemList = JSON.serialize(slOrdItems);
         system.debug('orderList==== '+orderList);
         String ordName = acc.Id;
        String soName = sord.Id;
         
         string ordtes = 'Test';
         string ordl = 'Testlost';

        test.startTest();
        VisitManagerClone.loadVisits(UserInfo.getUserId());
         VisitManagerClone.getBanks();
         VisitManagerClone.getProducts();
         VisitManagerClone.getTripData();
         VisitManagerClone.getAccounts();
         VisitManagerClone.upsertAccounts(acLIst);
         VisitManagerClone.getTodaysVisits();
         VisitManagerClone.upsertVisits(vs1);
         VisitManagerClone.getDailyLog();
         VisitManagerClone.checkCreditPeriod(acc.id); 
         VisitManagerClone.checkStockForPrpduct(pro.id);
         VisitManagerClone.getCartProductStocks(pro.id);
         VisitManagerClone.getSelectedStockRec(st.id);
         VisitManagerClone.upsertDailyLog(dl,tr);
         VisitManagerClone.getDiscounts(acc.id);
         VisitManagerClone.getproductList();
         VisitManagerClone.getOrderItems();
         VisitManagerClone.getEmployees();
         VisitManagerClone.getOrders();
         VisitManagerClone.getOrderItems();
         VisitManagerClone.getCurrentButtonValue();
         system.debug('invItemList=== '+invItemList);
         VisitManagerClone.upsertOrderItem(invItemList,sl.Id,acc.Id);
         VisitManagerClone.getCartProducts(cartProductIds);
         VisitManagerClone.getOders(acc.Id);
         VisitManagerClone.getOdersItems(slo.Id);
         VisitManagerClone.upsertNewOrder(orderList,acc.Id);
         VisitManagerClone.addNewOrder(salesOrderList);
         VisitManagerClone.upsertSalesInvoiceItem(slInvItems,sl.Id);
         VisitManagerClone.addOrderItem(orderItemList,slo.Id,acc.Id);
         VisitManagerClone.saveReceipt(receipt,100,sl.Id);
         VisitManagerClone.insertSalesItem(orderItemList,slo.Id);
         List<Unsealed__c> unsealedObj = VisitManagerClone.addUnsealed(unsealedStr, acc.Id);
         VisitManagerClone.addUnsealedItems(unsealedItemStr,unsealedObj[0].Id, acc.Id);
         VisitManagerClone.getCashDiscount(slo.Id);
         test.stopTest();
     }
    
}