@IsTest
public class vanStockControllerTest {

    @IsTest
    static void testVanStockController_WithParams() {

       
        // 1. Create required master data
     

        // Route
        Route__c route = new Route__c(
            Name = 'Test Route'
        );
        insert route;

        // Custom Product (NOT Product2)
        Product__c product = new Product__c(
            Name = 'Test Product'
        );
        insert product;

        
        // 2. Create Stock History record
        
        Stock_History__c stock = new Stock_History__c(
            Route__c = route.Id,
            Product__c = product.Id,
            Opening_Quantity__c = 10,
            Initial_Quantity__c = 20,
            Sold_Quantity__c = 5,
            Available_Quantity__c = 25,
            Damaged_Quantity__c = 1,
            Free_Quantity__c = 2,
            Unsealed_Quantity__c = 1,
            Date__c = Date.today()
        );
        insert stock;

        
        // 3. Set VF page & parameters
        // (avoid static resource issue)
    
        Test.setCurrentPage(new PageReference('/apex/dummy'));
        ApexPages.currentPage().getParameters().put('Id', route.Id);
        ApexPages.currentPage().getParameters().put('from', String.valueOf(Date.today().addDays(-1)));
        ApexPages.currentPage().getParameters().put('to', String.valueOf(Date.today().addDays(1)));

       
        // 4. Execute controller
        
        Test.startTest();
        vanStockController controller = new vanStockController();
        Test.stopTest();

      
        // 5. Assertions
      
        System.assertNotEquals(
            null,
            controller.stockList,
            'Stock list should not be null'
        );

        System.assertEquals(
            1,
            controller.stockList.size(),
            'One Stock History record expected'
        );

        System.assertEquals(
            'Test Product',
            controller.stockList[0].Product__r.Name,
            'Product name should match'
        );
    }

    @IsTest
    static void testVanStockController_WithoutParams() {

        // No parameters passed
        Test.setCurrentPage(new PageReference('/apex/dummy'));

        Test.startTest();
        vanStockController controller = new vanStockController();
        Test.stopTest();

        // stockList should remain null
        System.assertEquals(null, controller.stockList);
    }
}