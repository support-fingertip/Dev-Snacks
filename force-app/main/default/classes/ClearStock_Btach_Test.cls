@IsTest
public class ClearStock_Btach_Test {

    @testSetup
    static void setupData() {

        // 1️ Create Route
        Route__c route = new Route__c(
            Name = 'Test Route'
        );
        insert route;

        // 2️Create Stock linked to Route
        Stock__c stock = new Stock__c(
            Route__c = route.Id,
            Available_Quantity__c = 50,
            Intial_Stock__c = 50
        );
        insert stock;

        // 3️Create Stock History (TODAY)
        Stock_History__c sh = new Stock_History__c(
            Route__c = route.Id,
            Date__c = Date.today(),
            Available_Quantity__c = 50
        );
        insert sh;
    }

    @IsTest
    static void testClearStockBatch_success() {

        // Fetch Route
        List<Route__c> routes = [
            SELECT Id, Name FROM Route__c
        ];

        // Batch query (used in start method)
        String query = 'SELECT Id, Name FROM Route__c';

        Test.startTest();

        ClearStock_Btach batch =
            new ClearStock_Btach(query, routes);

        Database.executeBatch(batch, 1);

        Test.stopTest();

        // Validate Stock update
        Stock__c updatedStock = [
            SELECT Available_Quantity__c, Mismatch_Qty__c
            FROM Stock__c
            LIMIT 1
        ];

        System.assertEquals(0, updatedStock.Available_Quantity__c,
            'Available Quantity should be zero');
        System.assertEquals(50, updatedStock.Mismatch_Qty__c,
            'Mismatch Qty should match previous available qty');

        // Validate Stock History update
        Stock_History__c updatedSH = [
            SELECT Available_Quantity__c
            FROM Stock_History__c
            LIMIT 1
        ];

        System.assertEquals(0, updatedSH.Available_Quantity__c,
            'Stock history quantity should be zero');
    }
}