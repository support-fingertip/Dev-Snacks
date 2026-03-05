@isTest
public class StockTriggerTest {

     @isTest
    Public static void Test()
    {
       
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
        his.Date__c = system.today();
        insert his;        
        
        
        Stock__c stock = new Stock__c();
        stock.Intial_Stock__c = 100;
        stock.Available_Quantity__c = 70;
        stock.Sold_Qty__c = 15;
        stock.Blocked_Quantity__c = 15;
        stock.Product__c = productRec.id;
        stock.Route__c = routeRec.Id;
        Insert stock;
     
        Stock__c stock2 = new Stock__c();
        stock2.Intial_Stock__c = 100;
        stock2.Available_Quantity__c = 1;
        stock2.Sold_Qty__c = 15;
        stock2.Blocked_Quantity__c = 15;
        stock2.Product__c = productRec.id;
        stock2.Route__c = routeRec.Id;
        stock2.Stock_Type__c = 'Damaged';
        Insert stock2;
        
     
    }
}