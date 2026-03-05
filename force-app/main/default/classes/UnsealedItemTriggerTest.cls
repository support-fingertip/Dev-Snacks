@isTest
public class UnsealedItemTriggerTest {

     @isTest
    Public static void Test(){
        
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
        acc.routes__c = routeRec.Id;
        acc.Credit_period__c = 10;
        
        insert acc;
        
        acc.Approval_Status__c = 'Approved';
        update acc;
        
    
        
          Stock__c stock = new Stock__c();
        stock.Intial_Stock__c = 100;
        stock.Available_Quantity__c = 70;
        stock.Sold_Qty__c = 15;
        stock.Blocked_Quantity__c = 15;
        stock.Product__c = productRec.id;
        Insert stock;
        
        Stock_History__c his = new Stock_History__c();
        his.Route__c = routeRec.Id;
        his.Product__c = productRec.Id;
        his.Opening_Quantity__c = 100;
        his.Available_Quantity__c = his.Opening_Quantity__c;
        his.Ext_ID__c = String.valueOf(his.Product__c) + String.valueOf(his.Route__c)  + system.today();
        his.Date__c = system.today() ;
        insert his;  
        
        Unsealed__c goodsIssue = new Unsealed__c();
        goodsIssue.Route__c = routeRec.Id;
        goodsIssue.Customer__c =  acc.id;
        goodsIssue.Date__c = system.today();  
		insert goodsIssue;
        
        Unsealed_Item__c unsealedItem = new Unsealed_Item__c();
        unsealedItem.Stock__c = stock.Id;
        unsealedItem.Product__c = stock.Product__c;
        unsealedItem.Quantity__c = 1;
        unsealedItem.Unsealed__c = goodsIssue.Id;
        insert unsealedItem;
        
    }
}