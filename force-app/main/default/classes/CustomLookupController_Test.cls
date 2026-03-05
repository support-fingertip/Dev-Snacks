@isTest
public class CustomLookupController_Test {

    Public static testmethod void testlookup(){
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
       CustomLookupController.fetchRecords('Route__c','Name','Name','',''); 
        CustomLookupController.testcover();
    }
}