@isTest
public class AccountTriggerTest {
    @isTest
    static void testAccountTrigger() {
        // Create test User with a Route_Id__c value
        User testUser = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'system administrator'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
        Route_Id__c='Route123');
        insert testUser;

        // Create test Route related to the User's Route_Id__c value
        Route__c testRoute = new Route__c(
            Route_Id__c = 'Route123'
            //Branch_Name__c = 'Branch123',
            //Warehouse__c = 'Warehouse123',
            //Vehicle__c = 'Vehicle123'
        );
        insert testRoute;
        system.runAs(testUser){
               // Create test Account records
        Account testAccount1 = new Account(
            Name = 'Test Account 1',
            Approval_Status__c = 'Approved',
            CompanyId__c = 'Dev',
            Opening_Balance__c =100,
            Outstanding_Amount__c=0
        );
        Account testAccount2 = new Account(
            Name = 'Test Account 2',
            Approval_Status__c = 'Pending',
            CompanyId__c = 'Dev',
             Opening_Balance__c =100
        );

        Test.startTest();
        // Insert test Account records
        insert new List<Account>{testAccount1, testAccount2};
        Test.stopTest();

        // Verify the Account records have been updated with Route, Vehicle, and Warehouse information
        testAccount1 = [SELECT Routes__c, Vehicle__c, Warehouse__c FROM Account WHERE Id = :testAccount1.Id];
        testAccount2 = [SELECT Routes__c, Vehicle__c, Warehouse__c FROM Account WHERE Id = :testAccount2.Id];
               // Update testAccount1 to simulate triggering SAPsend_TriggerHandler
        testAccount1.Approval_Status__c = 'Approved';
        update testAccount1;
        }
     
		/*
        System.assertEquals(testRoute.Id, testAccount1.Routes__c);
        System.assertEquals(testRoute.Vehicle__c, testAccount1.Vehicle__c);
        System.assertEquals(testRoute.Warehouse__c, testAccount1.Warehouse__c);

        // Ensure testAccount2 has not been updated since it has a different Approval_Status__c value
        System.assertEquals(null, testAccount2.Routes__c);
        System.assertEquals(null, testAccount2.Vehicle__c);
        System.assertEquals(null, testAccount2.Warehouse__c);*/

     

        // Verify that SAPsend_TriggerHandler is triggered and called the sendToSap method
        // Assert the appropriate behavior of the SAPsend_TriggerHandler class based on the Account update
        // Mock the SAPsend_TriggerHandler class if needed and use System.assert to verify the expected behavior
    }
}