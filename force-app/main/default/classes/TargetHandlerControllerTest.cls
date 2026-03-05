@IsTest
public class TargetHandlerControllerTest {

    @testSetup
    static void setupData() {

        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        User manager = new User(
            FirstName = 'Manager',
            LastName = 'User',
            Email = 'manager@test.com',
            Username = 'manager' + System.currentTimeMillis() + '@test.com',
            Alias = 'mngr',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_IN',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        );
        insert manager;

        User exec = new User(
            FirstName = 'Exec',
            LastName = 'User',
            Email = 'exec@test.com',
            Username = 'exec' + System.currentTimeMillis() + '@test.com',
            Alias = 'exec',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_IN',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id,
            ManagerId = manager.Id
        );
        insert exec;

        Period__c period = new Period__c(
            Name = 'Test Period',
            Start_Date__c = Date.today().addDays(-5),
            End_Date__c = Date.today().addDays(5)
        );
        insert period;

        List<Target_Metrics__c> metrics = new List<Target_Metrics__c>{
            new Target_Metrics__c(Name = 'Sales', Active__c = true),
            new Target_Metrics__c(Name = 'Visits', Active__c = true),
            new Target_Metrics__c(Name = 'Account', Active__c = true)
        };
        insert metrics;

        List<Target__c> targets = new List<Target__c>();
        for (Target_Metrics__c tm : metrics) {
            targets.add(new Target__c(
                Executive__c = exec.Id,
                Target_Metrics__c = tm.Id,
                Target_Period__c = period.Id,
                Target__c = 100
            ));
        }
        insert targets;

        // Account used as Store / Company
        Account store = new Account(
            Name = 'Test Store',
            OwnerId = exec.Id
        );
        insert store;

        // -------- INVOICE (CompanyId__c via dynamic put) --------
        Invoice__c inv = new Invoice__c(
            OwnerId = exec.Id,
            Invoice_Date__c = Date.today(),
            Store__c = store.Id
        );
        inv.put('CompanyId__c', store.Id);
        insert inv;

        // -------- VISIT (CompanyId__c via dynamic put) --------
        Visit__c visit = new Visit__c(
            OwnerId = exec.Id,
            Date__c = Date.today()
        );
        visit.put('CompanyId__c', store.Id);
        insert visit;
    }

    @IsTest
    static void testCalculate() {

        Test.startTest();
        TargetHandlerController.calculate();
        Test.stopTest();

        System.assert([SELECT COUNT() FROM Target__c] > 0);
    }

    @IsTest
    static void testQueryTargets() {

        Id periodId = [SELECT Id FROM Period__c LIMIT 1].Id;
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id;
        Id managerId = [SELECT Id FROM User WHERE ManagerId = null LIMIT 1].Id;

        Test.startTest();
        TargetHandlerController.targetMetricsWrapper result =
            TargetHandlerController.queryTargets(periodId, profileId, managerId);
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assert(result.targetsWrapper.size() > 0);
        System.assert(result.targetMetrics.size() > 0);
    }
}