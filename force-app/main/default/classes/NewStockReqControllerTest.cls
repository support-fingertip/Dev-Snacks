@isTest
public class NewStockReqControllerTest {
    @isTest
    public static void testNewStockReqController(){
        
        Warehouse__c wh = new Warehouse__c();
        wh.name = 'test';
        insert wh;
        List<Route__c> rut = new List<Route__c>();
        Route__c r = new Route__c();
        r.warehouse__c = wh.id;
        r.Name = 'test route';
        rut.add(r);
        insert rut;
         Vehicle__c vh = new Vehicle__c();
        vh.Vehicle_Number__c = '23';
        insert vh;
         Branch__c br = new Branch__c();
        br.Name = 'tesbranch';
        br.Address__c = 'Bengaluru';
        br.Branch_Id__c = 453647;
        br.Account_Id__c = 'AccountId';
        br.Account_Name__c = 'Acc';
        insert br;
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
		Account acc=new Account();
        acc.Name='testaccount';
        acc.Phone = '9985522322';
        acc.Contact_Person__c = 'test';
        acc.CompanyId__c = 'Dev';
        acc.Cash_Discount__c = 1;
        insert acc;
        Sales_invoice__c sl = new Sales_invoice__c();
         sl.Name = 'testsal';
         sl.Customer__c = acc.id;
         sl.Route__c = r.id;
         sl.Doc_Date__c = Date.NewInstance(2022,03,09);
         sl.Tax_Date__c = Date.NewInstance(2022,03,09);
         sl.Payment_Type__c = 'Credit';
         //sl.Grand_Total_Discounted__c = 10;
         //sl.Amount_Received__c = 10;
         
         insert sl;
        Stock_Request__c sr = new Stock_Request__c();
        sr.Request_Date__c = Date.newInstance(2023, 06, 16);
        sr.Branch__c = br.Id;
        sr.Route__c = r.Id;
        sr.Vehicle__c = vh.Id;
        insert sr;
        
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
        String invItemList = JSON.serialize(slInvItems);
        
       /*Invoice__c i2 = new Invoice__c();
        i2.EID__c = 'chhchccgrcr';
        insert i2;*/
		List<Stock_Request_Item__c> srList = new List<Stock_Request_Item__c>();
            Stock_Request_Item__c srt = new Stock_Request_Item__c();
            srt.Received_Qunatity__c = 234;
        
            srt.Product__c = productRec.id;
            srt.Name = 'test';
            srList.add(srt);
       
        
        
        
        NewStockReqController.getSelectedProduct(productRec.Id);
        NewStockReqController.getStock();
        NewStockReqController.getUIThemeDescription();
        NewStockReqController.getProducts('10', '1', 'Test', 'ASC', 'Name', 'Name');
         NewStockReqController.getProducts('10', '1', 'Test', 'ASC', 'Name', 'Code');
      //  NewStockReqController.upsertReqItem(invItemList, i2.id);
        NewStockReqController.saveNewRequest(srList);
    }

}