@IsTest
public class stockHandlerTest {

    @IsTest
    static void testAddBlockedQuantityToStock() {

        Stock__c s = new Stock__c(
          
            Intial_Stock__c = 100,
            Sold_Qty__c = 10,
            Free_Quantity__c = 5,
            Replaced_Quantity__c = 0,
            Blocked_Quantity__c = 0
        );
        insert s;

        Map<Id, Decimal> blockMap = new Map<Id, Decimal>();
        blockMap.put(s.Id, 20);

        Test.startTest();
        stockHandler.addBlockedQuantityToStock(blockMap);
        Test.stopTest();

        Stock__c updatedStock = [
            SELECT Blocked_Quantity__c, Available_Quantity__c
            FROM Stock__c
            WHERE Id = :s.Id
        ];

        System.assertEquals(20, updatedStock.Blocked_Quantity__c);
        System.assertEquals(65, updatedStock.Available_Quantity__c);
    }

    @IsTest
    static void testRemoveBlockedQuantityToStockReplacement() {

        Stock__c s = new Stock__c(
           
            Intial_Stock__c = 100,
            Sold_Qty__c = 10,
            Free_Quantity__c = 5,
            Replaced_Quantity__c = 0,
            Blocked_Quantity__c = 20
        );
        insert s;

        Map<Id, Decimal> blockMap = new Map<Id, Decimal>();
        blockMap.put(s.Id, 10);

        Test.startTest();
        stockHandler.removeBlockedQuantityToStock(blockMap, 'Replacement');
        Test.stopTest();

        Stock__c updatedStock = [
            SELECT Blocked_Quantity__c, Replaced_Quantity__c, Available_Quantity__c
            FROM Stock__c
            WHERE Id = :s.Id
        ];

        System.assertEquals(10, updatedStock.Blocked_Quantity__c);
        System.assertEquals(10, updatedStock.Replaced_Quantity__c);
        System.assertEquals(65, updatedStock.Available_Quantity__c);
    }

    @IsTest
    static void testRemoveBlockedQuantityToStockUnsealed() {

        Stock__c s = new Stock__c(
          
            Intial_Stock__c = 100,
            Sold_Qty__c = 10,
            Free_Quantity__c = 5,
            Replaced_Quantity__c = 0,
            Blocked_Quantity__c = 20
        );
        insert s;

        Map<Id, Decimal> blockMap = new Map<Id, Decimal>();
        blockMap.put(s.Id, 10);

        Test.startTest();
        stockHandler.removeBlockedQuantityToStock(blockMap, 'Unsealed');
        Test.stopTest();

        Stock__c updatedStock = [
            SELECT Blocked_Quantity__c, Free_Quantity__c, Available_Quantity__c
            FROM Stock__c
            WHERE Id = :s.Id
        ];

        System.assertEquals(10, updatedStock.Blocked_Quantity__c);
        System.assertEquals(15, updatedStock.Free_Quantity__c);
        System.assertEquals(65, updatedStock.Available_Quantity__c);
    }
}