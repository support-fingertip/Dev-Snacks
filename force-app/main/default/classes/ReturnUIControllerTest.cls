@IsTest
public class ReturnUIControllerTest {

    // Test data setup
    @TestSetup
    static void setupData() {

        // Route
        Route__c route = new Route__c();
        insert route;

        // Account with route
        Account acc = new Account(
            Name = 'Test Customer',
            Routes__c = route.Id
        );
        insert acc;

        // Custom Product
        Product__c product = new Product__c();
        insert product;

        // Batch
        Batch__c batch = new Batch__c(
            Active__c = true
        );
        insert batch;

        // Stock (only writeable fields)
        Stock__c stock = new Stock__c(
            Route__c = route.Id,
            Product__c = product.Id,
            Batch_Number__c = batch.Name,
            Available_Quantity__c = 10,
            Sold_Qty__c = 5,
            Stock_Type__c = 'New'
        );
        insert stock;

        // Sales Invoice
        Sales_Invoice__c inv = new Sales_Invoice__c(
            Customer__c = acc.Id
        );
        insert inv;

        // Sales Invoice Item
        Sales_Invoice_Item__c invItem = new Sales_Invoice_Item__c(
            Sales_Invoice__c = inv.Id,
            Product__c = product.Id,
            Stock__c = stock.Id,
            Quantity__c = 2,
            Unit_Price__c = 100
        );
        insert invItem;

        // Discount
        Discount__c disc = new Discount__c(
            Customer__c = acc.Id,
            Discount_Percent__c = 10
        );
        insert disc;

        // Return
        Return__c ret = new Return__c(
            Type__c = 'Against Invoice',
            Sales_Invoice__c = inv.Id
        );
        insert ret;
    }

    // getCustomerStock success case
    @IsTest
    static void testGetCustomerStock() {

        Account acc = [SELECT Id FROM Account WHERE Routes__c != null LIMIT 1];

        Test.startTest();
        ReturnUIController rc = ReturnUIController.getCustomerStock(acc.Id);
        Test.stopTest();

        System.assertNotEquals(null, rc);
        System.assertNotEquals(null, rc.customer);
        System.assertNotEquals(null, rc.stocks);
    }

    // getCustomerStock when route missing
    @IsTest
    static void testGetCustomerStock_NoRoute() {

        Account acc = new Account(Name = 'No Route Acc');
        insert acc;

        try {
            Test.startTest();
            ReturnUIController.getCustomerStock(acc.Id);
            Test.stopTest();
            System.assert(false);
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Please add route'));
        }
    }

    // getInvoiceItems
    @IsTest
    static void testGetInvoiceItems() {

        Sales_Invoice__c inv = [SELECT Id FROM Sales_Invoice__c LIMIT 1];

        Test.startTest();
        List<Sales_Invoice_Item__c> items =
            ReturnUIController.getInvoiceItems(inv.Id);
        Test.stopTest();

        System.assert(items.size() > 0);
    }

    // getDiscounts
    @IsTest
    static void testGetDiscounts() {

        Account acc = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        List<Discount__c> discounts =
            ReturnUIController.getDiscounts(acc.Id);
        Test.stopTest();

        System.assertEquals(1, discounts.size());
    }

    // saveNewReturn
    @IsTest
    static void testSaveNewReturn() {

        Return__c ret = [SELECT Id FROM Return__c LIMIT 1];
        Stock__c stock = [SELECT Id FROM Stock__c LIMIT 1];

        Return_Item__c ri = new Return_Item__c(
            Quantity__c = 2,
            Stock__c = stock.Id
        );

        Test.startTest();
        String retId = ReturnUIController.saveNewReturn(
            ret.Id,
            null,
            new List<Return_Item__c>{ ri }
        );
        Test.stopTest();

        System.assertEquals(ret.Id, retId);

        List<Return_Item__c> items =
            [SELECT Id FROM Return_Item__c WHERE Return__c = :ret.Id];

        System.assertEquals(1, items.size());
    }
}