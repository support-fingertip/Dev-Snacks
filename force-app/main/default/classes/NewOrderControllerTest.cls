@IsTest
public class NewOrderControllerTest {

    @IsTest
    static void testGetStock() {

        // Create Product (required lookup)
        Product__c prod = new Product__c(
            Name = 'Test Product'
        );
        insert prod;

        // Create Stock record
        Stock__c stock = new Stock__c(
            Product__c = prod.Id,
            Available_Quantity__c = 10,
            Batch_Number__c = 'BATCH-001',
            Price__c = 100
        );
        insert stock;

        // Call method
        Test.startTest();
        List<Stock__c> stockList = NewOrderController.getStock();
        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, stockList);
        System.assert(stockList.size() > 0);

        Stock__c result = stockList[0];
        System.assertEquals(10, result.Available_Quantity__c);
        System.assertEquals('BATCH-001', result.Batch_Number__c);
        System.assertEquals(100, result.Price__c);
        System.assertEquals('Test Product', result.Product__r.Name);
    }
}