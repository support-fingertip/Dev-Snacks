@IsTest
public class DeleteRecordsWithinDateRange_Test {

    @testSetup
    static void setupData() {

        // Create test records
        List<Account> accList = new List<Account>();

        for (Integer i = 0; i < 5; i++) {
            accList.add(new Account(
                Name = 'Delete Test ' + i,
                CompanyId__c = 'Dev' 
            ));
        }
        insert accList;
 // Set CreatedDate within range
        DateTime dt = DateTime.now().addDays(-2);
        for (Account acc : accList) {
            Test.setCreatedDate(acc.Id, dt);
        }
    }
    @IsTest
static void testDeleteRecordsBatch() {

    Date startDate = Date.today().addDays(-5);
    Date endDate   = Date.today();

    Integer count = 5;

    Test.startTest();

    DeleteRecordsWithinDateRange batch =
        new DeleteRecordsWithinDateRange(
            startDate,
            endDate,
            'Account',
            count
        );


    Database.executeBatch(batch, 200);

    Test.stopTest();

   
    Integer remaining =
        [SELECT COUNT() FROM Account WHERE Name LIKE 'Delete Test%'];

    System.assertEquals(
        0,
        remaining,
        'All test accounts should be deleted'
    );
}
}