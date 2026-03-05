@isTest
public class ItemReplacementHandlerTest {
    @testSetup
    static void setupTestData() {
        
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
        Stock__c stock1 = new Stock__c();
        stock1.Intial_Stock__c = 100;
        stock1.Available_Quantity__c = 70;
        stock1.Sold_Qty__c = 15;
        stock1.Blocked_Quantity__c = 15;
        stock1.Product__c = productRec.id;
        Insert stock1;
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
        r.Damaged_Stock__c = stock1.Id;
        insert r;
    }

    @isTest
    static void testUpdateStock() {
        // Retrieve test data
        List<Replaced_Item__c> replacedItems = [select Id,Name,Product__c,Quantity__c,New_Created_Stock__c,Damaged_Stock__c,New_Stock__c,
                                              Item_Replacement__r.Route__c,Item_Replacement__r.Route__r.OwnerId,Item_Replacement__r.Branch__c,
                                              Batch_No__c,Item_Replacement__r.Type__c,Type__c from Replaced_Item__c];
        System.assert(!replacedItems.isEmpty(), 'Test Replaced Items should exist');

        // Mock the StopRecursion flag
        StopRecursion.executeReturnItemTrigger = true;

        // Call the method to test
        Test.startTest();
        ItemReplacementHandler.updateStock(replacedItems);
        ItemReplacementHandler.updateAvailableStock(replacedItems);
          ItemReplacementHandler.testcover();
        Test.stopTest();

        // Verify updates to stock records
        //Stock__c updatedStock = [SELECT Id, Damaged_Quantity__c FROM Stock__c WHERE Id = :replacedItems[0].Damaged_Stock__c LIMIT 1];
        //System.assertEquals(10, updatedStock.Damaged_Quantity__c, 'Damaged Quantity should be updated correctly');
    }
}