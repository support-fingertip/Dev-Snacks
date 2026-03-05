@isTest
public class GenrateLeadgerStatementControllerTest {

    public static testmethod void testLedger(){
         Account testAccount1 = new Account(
            Name = 'Test Account 1',
            Approval_Status__c = 'Approved',
            CompanyId__c = 'Dev'
        );
        insert testAccount1;
        
        GenrateLeadgerStatementController.GetCustomLedger(testAccount1.Id, system.today(),system.today());
        
    }
}