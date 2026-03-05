@isTest
public class DeleteRecords_Test {
	@isTest
    Public static void Test()
    {
       Log__c lg= new Log__c();
        insert lg;
          Log__c lg1= new Log__c();
        insert lg1;
        DeleteRecords.callDeleteBatch(system.today()-2, system.today()+1, 'Log__c');
          DeleteRecords.getRecords(system.today()-2, system.today()+1, 'Log__c');
         DeleteRecords.dataCount(system.today()-2, system.today()+1, 'Log__c');
        DeleteRecords.testcover();
    }
}