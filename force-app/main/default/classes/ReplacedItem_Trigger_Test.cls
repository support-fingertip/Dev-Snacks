@isTest
public class ReplacedItem_Trigger_Test {
@isTest
    Public static void Testdata(){
        // Create test data
        
        //List<Product__c> listproducts =  [SELECT Id,Name,MRP__c,Product_Image_Url__c , GST__c FROM Product__c where MRP__c != null];
        //system.debug('listproducts : '+listproducts);
        Account acc=new Account();
        acc.Name='testaccount1';
        acc.Phone = '9985542322';
        acc.Email__c = 'test@gmail.com';
        acc.CardType__c = 'C';
        acc.CompanyId__c = 'Dev';
        acc.OwnerId = UserInfo.getUserId();
        insert acc;
        
        Route__c routeRec = new Route__c();
        routeRec.Name = 'Kannur Route';
        routeRec.Route_Id__c = 'RI-01000';
        routeRec.Week_Sales__c = 'SUN';
        //routeRec.Week__c = 'First Week';
        insert routeRec;
        
        Product__c productRec = new Product__c();
        productRec.Name = 'Dev Snacks Rosted peanut';
        productRec.Product_Code__c = 'P009';
        productRec.MRP__c = 25;
        productRec.GST__c = '5';
        insert productRec;
        
        Stock_History__c his = new Stock_History__c();
        his.Route__c = routeRec.Id;
        his.Product__c = productRec.Id;
        his.Opening_Quantity__c = 100;
        his.Available_Quantity__c = his.Opening_Quantity__c;
        his.Ext_ID__c = String.valueOf(his.Product__c) + String.valueOf(his.Route__c)  + system.today();
        his.Date__c = system.today() ;
        insert his;      
        
        
        Stock__c stock = new Stock__c();
        stock.Intial_Stock__c = 100;
        stock.Available_Quantity__c = 70;
        stock.Sold_Qty__c = 15;
        stock.Blocked_Quantity__c = 15;
        stock.Product__c = productRec.id;
        Insert stock;
        Item_Replacement__c item = new Item_Replacement__c();
        item.Customer__c=acc.Id;
           item.Type__c='Replacement';
         item.Route__c=routeRec.Id;
        insert item;
        Replaced_Item__c r = new Replaced_Item__c();
        r.Item_Replacement__c=item.Id;
        r.Product__c=productRec.Id;
        r.Quantity__c=2;
        r.New_Stock__c=stock.Id;
        insert r;
        
    }
}