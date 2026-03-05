@IsTest
private class ExpenseTriggerTest {
    static testMethod void testExpenseTrigger() {
        // Create a test user
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
            Route_Id__c = 'TEST');
        insert testUser;
        
        // Create a test route
        Route__c r = new Route__c();
        r.Route_Id__c = 'TEST';
        r.Cash_In_Hand__c = 100;
        r.OwnerId = testUser.Id;
        insert r;
        system.debug('Route is - '+r);
        
        system.runAs(testUser){
            
            // Create a test trip
            Trip__c tr = new Trip__c();
            tr.Route__c = r.id;
            tr.Cash_In_Hand__c = 100;
            tr.Last_Cleared_Date__c = System.today();
            tr.Status__c = 'Started';
            insert tr;
            system.debug('Trip is - '+tr);
            
            // Create a test daily log
            DailyLog__c dl = new DailyLog__c();
            dl.Clock_In__c = System.Today();
            dl.Clock_In__c = System.today() + 1;
            dl.Trip__c = tr.Id;
            insert dl;
            system.debug('Daily log - '+dl);
            
            // Create a test expense
            Expense__c exp = new Expense__c();
            exp.Select_Expense_Entry__c = '	General Entry';
            exp.Expense_Comments__c = 'Some Comment';
            try{
                insert exp;
            }
            catch(DMLException e)
            {
                system.debug('Error is - '+e.getMessage());
            }
            Expense__c exp1 = new Expense__c();
            exp1.Select_Expense_Entry__c = '	General Entry';
            exp1.Expense_Comments__c = 'Some Comment';
            // exp1.OwnerId = UserInfo.getUserId();
            try{
                insert exp1;
            }
            catch(DMLException e)
            {
                system.debug('Error is - '+e.getMessage());
            }
            
            
            
            // Test before insert trigger
            Test.startTest();
            
            exp.Approval_Status__c = 'Approved';
            update exp;
            
            exp1.Approval_Status__c = 'Rejected';
            update exp1;
            Test.stopTest();
        }
    }
    
    
}