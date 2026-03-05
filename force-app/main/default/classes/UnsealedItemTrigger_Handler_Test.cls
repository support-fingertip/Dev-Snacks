@IsTest
public class UnsealedItemTrigger_Handler_Test {

    @IsTest
    static void testUpdateStockHistory() {

        Account acc = new Account(
            Name = 'Test Customer'
        );
        insert acc;

        Route__c route = new Route__c(
            Name = 'Test Route'
        );
        insert route;

        Product__c prod = new Product__c(
            Name = 'Test Product'
        );
        insert prod;

        Stock__c stock = new Stock__c(
            Available_Quantity__c = 100,
            Free_Quantity__c = 10
        );
        insert stock;

        Unsealed__c unsealed = new Unsealed__c(
            Customer__c = acc.Id,
            Route__c = route.Id,
            Company_Id__c = 'Dev'
        );
        insert unsealed;

        List<Unsealed_Item__c> unsealedItems = new List<Unsealed_Item__c>{
            new Unsealed_Item__c(
                Unsealed__c = unsealed.Id,
                Stock__c = stock.Id,
                Product__c = prod.Id,
                Quantity__c = 5
            ),
            new Unsealed_Item__c(
                Unsealed__c = unsealed.Id,
                Stock__c = stock.Id,
                Product__c = prod.Id,
                Quantity__c = 3
            )
        };
        insert unsealedItems;

       String extId = String.valueOf(prod.Id)
             + String.valueOf(route.Id)
             + String.valueOf(System.today());


        Stock_History__c history = new Stock_History__c(
            Product__c = prod.Id,
            Route__c = route.Id,
            Ext_ID__c = extId,
            Unsealed_Quantity__c = 0
        );
        insert history;

        Test.startTest();
        UnsealedItemTrigger_Handler.updateStockHistory(unsealedItems);
        Test.stopTest();

        Stock__c updatedStock = [
            SELECT Available_Quantity__c, Free_Quantity__c
            FROM Stock__c
            WHERE Id = :stock.Id
        ];

        System.assertEquals(
            Decimal.valueOf(92),
            updatedStock.Available_Quantity__c
        );

        System.assertEquals(
            Decimal.valueOf(18),
            updatedStock.Free_Quantity__c
        );

        Stock_History__c updatedHistory = [
            SELECT Unsealed_Quantity__c
            FROM Stock_History__c
            WHERE Ext_ID__c = :extId
            LIMIT 1
        ];

        System.assertEquals(
            Decimal.valueOf(8),
            updatedHistory.Unsealed_Quantity__c
        );
    }
}